// Regressietests voor de push-diagnoselog.
//
// Aanleiding: één gedeelde buffer van 80 events werd gedomineerd door
// lifecycle-regels (~58 per logdump tegenover 1 push). Daardoor rolden
// push-events er binnen ongeveer anderhalve minuut app-gebruik uit, precies
// de informatie die nodig is om te zien of een afgeleverde push ook getoond
// werd. Deze tests borgen dat dat niet terugkomt.

import 'package:Pulsly/utils/push_event_log.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
