import 'dart:isolate';
import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:collection/collection.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_vodozemac/flutter_vodozemac.dart' as vod;
import 'package:matrix/matrix.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:Pulsly/config/app_config.dart';
import 'package:Pulsly/utils/client_manager.dart';
import 'package:Pulsly/utils/foreground_services.dart';
import 'package:Pulsly/utils/notification_background_handler.dart';
import 'package:Pulsly/utils/platform_infos.dart';
import 'package:Pulsly/utils/push_event_log.dart';
import 'package:Pulsly/utils/sync_debugger.dart';
import 'package:Pulsly/widgets/error_widget.dart';
import 'config/setting_keys.dart';
import 'utils/app_text_scale.dart';
import 'utils/background_push.dart';
import 'widgets/plusly_app.dart';

ReceivePort? mainIsolateReceivePort;

void main() async {
  // Initialize Flutter bindings first for error handling
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await _initializeApp();
  } catch (e, s) {
    Logs().e('Fatal error during app initialization', e, s);
    
    // Log to console for debugging
    debugPrint('FATAL ERROR: $e');
    debugPrint('Stack trace: $s');
    
    // Show error UI instead of crashing (dark mode compatible)
    runApp(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData.dark(),
        home: Scaffold(
          backgroundColor: const Color(0xFF1A0F0F),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Color(0xFFFF6B6B), size: 64),
                  const SizedBox(height: 16),
                  const Text(
                    'Oops! Something went wrong',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFE0E0E0),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${AppConfig.applicationName} could not start. Please try restarting the app.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Color(0xFFBDBDBD)),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2D1F1F),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Error: $e',
                      style: const TextStyle(
                        fontSize: 12,
                        fontFamily: 'monospace',
                        color: Color(0xFFE0E0E0),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

Future<void> _initializeApp() async {
  Logs().i('Welcome to ${AppConfig.applicationName}! Wonderhoy!!');

  if (PlatformInfos.isAndroid) {
    final port = mainIsolateReceivePort = ReceivePort();
    IsolateNameServer.removePortNameMapping(AppConfig.mainIsolatePortName);
    IsolateNameServer.registerPortWithName(
      port.sendPort,
      AppConfig.mainIsolatePortName,
    );
    await waitForPushIsolateDone();
  }

  // Our background push shared isolate accesses flutter-internal things very early in the startup proccess
  // To make sure that the parts of flutter needed are started up already, we need to ensure that the
  // widget bindings are initialized already.
  WidgetsFlutterBinding.ensureInitialized();

  FlutterForegroundTask.initCommunicationPort();

  await vod.init(wasmPath: './assets/assets/vodozemac/');

  Logs().nativeColors = !PlatformInfos.isIOS;
  final store = await AppSettings.init();

  // De app-brede tekstschaal begint op de BEWAARDE waarde, zodat een
  // herstart de gekozen maat meteen toont. De notifier is de brug naar de
  // widget-tree; AppSettings blijft de bron van waarheid.
  appTextScale.value = AppSettings.fontSizeFactor.value;

  // FluffyChat-pariteit (upstream main.dart r81-105): een engine die in
  // background-fetch mode start, is er één zonder Activity. Detecteer dat
  // vóór de zware initialisatie, zodat de foreground-service het HELE
  // koude-start-venster beschermt en niet alleen de staart.
  //
  // Let op: een koud gestarte push-engine meldt NIET altijd `detached`.
  // Flutter vult lifecycleState alleen bij een Activity
  // (services/binding.dart:295 readInitialLifecycleStateFromNativeWindow
  // stopt zolang initialLifecycleState leeg is), dus in de headless engine
  // van UnifiedPushService.getEngine() blijft de state NULL. Upstream's
  // `detached == lifecycleState` evalueert dan false en de hele tak wordt
  // overgeslagen. Omdat upstream vrijwel altijd via FCM loopt, raakt zijn
  // UnifiedPush-tak die situatie zelden; hier is het de normale koude start.
  final lifecycleState = WidgetsBinding.instance.lifecycleState;
  final isBackgroundFetch = PlatformInfos.isAndroid &&
      (lifecycleState == null ||
          lifecycleState == AppLifecycleState.detached);

  // Instrument (geen gedragswijziging): elke start logt de effectieve
  // lifecycle-state, zodat een volgende dump zelf bewijst welke tak een
  // koude start nam in plaats van dat we dat moeten afleiden.
  try {
    await PushEventLog().ensureLoaded();
    PushEventLog().add('init', {
      'startup_state': '${lifecycleState ?? 'null'}',
      'branch': isBackgroundFetch ? 'background' : 'foreground',
    });
  } catch (_) {}

  if (isBackgroundFetch) {
    // FluffyChat-pariteit (upstream main.dart r86): start de korte
    // foreground-service VÓÓR ClientManager.getClients(). Upstream's volgorde
    // is AppSettings.init() → startService → getClients; een service die pas
    // ná de zware init start, laat het hele koude-start-venster (Hive +
    // client-setup, seconden lang) onbeschermd, waarna Android het proces
    // wegvaagt vóór de notificatie getoond is. Gestopt in push_helper.dart
    // (finally), net als upstream push_helper.dart r93-94.
    await ForegroundServices.startService('background_push');

    final clients = await ClientManager.getClients(store: store);

    // Do not send online presences when app is in background fetch mode.
    for (final client in clients) {
      client.backgroundSync = false;
      client.syncPresence = PresenceType.offline;
    }

    // FluffyChat-pariteit: in background-fetch mode initialiseert
    // BackgroundPush.clientOnly() de lokale notificaties en UnifiedPush.
    Logs().i('[Main] Background-fetch mode, background push service');
    BackgroundPush.clientOnly(clients);
    // To start the flutter engine afterwards we add an custom observer.
    WidgetsBinding.instance.addObserver(AppStarter(clients, store));
    Logs().i(
      '${AppConfig.applicationName} started in background-fetch mode. No GUI will be created unless the app is no longer detached.',
    );
    return;
  }

  final clients = await ClientManager.getClients(store: store);

  for (final client in clients) {
    client.syncPresence = PresenceType.values.firstWhere(
      (x) => x.name == AppSettings.presenceStatus.value,
    );
    // Start sync debugging for first client
    if (client == clients.first) {
      SyncDebugger().startMonitoring(client);
    }
  }

  // Started in foreground mode.
  Logs().i(
    '${AppConfig.applicationName} started in foreground mode. Rendering GUI...',
  );
  await startGui(clients, store);
}

/// Fetch the pincode for the applock and start the flutter engine.
Future<void> startGui(List<Client> clients, SharedPreferences store) async {
  // Fetch the pin for the applock if existing for mobile applications.
  String? pin;
  if (PlatformInfos.isMobile) {
    try {
      pin = await const FlutterSecureStorage().read(
        key: SettingKeys.appLockKey,
      );
    } catch (e, s) {
      Logs().d('Unable to read PIN from Secure storage', e, s);
    }
  }

  // Preload first client
  final firstClient = clients.firstOrNull;
  await firstClient?.roomsLoading;
  await firstClient?.accountDataLoading;

  // PLUSLY-CHANGE (FluffyChat-pariteit): persisteer de effectieve UI-locale
  // zodat de detached/headless push-engine dezelfde taal gebruikt voor
  // notificaties. De headless engine krijgt de Android-locale NIET mee
  // (valt terug op en_US) — zonder dit waren push-notificaties Engels
  // op een Nederlands toestel. Zie loadPushL10n() in push_helper.dart.
  try {
    final uiLocale = PlatformDispatcher.instance.locale;
    final languageCode = uiLocale.languageCode;
    await store.setString('plusly_ui_locale', languageCode);
    Logs().d('[Locale] UI-locale gepersisteerd: $languageCode');
  } catch (e) {
    Logs().d('[Locale] kon UI-locale niet persistenteren: $e');
  }

  ErrorWidget.builder = (details) => PluslyErrorWidget(details);
  Logs().w("${clients.length} clients");
  runApp(PluslyApp(clients: clients, pincode: pin, store: store));
}

/// Watches the lifecycle changes to start the application when it
/// is no longer detached.
class AppStarter with WidgetsBindingObserver {
  final List<Client> clients;
  final SharedPreferences store;
  bool guiStarted = false;

  AppStarter(this.clients, this.store);

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (guiStarted) return;
    if (state == AppLifecycleState.detached) return;

    Logs().i(
      '${AppConfig.applicationName} switches from the detached background-fetch mode to ${state.name} mode. Rendering GUI...',
    );
    // Switching to foreground mode needs to reenable send online sync presence.
    for (final client in clients) {
      client.backgroundSync = true;
      client.syncPresence = PresenceType.values.firstWhere(
        (x) => x.name == AppSettings.presenceStatus.value,
      );
    }
    startGui(clients, store);
    // We must make sure that the GUI is only started once.
    guiStarted = true;
  }
}
