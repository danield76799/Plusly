import 'dart:io';

import 'package:matrix/matrix.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../domain/push_provider.dart';
import '../domain/push_state.dart';
import 'unified_push_provider.dart';

/// Factory die de UnifiedPush provider kiest.
///
/// Alleen UnifiedPush — geen Firebase fallback.
class PushProviderFactory {
  final SharedPreferences _store;
  final List<Client> _clients;

  PushProviderFactory(this._store, this._clients);

  /// Maak provider met UnifiedPush.
  /// Returnt [PushProviderResult] met gekozen provider of error.
  Future<PushProviderResult> createWithFallback() async {
    // ─── UnifiedPush (Android only) ───
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

    // ─── Geen push mogelijk ───
    return PushProviderResult.failure(
      Platform.isAndroid
          ? 'Geen UnifiedPush distributor gevonden.\n'
              'Gebruik SunUP of ntfy.'
          : 'Push notificaties alleen beschikbaar op Android.',
    );
  }

  /// Maak specifieke provider (voor manual override in settings)
  PushProvider createProvider(PushProviderType type) {
    switch (type) {
      case PushProviderType.unifiedPush:
        return UnifiedPushProvider(_store, _clients);
      case PushProviderType.firebase:
      case PushProviderType.none:
        throw ArgumentError('Cannot create provider for type "$type"');
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
