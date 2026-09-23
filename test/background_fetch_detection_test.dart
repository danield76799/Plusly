// Regressietest: de headless push-engine herkennen bij koud start.
//
// Achtergrond (bewezen defect, nacht 23-09): de UnifiedPush-connector
// start bij een koude push een eigen FlutterEngine zónder Activity.
// Flutter vult WidgetsBinding.instance.lifecycleState alleen bij een
// Activity (services/binding.dart: readInitialLifecycleStateFromNativeWindow()
// returnt zolang initialLifecycleState leeg is), dus in die headless
// engine is de state NULL — niet detached. De oude check
//   AppLifecycleState.detached == lifecycleState
// evalueerde daardoor false, en de HELE background-tak werd overgeslagen:
// geen foreground-service, geen UnifiedPush.initialize(). De distributor
// leverde wél af (ntfy-log: Sending MESSAGE), de app verwerkte niets.
// Bewijs: 5 kamer-pushes in de nacht van 23-09, 0 verwerkt; de ochtend-
// burst om 07:33:27 leverde 8 opgestapelde broadcasts in 0,25 s (replay-
// buffer van de connector, Plugin.kt replay=20) pas bij het openen.
//
// Gedrag is hier niet zonder echt Android-proces aanroepbaar, dus deze
// test leest de broncode en toetst de check zelf.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('main.dart: koude-start-herkenning van de push-engine', () {
    late String bron;

    setUpAll(() {
      bron = File('lib/main.dart').readAsStringSync();
    });

    // Zoek per regel en sla commentaar over: anders matcht indexOf de
    // uitleg in het commentaarblok boven de fix en meet je de verkeerde
    // positie / de verkeerde 'check'.
    List<int> regelsVan(String codeFragment) {
      final regels = bron.split('\n');
      final gevonden = <int>[];
      for (var i = 0; i < regels.length; i++) {
        final r = regels[i].trimLeft();
        if (r.startsWith('//')) continue; // commentaar telt niet
        if (r.contains(codeFragment)) gevonden.add(i);
      }
      return gevonden;
    }

    test('de background-check behandelt lifecycleState == null als push', () {
      // De check moet null expliciet afvangen: null == detached is false,
      // dus een gewone gelijkheidscheck laat de headless engine vallen.
      final nullIdx = regelsVan('lifecycleState == null');
      expect(nullIdx, isNotEmpty,
          reason: 'een koud gestarte push-engine rapporteert lifecycleState '
              'null (geen Activity), niet detached; zonder deze tak werd de '
              'hele background-afhandeling overgeslagen');
    });

    test('detached blijft óók een background-start', () {
      // Het verbreden mag de oorspronkelijke detached-herkenning niet
      // vervangen: de warme headless engine (Activity bestond al wel,
      // daarna detached) moet dezelfde tak nemen.
      final detachIdx = regelsVan('lifecycleState == AppLifecycleState.detached');
      expect(detachIdx, isNotEmpty,
          reason: 'detached is nog steeds een background-fetch start; '
              'de null-tak is een verbreding, geen vervanging');
    });

    test('isBackgroundFetch combineert null én detached met ||', () {
      // Beide signalen moeten elkaár aanvullen (||), niet beide vereist
      // zijn (&&): null sluit detached uit en omgekeerd.
      final combiIdx = bron.indexOf('lifecycleState == null ||');
      expect(combiIdx, greaterThan(-1),
          reason: 'null en detached zijn elkaars uitsluitende gevallen; '
              'de check moet ze OF-combineren');
    });

    test('elke start logt startup_state voor het bewijs in de dump', () {
      // Zonder deze regel is de volgende diagnose weer giswerk: dan
      // kunnen we nooit laten zien dát de headless engine null
      // rapporteerde (of juist niet).
      final initIdx = regelsVan("'init'");
      final stateIdx = regelsVan('startup_state');
      expect(initIdx, isNotEmpty,
          reason: "PushEventLog().add('init', …) moet bij elke start "
              'uitgevoerd worden');
      expect(stateIdx, isNotEmpty,
          reason: 'de logregel moet de effectieve lifecycleState bevatten '
              "(startup_state), anders bewijst een dump niets");
    });

    test('AppStarter-vingnet blijft bestaan voor Activity-starts', () {
      // Als een Activity-start ooit null rapporteert en onterecht de
      // background-tak neemt, redt AppStarter de GUI zodra de eerste
      // echte lifecycle-wijziging binnenkomt. Die garantie mag niet weg.
      final starterIdx = regelsVan('class AppStarter');
      expect(starterIdx, isNotEmpty,
          reason: 'AppStarter is het vangnet dat de GUI alsnog start bij '
              'een Activity-start die per ongeluk de background-tak nam');
    });
  });
}