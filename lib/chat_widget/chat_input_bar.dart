import 'package:flutter/material.dart';

class ChatInputBar extends StatefulWidget {
  final VoidCallback onSend;
  final VoidCallback? onMicTap;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onAttachmentSelected;
  final VoidCallback? onEmojiTap;
  final TextEditingController? controller;
  final bool isLoading;

  const ChatInputBar({
    super.key,
    required this.onSend,
    this.onMicTap,
    this.onChanged,
    this.onAttachmentSelected,
    this.onEmojiTap,
    this.controller,
    this.isLoading = false,
  });

  @override
  State<ChatInputBar> createState() => _ChatInputBarState();
}

class _ChatInputBarState extends State<ChatInputBar> {
  late final TextEditingController _controller;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _hasText = _controller.text.trim().isNotEmpty;
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    } else {
      _controller.removeListener(_onTextChanged);
    }
    super.dispose();
  }

  void _onTextChanged() {
    final hasText = _controller.text.trim().isNotEmpty;
    if (hasText != _hasText) {
      setState(() => _hasText = hasText);
    }
  }

  void _submit() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    widget.onSend();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final fieldColor = isDark
        ? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.55)
        : theme.colorScheme.surface.withValues(alpha: 0.9);

    final borderColor = _hasText
        ? theme.colorScheme.primary.withValues(alpha: 0.35)
        : theme.colorScheme.outline.withValues(alpha: 0.18);

    return SafeArea(
      top: false,
      child: Container(
        padding: EdgeInsets.fromLTRB(
          12,
          10,
          12,
          MediaQuery.of(context).viewPadding.bottom + 8,
        ),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.shadow.withValues(alpha: 0.1),
              blurRadius: 12,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Attachment
            IconButton(
              tooltip: 'Bestand bijvoegen',
              onPressed: widget.onAttachmentSelected,
              icon: Icon(
                Icons.attach_file_rounded,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(width: 2),

            // Pill container
            Expanded(
              child: Container(
                constraints: const BoxConstraints(minHeight: 44),
                decoration: BoxDecoration(
                  color: fieldColor,
                  borderRadius: BorderRadius.circular(26),
                  border: Border.all(color: borderColor, width: 1.2),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Text field
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 18),
                        child: TextField(
                          controller: _controller,
                          onChanged: widget.onChanged,
                          onSubmitted: (_) => _submit(),
                          maxLines: null,
                          textCapitalization: TextCapitalization.sentences,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface,
                            fontSize: 15,
                            height: 1.35,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Schrijf een bericht...',
                            hintStyle: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(
                                alpha: 0.45,
                              ),
                            ),
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 12,
                            ),
                            isDense: true,
                          ),
                        ),
                      ),
                    ),

                    // Emoji
                    IconButton(
                      tooltip: 'Emoji',
                      onPressed: widget.onEmojiTap,
                      icon: Icon(
                        Icons.emoji_emotions_outlined,
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.6,
                        ),
                      ),
                    ),

                    // Send
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 160),
                      transitionBuilder: (child, anim) {
                        return ScaleTransition(scale: anim, child: child);
                      },
                      child:
                          _hasText
                              ? IconButton(
                                    key: const ValueKey('send'),
                                    tooltip: 'Verzenden',
                                    onPressed: _submit,
                                    icon: Icon(
                                      Icons.send_rounded,
                                      color: theme.colorScheme.primary,
                                    ),
                                  )
                              : const SizedBox(
                                    key: ValueKey('empty'),
                                    width: 4,
                                  ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(width: 6),

            // Microphone
            AnimatedScale(
              scale: _hasText ? 0.75 : 1.0,
              duration: const Duration(milliseconds: 160),
              child: IconButton(
                tooltip: 'Spraakopname',
                onPressed: _hasText ? null : widget.onMicTap,
                icon: Icon(
                  _hasText
                      ? Icons.keyboard_voice_rounded
                      : Icons.mic_rounded,
                  color:
                      _hasText
                          ? theme.colorScheme.onSurface.withValues(alpha: 0.3)
                          : theme.colorScheme.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
