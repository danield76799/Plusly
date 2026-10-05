import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Source-reading test: de video-note-flow moet `maxBytes` meegeven aan
/// `resizeVideo`, zodat de video onder de serverlimiet blijft.
void main() {
  final chat = File('lib/pages/chat/chat.dart').readAsStringSync();

  test('onVideoSend geeft maxBytes mee aan resizeVideo', () {
    // Zoek de regel waar resizeVideo wordt aangeroepen in onVideoSend
    final idx = chat.indexOf('await videoFile.resizeVideo(');
    expect(idx, greaterThan(-1), reason: 'resizeVideo-aanroep niet gevonden');

    // Lees de regel en de regel erbij
    final endIdx = chat.indexOf('\n', idx);
    final call = chat.substring(idx, endIdx);

    expect(call, contains('maxBytes:'));
  });

  test('maxBytes is gebaseerd op server mUploadSize', () {
    // De video-note-flow moet de serverlimiet opvragen
    expect(chat, contains('clientConfig.mUploadSize'));
  });
}
