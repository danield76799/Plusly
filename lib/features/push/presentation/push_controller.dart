import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:matrix/matrix.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../domain/push_provider.dart';
import '../domain/push_state.dart';
import '../data/push_provider_factory.dart';

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

  PushState _state = const PushState.initial();
  PushProvider? _activeProvider;

  PushController(this._store, this._clients);

  // ─── Public API ───

  PushState get state => _state;
  PushProvider? get activeProvider => _activeProvider;
  bool get isActive => _state.isActive;

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

    // TODO: Deduplicatie
    // TODO: Check foreground room
    // TODO: Toon lokale notificatie

    // Voor nu: alleen loggen (shadow mode)
    // De legacy BackgroundPush handelt het echte werk af
  }

  /// Cleanup
  @override
  void dispose() {
    _activeProvider?.unregister();
    _activeProvider?.dispose();
    _activeProvider = null;
    super.dispose();
  }

  // ─── Intern ───

  void _setState(PushState newState) {
    _state = newState;
    notifyListeners();
  }
}
