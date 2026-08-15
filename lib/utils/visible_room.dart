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

  static String? get current => _current;

  static void set(String? roomId) {
    _current = roomId;
    Logs().v('[VisibleRoom] set to $roomId');
  }

  static void clear() {
    _current = null;
    Logs().v('[VisibleRoom] cleared');
  }

  /// True als de gegeven roomId op dit moment zichtbaar is.
  ///
  /// Geldig zolang [set] niet opnieuw wordt aangeroepen of [clear] wordt
  /// aangeroepen door [ChatPage.dispose]. De statische waarde verdwijnt
  /// automatisch bij een app-crash/herstart. De lifecycle-check in
  /// [pushHelper] zorgt er apart voor dat berichten in de achtergrond wél
  /// worden getoond.
  static bool isVisible(String? roomId) {
    if (roomId == null || _current == null) return false;
    return _current == roomId;
  }
}
