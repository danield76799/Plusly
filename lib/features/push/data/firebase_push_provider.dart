import 'dart:async';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:matrix/matrix.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../domain/push_provider.dart';
import '../../../config/app_config.dart';
import '../../../utils/platform_infos.dart';

/// Firebase Cloud Messaging fallback provider.
///
/// Werkt op alle platforms, vereist Google Play Services.

/// Top-level background message handler voor Firebase.
/// Moet top-level zijn met @pragma('vm:entry-point') voor firebase_messaging >=15.x.
@pragma('vm:entry-point')
Future<void> firebaseBackgroundMessageHandler(RemoteMessage message) async {
  Logs().v('[FirebasePush] Background message: ${message.messageId}');
  // Background messages worden afgehandeld door het systeem
  // We kunnen hier geen stream gebruiken omdat dit in een isolate draait
}

class FirebasePushProvider implements PushProvider {
  final SharedPreferences _store;
  final List<Client> _clients;
  final _messageController = StreamController<PushMessage>.broadcast();
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  bool _isActive = false;
  String? _currentToken;

  @override
  String get id => 'firebase';

  @override
  String get displayName => 'Firebase Cloud Messaging';

  @override
  bool get isAvailable => true; // Overal beschikbaar als fallback

  @override
  bool get isActive => _isActive;

  FirebasePushProvider(this._store, this._clients);

  @override
  Future<bool> initialize() async {
    try {
      // Vraag notificatie permissie (vereist voor iOS)
      if (Platform.isIOS) {
        final settings = await _fcm.requestPermission(
          alert: true,
          badge: true,
          sound: true,
        );
        Logs().i('[FirebasePush] Permission status: ${settings.authorizationStatus}');
      }

      // Luister naar FCM messages
      FirebaseMessaging.onMessage.listen(_onForegroundMessage);
      FirebaseMessaging.onBackgroundMessage(firebaseBackgroundMessageHandler);

      // Luister naar token refreshes
      _fcm.onTokenRefresh.listen(_onTokenRefresh);

      return true;
    } catch (e, s) {
      Logs().e('[FirebasePush] Init failed', e, s);
      return false;
    }
  }

  @override
  Future<String?> register() async {
    try {
      final token = await _fcm.getToken();
      if (token == null || token.isEmpty) {
        Logs().w('[FirebasePush] No token received');
        return null;
      }

      _currentToken = token;
      Logs().i('[FirebasePush] Token received: ${token.substring(0, 20)}...');

      // Registreer token bij alle ingelogde clients
      for (final client in _clients.where((c) => c.isLogged())) {
        await _setupPusher(client, token);
      }

      _isActive = true;
      return token;
    } catch (e, s) {
      Logs().e('[FirebasePush] Registration failed', e, s);
      return null;
    }
  }

  @override
  Future<void> unregister() async {
    try {
      // Verwijder token van FCM
      await _fcm.deleteToken();

      // Verwijder pusher van alle clients
      if (_currentToken != null) {
        for (final client in _clients.where((c) => c.isLogged())) {
          await _removePusher(client, _currentToken!);
        }
      }

      _currentToken = null;
      _isActive = false;
      Logs().i('[FirebasePush] Unregistered');
    } catch (e, s) {
      Logs().e('[FirebasePush] Unregister failed', e, s);
    }
  }

  @override
  Stream<PushMessage> get messageStream => _messageController.stream;

  @override
  void dispose() {
    _messageController.close();
  }

  // ─── Interne handlers ───

  void _onForegroundMessage(RemoteMessage message) {
    Logs().v('[FirebasePush] Foreground message: ${message.messageId}');
    _handleRemoteMessage(message);
  }

  void _onTokenRefresh(String token) {
    Logs().i('[FirebasePush] Token refreshed');
    _currentToken = token;

    // Re-registreer bij alle clients
    for (final client in _clients.where((c) => c.isLogged())) {
      _setupPusher(client, token);
    }
  }

  void _handleRemoteMessage(RemoteMessage message) {
    final data = message.data;
    if (data.isEmpty) return;

    _messageController.add(PushMessage(
      roomId: data['room_id'] ?? '',
      eventId: data['event_id'] ?? '',
      sender: data['sender'] ?? '',
      body: data['body'] ?? message.notification?.body ?? '',
      source: PushProviderType.firebase,
      receivedAt: DateTime.now(),
      unreadCount: int.tryParse(data['unread']?.toString() ?? ''),
      clientName: data['client_name'],
    ));
  }

  // ─── Pusher setup ───

  Future<void> _setupPusher(Client client, String token) async {
    try {
      final gatewayUrl = 'https://matrix.gateway.unifiedpush.org/_matrix/push/v1/notify';
      final appId = '${AppConfig.appId}.data_message';

      await client.postPusher(
        Pusher(
          pushkey: token,
          appId: appId.substring(0, appId.length > 64 ? 64 : appId.length),
          appDisplayName: PlatformInfos.clientName,
          deviceDisplayName: client.deviceName ?? 'Plusly',
          lang: 'en',
          data: PusherData(
            url: Uri.parse(gatewayUrl),
            format: 'event_id_only',
          ),
          kind: 'http',
        ),
        append: false,
      );

      Logs().i('[FirebasePush] Pusher set for ${client.clientName}');
    } catch (e, s) {
      Logs().e('[FirebasePush] Failed to set pusher', e, s);
    }
  }

  Future<void> _removePusher(Client client, String token) async {
    try {
      final pushers = await client.getPushers().catchError((e) {
        Logs().w('[FirebasePush] Unable to get pushers', e);
        return <Pusher>[];
      });
      if (pushers != null) {
        final pusher = pushers.firstWhereOrNull((p) => p.pushkey == token);
        if (pusher != null) {
          await client.deletePusher(pusher);
          Logs().i('[FirebasePush] Pusher removed for ${client.clientName}');
        }
      }
    } catch (e, s) {
      Logs().e('[FirebasePush] Failed to remove pusher', e, s);
    }
  }
}
