// Borgt vast dat een tik op een bericht in selectiemodus het bericht
// toevoegt aan de selectie.
//
// HET GAT (gemeld door de gebruiker: "multiselect werkt niet"). In de
// bubbel zitten twee tik-afhandelingen:
//
//   GestureDetector(            ← om de TEKST heen, dus BOVENOP
//     onTapDown: ...,
//     onDoubleTap: ...reactie...,
//     onLongPress: ...menu...,
//   )
//   Positioned.fill(
//     child: InkWell(onTap: ..., onLongPress: ...reactie-overlay...),
//   )                           ← ONDER de inhoud
//
// Een `Text` in een `Stack` meldt een hit en slokt de tik op: de InkWell
// onder de inhoud krijgt die tik nooit. Het gevolg was dat een tik op de
// tekst niets deed — dus na het selecteren van het eerste bericht kon er
// geen tweede bij. De InkWell onder de inhoud is in de praktijk alleen
// bereikbaar op de randen van de bubbel.
//
// OPGELOST: de GestureDetector om de tekst heeft zelf een `onTap`, die
// alleen actief is in selectiemodus (`longPressSelect`). Buiten
// selectiemodus blijft een tik niets doen, zoals WhatsApp en Signal.

import 'dart:io';

import 'package:flutter/material.dart';
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
  group('tik op een bericht in selectiemodus', () {
    for (final pad in const [
      'lib/pages/chat/events/message_bubble.dart',
      'lib/pages/chat/events/message_modern.dart',
      'lib/pages/chat/events/message_bubble_legacy.dart',
    ]) {
      test('$pad heeft een onTap in selectiemodus', () {
        final code = _code(pad);
        expect(
          code.contains('onTap: widget.longPressSelect'),
          isTrue,
          reason: 'zonder onTap in selectiemodus bereikt een tik het bericht '
              'niet (de InkWell onder de tekst slokt de tik op) en kun je '
              'nooit een tweede bericht selecteren',
        );
        expect(
          code.contains('widget.onSelect(event, _tapPosition)'),
          isTrue,
          reason: 'de tik moet de selectie-toggle aanroepen',
        );
      });
    }
  });

  group('waarom de InkWell onder de inhoud niet volstaat', () {
    // Dit gedrag van Flutter is de hele bug: wie de GestureDetector weer
    // onder de tekst zet, breekt de multiselectie opnieuw.
    testWidgets('een Text in een Stack slokt de tik op', (tester) async {
      var taps = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Stack(
              children: [
                Positioned.fill(
                  child: InkWell(
                    onTap: () => taps++,
                    child: const Material(child: SizedBox.expand()),
                  ),
                ),
                const Center(child: Text('hoi')),
              ],
            ),
          ),
        ),
      );
      await tester.tap(find.text('hoi'));
      await tester.pump();
      expect(
        taps,
        0,
        reason: 'de tekst meldt de hit; de InkWell eronder wordt niet eens '
            'getest. Daarom moet de tik-afhandeling OM de tekst zitten.',
      );
    });
  });
}
