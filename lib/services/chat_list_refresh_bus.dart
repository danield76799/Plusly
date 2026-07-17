import 'dart:async';

/// Lightweight broadcast channel to force the chat list to refresh
/// immediately after certain actions like sending a reply.
/// Optional room ID lets the list optimistically bump that room to the top.
class ChatListRefreshBus {
  static final _controller = StreamController<String?>.broadcast();
  static Stream<String?> get stream => _controller.stream;
  static void refresh() => _controller.add(null);
  static void refreshForRoom(String roomId) => _controller.add(roomId);
}
