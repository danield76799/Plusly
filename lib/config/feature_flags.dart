import 'package:shared_preferences/shared_preferences.dart';

/// Feature flags voor veilige rollout van nieuwe features.
/// 
/// Alle flags default naar FALSE — nieuwe code is opt-in.
/// 
/// Gebruik:
/// ```dart
/// if (FeatureFlags.useNewPushSystem) {
///   // Nieuwe push code
/// } else {
///   // Legacy push code (default, veilig)
/// }
/// ```
abstract class FeatureFlags {
  static SharedPreferences? _prefs;
  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) return;
    _prefs = await SharedPreferences.getInstance();
    _initialized = true;
  }

  static SharedPreferences get _requirePrefs {
    if (!_initialized) {
      throw StateError(
        'FeatureFlags niet geinitialiseerd. Roep FeatureFlags.init() aan in main()',
      );
    }
    return _prefs!;
  }

  // ─────────────────────────────────────────────
  // Push Notification Feature Flag
  // ─────────────────────────────────────────────

  static const String _kUseNewPush = 'ff_use_new_push_v2';

  /// Nieuwe push architectuur (default: false = legacy)
  static bool get useNewPushSystem {
    return _requirePrefs.getBool(_kUseNewPush) ?? false;
  }

  static set useNewPushSystem(bool value) {
    _requirePrefs.setBool(_kUseNewPush, value);
  }

  /// Toggle push systeem (voor settings UI)
  static Future<bool> toggleNewPushSystem() async {
    final newValue = !useNewPushSystem;
    await _requirePrefs.setBool(_kUseNewPush, newValue);
    return newValue;
  }

  // ─────────────────────────────────────────────
  // Debug / Test helpers
  // ─────────────────────────────────────────────

  static const String _kShadowMode = 'ff_push_shadow_mode';

  /// Shadow mode: nieuwe push draait parallel maar niet actief
  /// Logt verschillen voor debugging (default: false)
  static bool get pushShadowMode {
    return _requirePrefs.getBool(_kShadowMode) ?? false;
  }

  static set pushShadowMode(bool value) {
    _requirePrefs.setBool(_kShadowMode, value);
  }

  /// Reset alle feature flags (voor testing)
  static Future<void> resetAll() async {
    await _requirePrefs.remove(_kUseNewPush);
    await _requirePrefs.remove(_kShadowMode);
  }
}
