// Regressietest: de foreground-service moet het HELE verwerkingsvenster
// beschermen, niet pas het laatste stukje.
//
// Achtergrond (bewezen defect): Plusly startte
// ForegroundServices.startService('background_push') pas NA
// ClientManager.getClients(). FluffyChat upstream doet dat ervóór
// (main.dart:86 vs :88). Een headless push-proces dat tijdens de
// Hive/client-initialisatie niets doet, wordt door Android gekild nog vóór de
// service bescherming biedt -> ntfy levert af, de app verwerkt niets.
//
// Deze test leest de bron en toetst de ORDE, want gedrag is hier niet
// aanroepbaar zonder een echt Android-proces.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('main.dart: volgorde van de foreground-service', () {
    late String bron;

    setUpAll(() {
      bron = File('lib/main.dart').readAsStringSync();
    });

    test('startService komt VÓÓR ClientManager.getClients', () {
      // Zoek per regel en sla commentaar over: anders matcht indexOf de
      // tekst in het commentaarblok hierboven en meet je de verkeerde positie.
      int regelVan(String codeFragment) {
        final regels = bron.split('\n');
        for (var i = 0; i < regels.length; i++) {
          final r = regels[i].trimLeft();
          if (r.startsWith('//')) continue; // commentaar telt niet
          if (r.contains(codeFragment)) return i;
        }
        return -1;
      }

      final startIdx = regelVan("ForegroundServices.startService('background_push')");
      final clientsIdx = regelVan('ClientManager.getClients');

      expect(startIdx, greaterThan(-1),
          reason: 'de foreground-service moet überhaupt gestart worden');
      expect(clientsIdx, greaterThan(-1),
          reason: 'ClientManager.getClients hoort in main.dart te staan');
      expect(
        startIdx,
        lessThan(clientsIdx),
        reason: 'de service moet het hele verwerkingsvenster beschermen; '
            'upstream start hem vóór getClients (main.dart:86 vs :88)',
      );
    });

    test('de detached-check staat vóór de service-start', () {
      int regelVan(String codeFragment) {
        final regels = bron.split('\n');
        for (var i = 0; i < regels.length; i++) {
          final r = regels[i].trimLeft();
          if (r.startsWith('//')) continue;
          if (r.contains(codeFragment)) return i;
        }
        return -1;
      }

      final detachedIdx = regelVan('isBackgroundFetch =');
      final startIdx = regelVan("ForegroundServices.startService('background_push')");
      expect(detachedIdx, greaterThan(-1));
      expect(detachedIdx, lessThan(startIdx),
          reason: 'de service mag alleen in background-fetch mode starten');
    });

    test('de service wordt weer gestopt in push_helper', () {
      final helper = File('lib/utils/push_helper.dart').readAsStringSync();
      expect(
        helper.contains("ForegroundServices.stopService('background_push')"),
        isTrue,
        reason: 'zonder stop blijft de service (en de melding) eeuwig staan',
      );
    });
  });
}
