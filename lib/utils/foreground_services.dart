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

import 'package:Pulsly/config/app_config.dart';
import 'package:Pulsly/generated/l10n/l10n.dart';
import 'package:Pulsly/utils/platform_infos.dart';

abstract class ForegroundServices {
  static final List<String> _runningServices = [];
  static bool _externGestart = false;

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
        // Al aan (bv. gesprek): delen, maar straks niet stoppen.
        _externGestart = true;
        Logs().d('[ForegroundServices] service already running, sharing it');
        return;
      }
      _externGestart = false;
      final result = await FlutterForegroundTask.startService(
        serviceTypes: [ForegroundServiceTypes.shortService],
        notificationTitle: AppConfig.applicationName,
        notificationText: l10n.loadingMessages,
      );
      Logs().d('[ForegroundServices] start $name: $result');
    } catch (e) {
      Logs().e('[ForegroundServices] start failed', e);
    }
  }

  static Future<void> stopService(String name) async {
    try {
      if (!platformSupported) return;
      _runningServices.remove(name);
      if (_runningServices.isNotEmpty) return;
      if (_externGestart) {
        // Niet van ons — laten draaien (gesprek blijft aan).
        _externGestart = false;
        return;
      }
      await FlutterForegroundTask.stopService();
    } catch (e) {
      Logs().e('[ForegroundServices] stop failed', e);
    }
  }
}
