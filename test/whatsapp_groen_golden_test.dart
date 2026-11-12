// Golden-test voor de WhatsApp-look van de eigen bubbel (groen) en de
// strakkere hoekradius (10 i.p.v. 20).
//
//   flutter test --update-goldens test/whatsapp_groen_golden_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:Pulsly/config/app_config.dart';

void main() {
  testWidgets('whatsapp-groen + radius 10', (tester) async {
    const surface = Color(0xFF0B141A); // donker, zodat de bubbels afsteken
    const incoming = Color(0xFF202C33);
    const whatsAppGreen = Color(0xFF005C4B);
    const onGreen = Color(0xFFE9EDEF);

    Widget bubble(
      String text, {
      required Color color,
      required Color textColor,
      bool own = false,
    }) {
      return Align(
        alignment: own ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 6),
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(
                !own ? 0 : AppConfig.bubbleRadius,
              ),
              topRight: Radius.circular(AppConfig.bubbleRadius),
              bottomLeft: Radius.circular(AppConfig.bubbleRadius),
              bottomRight: Radius.circular(
                own ? 0 : AppConfig.bubbleRadius,
              ),
            ),
          ),
          child: Text(text, style: TextStyle(fontSize: 15, color: textColor)),
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
                bubble('Bericht van de ander', color: incoming, textColor: const Color(0xFFE9EDEF)),
                bubble('Eigen bericht (WhatsApp-groen)', color: whatsAppGreen, textColor: onGreen, own: true),
                bubble('Nog een van de ander', color: incoming, textColor: const Color(0xFFE9EDEF)),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await expectLater(
      find.byType(Scaffold),
      matchesGoldenFile('goldens/whatsapp_groen.png'),
    );
  });
}
