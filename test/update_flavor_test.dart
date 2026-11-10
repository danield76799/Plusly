// Regressietest voor de updater.
//
// Bug: de Play Store-build kon nooit automatisch updaten. De playstore-
// flavor haalt `REQUEST_INSTALL_PACKAGES` uit het manifest (Google Play
// verbiedt dat een Play-app zelf APK's installeert), maar de updater vroeg
// die permission wél aan. Je kreeg dus de doodlopende melding "Plusly mag
// geen APK's installeren" in plaats van een werkende update.
//
// Fix: de updater weet welke build het is (`PLUSLY_PLAYSTORE`) en biedt bij
// een Play-build de browser-route aan — de gebruiker installeert dan zelf,
// wat wél is toegestaan.

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:Pulsly/utils/check_updates.dart';

void main() {
  group('Updatemek', () {
    test('de standaardbuild is geen Play Store-build', () {
      // Zonder de dart-define is dit de github-build, die wél zelf APK's
      // mag installeren.
      expect(isPlayStoreBuild, isFalse);
    });

    test('de playstore-flavor haalt REQUEST_INSTALL_PACKAGES weg', () {
      final manifest = File(
        'android/app/src/playstore/AndroidManifest.xml',
      ).readAsStringSync();

      expect(
        manifest,
        contains('REQUEST_INSTALL_PACKAGES'),
        reason:
            'De playstore-manifest moet de permission juist VERWIJDEREN; '
            'dit bestand bevat de removal-tag',
      );
      expect(
        manifest,
        contains('tools:node="remove"'),
        reason:
            'De permission wordt met tools:node="remove" verwijderd, anders '
            'staat hij alsnog in de gecompileerde Play-build',
      );
    });

    test('de CI zet PLUSLY_PLAYSTORE bij de Play Store-AAB', () {
      final workflow = File(
        '.github/workflows/main_deploy.yml',
      ).readAsStringSync();

      expect(
        workflow,
        contains('--dart-define=PLUSLY_PLAYSTORE=true'),
        reason:
            'De Play Store-AAB moet met PLUSLY_PLAYSTORE=true gebouwd '
            'worden, anders weet de updater niet dat hij niet zelf mag '
            'installeren',
      );
    });

    test('de updater biedt de browser-route aan als fallback', () {
      final bron = File(
        'lib/utils/check_updates.dart',
      ).readAsStringSync();

      expect(
        bron,
        contains('isPlayStoreBuild'),
        reason:
            'De updater moet de build-typen onderscheiden: een Play-build '
            'mag zelf geen APK installeren',
      );
      expect(
        bron,
        contains('releases'),
        reason:
            'Er moet altijd een werkende route naar de releasepagina '
            'blijven (browser-download door de gebruiker zelf)',
      );
    });
  });
}
