import 'dart:async';

/// Lightweight broadcast channel to force the chat list to refresh
/// immediately after certain actions like sending a reply.
/// Optional room ID lets the list optimistically bump that room to the top.
///
/// The stream replays the last emitted value to each new listener. This
/// matters because the chat list StreamBuilder is not mounted while the user
/// is inside a chat — a `refreshForRoom` emitted during sending would
/// otherwise be lost (plain broadcast streams drop events with no listener),
/// so the sent room would never jump to the top after returning to the list.
class ChatListRefreshBus {
  static String? _lastRoomId;

  static final List<StreamController<String?>> _listeners = [];

  /// Stream that replays the latest value to any new subscriber, then keeps
  /// streaming subsequent refreshes.
  static Stream<String?> get stream {
    final controller = StreamController<String?>.broadcast();
    if (_lastRoomId != null) {
      // Replay the last value once this listener subscribes.
      controller.onListen = () {
        if (_lastRoomId != null) controller.add(_lastRoomId!);
      };
    }
    _listeners.add(controller);
    // Clean up when the subscriber cancels (e.g. chat list disposed).
    controller.onCancel = () => _listeners.remove(controller);
    return controller.stream;
  }

  static void _emit(String? value) {
    _lastRoomId = value;
    for (final c in List.of(_listeners)) {
      if (!c.isClosed) c.add(value);
    }
  }

  static void refresh() => _emit(null);

  static void refreshForRoom(String roomId) => _emit(roomId);
}
