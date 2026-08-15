import 'package:matrix/matrix.dart';

/// Globale hulp voor foreground-room detectie.
///
/// De router-based activeRoomId is niet altijd betrouwbaar (bijv. na een
/// lifecycle transition, op bepaalde schermformaten, of als de push handler
/// wordt aangeroepen door het legacy BackgroundPush-systeem dat geen
/// router-listener heeft). Daarom houdt de zichtbare ChatPage zelf bij welke
/// room op dit moment actief is.
class VisibleRoom {
  static String? _current;
  static DateTime? _since;

  static String? get current => _current;

  static void set(String? roomId) {
    _current = roomId;
    _since = roomId != null ? DateTime.now() : null;
    Logs().v('[VisibleRoom] set to $roomId');
  }

  static void clear() {
    _current = null;
    _since = null;
    Logs().v('[VisibleRoom] cleared');
  }

  /// True als de gegeven roomId op dit moment zichtbaar is.
  /// Vergeet na 60 seconden geen update — dan gaan we ervan uit dat de
  /// ChatPage niet meer actief is (bijv. app gecrasht zonder dispose).
  static bool isVisible(String? roomId) {
    if (roomId == null || _current == null) return false;
    if (_current != roomId) return false;
    final since = _since;
    if (since == null) return false;
    if (DateTime.now().difference(since) > const Duration(seconds: 60)) {
      return false;
    }
    return true;
  }
}
