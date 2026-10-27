// Borgt de multiselectie en de kopieeracties vast.
//
// HET PROBLEEM. Plusly kon al meerdere berichten selecteren, maar de
// selectiebalk onderin had alleen "Versturen" en "Antwoorden". Kopiëren
// stond wél in de app-balk, maar die is op mobiel nauwelijks te vinden —
// de gebruiker vroeg erom zonder het te kunnen vinden. De enige route naar
// de selectie was het contextmenu van een tik, en in de overlay bij
// lang-druk stond helemaal geen "Selecteren".
//
// Deze test bewaakt dat de kopieeracties in de selectiebalk staan en dat
// de overlay een Selecteren-knop heeft.

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Broncode zonder commentaar: uitleg citeert bewust oude code.
String _code(String pad) {
  final c = File(pad).readAsStringSync();
  final zonderBlok = c.replaceAll(RegExp(r'/\*[\s\S]*?\*/'), '');
  return zonderBlok
      .split('\n')
      .map((r) => r.replaceAll(RegExp(r'//.*$', multiLine: true), ''))
      .join('\n');
}

void main() {
  group('multiselectie in de chat', () {
    final balk = _code('lib/pages/chat/chat_input_row.dart');
    final overlay = _code('lib/pages/chat/quick_reactions_overlay.dart');
    final bubble = _code('lib/pages/chat/events/message_bubble.dart');
    final menu = _code('lib/pages/chat/message_context_menu.dart');

    test('de selectiebalk kan de gekozen berichten kopiëren', () {
      expect(
        balk.contains('controller.copyEventsAction'),
        isTrue,
        reason: 'zonder "Kopiëren" in de selectiebalk is er geen snelle manier '
            'om meerdere berichten te kopiëren — de hele reden dat je '
            'multiselectie gebruikt',
      );
      expect(
        balk.contains('controller.copyLinkAction'),
        isTrue,
        reason: 'de links van meerdere berichten tegelijk kopiëren hoort er '
            'ook bij',
      );
    });

    test('de selectiebalk kan verwijderen en doorsturen', () {
      expect(
        balk.contains('controller.redactEventsAction'),
        isTrue,
        reason: 'meerdere berichten tegelijk verwijderen hoort bij de '
            'selectiebalk',
      );
      expect(
        balk.contains('controller.forwardEventsAction'),
        isTrue,
        reason: 'doorsturen van meerdere berichten hoort bij de selectiebalk',
      );
    });

    test('de selectiebalk is scrollbaar', () {
      // Op een smalle telefoon passen vijf knoppen niet op één rij; zonder
      // scrollbaar balk vallen de laatste knoppen eraf.
      expect(
        balk.contains('SingleChildScrollView'),
        isTrue,
        reason: 'de selectiebalk moet scrollbaar zijn, anders vallen de '
            'kopieeracties op een smalle telefoon eraf',
      );
      expect(
        balk.contains('scrollDirection: Axis.horizontal'),
        isTrue,
        reason: 'horizontaal scrollen, want de balk staat onder de chat',
      );
    });

    test('lang-drukken biedt een Selecteren-knop', () {
      expect(
        overlay.contains('onSelect'),
        isTrue,
        reason: 'de overlay moet een Selecteren-knop kunnen tonen',
      );
      expect(
        overlay.contains('Icons.check_circle_outline'),
        isTrue,
        reason: 'de Selecteren-knop moet zichtbaar zijn in de overlay',
      );
      expect(
        bubble.contains('onMultiSelect'),
        isTrue,
        reason: 'de overlay-knop moet de berichten echt selecteren',
      );
    });

    test('het contextmenu biedt ook Selecteren', () {
      expect(
        menu.contains('controller.onMultiSelect'),
        isTrue,
        reason: 'de oude route (contextmenu) blijft ook bestaan',
      );
    });
  });
}
