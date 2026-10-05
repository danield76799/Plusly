import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Source-reading test: de upload-timeout moet langer zijn dan de SDK-standaard
/// van 1 minuut, zodat grote video's (zelfs gecomprimeerd) niet te vroeg als
/// fout worden gemarkeerd.
void main() {
  final clientManager = File('lib/utils/client_manager.dart').readAsStringSync();

  test('sendTimelineEventTimeout is ingesteld op 10 minuten', () {
    expect(
      clientManager,
      contains('sendTimelineEventTimeout: const Duration(minutes: 10)'),
    );
  });

  test('sendTimelineEventTimeout komt ná defaultNetworkRequestTimeout', () {
    final netIdx = clientManager.indexOf('defaultNetworkRequestTimeout');
    final uploadIdx = clientManager.indexOf('sendTimelineEventTimeout');
    expect(netIdx, greaterThan(-1));
    expect(uploadIdx, greaterThan(netIdx));
  });
}
