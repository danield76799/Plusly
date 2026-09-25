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

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_new_badger/flutter_new_badger.dart';
import 'package:http/http.dart' as http;
import 'package:matrix/matrix.dart';
import 'package:unifiedpush/unifiedpush.dart';
import 'package:unifiedpush_ui/unifiedpush_ui.dart';

import 'package:Pulsly/generated/l10n/l10n.dart';
import 'package:Pulsly/main.dart';

import 'package:Pulsly/utils/notification_background_handler.dart';
import 'package:Pulsly/utils/platform_infos.dart';
import 'package:Pulsly/utils/push_event_log.dart';
import 'package:Pulsly/utils/push_helper.dart';
import 'package:Pulsly/widgets/plusly_app.dart';
import '../config/app_config.dart';
import '../config/setting_keys.dart';
import '../widgets/matrix.dart';

class BackgroundPush {
  static BackgroundPush? _instance;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
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
    if (PlatformInfos.isAndroid) {
      _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
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
        // Zorg dat de log klaarstaat VÓÓR de eerste UP-callback binnen kan
        // komen; anders wist een eerste add() vanuit een koude start de
        // bewaarde geschiedenis.
        await PushEventLog().ensureLoaded();
        await UnifiedPush.initialize(
          onNewEndpoint: _newUpEndpoint,
          onRegistrationFailed: (_, i) => _upUnregistered(i),
          onUnregistered: _upUnregistered,
          onMessage: _onUpMessage,
        );
      }
    } catch (e, s) {
      Logs().e('Unable to initialize Flutter local notifications', e, s);
    }
  }

  BackgroundPush._(this.clients) {
    _init();
  }

  /// FluffyChat-pariteit (upstream background_push.dart r142-144): de
  /// clientOnly-factory neemt de HELE client-lijst. Plusly gaf hier eerder
  /// alleen `clients.first` door, waardoor een push voor een tweede account
  /// altijd de eerste client als "opgeloste" client kreeg.
  factory BackgroundPush.clientOnly(List<Client> clients) {
    return _instance ??= BackgroundPush._(clients);
  }

  /// Reset de static singleton. Aangeroepen bij het wisselen van push-systeem
  /// om te voorkomen dat callbacks van de oude instantie blijven hangen.
  static void resetInstance() {
    _instance = null;
  }

  factory BackgroundPush(MatrixState matrix) {
    final instance = BackgroundPush.clientOnly(matrix.widget.clients);
    instance.matrix = matrix;
    return instance;
  }

  Future<void> cancelNotification(Client client, String roomId) async {
    Logs().v('Cancel notification for room', roomId);
    // FluffyChat-pariteit: exact DEZELFDE ID-formule als push_helper's
    // show(). Twee formules voor hetzelfde kanaal betekenen dat een cancel de
    // getoonde melding nooit raakt (blijft staan), of juist de melding van een
    // ánder account wist.
    await _flutterLocalNotificationsPlugin.cancel(
      id: notificationIdFor(client.clientName, roomId),
    );

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
    required Client client,
    String? gatewayUrl,
    String? token,
  }) async {
    if (PlatformInfos.isIOS) {
      //<GOOGLE_SERVICES>await firebase.requestPermission();
    }
    if (PlatformInfos.isAndroid) {
      _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.requestNotificationsPermission();
    }
    final appDisplayName = PlatformInfos.clientName;

    final pushers =
        await (client.getPushers().catchError((e) {
          Logs().w('[Push] Unable to request pushers', e);
          return <Pusher>[];
        })) ??
        [];

    // we need the deviceAppId to remove potential legacy pusher
    var deviceAppId = '${AppConfig.pushNotificationsAppId}.${client.deviceID}';
    // appId may only be up to 64 chars as per spec
    if (deviceAppId.length > 64) {
      deviceAppId = deviceAppId.substring(0, 64);
    }
    final thisAppId = deviceAppId;
    if (gatewayUrl == null || token == null) {
      Logs().w('[Push] Missing required push credentials');
      return;
    }

    if (pushers.any(
      (currentPusher) =>
          currentPusher.pushkey == token &&
          currentPusher.data.additionalProperties["client_name"] ==
              client.clientName &&
          currentPusher.kind == 'http' &&
          currentPusher.appId == thisAppId &&
          currentPusher.appDisplayName == appDisplayName &&
          currentPusher.deviceDisplayName == client.deviceName &&
          currentPusher.lang == 'en' &&
          currentPusher.data.url.toString() == gatewayUrl &&
          currentPusher.data.format ==
              AppSettings.pushNotificationsPusherFormat.value &&
          currentPusher.data.additionalProperties['data_message'] ==
              pusherDataMessageFormat,
    )) {
      Logs().i('[Push] Pusher already set for ${client.deviceID}');
      return;
    }

    if (!client.isLogged()) return;

    final legacyPushers = pushers.where(
      (pusher) =>
          pusher.appId == thisAppId || // To migrate older app-id format:
          ((pusher.appId == 'chat.fluffy.fluffychat.data_message' ||
                  pusher.appId == 'chat.fluffy.fluffychat') &&
              pusher.pushkey == token),
    );
    for (final pusher in legacyPushers) {
      try {
        await client.deletePusher(pusher);
        Logs().i('[Push] Removed legacy pusher for ${client.deviceID}');
      } catch (err) {
        Logs().w(
          '[Push] Failed to remove old pusher for ${client.deviceID}',
          err,
        );
      }
    }

    Logs().i('Need to set new pusher for ${client.clientName}');
    try {
      await client.postPusher(
        Pusher(
          pushkey: token,
          appId: thisAppId,
          appDisplayName: appDisplayName,
          deviceDisplayName: PlatformInfos.clientName,
          lang: 'en',
          data: PusherData(
            url: Uri.parse(gatewayUrl),
            format: AppSettings.pushNotificationsPusherFormat.value,
            additionalProperties: {
              "client_name": client.clientName,
              "data_message": pusherDataMessageFormat,
            },
          ),
          kind: 'http',
        ),
        append: true,
      );
    } catch (e, s) {
      Logs().e('[Push] Unable to set pushers', e, s);
    }
  }

  final pusherDataMessageFormat = Platform.isAndroid;

  static bool _wentToRoomOnStartup = false;

  Future<void> setupPush(List<Client> clients) async {
    Logs().d("SetupPush called with ${clients.length} clients");
    this.clients = clients;

    // Check if any client is logged in
    final anyLoggedIn = clients.any(
          (c) => c.onLoginStateChanged.value == LoginState.loggedIn,
        );
    Logs().d("Any client logged in: $anyLoggedIn");
    Logs().d("Is mobile: ${PlatformInfos.isMobile}");
    Logs().d("Matrix is null: ${matrix == null}");
    
    if (!anyLoggedIn || !PlatformInfos.isMobile || matrix == null) {
      Logs().w("SetupPush early return - not logged in or not mobile");
      return;
    }
    final context = matrix?.context;
    if (PlatformInfos.isAndroid &&
        (await UnifiedPush.getDistributors()).isNotEmpty &&
        context != null &&
        context.mounted) {
      // FluffyChat-pariteit: gebruik de moderne UnifiedPushUi-API in plaats
      // van handmatig endpoint/registered-boekhouding. Deze aanpak laat het
      // volledige endpoint-beheer over aan unifiedpush_ui en de onNewEndpoint
      // callback, waardoor de `endpoint=saved / registered=false`-staat na een
      // re-login geen stille push-failure meer kan veroorzaken.
      await UnifiedPushUi(
        context: context,
        instances: clients
            .where((c) => c.isLogged())
            .map((c) => c.clientName)
            .toList(),
        unifiedPushFunctions: UPFunctions(),
        showNoDistribDialog: false,
        onNoDistribDialogDismissed: () {},
      ).registerAppWithDialog();
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

  Future<void> _newUpEndpoint(PushEndpoint newPushEndpoint, String i) async {
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
    // Upstream r402-408: registreer een pusher voor ELKE client, niet alleen
    // voor de client die matched met de UnifiedPush-instance-string. In
    // single-account is dat hetzelfde; in multi-account misten de overige
    // accounts anders hun pusher.
    for (final client in clients) {
      await setupPusher(
        client: client,
        gatewayUrl: endpoint,
        token: newEndpoint,
      );
    }
    await AppSettings.unifiedPushEndpoint.setItem(newEndpoint);
    await AppSettings.unifiedPushRegistered.setItem(true);
  }

  Future<void> _upUnregistered(String i) async {
    upAction = true;
    Logs().i('[Push] Removing UnifiedPush endpoint...');
    await AppSettings.unifiedPushEndpoint.setItem(
      AppSettings.unifiedPushEndpoint.defaultValue,
    );
    await AppSettings.unifiedPushRegistered.setItem(false);
  }

  Future<void> _onUpMessage(PushMessage pushMessage, String i) async {
    final message = pushMessage.content;
    upAction = true;
    final data = Map<String, dynamic>.from(
      json.decode(utf8.decode(message))['notification'],
    );
    // UP may strip the devices list
    data['devices'] ??= [];
    // Instrument (geen gedragswijziging): log dat we de raw push binnen hebben
    // VÓÓR we naar pushHelper gaan. Als pushHelper hangt/crasht zien we
    // in ieder geval 'push_received'.
    PushEventLog().add('push_received', {
      'instance': i,
      'room': data['room_id']?.toString() ?? '',
    });
    await PushHelper.pushHelper(
      PushNotification.fromJson(data),
      clients: clients,
      l10n: l10n,
      activeRoomId: matrix?.activeRoomId,
      flutterLocalNotificationsPlugin: _flutterLocalNotificationsPlugin,
      instance: i,
    );
    // Log dat pushHelper helemaal is afgerond (tonen of clearing).
    PushEventLog().add('push', {
      'instance': i,
      'room': data['room_id']?.toString() ?? '',
      'ts': DateTime.now().toIso8601String(),
    });
  }
}

class UPFunctions extends UnifiedPushFunctions {
  final List<String> features = [];

  @override
  Future<String?> getDistributor() async {
    return await UnifiedPush.getDistributor();
  }

  @override
  Future<List<String>> getDistributors() async {
    return await UnifiedPush.getDistributors(features);
  }

  @override
  Future<void> registerApp(String instance) async {
    await UnifiedPush.register(instance: instance, features: features);
  }

  @override
  Future<void> saveDistributor(String distributor) async {
    await UnifiedPush.saveDistributor(distributor);
  }
}

Client? clientFromInstance(String? instance, List<Client> clients) {
  for (final c in clients) {
    if (c.clientName == instance) {
      return c;
    }
  }
  return null;
}
