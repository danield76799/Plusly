import 'dart:io';
import 'package:integration_test/integration_test_driver_extended.dart';

Future<void> main() async {
  await integrationDriver(
    onScreenshot: (String screenshotName, List<int> screenshotBytes, [Map<String, Object?>? args]) async {
      final File image = File(screenshotName);
      await image.writeAsBytes(screenshotBytes);
      print('Screenshot saved: $screenshotName');
      return true;
    },
  );
}
