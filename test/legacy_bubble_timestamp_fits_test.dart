// Regressietest: de voettekst (tijd + vinkjes) mag nooit uit de bubbel
// lopen.
//
// Het probleem: in de klassieke bubbel-stijl stond de voettekst als
// `Positioned` in een `Stack`. Een Positioned bepaalt de breedte van de
// Stack niet — die wordt alleen zo breed als de inhoud. Bij een kort
// bericht ("Hi") was de bubbel dus smaller dan "20:04 + vinkjes", liep de
// rij naar buiten en werd de tijd links afgeknipt: "0:04" in plaats van
// "20:04".
//
// Opgelost zonder de vorm te veranderen: de bubbel krijgt een minimale
// breedte (zodat de voettekst er vanzelf in past) en de voettekst wordt
// door een FittedBox teruggeschaald als de bubbel toch te smal is. De
// bubbel blijft dus smal, met de tijd rechtsonder.

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('klassieke bubbel-stijl', () {
    final code = File(
      'lib/pages/chat/events/message_bubble_legacy.dart',
    ).readAsStringSync();

    test('de voettekst blijft rechtsonder staan (smalle bubbel)', () {
      expect(
        code.contains('if (useBottomRowStatus)'),
        isTrue,
        reason: 'de voettekst staat als Positioned onderaan rechts; dat is '
            'de vorm die er was',
      );
      expect(
        code.contains('right: 0'),
        isTrue,
        reason: 'de Positioned moet left+right krijgen: met alleen "right" '
            'krijgt hij de loose constraints van de Stack (de hele '
            'schermbreedte) en niet de breedte van de bubbel',
      );
    });

    test('de voettekst wordt teruggeschaald als de bubbel te smal is', () {
      expect(
        code.contains('fit: BoxFit.scaleDown'),
        isTrue,
        reason: 'zonder FittedBox loopt de voettekst uit de bubbel en wordt '
            'de tijd afgeknipt ("0:04")',
      );
    });

    test('de bubbel heeft een minimale breedte voor de voettekst', () {
      expect(
        code.contains('minWidth: 64'),
        isTrue,
        reason: 'een korte bubbel moet ruimte houden voor "20:04" + vinkjes',
      );
    });

    testWidgets('het tijdstip valt binnen de bubbel', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              // Zelfde opbouw als de klassieke bubbel.
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: ColoredBox(
                  color: Colors.teal,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 6,
                      horizontal: 10,
                    ),
                    child: Stack(
                      children: [
                        ConstrainedBox(
                          constraints: const BoxConstraints(minWidth: 64),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Hi'),
                              const SizedBox(height: 22),
                            ],
                          ),
                        ),
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: 6,
                          child: Padding(
                            padding: const EdgeInsets.only(right: 12),
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerRight,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text('20:04'),
                                  const SizedBox(width: 4),
                                  const Icon(Icons.check, size: 13),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final bubbel = tester.getRect(find.byType(ClipRRect));
      final tijd = tester.getRect(find.text('20:04'));
      expect(
        tijd.left,
        greaterThanOrEqualTo(bubbel.left - 0.01),
        reason: 'de tijd loopt uit de bubbel en wordt afgeknipt',
      );
      expect(
        tijd.right,
        lessThanOrEqualTo(bubbel.right + 0.01),
        reason: 'de tijd loopt uit de bubbel',
      );
      expect(tester.takeException(), isNull);
    });
  });
}
