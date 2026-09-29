// Copyright (C) 2025 Daan – Na-meting van de getoonde notificatie.
//
// HET GAT IN DE VORIGE METING.
//
// `push_active_check` meet direct na show() en gaf in alle dumps actief=ja.
// Dat bewijst dat Android de melding aanneemt, maar niet dat hij BLIJFT.
// De clearing-tak in dezelfde functie draait bij elke push zonder event en
// kan een net getoonde melding opruimen (unread==0 volstaat al). Dan ervaart
// de gebruiker "de melding is er even en dan weg", terwijl de log alleen
// 'getoond' laat zien.
//
// Deze test legt vast dat er een TWEEDE meting bestaat, ruim na de
// push-afhandeling, en dat de uitslag in het diagnosescherm zichtbaar is.
// Zonder die tweede meting is "Android toont hem niet" niet te scheiden van
// "wij hebben hem weggehaald" — precies het onderscheid dat al weken zoekt.

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  String code(String pad) {
    final c = File(pad).readAsStringSync();
    final zonderBlok = c.replaceAll(RegExp(r'/\*[\s\S]*?\*/'), '');
    return zonderBlok
        .split('\n')
        .map((r) {
          final idx = r.indexOf('//');
          return idx == -1 ? r : r.substring(0, idx);
        })
        .join('\n');
  }

  group('na-meting van de getoonde notificatie', () {
    test('push_helper meet opnieuw, vertraagd na show()', () {
      final helper = code('lib/utils/push_helper.dart');
      // De tweede meting moet bestaan en moet VERTRAAGD zijn: direct meten
      // levert hetzelfde beeld als de eerste check en voegt niets toe.
      expect(
        helper.contains('push_active_later'),
        isTrue,
        reason:
            'er moet een tweede meting zijn die vastlegt of de melding '
            'bleef staan; zonder die meting is "Android toont hem niet" niet '
            'te scheiden van "de app heeft hem opgeruimd"',
      );
      expect(
        helper.contains('Future<void>.delayed'),
        isTrue,
        reason:
            'de na-meting moet vertraagd zijn; direct na show() meten geeft '
            'hetzelfde antwoord als de bestaande check',
      );
    });

    test('de na-meting kijkt naar hetzelfde notificatie-id', () {
      final helper = code('lib/utils/push_helper.dart');
      final start = helper.indexOf('push_active_later');
      expect(start, isNonNegative);
      // Kijk in een ruim venster vóór de logregel naar het id dat gemeten
      // wordt. Zonder id-vergelijking meet je alleen het TOTAAL aantal
      // meldingen, en dat zegt niet of DEZE melding nog bestaat.
      final venster = helper.substring(
        start > 1200 ? start - 1200 : 0,
        start,
      );
      expect(
        venster.contains('n.id == notificationId'),
        isTrue,
        reason:
            'de na-meting moet op hetzelfde notificationId filteren; anders '
            'meet hij alleen het totale aantal actieve meldingen',
      );
    });

    test('het diagnosescherm toont de uitkomst van de na-meting', () {
      final scherm = code('lib/pages/settings/push_debug_screen.dart');
      expect(
        scherm.contains('push_active_later'),
        isTrue,
        reason:
            'de na-meting is alleen nuttig als de uitslag in de dump staat; '
            'anders moet je de ruwe eventlijst met de hand doorzoeken',
      );
      expect(
        scherm.contains('[na-meting]'),
        isTrue,
        reason:
            'een samenvattingsregel maakt in één oogopslag duidelijk of '
            'meldingen blijven staan of door de app zelf worden opgeruimd',
      );
    });
  });
}
