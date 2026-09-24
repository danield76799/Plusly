// Borgt de migratie van de UnifiedPush registered-flag.
//
// Aanleiding: de statusdump van 24 september toonde
// `Client=Plusly-... endpoint=saved registered=false` terwijl er dezelfde
// nacht en ochtend push aankwam. De flag bleek puur diagnostisch (nergens
// een guard, alleen logging), maar de waarde loog.
//
// Oorzaak: `AppSettings.unifiedPushRegistered.value` geeft de DEFAULT (false)
// terug als de globale sleutel ontbreekt. Het migratieblok in setupPush
// schreef die default onvoorwaardelijk naar de per-client sleutel en
// verwijderde daarna de globale sleutel — en setupPush loopt bij elke
// login-state-overgang. `true` wordt alleen door _newUpEndpoint gezet, dus
// elke volgende aanroep overschreef de vlag met false.
//
// Deze tests zijn STRUCTUREEL: ze lezen de bron. Een gedragstest kan dit niet
// zien, want het vergt een echte store met een ontbrekende sleutel.

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

String _code(String pad) {
  final c = File(pad).readAsStringSync();
  return c
      .replaceAll(RegExp(r'/\*[\s\S]*?\*/'), '')
      .split('\n')
      .map((r) => r.replaceAll(RegExp(r'//.*$', multiLine: true), ''))
      .join('\n');
}

void main() {
  final bron = _code('lib/utils/background_push.dart');

  // Het migratieblok. LET OP: _code() stript commentaar, dus anker op CODE,
  // niet op de toelichtende regel — anders is het anker zelf verdwenen.
  final blok = () {
    final start = bron.indexOf('final registered = matrix!.store.getBool(');
    expect(start, greaterThan(-1), reason: 'migratieblok niet gevonden');
    return bron.substring(
      (start - 2200).clamp(0, bron.length),
      (start + 700).clamp(0, bron.length),
    );
  };

  group('UnifiedPush registered-migratie', () {
    test('schrijft de flag NIET onvoorwaardelijk uit .value', () {
      // Dit is de bug: .value valt terug op de default (false) als de sleutel
      // ontbreekt, dus de migratie introduceert een false die er nooit stond.
      expect(
        blok().contains('unifiedPushRegistered.value'),
        isFalse,
        reason: 'AppSettings.value geeft de default terug bij een ontbrekende '
            'sleutel, waardoor afwezig als false gemigreerd wordt',
      );
    });

    test('leest de ruwe store-waarde zodat AFWEZIG van false te scheiden is', () {
      expect(
        blok().contains('store.getBool(') && blok().contains(
          'AppSettings.unifiedPushRegistered.key',
        ),
        isTrue,
        reason: 'getBool geeft null bij een ontbrekende sleutel — dat is het '
            'enige signaal dat de vlag nog niet bestaat',
      );
    });

    test('migreert alleen als de sleutel bestaat, en ruimt dan pas op', () {
      expect(
        blok().contains('if (registered != null)'),
        isTrue,
        reason: 'zonder deze guard wordt de afwezigheid zelf gemigreerd',
      );
      // De remove moet BINNEN de guard staan, anders is de bron toch weg.
      // LET OP: anker op de registered-sleutel — de endpoint-migratie heeft
      // ook een store.remove(), en die staat EERDER in het blok.
      final guard = blok().indexOf('if (registered != null)');
      final remove = blok().indexOf(
        'store.remove(AppSettings.unifiedPushRegistered.key)',
      );
      expect(guard, greaterThan(-1), reason: 'guard niet gevonden');
      expect(remove, greaterThan(-1), reason: 'registered-remove niet gevonden');
      expect(
        remove,
        greaterThan(guard),
        reason: 'de globale sleutel mag pas weg als hij gelezen is',
      );
    });

    test('de endpoint-migratie blijft intact', () {
      // Niet de fix stukmaken: het endpoint heeft geen default, dus daar is
      // de bestaande isNotEmpty-check al voldoende.
      expect(blok().contains('unifiedPushEndpoint'), isTrue);
      expect(blok().contains('endpoint.isNotEmpty'), isTrue);
    });
  });
}
