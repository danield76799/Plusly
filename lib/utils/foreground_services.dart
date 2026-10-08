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

import 'dart:async';
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

  /// Naam waarmee main.dart de koude-start-service start.
  static const backgroundPushService = 'background_push';

  /// Bovengrens op hoe lang de koude-start-service mag blijven staan.
  ///
  /// Normaal stopt push_helper hem in zijn finally. Die tak wordt niet bereikt
  /// als de client-initialisatie vóór pushHelper hangt of gooit (zwak netwerk bij
  /// een koude start). Een foreground-service is er juist op gebouwd om door te
  /// draaien, dus dan blijft "Berichten laden" eeuwig staan — precies het
  /// gemeten gedrag. Deze watchdog is het vangnet: na [watchdogTimeout] gaat de
  /// service uit, wat er ook gebeurd is.
  ///
  /// Voorheen 120s, maar in de praktijk blijft de melding zichtbaar zolang de
  /// service draait. 30s is ruim genoeg voor de push-pipeline (pushHelper timeout
  /// = 30s) en zorgt dat een achtergebleven melding snel verdwijnt.
  static const watchdogTimeout = Duration(seconds: 30);
  static Timer? _watchdog;
  static DateTime? _serviceStartedAt;

  static bool get platformSupported => PlatformInfos.isMobile;

  /// Ruimt een achtergebleven service op wanneer de app zélf naar de
  /// voorgrond komt.
  ///
  /// WAAROM DIT NODIG IS. De koude-start-service wordt gestart vóór de client-
  /// initialisatie en normaal gestopt door pushHelper. Hangt die initialisatie
  /// (traag netwerk) of komt de UP-boodschap nooit, dan blijft de service staan
  /// en toont Android eeuwig "Plusly / Berichten laden". Er is dan geen enkele
  /// andere gebeurtenis die hem opruimt: een foreground-service is juist
  /// ontworpen om te blijven draaien.
  ///
  /// Een bezoek aan de voorgrond is het betrouwbare opruimmoment: de gebruiker
  /// kijkt naar de app, dus een laadmelding van een oude push is per definitie
  /// verouderd.
  ///
  /// We stoppen de service als:
  /// - hij van ons is ([backgroundPushService] owner), óf
  /// - er helemaal geen owner bekend is (dode service zonder eigenaar), óf
  /// - de service al langer dan [watchdogTimeout] draait.
  ///
  /// `send_files` wordt nooit gestopt door deze functie; die heeft een eigen
  /// levenscyclus en de owner-markering staat op een andere naam.
  static Future<void> reconcileOnForegroundStart() async {
    try {
      if (!platformSupported) return;
      if (!await FlutterForegroundTask.isRunningService) return;
      final prefs = await SharedPreferences.getInstance();
      final owner = prefs.getString(_ownerKey);
      final runningTooLong = _serviceStartedAt != null &&
          DateTime.now().difference(_serviceStartedAt!) > watchdogTimeout;
      final shouldStop = owner == backgroundPushService ||
          (owner == null && runningTooLong) ||
          (owner == null &&
              _runningServices.isEmpty &&
              await FlutterForegroundTask.isRunningService);
      if (!shouldStop) return;
      Logs().w(
        '[ForegroundServices] reconcile: stale service (owner=$owner, runningTooLong=$runningTooLong), stopping',
      );
      await prefs.remove(_ownerKey);
      _runningServices.remove(owner);
      _watchdog?.cancel();
      _watchdog = null;
      _serviceStartedAt = null;
      await FlutterForegroundTask.stopService();
    } catch (e) {
      Logs().e('[ForegroundServices] reconcile failed', e);
    }
  }

  static Future<void> startService(String name) async {
    try {
      if (!platformSupported) return;
      if (!_runningServices.contains(name)) {
        _runningServices.add(name);
      }
      final l10n = await L10n.delegate.load(PlatformDispatcher.instance.locale);
      final prefs = await SharedPreferences.getInstance();
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
      final alreadyRunning = await FlutterForegroundTask.isRunningService;
      if (alreadyRunning) {
        // Service draait al. Drie mogelijkheden:
        // 1. In dezelfde levenscyclus gestart (bv. tweede send) → delen, later stoppen.
        // 2. Echt extern (voip/gesprek) → delen, nooit stoppen.
        // 3. Wees van een gekilde proces → opruimen en opnieuw starten.
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
          Logs().d('[ForegroundServices] service already running without owner, sharing it');
          return;
        }
      }
      _externGestart = false;
      _serviceStartedAt = DateTime.now();
      final result = await FlutterForegroundTask.startService(
        serviceTypes: [ForegroundServiceTypes.shortService],
        notificationTitle: AppConfig.applicationName,
        notificationText: l10n.loadingMessages,
      );
      // Markeren wie 'm startte: een app-kill laat de native service draaien,
      // en zonder dit staat de volgende processtart hem buiten onze scope.
      await prefs.setString(_ownerKey, name);
      // Vangnet: als de afronding (pushHelper finally / whenComplete) nooit
      // loopt, ruimt de watchdog de service alsnog op.
      _armWatchdog(name);
      Logs().d('[ForegroundServices] start $name: $result');
    } catch (e) {
      Logs().e('[ForegroundServices] start failed', e);
    }
  }

  /// (Her)start de watchdog voor [name]. Idempotent: een tweede start binnen
  /// dezelfde levenscyclus zet de klok opnieuw, zodat een lange upload niet
  /// halverwege wordt afgekapt.
  ///
  /// Alleen voor [backgroundPushService]: die is gebonden aan de pushpijplijn
  /// (30s-timeout in pushHelper) en hoort dus nooit minuten te blijven staan.
  /// `send_files` is een upload — video-compressie en verzenden duren legitiem
  /// langer, dus die mag de watchdog niet afkappen.
  static void _armWatchdog(String name) {
    _watchdog?.cancel();
    _watchdog = null;
    if (name != backgroundPushService) return;
    _watchdog = Timer(watchdogTimeout, () async {
      Logs().w('[ForegroundServices] watchdog fired for $name, stopping');
      await stopService(name);
    });
  }

  static Future<void> stopService(String name) async {
    try {
      if (!platformSupported) return;
      // Op een koude start is _runningServices leeg, maar de
      // owner-markering in SharedPreferences is wél aanwezig als
      // deze service door ons in een eerdere levenscyclus is
      // gestart. De markering is het betrouwbare signaal:
      // staat hij er én komt hij van ons → stop hem.
      // Een externe service (voip/gesprek) heeft géén markering →
      // laten we lopen.
      final stopPrefs = await SharedPreferences.getInstance();
      final owner = stopPrefs.getString(_ownerKey);
      final isOurs = owner == name || _runningServices.contains(name);
      if (!isOurs) return;
      _watchdog?.cancel();
      _watchdog = null;
      _serviceStartedAt = null;
      // Markeren verwijderen: een volgende start mag deze service
      // niet meer als 'ons' beschouwen als hij inmiddels is
      // opgeruimd door iets anders.
      await stopPrefs.remove(_ownerKey);
      _runningServices.remove(name);
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
