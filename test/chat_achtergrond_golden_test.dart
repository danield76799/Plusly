// Golden-test voor de ingebouwde chatachtergronden.
//
// Rendert elke achtergrond in licht én donker naar test/goldens/,
// zodat de ontwerpen visueel beoordeeld kunnen worden.
//
//   flutter test --update-goldens test/chat_achtergrond_golden_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:Pulsly/widgets/chat_background.dart';

void main() {
  final backgrounds = [
    'dusk',
    'forest',
    'ocean',
    'dots',
    'waves',
    'stars',
    'lattice',
  ];

  for (final id in backgrounds) {
    for (final brightness in [Brightness.dark, Brightness.light]) {
      testWidgets('achtergrond $id (${brightness.name})', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData(brightness: brightness),
            home: Scaffold(
              body: SizedBox(
                width: 180,
                height: 320,
                child: Stack(
                  children: [
                    ChatBackground(background: id),
                    // Een namaak-bericht zodat de zichtbaarheid in context
                    // beoordeeld kan worden.
                    Positioned(
                      top: 40,
                      left: 12,
                      child: Container(
                        width: 110,
                        height: 34,
                        decoration: BoxDecoration(
                          color: brightness == Brightness.dark
                              ? const Color(0xFF1F2C34)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 84,
                      right: 12,
                      child: Container(
                        width: 90,
                        height: 34,
                        decoration: BoxDecoration(
                          color: brightness == Brightness.dark
                              ? const Color(0xFF005C4B)
                              : const Color(0xFFD9FDD3),
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
        await expectLater(
          find.byType(Scaffold),
          matchesGoldenFile('goldens/chat_background_${id}_${brightness.name}.png'),
        );
      });
    }
  }
}
