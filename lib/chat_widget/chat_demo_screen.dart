import 'package:flutter/material.dart';
import 'chat_message.dart';
import 'chat_screen.dart';

class ChatDemoScreen extends StatelessWidget {
  const ChatDemoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final messages = <ChatMessage>[
      ChatMessage(
        text: 'Zin je morgen mee naar het strand?',
        isMe: false,
        timestamp: DateTime(now.year, now.month, now.day, 9, 12),
        senderName: 'Fenna',
      ),
      ChatMessage(
        text: 'Zeker! Wat tijd?',
        isMe: true,
        timestamp: DateTime(now.year, now.month, now.day, 9, 14),
        senderName: 'Daniel',
      ),
      ChatMessage(
        text: 'Rond 11? Dan kunnen we eerst nog even koffie halen.',
        isMe: false,
        timestamp: DateTime(now.year, now.month, now.day, 9, 15),
        senderName: 'Fenna',
      ),
      ChatMessage(
        text: 'Goed plan, ik breng ook de drop.',
        isMe: true,
        timestamp: DateTime(now.year, now.month, now.day, 9, 16),
        senderName: 'Daniel',
      ),
      ChatMessage(
        text: 'Top, tot dan!',
        isMe: false,
        timestamp: DateTime(now.year, now.month, now.day, 9, 17),
        senderName: 'Fenna',
      ),
    ];

    return Theme(
      data: ThemeData.dark(useMaterial3: true).copyWith(
        scaffoldBackgroundColor: const Color(0xFF0E1116),
        colorScheme: const ColorScheme.dark(
          surface: Color(0xFF0E1116),
          surfaceContainerHighest: Color(0xFF1E2228),
          primary: Color(0xFF4d9de0),
          onPrimary: Colors.white,
          onSurface: Color(0xFFE7EAEE),
        ),
      ),
      child: ChatScreen(
        contactName: 'Fenna (WA)',
        status: 'online',
        avatarUrl: null,
        messages: messages,
        onBack: () {},
        onSend: () {},
      ),
    );
  }
}
