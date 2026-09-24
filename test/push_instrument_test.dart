// Borgt het MEETINSTRUMENT, niet de push-logica.
//
// Aanleiding: de dump van 24 september bevatte 84 events terwijl de cap 80 is,
// en er stond geen enkele koude start in. Daarmee was niet vast te stellen of
// de room-push van 07:28:43 getoond, onderdrukt of gemist was. Bij het
// uitzoeken bleek het rijkere instrument (aparte ringen, isolate-tag, merge,
// reload) bij een eerdere rollback te zijn weggevallen en nooit hersteld — in
// geen van beide FC-pariteitsrondes.
//
// Deze tests zijn STRUCTUREEL: ze lezen de bron, want een gedragstest kan dit
// niet zien (het instrument schrijft naar SharedPreferences en dat vraagt een
// echte opslaglaag). Ze borgen de eigenschappen waarvan de diagnose afhangt.

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

String _code(String pad) {
  final c = File(pad).readAsStringSync();
  final zonderBlok = c.replaceAll(RegExp(r'/\*[\s\S]*?\*/'), '');
  return zonderBlok
      .split('\n')
      .map((r) => r.replaceAll(RegExp(r'//.*$', multiLine: true), ''))
      .join('\n');
}

void main() {
  final logBron = _code('lib/utils/push_event_log.dart');

  group('Push-meetinstrument', () {
    test('push- en lifecycle-events hebben elk hun EIGEN ring', () {
      // Eén gedeelde buffer van 80 loopt vol met lifecycle-regels (elke
      // app-wissel schrijft er ~4), waarna de pushes eruit rollen — precies
      // de informatie die je nodig hebt. Gemeten: 84 events in een dump bij
      // cap 80, waarvan 62 lifecycle.
      expect(
        logBron.contains('maxPushEvents'),
        isTrue,
        reason: 'zonder aparte push-ring verdringen lifecycle-events de pushes',
      );
      expect(
        logBron.contains('maxLifecycleEvents'),
        isTrue,
        reason: 'lifecycle moet een EIGEN, kleine ring hebben — niet weggegooid, '
            'want het is het enige bewijs dat de headless engine wakker werd',
      );
      expect(logBron.contains('_lifecycleEvents'), isTrue);
      expect(logBron.contains('_pushEvents'), isTrue);
    });

    test('de push-cap is groot genoeg voor een werkdag', () {
      final m = RegExp(r'maxPushEvents\s*=\s*(\d+)').firstMatch(logBron);
      expect(m, isNotNull, reason: 'cap niet gevonden');
      final cap = int.parse(m!.group(1)!);
      expect(
        cap,
        greaterThanOrEqualTo(200),
        reason: 'bij cap $cap rolt een drukke dag aan pushes eruit voordat je '
            'de dump leest',
      );
    });

    test('elke regel draagt de ISOLATE-tag', () {
      // De UnifiedPush-plugin start zijn eigen FlutterEngine zodra er nog geen
      // engine aan de plugin hangt: dat is juist de koude-start-situatie. Twee
      // schrijvers op één prefs-sleutel zijn onzichtbaar zonder tag.
      expect(
        logBron.contains('_isolateTag'),
        isTrue,
        reason: 'zonder tag is een tweede schrijver niet te zien in een dump',
      );
      expect(
        logBron.contains('Isolate.current'),
        isTrue,
        reason: 'de tag moet uit de echte isolate komen, niet hardcoded',
      );
      expect(
        logBron.contains("'iso': _isolateTag"),
        isTrue,
        reason: 'de tag moet op elke regel gezet worden',
      );
    });

    test('persisten MERGED in plaats van te overschrijven', () {
      expect(
        logBron.contains('await prefs.reload()'),
        isTrue,
        reason: 'SharedPreferences.getInstance() geeft een PER-ISOLATE cache; '
            'zonder reload lees je een stale kopie en schrijf je die terug, '
            'waarmee je de regels van het andere isolate alsnog wist',
      );
      expect(
        logBron.contains('bestaand'),
        isTrue,
        reason: 'de bestaande regels moeten gelezen en samengevoegd worden',
      );
      expect(
        logBron.contains('voegToe'),
        isTrue,
        reason: 'samenvoegen met dedupe op de encoded vorm',
      );
      // De oude, kapotte vorm: de eigen lijst blind wegschrijven.
      expect(
        RegExp(r'setStringList\(\s*_key,\s*_events').hasMatch(logBron),
        isFalse,
        reason: 'dat is de overschrijf-variant die andermans regels wist',
      );
    });

    test('oude logregels blijven leesbaar na de formaatwijziging', () {
      // Er staan legacy-regels op toestellen van voor deze wijziging. Wie ze
      // niet kan lezen, toont na een update een lege geschiedenis.
      expect(
        logBron.contains('isNewFormat'),
        isTrue,
        reason: 'discrimineer op veldaantal, niet op inhoud gokken',
      );
      expect(
        logBron.contains("parts[0] == 'p'") || logBron.contains("'l'"),
        isTrue,
        reason: 'het nieuwe formaat draagt de ring als eerste veld',
      );
    });

    test('opeenvolgende identieke lifecycle-toestanden worden niet herhaald', () {
      expect(
        logBron.contains('if (vorige == extra[\'state\']) return;'),
        isTrue,
        reason: 'elke koude start schrijft inactive/hidden/paused/detached; '
            'zonder deze filter is de lifecycle-ring pure herhaling',
      );
    });

    test('de debug-dump toont een samenvatting en de cap', () {
      final scherm = _code('lib/pages/settings/push_debug_screen.dart');
      expect(
        scherm.contains('[samenvatting]'),
        isTrue,
        reason: 'zonder samenvattingsregel moet je elke dump met de hand '
            'tellen om te zien of de buffer vol zat',
      );
      expect(
        scherm.contains('met room='),
        isTrue,
        reason: 'de verhouding getoond/room-pushes is de enige bruikbare ratio; '
            'teller-pushes kunnen per definitie geen notificatie tonen',
      );
      expect(
        scherm.contains('koude starts='),
        isTrue,
        reason: 'een koude start in het venster is wat de cold-start-tak test',
      );
    });
  });
}
