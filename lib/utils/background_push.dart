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

import 'package:collection/collection.dart';

import 'package:flutter/foundation.dart';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_new_badger/flutter_new_badger.dart';
import 'package:http/http.dart' as http;
import 'package:matrix/matrix.dart';
import 'package:unifiedpush/unifiedpush.dart';
import 'package:unifiedpush_ui/unifiedpush_ui.dart';

import 'package:Pulsly/generated/l10n/l10n.dart';
import 'package:Pulsly/main.dart';

import 'package:Pulsly/utils/notification_background_handler.dart';
import 'package:Pulsly/utils/push_helper.dart';
import 'package:Pulsly/widgets/plusly_app.dart';
import '../config/app_config.dart';
import '../config/setting_keys.dart';
import '../widgets/matrix.dart';
import 'platform_infos.dart';

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
      final currentPushers = pushers.where((pusher) => pusher.pushkey == token);
      if (currentPushers.length == 1 &&
          currentPushers.first.kind == 'http' &&
          currentPushers.first.appId == thisAppId &&
          currentPushers.first.appDisplayName == clientName &&
          currentPushers.first.deviceDisplayName == client.deviceName &&
          currentPushers.first.lang == 'en' &&
          currentPushers.first.data.url.toString() == gatewayUrl &&
          currentPushers.first.data.format ==
              AppSettings.pushNotificationsPusherFormat.value &&
          mapEquals(currentPushers.single.data.additionalProperties, {
            "client_name": client.clientName,
            "data_message": pusherDataMessageFormat,
          })) {
        Logs().i('[Push] Pusher already set');
      } else {
        Logs().i('Need to set new pusher');
        oldTokens.add(token);
        if (client.isLogged()) {
          setNewPusher = true;
        }
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
        await client.postPusher(
          Pusher(
            pushkey: token!,
            appId: thisAppId,
            appDisplayName: clientName,
            deviceDisplayName: client.deviceName!,
            lang: 'en',
            data: PusherData(
              url: Uri.parse(gatewayUrl!),
              format: AppSettings.pushNotificationsPusherFormat.value,
              // FluffyChat-pariteit (upstream background_push.dart r248-251):
              // `client_name` meeschrijven in de pusher. Upstream's
              // notificatie-ID wordt hieruit afgeleid
              // (PushNotification.clientName → devices[].data.client_name).
              // Plusly leidt het ID van de opgeloste client af, maar de
              // sleutel hoort desondanks op de pusher te staan: hij maakt de
              // pusher-vergelijking hierboven volledig en houdt de payload
              // gelijk aan upstream, zodat een later herstel van die route niet
              // stil op de roomId-fallback terugvalt.
              additionalProperties: {
                "client_name": client.clientName,
                "data_message": pusherDataMessageFormat,
              },
            ),
            kind: 'http',
          ),
          append: false,
        );
      } catch (e, s) {
        Logs().e('[Push] Unable to set pushers', e, s);
      }
    }
  }

  final pusherDataMessageFormat = Platform.isAndroid
      ? 'android'
      : Platform.isIOS
      ? 'ios'
      : null;

  static bool _wentToRoomOnStartup = false;

  Future<void> setupPush(List<Client> clients) async {
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

      // De registered-flag mag ALLEEN gemigreerd worden als hij echt bestaat.
      //
      // BUG (dit was de `endpoint=saved registered=false` in de statusdump):
      // AppSettings.unifiedPushRegistered.value geeft de DEFAULT (false)
      // terug zodra de globale sleutel ontbreekt — en die default werd hier
      // onvoorwaardelijk naar de per-client sleutel geschreven, waarna de
      // globale sleutel werd verwijderd. setupPush wordt op vier plaatsen
      // aangeroepen, waaronder ELKE login-state-overgang (matrix.dart r284),
      // terwijl `true` alleen door _newUpEndpoint gezet wordt. Elke volgende
      // aanroep overschreef de vlag dus met false en niets zette hem terug.
      // De flag is puur diagnostisch — nergens een guard, alleen logging —
      // dus push bleef werken, maar de statusdump loog, en dat is precies
      // het instrument waarmee het koude-start-gat beoordeeld wordt.
      //
      // store.getBool geeft null als de sleutel ONTBREEKT, waardoor afwezig
      // van false te onderscheiden is. Zelfde patroon als de bestaande
      // migraties in setting_keys.dart r162.
      final registered = matrix!.store.getBool(
        AppSettings.unifiedPushRegistered.key,
      );
      if (registered != null) {
        matrix!.store.setBool(
          clients.first.clientName + AppSettings.unifiedPushRegistered.key,
          registered,
        );
        matrix!.store.remove(AppSettings.unifiedPushRegistered.key);
      }
    }

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
    // Register a pusher only for the client matching this UnifiedPush instance.
    final client = clientFromInstance(i, clients) ?? clients.firstWhereOrNull(
      (c) => c.isLogged(),
    );
    if (client == null) {
      Logs().w('[Push] No logged-in client for instance $i');
      return;
    }
    final oldTokens = <String?>{};
    try {
      //<GOOGLE_SERVICES>final fcmToken = await firebase.getToken();
      //<GOOGLE_SERVICES>oldTokens.add(fcmToken);
    } catch (_) {}
    await setupPusher(
      gatewayUrl: endpoint,
      token: newEndpoint,
      oldTokens: oldTokens,
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
    final message = pushMessage.content;
    upAction = true;
    final data = Map<String, dynamic>.from(
      json.decode(utf8.decode(message))['notification'],
    );
    // UP may strip the devices list
    data['devices'] ??= [];
    await PushHelper.pushHelper(
      PushNotification.fromJson(data),
      clients: clients,
      l10n: l10n,
      activeRoomId: matrix?.activeRoomId,
      flutterLocalNotificationsPlugin: _flutterLocalNotificationsPlugin,
      instance: i,
    );
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
