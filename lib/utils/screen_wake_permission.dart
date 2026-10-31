import 'package:flutter/services.dart';

import 'package:Pulsly/utils/platform_infos.dart';

import 'package:matrix/matrix.dart' show Logs;

/// Kan Plusly het scherm aanzetten als er een melding binnenkomt?
///
/// Plusly gebruikt daarvoor een full-screen intent: zo verschijnt de
/// melding meteen op het vergrendelde scherm, zoals WhatsApp dat doet.
/// Vanaf Android 14 is die toestemming voor bericht-apps standaard UIT —
/// het systeem geeft USE_FULL_SCREEN_INTENT niet meer automatisch weg. De
/// gebruiker moet 'Volledige schermmeldingen' aanzetten in de
/// app-instellingen. Zonder die toestemming blijft het scherm donker.
class ScreenWakePermission {
  static const MethodChannel _channel = MethodChannel(
    'com.danield.plusly.app/notification_permission',
  );

  /// Geeft aan of het systeem een full-screen intent toestaat.
  ///
  /// Buiten Android (of als de check mislukt) gaan we uit van 'ja': dan
  /// veranderen we het gedrag niet op basis van een onbekende toestand.
  static Future<bool> canWakeScreen() async {
    if (!PlatformInfos.isAndroid) return true;
    try {
      final granted = await _channel.invokeMethod<bool>(
        'canUseFullScreenIntent',
      );
      return granted ?? true;
    } catch (e) {
      Logs().w('Kon de schermmelding-toestemming niet uitlezen', e);
      return true;
    }
  }

  /// Open de systeeminstelling waar de gebruiker de toestemming kan geven.
  static Future<void> openSettings() async {
    if (!PlatformInfos.isAndroid) return;
    try {
      await _channel.invokeMethod<bool>('openFullScreenIntentSettings');
    } catch (e) {
      Logs().w('Kon de schermmelding-instellingen niet openen', e);
    }
  }
}
