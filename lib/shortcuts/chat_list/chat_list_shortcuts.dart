import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class NextChatIntent extends Intent {
  const NextChatIntent();
}

class PreviousChatIntent extends Intent {
  const PreviousChatIntent();
}

class ChatListShortcuts extends StatelessWidget {
  final void Function() onPreviousChat;
  final void Function() onNextChat;
  final Widget child;

  const ChatListShortcuts({
    required this.onPreviousChat,
    required this.onNextChat,
    required this.child,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Actions(
      actions: <Type, Action<Intent>>{
        NextChatIntent: CallbackAction<NextChatIntent>(
          onInvoke: (intent) {
            print("Switching to next chat");
            onNextChat();
            return null;
          },
        ),
        PreviousChatIntent: CallbackAction<PreviousChatIntent>(
          onInvoke: (intent) {
            print("Switching to prev chat");
            onPreviousChat();
            return null;
          },
        ),
      },
      child: Shortcuts(
        shortcuts: <LogicalKeySet, Intent>{
          LogicalKeySet(LogicalKeyboardKey.alt, LogicalKeyboardKey.arrowDown):
              const NextChatIntent(),
          LogicalKeySet(LogicalKeyboardKey.alt, LogicalKeyboardKey.arrowUp):
              const PreviousChatIntent(),
        },
        child: Focus(
          child: child,
        ),
      ),
    );
  }
}
