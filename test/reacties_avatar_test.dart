// Regressietest: emoji-reacties mogen niet over de avatar heen vallen.
//
// In de standaard Bubbles-layout stonden de reacties op `left: 8`, terwijl
// er bij inkomende berichten links een avatar (of een spacer van dezelfde
// breedte) staat. Daardoor vielen de reacties óver de avatar. De
// Klassiek-layout had dit al correct (`Avatar.defaultSize + 12`).

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('reacties beginnen rechts van de avatar, niet op de avatar', () {
    final bron = File(
      'lib/pages/chat/events/message_bubble.dart',
    ).readAsStringSync();

    expect(
      bron,
      contains('Avatar.defaultSize + 8'),
      reason:
          'De reacties moeten rechts van de avatar/spacer beginnen, anders '
          'vallen ze eroverheen',
    );
    expect(
      bron,
      isNot(contains('left: ownMessage ? null : 8')),
      reason: 'left: 8 zette de reacties precies op de avatar',
    );
  });
}
