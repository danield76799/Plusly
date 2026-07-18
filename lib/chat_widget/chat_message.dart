import 'package:flutter/material.dart';

class ChatMessage {
  final String text;
  final bool isMe;
  final DateTime timestamp;
  final String senderName;
  final String? avatarUrl;
  final bool isGroupChat; // true = groepschat, false = 1-on-1

  const ChatMessage({
    required this.text,
    required this.isMe,
    required this.timestamp,
    required this.senderName,
    this.avatarUrl,
    this.isGroupChat = false,
  });
}

class ChatBubble extends StatelessWidget {
  final ChatMessage message;
  final bool showAvatar;
  final bool showName;
  final bool isFirstInGroup;
  final VoidCallback? onAvatarTap;

  const ChatBubble({
    super.key,
    required this.message,
    this.showAvatar = true,
    this.showName = true,
    this.isFirstInGroup = true,
    this.onAvatarTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isMe = message.isMe;

    final bubbleColor = isMe
        ? theme.colorScheme.primary.withValues(alpha: 0.85)
        : theme.colorScheme.surfaceContainerHighest;
    final textColor = isMe
        ? theme.colorScheme.onPrimary
        : theme.colorScheme.onSurface;

    final timeStr = _formatTime(message.timestamp);
    final showStatus = isMe;

    return Row(
      mainAxisAlignment:
          isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Avatar + naam: alleen voor inkomende berichten
        if (!isMe) ...[
          if (showAvatar)
            GestureDetector(
              onTap: onAvatarTap,
              child: Padding(
                padding: const EdgeInsets.only(left: 12, right: 8),
                child: CircleAvatar(
                  radius: 16,
                  backgroundColor: theme.colorScheme.primaryContainer,
                  backgroundImage:
                      message.avatarUrl != null
                          ? NetworkImage(message.avatarUrl!)
                          : null,
                  child:
                      message.avatarUrl == null
                          ? Text(
                                message.senderName.characters.first.toUpperCase(),
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onPrimaryContainer,
                                  fontWeight: FontWeight.w600,
                                ),
                              )
                          : null,
                ),
              ),
            )
          else
            const SizedBox(width: 40),
          // Naam alléén tonen in groepschats (isGroupChat) en bij inkomende
          // berichten. In een 1-op-1 gesprek is de naam overbodig (rustiger).
          if (showName && showAvatar && message.isGroupChat)
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 12, bottom: 2),
                child: Text(
                  message.senderName,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ),
            )
          else if (!showName)
            const SizedBox(height: 4),
        ],

        // Bubble
        Flexible(
          child: Container(
            constraints: BoxConstraints(
              maxWidth:
                  MediaQuery.of(context).size.width *
                  (isMe ? 0.72 : 0.74),
            ),
            margin: EdgeInsets.only(
              top: isFirstInGroup ? 8 : 2,
              bottom: isFirstInGroup ? 6 : 2,
              left: isMe ? 16 : 4,
              right: isMe ? 4 : 16,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: bubbleColor,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(16),
                topRight: const Radius.circular(16),
                bottomLeft: Radius.circular(
                  isMe ? 16 : (isFirstInGroup ? 4 : 16),
                ),
                bottomRight: Radius.circular(
                  isMe ? (isFirstInGroup ? 4 : 16) : 16,
                ),
              ),
            ),
            child: Column(
              crossAxisAlignment:
                  isMe
                      ? CrossAxisAlignment.end
                      : CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  message.text,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 15,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      timeStr,
                      style: TextStyle(
                        color: textColor.withValues(alpha: 0.65),
                        fontSize: 10,
                      ),
                    ),
                    if (showStatus) ...[
                      const SizedBox(width: 4),
                      Icon(
                        Icons.done_all,
                        size: 14,
                        color: textColor.withValues(alpha: 0.75),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}
