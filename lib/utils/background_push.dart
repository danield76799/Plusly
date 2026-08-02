/*
 *   Famedly
 *   Copyright (C) 2020, 2021 Famedly GmbH
 *   Copyright (C) 2021-2026 Plusly
 *
 *   This program is free software: you can redistribute it and/or modify
 *   it under the terms of the GNU Affero General Public License as
 *   published by the Free Software Foundation, either version 3 of the
 *   License, or (at your option) any later version.
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 *   GNU Affero General Public License for more details.
 *
 *   You should have received a copy of the GNU Affero General Public License
 *   along with this program.  If not, see <https://www.gnu.org/licenses/>.
 */

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_new_badger/flutter_new_badger.dart';
import 'package:http/http.dart' as http;
import 'package:matrix/matrix.dart';
import 'package:unifiedpush/unifiedpush.dart';

import 'package:Pulsly/generated/l10n/l10n.dart';
import 'package:Pulsly/main.dart';
import 'package:Pulsly/utils/notification_background_handler.dart';
import 'package:Pulsly/utils/platform_infos.dart';
import 'package:Pulsly/utils/push_helper.dart';
import 'package:Pulsly/utils/push_log_buffer.dart';
import 'package:Pulsly/widgets/matrix.dart';
import 'package:Pulsly/widgets/plusly_app.dart';
import '../config/app_config.dart';
import '../config/setting_keys.dart';

class BackgroundPush {
  static BackgroundPush? _instance;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  /// Public accessor for diagnostic test notifications.
  FlutterLocalNotificationsPlugin get localNotificationsPlugin =>
      _flutterLocalNotificationsPlugin;
  List<Client> clients;
  MatrixState? matrix;
  L10n? l10n;

  Future<void> loadLocale() async {
    final context = matrix?.context;
    l10n ??=
        (context != null ? L10n.of(context) : null) ??
        (await L10n.delegate.load(PlatformDispatcher.instance.locale));
  }

  final pendingTests = <String, Completer<void>>{};

  DateTime? lastReceivedPush;

  bool upAction = false;

  Future<void> initialiseLocalNotifications() async {
    PushLogBuffer.instance.i('initialiseLocalNotifications() started');
    // Android 13+ requires a runtime notification permission. Ask early so
    // the diagnostic test (and later real pushes) can actually be displayed.
    if (PlatformInfos.isAndroid) {
      final androidPlugin = _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      final granted = await androidPlugin?.requestNotificationsPermission() ??
          false;
      PushLogBuffer.instance.i('Notification permission granted: $granted');

      // Android 8+ (API 26+) requires a notification channel before any
      // notification can be shown. Without this, show() silently fails.
      // IMPORTANT: do NOT delete and recreate the channel on every app start.
      // On many OEMs (Samsung, Xiaomi, Oppo) this resets the user's importance
      // setting to "Silent" or "No popup", causing notifications to disappear.
      // Only create the channel if it doesn't already exist.
      final existingChannels = await androidPlugin?.getNotificationChannels();
      final channelExists = existingChannels?.any(
        (c) => c.id == AppConfig.pushNotificationsChannelId,
      ) ?? false;
      PushLogBuffer.instance.i(
        'Notification channel ${channelExists ? "exists" : "missing"} '
        '(${existingChannels?.length ?? 0} channels total)',
      );
      if (!channelExists) {
        await androidPlugin?.createNotificationChannel(
          const AndroidNotificationChannel(
            AppConfig.pushNotificationsChannelId,
            'Berichten',
            description: 'Inkomende chatberichten',
            importance: Importance.max,
            enableVibration: true,
            enableLights: true,
          ),
        );
      }
    }

    await _flutterLocalNotificationsPlugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('notifications_icon'),
        iOS: DarwinInitializationSettings(),
      ),
      onDidReceiveNotificationResponse: (response) => notificationTap(
        response,
        clients: clients,
        router: PluslyApp.router,
        l10n: l10n,
      ),
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );
  }

  void _init() async {
    try {
      mainIsolateReceivePort?.listen((message) async {
        try {
          await notificationTap(
            NotificationResponseJson.fromJsonString(message),
            clients: clients,
            router: PluslyApp.router,
            l10n: l10n,
          );
        } catch (e, s) {
          Logs().wtf('Main Notification Tap crashed', e, s);
        }
      });
      if (PlatformInfos.isAndroid) {
        final port = ReceivePort();
        IsolateNameServer.removePortNameMapping('background_tab_port');
        IsolateNameServer.registerPortWithName(
          port.sendPort,
          'background_tab_port',
        );
        port.listen((message) async {
          try {
            await notificationTap(
              NotificationResponseJson.fromJsonString(message),
              clients: clients,
              router: PluslyApp.router,
              l10n: l10n,
            );
          } catch (e, s) {
            Logs().wtf('Main Notification Tap crashed', e, s);
          }
        });
      }
      await initialiseLocalNotifications();
      Logs().v('Flutter Local Notifications initialized');

      if (Platform.isAndroid) {
        PushLogBuffer.instance.i('Initializing UnifiedPush...');
        await UnifiedPush.initialize(
          onNewEndpoint: _newUpEndpoint,
          onRegistrationFailed: (_, i) {
            PushLogBuffer.instance.e('UnifiedPush registration FAILED! instance=$i');
            _upUnregistered(i);
          },
          onUnregistered: (i) {
            PushLogBuffer.instance.w('UnifiedPush unregistered! instance=$i');
            _upUnregistered(i);
          },
          onMessage: _onUpMessage,
        );
        PushLogBuffer.instance.i('UnifiedPush initialized');
      }
    } catch (e, s) {
      Logs().e('Unable to initialize Flutter local notifications', e, s);
    }
  }

  BackgroundPush._(this.clients) {
    _init();
  }

  factory BackgroundPush.clientOnly(Client client) {
    return _instance ??= BackgroundPush._([client]);
  }

  /// Reset the static singleton. Called when switching to the new push system
  /// to prevent the old instance's UnifiedPush callbacks from interfering.
  static void resetInstance() {
    _instance = null;
  }

  factory BackgroundPush(MatrixState matrix) {
    final instance = BackgroundPush.clientOnly(matrix.client);
    instance.matrix = matrix;
    return instance;
  }

  Future<void> cancelNotification(Client client, String roomId) async {
    Logs().v('Cancel notification for room', roomId);
    // Must use the SAME ID formula as push_helper where notifications are shown.
    await _flutterLocalNotificationsPlugin.cancel(id: '${client.clientName}_$roomId'.hashCode);

    // Workaround for app icon badge not updating
    if (Platform.isIOS) {
      final unreadCount = client.rooms
          .where((room) => room.isUnreadOrInvited && room.id != roomId)
          .length;
      if (unreadCount == 0) {
        FlutterNewBadger.removeBadge();
      } else {
        FlutterNewBadger.setBadge(unreadCount);
      }
      return;
    }
  }

  Future<void> setupPusher({
    String? gatewayUrl,
    String? token,
    Set<String?>? oldTokens,
    bool useDeviceSpecificAppId = false,
    required Client client,
  }) async {
    if (PlatformInfos.isAndroid) {
      _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.requestNotificationsPermission();
    }
    final clientName = PlatformInfos.clientName;
    oldTokens ??= <String>{};
    final pushers =
        await (client.getPushers().catchError((e) {
          Logs().w('[Push] Unable to request pushers', e);
          return <Pusher>[];
        })) ??
        [];
    var setNewPusher = false;
    // Just the plain app id, we add the .data_message suffix later
    var appId = AppConfig.pushNotificationsAppId;
    // we need the deviceAppId to remove potential legacy UP pusher
    var deviceAppId = '$appId.${client.deviceID}';
    // appId may only be up to 64 chars as per spec
    if (deviceAppId.length > 64) {
      deviceAppId = deviceAppId.substring(0, 64);
    }
    if (!useDeviceSpecificAppId && PlatformInfos.isAndroid) {
      appId += '.data_message';
    }
    final thisAppId = useDeviceSpecificAppId ? deviceAppId : appId;
    if (gatewayUrl != null && token != null) {
      // Always re-post the pusher on every app start. The homeserver can
      // silently expire/deactivate pushers without changing their parameters,
      // so checking for an exact match is not sufficient — we must force a
      // fresh registration to guarantee pushes keep working.
      oldTokens.add(token);
      if (client.isLogged()) {
        setNewPusher = true;
      }
    } else {
      Logs().w('[Push] Missing required push credentials');
    }
    for (final pusher in pushers) {
      if ((token != null &&
              pusher.pushkey != token &&
              deviceAppId == pusher.appId) ||
          oldTokens.contains(pusher.pushkey)) {
        try {
          await client.deletePusher(pusher);
          Logs().i('[Push] Removed legacy pusher for this device');
        } catch (err) {
          Logs().w('[Push] Failed to remove old pusher', err);
        }
      }
    }
    if (setNewPusher) {
      try {
        final tk = token!;
        PushLogBuffer.instance.i('Posting pusher: appId=$thisAppId, pushkey=${tk.length > 20 ? tk.substring(0, 20) : tk}...');
        await client.postPusher(
          Pusher(
            pushkey: tk,
            appId: thisAppId,
            appDisplayName: clientName,
            deviceDisplayName: client.deviceName!,
            lang: 'en',
            data: PusherData(
              url: Uri.parse(gatewayUrl!),
              format: AppSettings.pushNotificationsPusherFormat.value,
              additionalProperties: {"data_message": pusherDataMessageFormat},
            ),
            kind: 'http',
          ),
          append: false,
        );
      } catch (e, s) {
        PushLogBuffer.instance.e('Failed to post pusher: $e');
        Logs().e('[Push] Unable to set pushers', e, s);
      }
    } else {
      PushLogBuffer.instance.w('setNewPusher=false — no pusher posted');
    }
  }

  final pusherDataMessageFormat = Platform.isAndroid
      ? 'android'
      : Platform.isIOS
      ? 'ios'
      : null;

  static bool _wentToRoomOnStartup = false;

  Future<void> setupPush(List<Client> clients) async {
    PushLogBuffer.instance.i('setupPush() called with ${clients.length} clients');
    Logs().d("SetupPush called with ${clients.length} clients");
    this.clients = clients;

    {
      // migrate single client push settings to multiclient settings
      final endpoint = AppSettings.unifiedPushEndpoint.value;
      if (endpoint.isNotEmpty) {
        matrix!.store.setString(
          clients.first.clientName + AppSettings.unifiedPushEndpoint.key,
          endpoint,
        );
        matrix!.store.remove(AppSettings.unifiedPushEndpoint.key);
      }

      final registered = AppSettings.unifiedPushRegistered.value;

      matrix!.store.setBool(
        clients.first.clientName + AppSettings.unifiedPushRegistered.key,
        registered,
      );
      matrix!.store.remove(AppSettings.unifiedPushRegistered.key);
    }

    // Check if any client is logged in
    final anyLoggedIn = clients.any(
          (c) => c.onLoginStateChanged.value == LoginState.loggedIn,
        );
    Logs().d("Any client logged in: $anyLoggedIn");
    Logs().d("Is mobile: ${PlatformInfos.isMobile}");
    Logs().d("Matrix is null: ${matrix == null}");
    
    if (!anyLoggedIn || !PlatformInfos.isMobile || matrix == null) {
      PushLogBuffer.instance.w('setupPush early return: loggedIn=$anyLoggedIn, mobile=${PlatformInfos.isMobile}, matrix=${matrix != null}');
      Logs().w("SetupPush early return - not logged in or not mobile");
      return;
    }
    PushLogBuffer.instance.i('Setting up push notifications...');
    Logs().i("Setting up push notifications...");
    // DEBUG: print current UnifiedPush state so we can diagnose silent failures.
    await _logPushState();
    if (!PlatformInfos.isIOS &&
        (await UnifiedPush.getDistributors()).isNotEmpty) {
      // Check if saved distributor exists but endpoint is invalid (post-reset scenario)
      // This forces the distributor picker to show again if push stopped working
      final savedDistributor = await UnifiedPush.getDistributor();
      
      // Check if we have an endpoint for any logged-in client
      var hasValidEndpoint = false;
      for (final client in clients) {
        if (client.isLogged()) {
          final storedEndpoint = matrix?.store.getString(
            client.clientName + AppSettings.unifiedPushEndpoint.key,
          );
          if (storedEndpoint != null && storedEndpoint.isNotEmpty) {
            hasValidEndpoint = true;
            break;
          }
        }
      }
      
      // If no valid endpoint found, or no saved distributor, force re-setup
      if (!hasValidEndpoint || savedDistributor == null || savedDistributor.isEmpty) {
        Logs().i('[Push] Post-reset or missing registration detected, clearing to force re-setup');
        await UnifiedPush.saveDistributor('');  // Clear to force picker
      }
      await setupUp();
    } else {
      Logs().i('[Push] No UnifiedPush distributors available on this device');
    }

    // ignore: unawaited_futures
    _flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails().then((
      details,
    ) {
      if (details == null ||
          !details.didNotificationLaunchApp ||
          _wentToRoomOnStartup) {
        return;
      }
      _wentToRoomOnStartup = true;
      final response = details.notificationResponse;
      if (response != null) {
        notificationTap(
          response,
          clients: clients,
          router: PluslyApp.router,
          l10n: l10n,
        );
      }
    });
  }

  Future<void> _logPushState() async {
    try {
      final distributors = await UnifiedPush.getDistributors();
      final savedDistributor = await UnifiedPush.getDistributor();
      PushLogBuffer.instance.i('Distributors: $distributors');
      PushLogBuffer.instance.i('Saved distributor: $savedDistributor');
      Logs().i('[Push] Distributors: $distributors');
      Logs().i('[Push] Saved distributor: $savedDistributor');
      for (final client in clients.where((c) => c.isLogged())) {
        final endpoint = matrix?.store.getString(
          client.clientName + AppSettings.unifiedPushEndpoint.key,
        );
        final registered = matrix?.store.getBool(
          client.clientName + AppSettings.unifiedPushRegistered.key,
        );
        PushLogBuffer.instance.i(
          'Client ${client.clientName}: endpoint=${endpoint != null && endpoint.isNotEmpty ? "${endpoint.substring(0, (endpoint.length > 20 ? 20 : endpoint.length))}..." : "none"}, registered=$registered',
        );
        Logs().i(
          '[Push] Client ${client.clientName}: endpoint=${endpoint ?? 'none'}, registered=$registered',
        );
      }
    } catch (e, s) {
      PushLogBuffer.instance.e('Failed to log push state: $e');
      Logs().w('[Push] Failed to log push state', e, s);
    }
  }

  Future<void> setupUp() async {
    final distributors = await UnifiedPush.getDistributors();
    PushLogBuffer.instance.i('setupUp() called. distributors=$distributors');
    if (distributors.isEmpty) {
      PushLogBuffer.instance.w('setupUp() — no distributors found');
      Logs().i('[Push] No UnifiedPush distributors found');
      return;
    }

    // Check if a distributor is already saved — Extera pattern.
    // Always re-register with UnifiedPush on every app start, even if we
    // already have an endpoint stored. The pusher on the homeserver can
    // expire, and without re-registration pushes silently stop.
    final savedDistributor = await UnifiedPush.getDistributor();
    if (savedDistributor != null && savedDistributor.isNotEmpty) {
      PushLogBuffer.instance.i('Saved distributor: $savedDistributor');
      Logs().i('[Push] Using saved UnifiedPush distributor: $savedDistributor');
      for (final client in clients) {
        if (client.isLogged()) {
          await UnifiedPush.register(instance: client.clientName);
        }
      }

      // CRITICAL: UnifiedPush.register() may return the existing endpoint
      // without triggering _newUpEndpoint if Ntfy still considers it valid.
      // But the pusher on the Matrix homeserver can expire independently.
      // Always re-register the pusher with the homeserver using the stored
      // endpoint to prevent silent push failures.
      for (final client in clients) {
        if (!client.isLogged()) continue;
        final storedEndpoint = matrix?.store.getString(
          client.clientName + AppSettings.unifiedPushEndpoint.key,
        );
        if (storedEndpoint != null && storedEndpoint.isNotEmpty) {
          // Use the same gateway detection logic as _newUpEndpoint
          var gatewayUrl = 'https://matrix.gateway.unifiedpush.org/_matrix/push/v1/notify';
          try {
            final url = Uri.parse(storedEndpoint)
                .replace(path: '/_matrix/push/v1/notify', query: '')
                .toString()
                .split('?')
                .first;
            final res = json.decode(
              utf8.decode((await http.get(Uri.parse(url))).bodyBytes),
            );
            if (res['gateway'] == 'matrix' ||
                (res['unifiedpush'] is Map &&
                    res['unifiedpush']['gateway'] == 'matrix')) {
              gatewayUrl = url;
            }
          } catch (_) {
            // Fall back to default gateway
          }
          Logs().i('[Push] Re-registering pusher for ${client.clientName} via $gatewayUrl');
          PushLogBuffer.instance.i('Re-registering pusher for ${client.clientName} via $gatewayUrl');
          await setupPusher(
            gatewayUrl: gatewayUrl,
            token: storedEndpoint,
            useDeviceSpecificAppId: true,
            client: client,
          );
        } else {
          // Stored endpoint is empty (e.g. after clean reinstall).
          PushLogBuffer.instance.w('No stored endpoint for ${client.clientName}, forcing unregister+register');
          Logs().i('[Push] No stored endpoint for ${client.clientName}, forcing re-registration');
          await UnifiedPush.unregister(client.clientName);
          await UnifiedPush.register(instance: client.clientName);
        }
      }
      return;
    }
    
    String selectedDistributor;
    if (distributors.length == 1) {
      selectedDistributor = distributors.first;
    } else {
      // Multiple distributors: show a picker dialog
      final dialogContext =
          PluslyApp.router.routerDelegate.navigatorKey.currentContext ??
          matrix!.context;

      if (!dialogContext.mounted) {
        Logs().w('[Push] Context not mounted, cannot show distributor picker');
        // Fallback: use the first distributor
        selectedDistributor = distributors.first;
      } else {
        await loadLocale();
        final picked = await showDialog<String>(
          context: dialogContext,
          builder: (context) => AlertDialog(
            title: Text(
              l10n?.selectPushDistributor ?? 'Select push distributor',
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: distributors
                  .map(
                    (d) => ListTile(
                      title: Text(
                        d.split('.').last[0].toUpperCase() +
                            d.split('.').last.substring(1),
                      ),
                      subtitle: Text(d),
                      onTap: () => Navigator.of(context).pop(d),
                    ),
                  )
                  .toList(),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(l10n?.cancel ?? 'Cancel'),
              ),
            ],
          ),
        );

        if (picked != null) {
          selectedDistributor = picked;
        } else {
          // User dismissed the dialog - use the first distributor as fallback
          Logs().i(
            '[Push] User dismissed distributor picker, using first available',
          );
          selectedDistributor = distributors.first;
        }
      }
    }

    Logs().i('[Push] Saving UnifiedPush distributor: $selectedDistributor');
    await UnifiedPush.saveDistributor(selectedDistributor);
    
    // Check if we already have an endpoint for any client
    for (final client in clients) {
      if (client.isLogged()) {
        final endpoint = matrix?.store.getString(
          client.clientName + AppSettings.unifiedPushEndpoint.key,
        );
        if (endpoint != null && endpoint.isNotEmpty) {
          // Re-register pusher with existing endpoint
          await setupPusher(
            gatewayUrl: 'https://matrix.gateway.unifiedpush.org/_matrix/push/v1/notify',
            token: endpoint,
            useDeviceSpecificAppId: true,
            client: client,
          );
        } else {
          await UnifiedPush.register(instance: client.clientName);
        }
      }
    }
  }

  Future<void> _newUpEndpoint(PushEndpoint newPushEndpoint, String i) async {
    PushLogBuffer.instance.i('📡 _newUpEndpoint() called! url=${newPushEndpoint.url}');
    final newEndpoint = newPushEndpoint.url;
    upAction = true;
    if (newEndpoint.isEmpty) {
      await _upUnregistered(i);
      return;
    }
    var endpoint =
        'https://matrix.gateway.unifiedpush.org/_matrix/push/v1/notify';
    try {
      final url = Uri.parse(newEndpoint)
          .replace(path: '/_matrix/push/v1/notify', query: '')
          .toString()
          .split('?')
          .first;
      final res = json.decode(
        utf8.decode((await http.get(Uri.parse(url))).bodyBytes),
      );
      if (res['gateway'] == 'matrix' ||
          (res['unifiedpush'] is Map &&
              res['unifiedpush']['gateway'] == 'matrix')) {
        endpoint = url;
      }
    } catch (e) {
      Logs().i(
        '[Push] No self-hosted unified push gateway present: $newEndpoint',
      );
    }
    Logs().i('[Push] UnifiedPush using endpoint $endpoint');
    // Register a pusher for every logged-in client using this endpoint.
    for (final client in clients.where((c) => c.isLogged())) {
      await setupPusher(
        gatewayUrl: endpoint,
        token: newEndpoint,
        useDeviceSpecificAppId: true,
        client: client,
      );
      await matrix?.store.setString(
        client.clientName + AppSettings.unifiedPushEndpoint.key,
        newEndpoint,
      );
      await matrix?.store.setBool(
        client.clientName + AppSettings.unifiedPushRegistered.key,
        true,
      );
    }
  }

  Future<void> _upUnregistered(String i) async {
    upAction = true;
    final client = clientFromInstance(i, clients);
    if (client == null) {
      Logs().w('[Push] Could not find client for instance $i');
      return;
    }
    Logs().i(
      '[Push] Removing UnifiedPush endpoint for ${client.clientName}...',
    );
    final endpointKey = client.clientName + AppSettings.unifiedPushEndpoint.key;
    final registeredKey =
        client.clientName + AppSettings.unifiedPushRegistered.key;
    final oldEndpoint = matrix?.store.getString(endpointKey) ?? '';
    await matrix?.store.setString(endpointKey, '');
    await matrix?.store.setBool(registeredKey, false);
    if (oldEndpoint.isNotEmpty) {
      // remove the old pusher
      await setupPusher(oldTokens: {oldEndpoint}, client: client);
    }
  }

  Future<void> _onUpMessage(PushMessage pushMessage, String i) async {
    PushLogBuffer.instance.i('🔥 _onUpMessage() called! instance=$i');
    Logs().i('Push Notification from UP received', pushMessage);
    final message = pushMessage.content;
    upAction = true;
    final data = Map<String, dynamic>.from(
      json.decode(utf8.decode(message))['notification'],
    );
    // UP may strip the devices list
    data['devices'] ??= [];
    await pushHelper(
      PushNotification.fromJson(data),
      clients: clients,
      l10n: l10n,
      activeRoomId: matrix?.activeRoomId,
      activeClient: clientFromInstance(i, clients),
      flutterLocalNotificationsPlugin: _flutterLocalNotificationsPlugin,
      instance: i,
      useNotificationActions:
          true, // mark-as-read works fine with UP; only reply-input is buggy (#34)
      includeReplyAction: false, // UP connector bug with reply input (codeberg #34)
    );

    // NOTE: Do NOT trigger another sync here.
    // `pushHelper` already handles abortSync + oneShotSync internally,
    // including restoring backgroundSync when needed.
    // A second abortSync here can race with the first and corrupt
    // room/event state, causing wrong notification content.
  }
}

Client? clientFromInstance(String? instance, List<Client> clients) {
  for (final c in clients) {
    if (c.clientName == instance) {
      return c;
    }
  }
  // Fallback to first client — matches Extera behaviour.
  // Without this, instance name mismatches silently drop pushes.
  return clients.isNotEmpty ? clients.first : null;
}
