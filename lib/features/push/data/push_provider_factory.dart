import 'dart:io';

import 'package:matrix/matrix.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../domain/push_provider.dart';
import '../domain/push_state.dart';
import 'unified_push_provider.dart';
import 'firebase_push_provider.dart';
import '../../../config/feature_flags.dart';

/// Factory die het juiste push provider kiest met fallback logica:
///
/// 1. UnifiedPush (als beschikbaar)
/// 2. Firebase Cloud Messaging (fallback)
/// 3. null (geen push mogelijk)
class PushProviderFactory {
  final SharedPreferences _store;
  final List<Client> _clients;

  PushProviderFactory(this._store, this._clients);

  /// Maak provider met automatische fallback.
  /// Returnt [PushProviderResult] met gekozen provider of error.
  Future<PushProviderResult> createWithFallback() async {
    // ─── Stap 1: Probeer UnifiedPush ───
    if (Platform.isAndroid) {
      final up = UnifiedPushProvider(_store, _clients);

      if (up.isAvailable) {
        final initialized = await up.initialize();
        if (initialized) {
          final token = await up.register();

          // Wacht even op async endpoint callback
          await Future.delayed(const Duration(milliseconds: 500));

          if (up.isActive) {
            return PushProviderResult.success(up, PushProviderType.unifiedPush);
          }
        }
        up.dispose();
      }
    }

    // ─── Stap 2: Fallback naar Firebase (alleen als feature flag aan staat) ───
    if (FeatureFlags.useFirebase) {
      final fcm = FirebasePushProvider(_store, _clients);
      final fcmInitialized = await fcm.initialize();

      if (fcmInitialized) {
        final token = await fcm.register();
        if (token != null && fcm.isActive) {
          return PushProviderResult.success(fcm, PushProviderType.firebase);
        }
      }
      fcm.dispose();
    }

    // ─── Stap 3: Niets werkte ───
    return PushProviderResult.failure('Geen push provider beschikbaar');
  }

  /// Maak specifieke provider (voor manual override in settings)
  PushProvider createProvider(PushProviderType type) {
    switch (type) {
      case PushProviderType.unifiedPush:
        return UnifiedPushProvider(_store, _clients);
      case PushProviderType.firebase:
        return FirebasePushProvider(_store, _clients);
      case PushProviderType.none:
        throw ArgumentError('Cannot create provider for type "none"');
    }
  }
}

class PushProviderResult {
  final PushProvider? provider;
  final PushProviderType? type;
  final String? error;
  final bool isSuccess;

  PushProviderResult._({
    this.provider,
    this.type,
    this.error,
    required this.isSuccess,
  });

  factory PushProviderResult.success(PushProvider provider, PushProviderType type) {
    return PushProviderResult._(
      provider: provider,
      type: type,
      isSuccess: true,
    );
  }

  factory PushProviderResult.failure(String error) {
    return PushProviderResult._(
      error: error,
      isSuccess: false,
    );
  }
}
