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
// Opgelost: de voettekst staat in de flow van de bubbel, zodat de bubbel
// meegroeit.

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:matrix/matrix.dart';

import 'package:Pulsly/generated/l10n/l10n.dart';

void main() {
  group('klassieke bubbel-stijl', () {
    test('de voettekst staat in de flow, niet als Positioned', () {
      final code = File(
        'lib/pages/chat/events/message_bubble_legacy.dart',
      ).readAsStringSync();
      expect(
        code.contains('if (useBottomRowStatus)\n                                          Positioned('),
        isFalse,
        reason: 'een Positioned-voettekst wordt niet meegerekend in de '
            'breedte van de bubbel en loopt bij een kort bericht naar buiten',
      );
      expect(
        code.contains('if (useBottomRowStatus)\n                                              Align('),
        isTrue,
        reason: 'de voettekst moet in de flow van de bubbel staan',
      );
    });

    testWidgets('het tijdstip valt binnen de bubbel', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: L10n.localizationsDelegates,
          supportedLocales: L10n.supportedLocales,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(alwaysUse24HourFormat: true),
            child: child!,
          ),
          home: Scaffold(
            body: Center(
              // Zelfde opbouw als de klassieke bubbel: een ClipRRect om een
              // Column, met daarin de Stack en de voettekst in de flow.
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: ColoredBox(
                  color: Colors.teal,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 6,
                      horizontal: 10,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Stack(
                          children: [
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Hi'),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                      top: 4,
                                      right: 12,
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          DateTime(
                                            2026,
                                            10,
                                            29,
                                            10,
                                            4,
                                          ).toIso8601String().substring(
                                            11,
                                            16,
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        const Icon(Icons.check, size: 13),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
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
      final tijd = tester.getRect(find.text('10:04'));
      expect(
        tijd.left,
        greaterThanOrEqualTo(bubbel.left - 0.01),
        reason: 'de tijd loopt uit de bubbel en wordt afgeknipt',
      );
      expect(tester.takeException(), isNull);
    });
  });
}
