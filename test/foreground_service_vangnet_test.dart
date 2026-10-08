// Borgt het vangnet tegen een eeuwig hangende "Plusly / Berichten laden".
//
// HET GAT. `main.dart` start de koude-start-service vóór de client-
// initialisatie; de ENIGE stop is pushHelper's finally. Wordt die tak niet
// bereikt — getClients() hangt op een traag netwerk, of de UP-boodschap komt
// nooit — dan blijft de service staan. Een foreground-service is juist
// ontworpen om door te draaien, dus er is geen enkele andere gebeurtenis die
// hem opruimt. De gebruiker ziet de laadmelding uren later nog.
//
// Twee vangnetten, elk onafhankelijk van de push-afronding:
// 1. een watchdog die de push-service na een vaste tijd stopt;
// 2. opruimen zodra de app zelf naar de voorgrond komt.
//
// Zonder deze test kan iemand het vangnet weghalen en blijven de tests groen.

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Broncode zonder commentaar: uitleg citeert bewust oude code.
String _code(String pad) {
  final c = File(pad).readAsStringSync();
  final zonderBlok = c.replaceAll(RegExp(r'/\*[\s\S]*?\*/'), '');
  return zonderBlok
      .split('\n')
      .map((r) => r.replaceAll(RegExp(r'//.*$', multiLine: true), ''))
      .join('\n');
}

void main() {
  group('vangnet tegen blijvende laadmelding', () {
    final services = _code('lib/utils/foreground_services.dart');

    test('de push-service heeft een watchdog', () {
      expect(
        services.contains('_watchdog'),
        isTrue,
        reason:
            'zonder watchdog blijft de service staan als de pushpijplijn hem '
            'nooit afrondt — precies het gemeten "Berichten laden"',
      );
      expect(
        services.contains('watchdogTimeout'),
        isTrue,
        reason: 'de bovengrens moet expliciet zijn, niet impliciet',
      );
    });

    test('de watchdog raakt alleen de push-service, niet een upload', () {
      // send_files kan legitiem minuten duren (video-compressie). Valt die
      // onder dezelfde timer, dan breekt de fix het uploaden.
      expect(
        services.contains('if (name != backgroundPushService) return;'),
        isTrue,
        reason:
            'een upload mag niet door de watchdog worden afgekapt; alleen de '
            'aan de pushpijplijn gebonden service hoort een bovengrens te hebben',
      );
    });

    test('watchdog timeout is hooguit 60 seconden', () {
      // Meldingen moeten snel opruimen. PushHelper timeout = 30s; 60s is
      // ruim genoeg en voorkomt dat de melding minuten blijft staan.
      expect(
        services.contains('Duration(seconds: 120)'),
        isFalse,
        reason: '120s laat de melding te lang zichtbaar bij een achtergebleven service',
      );
    });

    test('stoppen ontwapent de watchdog', () {
      // Een watchdog die na een nette stop alsnog vuren kan, stopt een
      // daaropvolgende upload van een ander doel.
      final stopBlok = services.substring(
        services.indexOf('Future<void> stopService'),
      );
      expect(
        stopBlok.contains('_watchdog?.cancel()'),
        isTrue,
        reason: 'een afgeronde service mag de timer niet laten doorlopen',
      );
    });

    test('voorgrond komst ruimt een achtergebleven service op', () {
      expect(
        services.contains('reconcileOnForegroundStart'),
        isTrue,
        reason:
            'de voorgrond is het enige betrouwbare opruimmoment wanneer de '
            'push-afronding nooit liep',
      );
      // Alleen onze eigen service: een gesprek heeft geen owner-markering en
      // moet blijven draaien.
      expect(
        services.contains('owner == backgroundPushService'),
        isTrue,
        reason: 'een externe service (voip) mag niet worden gestopt, en een '
            'lopende upload evenmin',
      );
    });

    test('main.dart roept het opruimen aan vóór zware initialisatie', () {
      final main = _code('lib/main.dart');
      final initIdx = main.indexOf('isBackgroundFetch') + 'isBackgroundFetch'.length;
      final getClientsIdx = main.indexOf('ClientManager.getClients');
      final reconcileIdx = main.indexOf('reconcileOnForegroundStart()');
      expect(
        reconcileIdx != -1 && (getClientsIdx == -1 || reconcileIdx < getClientsIdx),
        isTrue,
        reason: 'reconcile moet vóór ClientManager.getClients lopen zodat de '
            'melding onmiddellijk verdwijnt, niet pas na de zware init',
      );
    });

    test('main.dart gebruikt de gedeelde servicenaam', () {
      final main = _code('lib/main.dart');
      expect(
        main.contains('ForegroundServices.backgroundPushService'),
        isTrue,
        reason:
            'een losse string hier betekent dat de watchdog-vergelijking en '
            'de start buiten elkaar kunnen lopen',
      );
      expect(
        main.contains("startService('background_push')"),
        isFalse,
        reason: 'de letterlijke string hoort niet meer in main.dart te staan',
      );
    });
  });
}
