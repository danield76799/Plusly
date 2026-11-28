import 'package:flutter/material.dart';

import 'package:Pulsly/config/themes.dart';
import 'package:Pulsly/generated/l10n/l10n.dart';

/// Lokale demo-modus voor app-review: geen Matrix-account nodig.
///
/// De reviewer ziet de chatlijst, een gesprek en een werkende composer.
/// Verzonden berichten blijven lokaal; er wordt niets naar een server gestuurd.
class DemoPage extends StatefulWidget {
  const DemoPage({super.key});

  @override
  State<DemoPage> createState() => _DemoPageState();
}

class _DemoPageState extends State<DemoPage> {
  static const _chats = [
    _DemoChat(
      name: 'Tamara',
      initials: 'T',
      color: Color(0xFFD97A63),
      preview: 'Ik heb bolletjes voor Mees zijn lunch',
      time: '10:42',
      unread: 2,
    ),
    _DemoChat(
      name: 'Familie App',
      initials: 'F',
      color: Color(0xFF4AA593),
      preview: 'Mama: Zijn jullie er om 18:00?',
      time: '10:12',
      unread: 5,
    ),
    _DemoChat(
      name: 'Mees',
      initials: 'M',
      color: Color(0xFF5E7BB5),
      preview: 'Tot straks!',
      time: '10:03',
      unread: 0,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.chatHeaderColor,
        foregroundColor: Colors.white,
        title: Text(L10n.of(context).demoMode),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).maybePop(),
            child: Text(
              L10n.of(context).close,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          _DemoBanner(text: L10n.of(context).demoNotice),
          Expanded(
            child: ListView.separated(
              itemCount: _chats.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (context, i) {
                final chat = _chats[i];
                return InkWell(
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => _DemoChatPage(chat: chat),
                    ),
                  ),
                  child: SizedBox(
                    height: 74,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 25,
                            backgroundColor: chat.color,
                            child: Text(
                              chat.initials,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 17,
                              ),
                            ),
                          ),
                          const SizedBox(width: 13),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  chat.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  chat.preview,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                chat.time,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: chat.unread > 0
                                      ? theme.colorScheme.primary
                                      : theme.colorScheme.outline,
                                ),
                              ),
                              if (chat.unread > 0) ...[
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 7,
                                  ),
                                  height: 22,
                                  constraints:
                                      const BoxConstraints(minWidth: 22),
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: theme.whatsAppBadgeColor,
                                    borderRadius: BorderRadius.circular(11),
                                  ),
                                  child: Text(
                                    '${chat.unread}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _DemoChat {
  final String name;
  final String initials;
  final Color color;
  final String preview;
  final String time;
  final int unread;

  const _DemoChat({
    required this.name,
    required this.initials,
    required this.color,
    required this.preview,
    required this.time,
    required this.unread,
  });
}

class _DemoChatPage extends StatefulWidget {
  final _DemoChat chat;

  const _DemoChatPage({required this.chat});

  @override
  State<_DemoChatPage> createState() => _DemoChatPageState();
}

class _DemoChatPageState extends State<_DemoChatPage> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  final _messages = <_DemoMessage>[
    const _DemoMessage(
      text: 'Hoi! Heb je even?',
      own: false,
      time: '10:38',
    ),
    const _DemoMessage(
      text: 'Ik heb bolletjes voor Mees zijn lunch meegenomen.',
      own: false,
      time: '10:38',
    ),
    const _DemoMessage(
      text: 'Zal ik ze bij je afgeven of leg je ze klaar?',
      own: false,
      time: '10:38',
    ),
    const _DemoMessage(
      text: 'Ah top, dank je! Ik ben rond 12:15 thuis.',
      own: true,
      time: '10:41',
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _messages.add(_DemoMessage(
        text: text,
        own: true,
        time:
            '${DateTime.now().hour.toString().padLeft(2, '0')}:${DateTime.now().minute.toString().padLeft(2, '0')}',
      ));
      _controller.clear();
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.chatHeaderColor,
        foregroundColor: Colors.white,
        titleSpacing: 0,
        title: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: widget.chat.color,
              child: Text(
                widget.chat.initials,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.chat.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  L10n.of(context).online,
                  style: const TextStyle(fontSize: 13, color: Colors.white70),
                ),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          _DemoBanner(text: L10n.of(context).demoChatNotice),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.fromLTRB(12, 14, 12, 8),
              itemCount: _messages.length,
              itemBuilder: (context, i) {
                final message = _messages[i];
                return Align(
                  alignment: message.own
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 6),
                    padding: const EdgeInsets.fromLTRB(11, 7, 11, 6),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.sizeOf(context).width * 0.75,
                    ),
                    decoration: BoxDecoration(
                      color: message.own
                          ? theme.bubbleColor
                          : theme.incomingBubbleColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          message.text,
                          style: TextStyle(
                            fontSize: 14.5,
                            height: 1.34,
                            color: message.own
                                ? theme.onBubbleColor
                                : theme.colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            message.time,
                            style: TextStyle(
                              fontSize: 11,
                              color: (message.own
                                      ? theme.onBubbleColor
                                      : theme.colorScheme.onSurface)
                                  .withValues(alpha: 0.6),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 6, 8, 6),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _send(),
                      decoration: InputDecoration(
                        hintText: L10n.of(context).sendAMessage,
                        filled: true,
                        fillColor: theme.colorScheme.surfaceContainerHigh,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(22),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  IconButton.filled(
                    onPressed: _send,
                    icon: const Icon(Icons.send_rounded),
                    style: IconButton.styleFrom(
                      backgroundColor: theme.whatsAppBadgeColor,
                      foregroundColor: const Color(0xFF0B141A),
                      minimumSize: const Size(46, 46),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DemoMessage {
  final String text;
  final bool own;
  final String time;

  const _DemoMessage({
    required this.text,
    required this.own,
    required this.time,
  });
}

class _DemoBanner extends StatelessWidget {
  final String text;

  const _DemoBanner({required this.text});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      color: theme.colorScheme.secondaryContainer,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            size: 18,
            color: theme.colorScheme.onSecondaryContainer,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 12.5,
                color: theme.colorScheme.onSecondaryContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
