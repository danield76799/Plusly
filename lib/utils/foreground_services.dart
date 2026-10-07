// Foreground-service rond bestanden versturen (upstream FluffyChat-patroon).
//
// Zonder service kan Android het upload-proces killen zodra de app naar de
// achtergrond gaat (wegdrukken tijdens een grote video = upload dood).
// Met serviceType shortService blijft de upload ~3 minuten alive — genoeg
// voor de meeste bestanden.
//
// Regels:
// - Alleen mobiel; op desktop/web gebeurt er niets.
// - Refcount via [runningServices]: meerdere gelijktijdige sends delen één
//   service; pas stoppen als de laatste klaar is.
// - Nooit een lopende service van een ander killen (bv. gesprek): stond de
//   service al aan vóór onze start, dan laten we hem bij stop met rust.

import 'dart:ui';

import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:matrix/matrix.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:Pulsly/config/app_config.dart';
import 'package:Pulsly/generated/l10n/l10n.dart';
import 'package:Pulsly/utils/platform_infos.dart';

abstract class ForegroundServices {
  static final List<String> _runningServices = [];
  static bool _externGestart = false;

  /// Persistent merkteken van wie de service startte in deze LEEFCYCLUS.
  ///
  /// WAAROM DIT NODIG IS. `_runningServices` is een in-memory map: bij een
  /// app-kill is die leeg terwijl de native service nog kan draaien. Bij een
  /// koude processtart ziet `startService` dan `isRunningService == true`,
  /// markeert hem als `_externGestart` ("niet van ons, laten draaien") — en
  /// stopt hem daarna NOOIT meer. De `loadingMessages`-placeholder ("Plusly
  /// Berichten laden") blijft dan eeuwig staan, precies het gemeten gedrag.
  ///
  /// De oplossing: onthouden WELKE component de service startte in
  /// SharedPreferences (die beide processen delen — ook na een kill). Enkel
  /// een service zónder die markering (bv. voip, die zijn eigen lifecycle
  /// beheert) wordt als echt extern beschouwd.
  static const _ownerKey = 'foreground_service_starter';

  static bool get platformSupported => PlatformInfos.isMobile;

  static Future<void> startService(String name) async {
    try {
      if (!platformSupported) return;
      if (!_runningServices.contains(name)) {
        _runningServices.add(name);
      }
      final l10n = await L10n.delegate.load(PlatformDispatcher.instance.locale);
      FlutterForegroundTask.init(
        androidNotificationOptions: AndroidNotificationOptions(
          channelId: 'notification_channel_id',
          channelName: 'Foreground Notification',
          channelDescription: l10n.foregroundServiceRunning,
          onlyAlertOnce: true,
        ),
        iosNotificationOptions: const IOSNotificationOptions(
          showNotification: false,
        ),
        foregroundTaskOptions: ForegroundTaskOptions(
          eventAction: ForegroundTaskEventAction.nothing(),
          allowWakeLock: true,
        ),
      );
      if (await FlutterForegroundTask.isRunningService) {
        // Service draait al. Drie mogelijkheden:
        // 1. In dezelfde levenscyclus gestart (bv. tweede send) → delen, later stoppen.
        // 2. Echt extern (voip/gesprek) → delen, nooit stoppen.
        // 3. Wees van een gekilde proces → opruimen en opnieuw starten.
        final prefs = await SharedPreferences.getInstance();
        final owner = prefs.getString(_ownerKey);
        if (owner != null) {
          // Wees-service: dit proces kende 'm niet, maar de markering staat er
          // nog. Ruim op en start de nieuwe taak vers op.
          Logs().d('[ForegroundServices] orphan from previous process: $owner, restarting');
          await FlutterForegroundTask.stopService();
          // Door naar start hieronder.
        } else {
          // Geen owner-markering → echt extern (voip) of al gedeeld in deze levenscyclus.
          _externGestart = true;
          Logs().d('[ForegroundServices] service already running, sharing it');
          return;
        }
      }
      _externGestart = false;
      final result = await FlutterForegroundTask.startService(
        serviceTypes: [ForegroundServiceTypes.shortService],
        notificationTitle: AppConfig.applicationName,
        notificationText: l10n.loadingMessages,
      );
      // Markeren wie 'm startte: een app-kill laat de native service draaien,
      // en zonder dit staat de volgende processtart hem buiten onze scope.
      final ownerPrefs = await SharedPreferences.getInstance();
      await ownerPrefs.setString(_ownerKey, name);
      Logs().d('[ForegroundServices] start $name: $result');
    } catch (e) {
      Logs().e('[ForegroundServices] start failed', e);
    }
  }

  static Future<void> stopService(String name) async {
    try {
      if (!platformSupported) return;
      // Verwijder de owner-markering ONAFHANKELIJK van de in-memory
      // lijst. Bij een koude start is `_runningServices` leeg, maar
      // de markering in SharedPreferences is wél aanwezig — dat is
      // precies het signaal dat deze service door een vorige, gekilde
      // levenscyclus is gestart en nu als wees beschouwd moet worden.
      // Een externe service (voip/gesprek) heeft géén markering, dus
      // wordt hier NIET geraakt.
      final stopPrefs = await SharedPreferences.getInstance();
      await stopPrefs.remove(_ownerKey);
      final wasOurs = _runningServices.remove(name);
      if (!wasOurs) return;
      if (_runningServices.isNotEmpty) return;
      if (_externGestart) {
        _externGestart = false;
        return;
      }
      await FlutterForegroundTask.stopService();
    } catch (e) {
      Logs().e('[ForegroundServices] stop failed', e);
    }
  }
}
