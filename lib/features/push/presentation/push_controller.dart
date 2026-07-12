import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:matrix/matrix.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../domain/push_provider.dart';
import '../domain/push_state.dart';
import '../data/push_provider_factory.dart';
import '../domain/deduplicator.dart';
import '../../../utils/push_helper.dart';
import 'notification_router.dart';

/// Centrale controller voor push notifications.
///
/// Gebruik:
/// ```dart
/// final controller = PushController(store, clients);
/// await controller.initialize(); // Probeer UP, fallback naar FCM
/// ```
///
/// Of voor legacy compatibiliteit:
/// ```dart
/// if (FeatureFlags.useNewPushSystem) {
///   await pushController.initialize();
/// } else {
///   // Oude BackgroundPush blijft werken
/// }
/// ```
class PushController extends ChangeNotifier {
  final SharedPreferences _store;
  final List<Client> _clients;
  final FlutterLocalNotificationsPlugin _notificationsPlugin;

  PushState _state = const PushState.initial();
  PushProvider? _activeProvider;
  String? _activeRoomId;
  Client? _activeClient;
  final _deduplicator = PushDeduplicator();

  PushController(
    this._store,
    this._clients, {
    FlutterLocalNotificationsPlugin? notificationsPlugin,
  }) : _notificationsPlugin = notificationsPlugin ?? FlutterLocalNotificationsPlugin();

  // ─── Public API ───

  PushState get state => _state;
  PushProvider? get activeProvider => _activeProvider;
  bool get isActive => _state.isActive;

  /// Set active room/client for foreground detection
  void setActiveRoom(String? roomId, Client? client) {
    _activeRoomId = roomId;
    _activeClient = client;
  }

  /// Initialiseer push met automatische fallback:
  /// 1. UnifiedPush (als beschikbaar)
  /// 2. Firebase Cloud Messaging (fallback)
  /// 3. Failed (als niets werkt)
  Future<void> initialize() async {
    _setState(_state.copyWith(status: PushStatus.initializing));

    final factory = PushProviderFactory(_store, _clients);
    final result = await factory.createWithFallback();

    if (result.isSuccess && result.provider != null) {
      _activeProvider = result.provider;
      _activeProvider!.messageStream.listen(
        _handleMessage,
        onError: (e, s) => Logs().e('[PushController] Message stream error', e, s),
      );
      _setState(PushState(
        status: PushStatus.active,
        activeProvider: result.type,
      ));
      Logs().i('[PushController] Active provider: ${result.type?.name}');
    } else {
      _setState(PushState(
        status: PushStatus.failed,
        errorMessage: result.error ?? 'Onbekende fout',
      ));
      Logs().w('[PushController] Failed: ${result.error}');
    }
  }

  /// Handmatig switchen naar specifieke provider (voor settings UI)
  Future<void> switchProvider(PushProviderType type) async {
    // De-activeer huidige
    if (_activeProvider != null) {
      await _activeProvider!.unregister();
      _activeProvider!.dispose();
      _activeProvider = null;
    }

    if (type == PushProviderType.none) {
      _setState(const PushState(status: PushStatus.disabled));
      return;
    }

    // Activeer nieuwe
    final factory = PushProviderFactory(_store, _clients);
    final newProvider = factory.createProvider(type);

    final initialized = await newProvider.initialize();
    if (!initialized) {
      _setState(PushState(
        status: PushStatus.failed,
        errorMessage: 'Kon $type niet initialiseren',
      ));
      newProvider.dispose();
      return;
    }

    final token = await newProvider.register();
    if (token != null || newProvider.isActive) {
      _activeProvider = newProvider;
      _activeProvider!.messageStream.listen(_handleMessage);
      _setState(PushState(
        status: PushStatus.active,
        activeProvider: type,
      ));
    } else {
      _setState(PushState(
        status: PushStatus.failed,
        errorMessage: 'Registratie mislukt voor $type',
      ));
      newProvider.dispose();
    }
  }

  /// Verwerk inkomende push message
  void _handleMessage(PushMessage message) {
    Logs().v('[PushController] Message received: $message');

    // Deduplicatie: check of we deze al hebben gehad
    if (_deduplicator.isDuplicate(message.eventId)) {
      Logs().v('[PushController] Duplicate message ignored: ${message.eventId}');
      return;
    }

    // Converteer naar Matrix PushNotification format
    final notification = PushNotification.fromJson({
      'room_id': message.roomId,
      'event_id': message.eventId,
      'sender': message.sender,
      'content': {'body': message.body},
      'counts': {'unread': message.unreadCount},
      'devices': [],
    });

    // Gebruik bestaande PushHelper voor notificatie weergave
    pushHelper(
      notification,
      clients: _clients,
      activeRoomId: _activeRoomId,
      activeClient: _activeClient,
      flutterLocalNotificationsPlugin: _notificationsPlugin,
      instance: message.clientName,
    );
  }

  /// Initialiseer lokale notificaties (voor Android/iOS)
  Future<void> initializeLocalNotifications() async {
    await _notificationsPlugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('notifications_icon'),
        iOS: DarwinInitializationSettings(),
      ),
      onDidReceiveNotificationResponse: NotificationRouter.onTap,
      onDidReceiveBackgroundNotificationResponse: NotificationRouter.onBackgroundTap,
    );

    // Vraag notificatie permission op Android 13+ (API 33)
    if (Platform.isAndroid) {
      await _notificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.requestNotificationsPermission();
    }
  }

  /// Her-registreer bij alle ingelogde clients (bv. na login).
  /// Werkt alleen als er al een actieve provider is.
  Future<void> reRegister() async {
    if (_activeProvider == null) {
      Logs().w('[PushController] reRegister called but no active provider');
      // Probeer opnieuw te initialiseren
      await initialize();
      return;
    }
    Logs().i('[PushController] Re-registering push for logged-in clients');
    final token = await _activeProvider!.register();
    if (token != null || _activeProvider!.isActive) {
      Logs().i('[PushController] Re-registration successful');
    } else {
      Logs().w('[PushController] Re-registration failed');
    }
  }

  /// Cleanup
  @override
  void dispose() {
    _activeProvider?.unregister();
    _activeProvider?.dispose();
    _activeProvider = null;
    NotificationRouter.dispose();
    super.dispose();
  }

  // ─── Intern ───

  void _setState(PushState newState) {
    _state = newState;
    notifyListeners();
  }
}
