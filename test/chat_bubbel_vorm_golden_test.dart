// Golden-test voor de WhatsApp-vorm van de berichtbubbel.
//
// Schrijft een PNG van de bubbel-compositie (ClipRRect + BubbleTail erachter),
// zodat de geometrie visueel gecontroleerd kan worden.
//
//   flutter test --update-goldens test/chat_bubbel_vorm_golden_test.dart
//
// De PNG komt in test/goldens/chat_bubbel_vorm.png.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:Pulsly/pages/chat/events/bubble_tail.dart';

/// Evenaart de bubbel-compositie uit MessageBubble._buildBubble.
Widget _bubbel({
  required String tekst,
  required bool eigen,
  required Color kleur,
  required BorderRadius hoeken,
}) {
  final bubble = ClipRRect(
    borderRadius: hoeken,
    child: Material(
      color: kleur,
      borderRadius: hoeken,
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 10.0),
        child: Text(
          tekst,
          style: const TextStyle(fontSize: 15, color: Colors.black87),
        ),
      ),
    ),
  );

  return Stack(
    clipBehavior: Clip.none,
    children: [
      Positioned(
        bottom: -4,
        left: eigen ? null : -3,
        right: eigen ? -3 : null,
        child: BubbleTail(color: kleur, ownMessage: eigen),
      ),
      bubble,
    ],
  );
}

void main() {
  testWidgets('bubbelvorm', (tester) async {
    const radius = Radius.circular(20);
    const eigenKleur = Color(0xFFD9FDD3); // WhatsApp outgoing light
    const anderKleur = Color(0xFFFFFFFF); // WhatsApp incoming light

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          backgroundColor: const Color(0xFFECE5DD), // WhatsApp chat wallpaper
          body: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 40, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Inkomend: bov-hoek vierkant (start van een groep).
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    _bubbel(
                      tekst: 'Hoi, hoe gaat het?',
                      eigen: false,
                      kleur: anderKleur,
                      hoeken: const BorderRadius.only(
                        topLeft: Radius.zero,
                        topRight: radius,
                        bottomLeft: radius,
                        bottomRight: radius,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                // Inkomend, vervolg van dezelfde afzender.
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    _bubbel(
                      tekst: 'Alles goed hier!',
                      eigen: false,
                      kleur: anderKleur,
                      hoeken: const BorderRadius.only(
                        topLeft: radius,
                        topRight: radius,
                        bottomLeft: radius,
                        bottomRight: radius,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                // Eigen bericht.
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    _bubbel(
                      tekst: 'Mooi, tot straks!',
                      eigen: true,
                      kleur: eigenKleur,
                      hoeken: const BorderRadius.only(
                        topLeft: radius,
                        topRight: radius,
                        bottomLeft: radius,
                        bottomRight: radius,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await expectLater(
      find.byType(Scaffold),
      matchesGoldenFile('goldens/chat_bubbel_vorm.png'),
    );
  });
}
