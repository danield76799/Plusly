import 'package:flutter/material.dart';
import 'chat_message.dart';
import 'chat_input_bar.dart';

class ChatScreen extends StatelessWidget {
  final List<ChatMessage> messages;
  final String contactName;
  final String? status;
  final String? avatarUrl;
  final VoidCallback? onBack;
  final VoidCallback? onSend;
  final VoidCallback? onMicTap;
  final VoidCallback? onAttachmentSelected;
  final VoidCallback? onEmojiTap;
  final ValueChanged<String>? onInputChanged;
  final TextEditingController? inputController;
  final bool isLoading;

  const ChatScreen({
    super.key,
    required this.messages,
    required this.contactName,
    this.status,
    this.avatarUrl,
    this.onBack,
    this.onSend,
    this.onMicTap,
    this.onAttachmentSelected,
    this.onEmojiTap,
    this.onInputChanged,
    this.inputController,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF0E1116) : theme.colorScheme.surface,
      appBar: _buildAppBar(context, theme, isDark),
      // SafeArea beschermt de body (incl. de bottom input bar) tegen de
      // OS home-indicator onderaan het scherm.
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                reverse: true,
                padding: const EdgeInsets.symmetric(vertical: 12),
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final message = messages[index];
                  final realIndex = messages.length - 1 - index;
                  final previousMessage =
                      realIndex > 0 ? messages[realIndex - 1] : null;

                  final isMe = message.isMe;
                  final isFirst =
                      previousMessage == null ||
                      previousMessage.isMe != isMe ||
                      previousMessage.senderName != message.senderName;

                  return ChatBubble(
                    key: ValueKey('${message.timestamp.millisecondsSinceEpoch}-${message.text.hashCode}'),
                    message: message,
                    showAvatar: isFirst && !isMe,
                    showName: isFirst && !isMe,
                    isFirstInGroup: isFirst,
                    onAvatarTap: () {},
                  );
                },
              ),
            ),
            ChatInputBar(
              onSend: onSend ?? () {},
              onMicTap: onMicTap,
              onAttachmentSelected: onAttachmentSelected ?? () {},
              onEmojiTap: onEmojiTap ?? () {},
              onChanged: onInputChanged,
              controller: inputController,
              isLoading: isLoading,
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, ThemeData theme, bool isDark) {
    return AppBar(
      backgroundColor: isDark ? const Color(0xFF0A0C10) : theme.colorScheme.surface,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: Row(
        children: [
          const SizedBox(width: 6),
          IconButton(
            tooltip: 'Terug',
            onPressed: onBack ?? () => Navigator.maybePop(context),
            icon: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: theme.colorScheme.onSurface,
              size: 20,
            ),
          ),
        ],
      ),
      titleSpacing: 0,
      title: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor:
                avatarUrl == null
                    ? theme.colorScheme.primaryContainer
                    : null,
            backgroundImage:
                avatarUrl != null ? NetworkImage(avatarUrl!) : null,
            child:
                avatarUrl == null
                    ? Text(
                          contactName.characters.first.toUpperCase(),
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: theme.colorScheme.onPrimaryContainer,
                            fontWeight: FontWeight.w600,
                          ),
                        )
                    : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  contactName,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: theme.colorScheme.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (status != null)
                  Text(
                    status!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontSize: 12,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          tooltip: 'Beveiligd',
          onPressed: () {},
          icon: Icon(
            Icons.lock_outline_rounded,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.45),
            size: 20,
          ),
        ),
        IconButton(
          tooltip: 'Meer',
          onPressed: () {},
          icon: Icon(
            Icons.more_vert_rounded,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.45),
            size: 22,
          ),
        ),
      ],
    );
  }
}
