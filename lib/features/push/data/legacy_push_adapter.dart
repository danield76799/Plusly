import 'dart:async';


import '../domain/push_provider.dart';

/// Adapter die de nieuwe [PushProvider] interface implementeert
/// door de **bestaande** [BackgroundPush] aan te roepen.
///
/// Zo kan de [PushController] met legacy code werken zonder
/// dat we BackgroundPush hoeven aan te passen.
///
/// ⚠️ Dit is een overgangsoplossing — uiteindelijk vervangen
/// door [UnifiedPushProvider].
class LegacyPushAdapter implements PushProvider {
  final dynamic _backgroundPush; // BackgroundPush instance

  @override
  String get id => 'legacy';

  @override
  String get displayName => 'Legacy (BackgroundPush)';

  @override
  bool get isAvailable => true;

  @override
  bool get isActive => _backgroundPush != null;

  LegacyPushAdapter(this._backgroundPush);

  @override
  Future<bool> initialize() async {
    // Legacy is al geïnitialiseerd door matrix.dart
    return _backgroundPush != null;
  }

  @override
  Future<String?> register() async {
    // Legacy registreert zichzelf
    return 'legacy_token';
  }

  @override
  Future<void> unregister() async {
    // Niet nodig voor legacy — wordt afgehandeld door dispose
  }

  @override
  Stream<PushMessage> get messageStream {
    // Legacy gebruikt geen stream — messages komen via callbacks
    // We returnen een lege stream
    return const Stream<PushMessage>.empty();
  }

  @override
  void dispose() {
    // Legacy cleanup gebeurt elders
  }
}
