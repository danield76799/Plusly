// Borgt vast dat een push-burst niet blijft piepen of hangen.
//
// HET PROBLEEM. Bij een push-burst (twintig pushes binnen twee seconden)
// wordt dezelfde melding steeds opnieuw geplaatst. Zonder `onlyAlertOnce`
// geeft elke herplaatsing opnieuw een heads-up: de kaart komt steeds
// terug, blijft hangen en blijft piepen. De gebruiker meldde precies dat
// ("notificatie blijft op de voorgrond").

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
  group('heads-up bij een push-burst', () {
    final code = _code('lib/utils/push_helper.dart');

    test('de berichtmelding geeft maar één keer een heads-up', () {
      expect(
        code.contains('onlyAlertOnce: true'),
        isTrue,
        reason: 'zonder onlyAlertOnce geeft elke herplaatsing van dezelfde '
            'melding opnieuw een heads-up; de kaart blijft dan hangen',
      );
    });

    test('het aantal onlyAlertOnce-declaraties dekt de meldingen', () {
      // Zowel de echte berichtmelding als de generieke vangnetmelding
      // moeten het aandoen.
      final aantal = 'onlyAlertOnce: true'.allMatches(code).length;
      expect(
        aantal,
        greaterThanOrEqualTo(2),
        reason: 'zowel de berichtmelding als de vangnetmelding moeten '
            'onlyAlertOnce zetten',
      );
    });
  });
}
