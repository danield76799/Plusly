// Golden-test voor de WhatsApp-groepering: opeenvolgende berichten van
// dezelfde afzender vormen één aaneengesloten blok, en alleen het onderste
// bericht krijgt een staartje.
//
//   flutter test --update-goldens test/groepering_golden_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:Pulsly/config/app_config.dart';

void main() {
  testWidgets('groepering + enkel staartje', (tester) async {
    const surface = Color(0xFF0B141A);
    const incoming = Color(0xFF202C33);

    // Repliceert de hoeklogica uit MessageBubble: vierkante hoeken aan de
    // zijden die aan het blok grenzen.
    Widget bubble(String text, {required bool sameAbove, required bool sameBelow, required bool tail}) {
      const r = Radius.circular(AppConfig.bubbleRadius);
      final radius = BorderRadius.only(
        topLeft: sameAbove ? Radius.zero : r,
        topRight: sameAbove ? Radius.zero : r,
        bottomLeft: sameBelow ? Radius.zero : r,
        bottomRight: sameBelow ? Radius.zero : r,
      );
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 1),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              if (tail)
                Positioned(
                  bottom: -3,
                  left: -2,
                  child: Container(width: 10, height: 10, color: incoming),
                ),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                decoration: BoxDecoration(color: incoming, borderRadius: radius),
                child: Text(text, style: const TextStyle(fontSize: 15, color: Colors.white)),
              ),
            ],
          ),
        ),
      );
    }

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          backgroundColor: surface,
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                bubble('Eerste van het blok', sameAbove: false, sameBelow: true, tail: false),
                bubble('Midden', sameAbove: true, sameBelow: true, tail: false),
                bubble('Laatste (staartje)', sameAbove: true, sameBelow: false, tail: true),
                bubble('Andere afzender', sameAbove: false, sameBelow: false, tail: false),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await expectLater(
      find.byType(Scaffold),
      matchesGoldenFile('goldens/groepering.png'),
    );
  });
}
