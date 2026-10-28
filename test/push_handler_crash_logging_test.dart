// Borgt vast dat de push-verwerking een fout nooit doorslaat naar de
// generieke fallbackmelding.
//
// HET PROBLEEM. De melding "💬 Nieuw bericht in Plusly / Open de app om
// de berichten te lezen" is GEEN echte melding: die wordt alleen getoond
// uit de catch van de push-verwerker. De gebruiker kreeg hem bij elke
// binnenkomend bericht — de echte melding (met kamernaam en tekst) bleef
// uit, en er kwamen twee van zulke generieke meldingen plus een
// opstartfout in de notificatiestapel.
//
// Twee dingen moeten daarom gebeuren:
// 1. de fout komt in de push-diagnose terecht, zodat er een spoor is;
// 2. één mislukte stap (het berekenen van de berichttekst) mag de hele
//    melding niet klappen.

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
  group('push-verwerking', () {
    final code = _code('lib/utils/push_helper.dart');

    test('een crash komt in de push-diagnose terecht', () {
      expect(
        code.contains("PushEventLog().add('push_handler_crash'"),
        isTrue,
        reason: 'zonder spoor in de push-diagnose is er geen manier om de '
            'oorzaak te vinden; de gebruiker ziet alleen de generieke '
            'fallbackmelding',
      );
    });

    test('het berekenen van de body mag de melding niet klappen', () {
      // Zonder deze vangst eindigt één mislukte body-berekening in de
      // catch, en dan verschijnt de generieke "Nieuw bericht in Plusly"-
      // melding in plaats van de echte.
      expect(
        code.contains("PushEventLog().add('push_body_failed'"),
        isTrue,
        reason: 'het mislukken van de body-berekening wordt vastgelegd',
      );
      expect(
        code.contains('body = l10n!.newMessageInFluffyChat;'),
        isTrue,
        reason: 'bij een mislukte body nemen we de generieke tekst, maar de '
            'melding zelf (met kamernaam) blijft bestaan',
      );
    });

    test('de generieke fallback blijft bestaan als laatste vangnet', () {
      // Het mag niet verdwijnen: als de hele verwerking faalt moet de
      // gebruiker íets zien.
      expect(
        code.contains('title: l10n.newMessageInFluffyChat'),
        isTrue,
        reason: 'de vangnetmelding blijft bestaan',
      );
      expect(
        code.contains('body: l10n.openAppToReadMessages'),
        isTrue,
        reason: 'de vangnetmelding blijft bestaan',
      );
    });
  });
}
