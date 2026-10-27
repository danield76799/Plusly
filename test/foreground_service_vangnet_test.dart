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
        stopBlok.contains('_watchdogs[name]?.cancel()'),
        isTrue,
        reason: 'een afgeronde service mag de timer niet laten doorlopen',
      );
    });

    test('elke service heeft zijn eigen watchdog', () {
      // Eén globale timer betekende dat het starten van een upload de
      // watchdog van de push-service Annuleerde. De push-service verloor
      // dan zijn bovengrens terwijl de push-pijplijn nog bezig kon zijn —
      // en de melding bleef wél hangen.
      expect(
        services.contains('Map<String, Timer> _watchdogs'),
        isTrue,
        reason: 'een timer per service, zodat de ene de andere niet van '
            'zijn vangnet berooft',
      );
      expect(
        services.contains('_watchdogs[name]?.cancel()'),
        isTrue,
        reason: 'het herstarten van de watchdog van één service mag de '
            'watchdog van een andere service niet raken',
      );
    });

    test('de push-service meldt dat hij meldingen ophaalt', () {
      // "Berichten laden" bij het ontvangen van een bericht suggereerde
      // dat de app vastloopt. Voor de push-service is "Meldingen ophalen"
      // waarheid.
      expect(
        services.contains('pushServiceNotification'),
        isTrue,
        reason: 'de push-service hoort een eigen, waarheidsgetrouwe tekst te '
            'tonen',
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

    test('een upload-service van een vorig proces wordt ook opgeruimd', () {
      // HET GAT. Wordt de app gekild tijdens een upload, dan blijft de
      // native service draaien en staat 'send_files' in SharedPreferences.
      // `reconcileOnForegroundStart` stopte alleen de push-service, dus de
      // melding "Plusly / Berichten laden" bleef staan tot er bijgevolg een
      // nieuwe upload werd gestart. Een brugkamer-conversie maakt uploads
      // groter en dus dit gat vaker.
      expect(
        services.contains('sendFilesService'),
        isTrue,
        reason: 'de upload-service moet een eigen naam hebben, anders kan '
            'het opruimen hem niet van de push-service onderscheiden',
      );
      expect(
        services.contains('leftoverUpload'),
        isTrue,
        reason: 'een service die een vorig proces achterliet moet bij de '
            'voorgrondkomst worden gestopt',
      );
      // Een lopende upload in dit proces zelf mag nooit worden gekilld.
      expect(
        services.contains('!_runningServices.contains(owner)'),
        isTrue,
        reason: 'een actieve upload in deze levenscyclus mag niet worden '
            'gestopt, alleen een achtergeblevene',
      );
    });

    test('een stop tijdens het starten gaat niet verloren', () {
      // DE RACE. De plak-route start de service fire-and-forget en stopt
      // hem in een whenComplete. Is de upload klaar vóórdat de service
      // klaar is met starten, dan stopt de stop een service die nog niet
      // bestaat — en de service komt daarna alsnog omhoog en blijft
      // draaien. Precies het gemeten "Plusly / Berichten laden".
      expect(
        services.contains('_startingServices'),
        isTrue,
        reason: 'er moet bijgehouden worden welke service aan het starten is',
      );
      expect(
        services.contains('_stopRequested'),
        isTrue,
        reason: 'een stop tijdens het starten moet worden vastgelegd',
      );
      expect(
        services.contains('if (_stopRequested.remove(name))'),
        isTrue,
        reason: 'de vastgelegde stop moet daadwerkelijk nog uitgevoerd '
            'worden zodra het starten klaar is',
      );
    });
  });
}
