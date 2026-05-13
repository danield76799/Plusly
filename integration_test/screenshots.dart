import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:Pulsly/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Screenshots', () {
    testWidgets('Take screenshots', (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Create screenshots directory
      final screenshotDir = Directory('screenshots');
      if (!screenshotDir.existsSync()) {
        screenshotDir.createSync();
      }

      // Screenshot 1: Chat list
      await takeScreenshot(tester, 'screenshots/01_chat_list.png');
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Try to open a chat if available
      final chatListItems = find.byType(ListTile);
      if (chatListItems.evaluate().isNotEmpty) {
        await tester.tap(chatListItems.first);
        await tester.pumpAndSettle(const Duration(seconds: 2));

        // Screenshot 2: Chat screen
        await takeScreenshot(tester, 'screenshots/02_chat.png');
        await tester.pumpAndSettle(const Duration(seconds: 1));

        // Screenshot 3: Chat with attachment menu
        final attachmentButton = find.byIcon(Icons.add_circle_outline);
        if (attachmentButton.evaluate().isNotEmpty) {
          await tester.tap(attachmentButton.first);
          await tester.pumpAndSettle(const Duration(seconds: 1));
          await takeScreenshot(tester, 'screenshots/03_chat_attachments.png');
          await tester.pumpAndSettle(const Duration(seconds: 1));
          
          // Close menu
          await tester.tapAt(const Offset(100, 100));
          await tester.pumpAndSettle(const Duration(seconds: 1));
        }
      }

      // Navigate to settings
      final settingsButton = find.byIcon(Icons.settings);
      if (settingsButton.evaluate().isNotEmpty) {
        await tester.tap(settingsButton.first);
        await tester.pumpAndSettle(const Duration(seconds: 2));
        await takeScreenshot(tester, 'screenshots/04_settings.png');
      }

      // Navigate to explore rooms
      final exploreButton = find.byIcon(Icons.explore);
      if (exploreButton.evaluate().isNotEmpty) {
        await tester.tap(exploreButton.first);
        await tester.pumpAndSettle(const Duration(seconds: 2));
        await takeScreenshot(tester, 'screenshots/05_explore.png');
      }
    });
  });
}

Future<void> takeScreenshot(WidgetTester tester, String filename) async {
  final binding = IntegrationTestWidgetsFlutterBinding.instance;
  await binding.convertFlutterSurfaceToImage();
  await tester.pumpAndSettle();
  await binding.takeScreenshot(filename);
}
