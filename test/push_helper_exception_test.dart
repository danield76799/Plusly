import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Borgt dat push_helper exception uit `getEventByPushNotification` opvangt.
///
/// De Extera-fork van de SDK gooit `Exception('Unable to find event for this
/// push notification!')` terwijl upstream `null` returned (clearing-indicator).
/// Als push_helper dat verschil niet opvangt, crasht de hele helper en ziet
/// de gebruiker geen melding.
void main() {
  group('Push helper exception handling', () {
    test('PushHelper.pushHelper vangt SDK-fout en behandelt als clearing', () {
      // We kunnen geen echte Client mocken in widget-test zonder SDK. Test
      // daarom de bronstructuur: er moet een try/catch rond
      // getEventByPushNotification zitten die event op null zet.
      final bron = File('lib/utils/push_helper.dart').readAsStringSync();

      expect(
        bron.contains('event = await client.getEventByPushNotification('),
        isTrue,
        reason: 'event laden moet binnen try staan',
      );
      expect(
        bron.contains('event = null;'),
        isTrue,
        reason: 'catch moet event terugzetten naar null (clearing)',
      );

      final blok = bron.substring(bron.indexOf('getEventByPushNotification('));
      expect(
        RegExp(
          r'} catch \(e, s\) \{[\s\S]*?event\s*=\s*null;',
        ).hasMatch(blok),
        isTrue,
        reason: 'null-toewijzing hoort in het catch-blok na getEventByPushNotification',
      );
    });
  });
}
