import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Het scherm oplichten bij een melding gaat via een full-screen intent.
/// Vanaf Android 14 is die toestemming voor bericht-apps standaard uit,
/// dus de app moet (a) de toestemming gebruiken, (b) de stand kunnen
/// uitlezen en (c) de gebruiker naar de instellingen kunnen sturen.
void main() {
  group('scherm aan bij een melding', () {
    test('de melding gebruikt een full-screen intent', () {
      final code = File(
        'lib/utils/push_helper.dart',
      ).readAsStringSync();
      expect(
        code.contains('fullScreenIntent: true'),
        isTrue,
        reason: 'zonder full-screen intent licht het scherm niet op',
      );
    });

    test('de toestemming staat in het manifest', () {
      final manifest = File(
        'android/app/src/main/AndroidManifest.xml',
      ).readAsStringSync();
      expect(
        manifest.contains('android.permission.USE_FULL_SCREEN_INTENT'),
        isTrue,
      );
    });

    test('de app kan de toestemming uitlezen', () {
      final dart = File(
        'lib/utils/screen_wake_permission.dart',
      ).readAsStringSync();
      expect(dart.contains('canUseFullScreenIntent'), isTrue);

      final kotlin = File(
        'android/app/src/main/kotlin/com/danield/plusly/app/NotificationPermissionChannel.kt',
      ).readAsStringSync();
      expect(
        kotlin.contains('manager.canUseFullScreenIntent()'),
        isTrue,
        reason: 'de stand moet uit NotificationManager komen',
      );
      expect(
        kotlin.contains('ACTION_MANAGE_APP_USE_FULL_SCREEN_INTENT'),
        isTrue,
        reason: 'de gebruiker moet naar de juiste instelling kunnen',
      );
    });

    test('de app vraagt niet blind aan bij elke start', () {
      final code = File(
        'lib/utils/background_push.dart',
      ).readAsStringSync();
      expect(
        code.contains('requestFullScreenIntentPermission()'),
        isFalse,
        reason:
            'dat opende bij elke app-start de systeeminstellingen, '
            'zonder uitleg',
      );
      expect(
        code.contains('ScreenWakePermission.canWakeScreen()'),
        isTrue,
        reason: 'de stand wordt wel gecontroleerd',
      );
    });

    test('de gebruiker wordt in de app zelf gewezen', () {
      final settings = File(
        'lib/pages/settings_notifications/settings_notifications_view.dart',
      ).readAsStringSync();
      expect(settings.contains('ScreenWakePermission.openSettings()'), isTrue);

      final chatList = File(
        'lib/pages/chat_list/chat_list.dart',
      ).readAsStringSync();
      expect(chatList.contains('_maybeAskForScreenWake()'), isTrue);
    });
  });
}
