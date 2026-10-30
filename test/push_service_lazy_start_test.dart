// Regressietest: de "Meldingen ophalen"-melding moet zo min mogelijk
// verschijnen.
//
// De foreground-service beschermt het proces tegen een kill door Android
// tijdens de initialisatie, maar toont bij elke push een melding. Op een
// normale koude start duurt de initialisatie (Hive + client) maar een
// paar seconden en is de service niet nodig. Daarom start de service pas
// als de init aantoonbaar lang duurt.

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('koude start zonder onnodige service-melding', () {
    final code = File('lib/main.dart').readAsStringSync();

    test('de service start pas als de init lang duurt', () {
      expect(
        code.contains("Timer(const Duration(seconds: 5)"),
        isTrue,
        reason: 'de service moet vertraagd starten: eerst kijken of de '
            'initialisatie op tijd is',
      );
      expect(
        code.contains('if (initKlaar) return;'),
        isTrue,
        reason: 'is de init al klaar, dan is de service niet nodig',
      );
    });

    test('de client-initialisatie hoeft niet meer te wachten op de service', () {
      // De oude volgorde was: startService → getClients. Nu is het:
      // getClients (as future) → service pas bij een trage init.
      final serviceIndex = code.indexOf(
        'ForegroundServices.startService(\n        ForegroundServices.backgroundPushService',
      );
      final initIndex = code.indexOf('ClientManager.getClients(store: store)');
      expect(serviceIndex, greaterThan(-1), reason: 'de service wordt nog '
          'gestart, maar alleen bij een trage initialisatie');
      expect(initIndex, greaterThan(-1));
      expect(
        initIndex,
        lessThan(serviceIndex),
        reason: 'de initialisatie begint vóórdat er een service start',
      );
    });

    test('de duur van de init wordt vastgelegd', () {
      expect(
        code.contains("PushEventLog().add('init_done'"),
        isTrue,
        reason: 'zonder deze meting is niet te zien of de service echt nodig '
            'was op dit apparaat',
      );
    });
  });
}
