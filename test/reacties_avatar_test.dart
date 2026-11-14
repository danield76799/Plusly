// Regressietests: emoji-reacties mogen niet op de tekst of de avatar vallen.
//
// In de standaard Bubbles-layout stonden de reacties als `Positioned(
// bottom: -8)` over de bubbel heen — de pil viel dan bovenop de laatste
// tekstregel van het bericht. De Klassiek- en Modern-layout plaatsen de
// reactie-rij ónder de bubbel, ingesprongen op avatarbreedte bij inkomende
// berichten. De Bubbles-layout doet dat nu ook.

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('reacties-rij staat onder de bubbel, niet als overlay eroverheen', () {
    final bron = File(
      'lib/pages/chat/events/message_bubble.dart',
    ).readAsStringSync();

    expect(
      bron,
      isNot(contains('bottom: -8')),
      reason:
          'Positioned(bottom: -8) legt de reactie-pil bovenop de laatste '
          'tekstregel van de bubbel',
    );
    expect(
      bron,
      contains('Avatar.defaultSize'),
      reason:
          'De reactie-rij moet bij inkomende berichten ingesprongen zijn op '
          'avatarbreedte',
    );
    expect(
      bron,
      contains('MessageReactions('),
      reason: 'De reactie-rij moet ná de bubbel worden gerenderd',
    );
  });
}
