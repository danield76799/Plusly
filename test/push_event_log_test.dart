// Regressietests voor de push-diagnoselog.
//
// Aanleiding: één gedeelde buffer van 80 events werd gedomineerd door
// lifecycle-regels (~58 per logdump tegenover 1 push). Daardoor rolden
// push-events er binnen ongeveer anderhalve minuut app-gebruik uit, precies
// de informatie die nodig is om te zien of een afgeleverde push ook getoond
// werd. Deze tests borgen dat dat niet terugkomt.
//
// Tweede aanleiding: de UnifiedPush-plugin start zijn eigen FlutterEngine,
// dus er kan een tweede isolate op dezelfde prefs-sleutel schrijven. Toen
// _persist() de eigen in-memory lijst wegschreef in plaats van samen te
// voegen, wiste het ene isolate de regels van het andere — en toonde de
// diagnosepagina een push-gat dat niet bestond. Zie 'twee schrijvers'.

import 'package:Pulsly/utils/push_event_log.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _key = 'plusly_push_event_log';

/// Wacht tot de fire-and-forget _persist() van [add] is weggeschreven.
Future<void> _flush() => Future<void>.delayed(Duration.zero);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await PushEventLog().clear();
  });

  group('PushEventLog bufferscheiding', () {
    test('heel veel lifecycle-events verdringen geen push-events', () async {
      final log = PushEventLog();

      // Eén push, volledig traject.
      log.add('push_received', {'room': '!abc:server'});
      log.add('push_event', {'type': 'm.room.message'});
      log.add('push_shown', {'room': '!abc:server', 'id': '1'});
      log.add('push', {'room': '!abc:server'});

      // Daarna 200 lifecycle-events — ruim boven de lifecycle-cap.
      for (var i = 0; i < 200; i++) {
        log.add('lifecycle', {'state': 'paused'});
      }

      final pushes = log.pushEvents;
      expect(
        pushes.length,
        4,
        reason: 'de push-events moeten de lifecycle-golf overleven',
      );
      expect(pushes.where((e) => e['kind'] == 'push_received').length, 1);
      expect(pushes.where((e) => e['kind'] == 'push_shown').length, 1);
    });

    test('lifecycle-buffer blijft begrensd', () async {
      final log = PushEventLog();
      // Afwisselende toestanden: gelijke opeenvolgende toestanden worden
      // samengevat, dus alleen echte overgangen tellen mee.
      for (var i = 0; i < PushEventLog.maxLifecycleEvents + 50; i++) {
        log.add('lifecycle', {'state': i.isEven ? 'paused' : 'resumed'});
      }
      final lifecycle =
          log.events.where((e) => e['kind'] == 'lifecycle').length;
      expect(lifecycle, PushEventLog.maxLifecycleEvents);
    });

    test('push-buffer houdt honderden pushes vast', () async {
      final log = PushEventLog();
      for (var i = 0; i < 300; i++) {
        log.add('push_received', {'room': '!r$i:server'});
      }
      expect(log.pushEvents.length, 300);
      expect(PushEventLog.maxPushEvents, greaterThanOrEqualTo(300));
    });

    test('events zijn chronologisch over beide ringen heen', () async {
      final log = PushEventLog();
      log.add('lifecycle', {'state': 'paused'});
      log.add('push_received', {'room': '!a:server'});
      log.add('lifecycle', {'state': 'resumed'});

      final events = log.events;
      final timestamps = events.map((e) => e['ts'] ?? '').toList();
      final sorted = [...timestamps]..sort();
      expect(timestamps, sorted, reason: 'lifecycle moet tussen de pushes staan');
    });

    test('opeenvolgende identieke lifecycle-toestanden worden samengevat',
        () async {
      final log = PushEventLog();
      // Een echte dump had 'resumed, inactive, resumed, paused, detached'
      // door elkaar; alleen ECHTE overgangen zijn nuttige context.
      log.add('lifecycle', {'state': 'paused'});
      log.add('lifecycle', {'state': 'paused'});
      log.add('lifecycle', {'state': 'paused'});
      log.add('lifecycle', {'state': 'resumed'});
      log.add('lifecycle', {'state': 'resumed'});
      log.add('lifecycle', {'state': 'paused'});

      final staten = log.events
          .where((e) => e['kind'] == 'lifecycle')
          .map((e) => e['state'])
          .toList();
      expect(staten, ['paused', 'resumed', 'paused'],
          reason: 'alleen echte overgangen, geen herhalingen');
    });

    test('elke regel draagt een isolate-tag', () async {
      final log = PushEventLog();
      log.add('push_received', {'room': '!iso:server'});
      expect(log.pushEvents.first['iso'], isNotNull,
          reason: 'zonder tag is niet te zien welke schrijver een regel zette');
    });
  });

  group('twee schrijvers op één prefs-sleutel', () {
    test('een eigen add() wist de regels van een andere schrijver niet',
        () async {
      // Simuleer het tweede isolate: het schrijft zijn regel rechtstreeks
      // naar prefs, zoals de UnifiedPush-engine dat doet.
      const vanAndereSchrijver =
          'p|2026-09-22T19:25:17.000000|push_received|room=!ander:server&iso=up-engine';
      SharedPreferences.setMockInitialValues({
        _key: <String>[vanAndereSchrijver],
      });

      PushEventLog().add('push_received', {'room': '!eigen:server'});
      await _flush();

      final bewaard =
          (await SharedPreferences.getInstance()).getStringList(_key) ??
              const <String>[];

      expect(
        bewaard.contains(vanAndereSchrijver),
        isTrue,
        reason: 'de regel van het andere isolate mag NIET verdwijnen',
      );
      expect(bewaard.length, 2, reason: 'beide regels moeten bewaard blijven');
    });

    test('herhaald persisten levert geen duplicaten op', () async {
      final log = PushEventLog();
      log.add('push_received', {'room': '!dup:server'});
      await _flush();
      // Twee keer extra persisten van dezelfde inhoud.
      await log.ensureLoaded();
      log.add('lifecycle', {'state': 'paused'});
      await _flush();
      log.add('lifecycle', {'state': 'resumed'});
      await _flush();

      final bewaard =
          (await SharedPreferences.getInstance()).getStringList(_key) ??
              const <String>[];
      final ontvangen =
          bewaard.where((e) => e.contains('push_received')).length;
      expect(ontvangen, 1, reason: 'de push-regel mag niet verdubbelen');
    });

    test('de gezamenlijke buffer blijft begrensd op maxPushEvents', () async {
      // 600 regels van een andere schrijver + eigen regel: de ring moet
      // terugvallen op de nieuwste maxPushEvents, niet onbeperkt groeien.
      SharedPreferences.setMockInitialValues({
        _key: <String>[
          for (var i = 0; i < 600; i++)
            'p|2026-09-22T10:00:${(i % 60).toString().padLeft(2, '0')}.'
                '000000|push_received|room=!r$i:server',
        ],
      });
      final log = PushEventLog();
      await log.ensureLoaded();
      log.add('push_received', {'room': '!nieuw:server'});
      await _flush();

      final bewaard =
          (await SharedPreferences.getInstance()).getStringList(_key) ??
              const <String>[];
      expect(bewaard.length, PushEventLog.maxPushEvents);
    });
  });

  group('PushEventLog persistentie', () {
    test('rondje door SharedPreferences behoudt beide ringen', () async {
      final log = PushEventLog();
      log.add('push_received', {'room': '!persist:server'});
      log.add('push_shown', {'room': '!persist:server'});
      log.add('lifecycle', {'state': 'paused'});

      // Tweede "sessie": load() leest wat _persist() wegschreef.
      await log.load();

      expect(log.pushEvents.length, 2);
      expect(log.pushEvents.first['room'], '!persist:server');
      expect(
        log.events.where((e) => e['kind'] == 'lifecycle').length,
        1,
      );
    });

    test('ensureLoaded leest de geschiedenis voordat er iets geschreven wordt',
        () async {
      // Dit is het defect dat de vorige sessie onzichtbaar maakte: een verse
      // start met lege in-memory lijst schreef de bewaarde geschiedenis over.
      SharedPreferences.setMockInitialValues({
        _key: <String>[
          'p|2026-09-22T13:18:25.216005|push_received|room=!eerder:server',
        ],
      });
      final log = PushEventLog();
      await log.ensureLoaded();
      log.add('push_received', {'room': '!nu:server'});
      await _flush();

      final bewaard =
          (await SharedPreferences.getInstance()).getStringList(_key) ??
              const <String>[];
      expect(bewaard.any((e) => e.contains('!eerder:server')), isTrue,
          reason:
              'de vorige sessie mag niet gewist worden bij een nieuwe start');
      expect(bewaard.any((e) => e.contains('!nu:server')), isTrue);
    });

    test('leest het OUDE formaat zonder ring-prefix nog in', () async {
      // Oud formaat was '<ts>|<kind>|<key=value&...>' zonder ring-prefix.
      // Zonder vangnet zou de timestamp als ring gelezen worden en zou de
      // hele geschiedenis stilletjes verdwijnen.
      SharedPreferences.setMockInitialValues({
        'plusly_push_event_log': <String>[
          '2026-09-22T13:18:25.216005|push_received|room=!oud:server',
          '2026-09-22T13:18:25.300000|lifecycle|state=paused',
        ],
      });
      final log = PushEventLog();
      await log.load();

      expect(log.pushEvents.length, 1, reason: 'oude push-regel moet bewaard blijven');
      expect(log.pushEvents.first['kind'], 'push_received');
      expect(log.pushEvents.first['room'], '!oud:server');
      expect(log.pushEvents.first['ts'], '2026-09-22T13:18:25.216005');
      expect(log.events.where((e) => e['kind'] == 'lifecycle').length, 1);
    });
  });
}
