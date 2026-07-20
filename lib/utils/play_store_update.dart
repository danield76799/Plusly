import 'dart:io';

import 'package:in_app_update/in_app_update.dart';

/// Helper voor Play Store in-app updates.
/// Wordt alleen gebruikt wanneer de app via de Play Store geïnstalleerd is.
class PlayStoreUpdate {
  /// Controleert of de app via de Play Store geïnstalleerd is.
  /// Op niet-Play installs (sideload/APK) geeft Play geen update info.
  static Future<bool> isInstalledViaPlay() async {
    if (!Platform.isAndroid) return false;
    try {
      final info = await InAppUpdate.checkForUpdate();
      // Als Google Play een updateInfo teruggeeft, is de app via Play.
      // Bij sideload krijg je vaak updateAvailable=false maar geen error.
      // We gebruiken de aanwezigheid van een echte install store als signaal.
      return info.updateAvailability != UpdateAvailability
          .updateNotAvailable ||
          info.immediateUpdateAllowed ||
          info.flexibleUpdateAllowed;
    } catch (e) {
      // Geen Play Store beschikbaar (emulator, sideload, F-Droid, etc.)
      return false;
    }
  }

  /// Start een immediate update via Play Store als er een beschikbaar is.
  /// Retourneert true als een update gestart is.
  static Future<bool> startUpdate() async {
    if (!Platform.isAndroid) return false;
    try {
      final info = await InAppUpdate.checkForUpdate();
      if (info.updateAvailability == UpdateAvailability.updateAvailable) {
        await InAppUpdate.performImmediateUpdate();
        return true;
      }
    } catch (e) {
      // Fallback: niets gedaan
    }
    return false;
  }
}
