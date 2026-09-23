// Borgt het TWEEDE lid van "geplande berichten gaan direct de deur uit".
//
// Het lokale pad gebruikte `diff.inSeconds.abs() <= 60`. Die `.abs()` maakt
// het venster tweezijdig: een bericht dat 45 seconden in de TOEKOMST ligt
// (diff = -45) valt er ook in en werd dus direct verzonden. Met de 30s-timer
// en de check bij het opstarten kon elk bericht binnen een minuut vooruit te
// vroeg vertrekken.
//
// De test rekent met ECHTE DateTime-waarden. Let op wat elke groep WEL en
// NIET bewijst:
//
// - Groep 1 toetst de BESLISREGEL zoals die hieronder is nagebouwd. Dat is een
//   specificatie van het gewenste gedrag, GEEN bewijs dat de bron het doet:
//   deze tests zijn ook groen op de oude code, want ze lezen de bron niet.
// - Groep 2 toetst de BRON zelf en is het eigenlijke bewijs. Die gaat rood op
//   de code van vóór de fix (gecontroleerd: 1 failure).
//
// De verzendfunctie wordt nergens aangeroepen — alleen de beslisregel.

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// De beslisregel zoals die in scheduled_messages_service.dart staat.
/// Groep 2 controleert dat deze regel ook echt in de bron staat.
bool isDue(DateTime scheduledAt, DateTime now) {
  final diff = now.difference(scheduledAt);
  return !diff.isNegative && diff.inSeconds <= 60;
}

void main() {
  final now = DateTime(2026, 9, 23, 14, 0, 0);

  group('Lokale planner: alleen verzenden als het tijdstip gepasseerd is', () {
    test('45 seconden in de TOEKOMST wordt NIET verzonden', () {
      final scheduledAt = now.add(const Duration(seconds: 45));
      expect(
        isDue(scheduledAt, now),
        isFalse,
        reason: 'met de oude .abs()-toets gaf dit TRUE en ging het bericht '
            'direct de deur uit',
      );
    });

    test('1 seconde in de toekomst wordt NIET verzonden', () {
      expect(isDue(now.add(const Duration(seconds: 1)), now), isFalse);
    });

    test('exact nu wordt WEL verzonden', () {
      expect(isDue(now, now), isTrue);
    });

    test('30 seconden geleden wordt WEL verzonden', () {
      expect(isDue(now.subtract(const Duration(seconds: 30)), now), isTrue);
    });

    test('45 seconden geleden wordt WEL verzonden', () {
      expect(isDue(now.subtract(const Duration(seconds: 45)), now), isTrue);
    });

    test('5 minuten geleden valt buiten het venster (te oud)', () {
      expect(isDue(now.subtract(const Duration(minutes: 5)), now), isFalse);
    });

    test('5 minuten vooruit valt buiten het venster', () {
      expect(isDue(now.add(const Duration(minutes: 5)), now), isFalse);
    });
  });

  group('De bron gebruikt dezelfde regel', () {
    test('.abs() is weg en de richting wordt getoetst', () {
      final c = File('lib/utils/scheduled_messages_service.dart').readAsStringSync();
      final zonderBlok = c.replaceAll(RegExp(r'/\*[\s\S]*?\*/'), '');
      final code = zonderBlok
          .split('\n')
          .map((r) => r.replaceAll(RegExp(r'//.*$', multiLine: true), ''))
          .join('\n');

      expect(
        code.contains('diff.inSeconds.abs()'),
        isFalse,
        reason: 'de abs() maakte het venster tweezijdig: toekomstige berichten '
            'werden ook verzonden',
      );
      expect(
        code.contains('!diff.isNegative && diff.inSeconds <= 60'),
        isTrue,
        reason: 'de beslisregel van deze test moet in de bron staan',
      );
    });
  });
}
