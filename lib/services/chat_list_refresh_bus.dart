import 'dart:async';

/// Lightweight broadcast channel to force the chat list to refresh
/// immediately after certain actions like sending a reply.
class ChatListRefreshBus {
  static final _controller = StreamController<void>.broadcast();
  static Stream<void> get stream => _controller.stream;
  static void refresh() => _controller.add(null);
}
