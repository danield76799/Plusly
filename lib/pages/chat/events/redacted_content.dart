import 'package:flutter/material.dart';

import 'package:matrix/matrix.dart';

import 'package:Pulsly/generated/l10n/l10n.dart';

class EventRedactedContent extends StatefulWidget {
  final Event event;
  final Color textColor;
  final double fontSize;

  const EventRedactedContent({
    super.key,
    required this.event,
    required this.textColor,
    required this.fontSize,
  });

  @override
  State<EventRedactedContent> createState() => _EventRedactedContentState();
}

class _EventRedactedContentState extends State<EventRedactedContent> {
  bool _showContent = false;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<User?>(
      future: widget.event.redactedBecause?.fetchSenderUser(),
      builder: (context, snapshot) {
        final reason = widget.event.redactedBecause?.content.tryGet<String>('reason');
        final redactedBy =
            snapshot.data?.calcDisplayname() ??
            widget.event.redactedBecause?.senderId.localpart ??
            L10n.of(context).user;

        final label = reason == null
            ? L10n.of(context).redactedBy(redactedBy)
            : L10n.of(context).redactedByBecause(redactedBy, reason);

        final body = widget.event.calcLocalizedBodyFallback(
          MatrixLocals(L10n.of(context)),
        );

        return GestureDetector(
          onTap: () => setState(() => _showContent = !_showContent),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: _showContent 
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Original content (clicked to hide):',
                      style: TextStyle(
                        color: widget.textColor.withAlpha(100),
                        fontSize: widget.fontSize * 0.8,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      body.isEmpty ? 'No text content available' : body,
                      style: TextStyle(
                        color: widget.textColor,
                        fontSize: widget.fontSize,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tap to hide 🗑️',
                      style: TextStyle(
                        color: widget.textColor.withAlpha(128),
                        fontSize: widget.fontSize * 0.8,
                      ),
                    ),
                  ],
                )
              : Text(
                  '🗑️  $label (tap to show)',
                  style: TextStyle(
                    color: widget.textColor.withAlpha(128),
                    fontSize: widget.fontSize,
                    decoration: TextDecoration.underline,
                    decorationStyle: TextDecorationStyle.dotted,
                  ),
                ),
          ),
        );
      },
    );
  }
}
