import 'package:flutter/material.dart';

import 'package:matrix/matrix.dart';

import 'package:Pulsly/generated/l10n/l10n.dart';
import 'package:Pulsly/utils/redacted_body_cache.dart';

/// Toont een verwijderd bericht.
///
/// Standaard zie je alleen "Verwijderd door X". Tik je erop, dan klapt de
/// originele tekst open.
///
/// De originele tekst komt uit [RedactedBodyCache]: bij een redaction
/// verwijdert de Matrix-SDK de content van het event, dus de tekst is dan
/// alleen terug te vinden als die vooraf bewaard is.
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

        // Originele tekst uit de cache. Zonder deze cache levert de
        // Event.body de letterlijke string 'Redacted' op: de SDK strip't de
        // content van een bericht zodra het wordt verwijderd.
        final cached = RedactedBodyCache.instance.lookup(
          redactedCacheKey(widget.event.room.id, widget.event.eventId),
        );
        var body = cached ?? widget.event.text;
        // 'Redacted' is geen echte tekst: de SDK levert die placeholder
        // wanneer de content is gestript.
        if (body.trim().toLowerCase() == 'redacted') body = '';

        return GestureDetector(
          onTap: () => setState(() => _showContent = !_showContent),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: _showContent 
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      L10n.of(context).redactedOriginalContent,
                      style: TextStyle(
                        color: widget.textColor.withAlpha(100),
                        fontSize: widget.fontSize * 0.8,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      body.isEmpty
                          ? L10n.of(context).redactedContentUnavailable
                          : body,
                      style: TextStyle(
                        color: widget.textColor,
                        fontSize: widget.fontSize,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      L10n.of(context).redactedTapToHide,
                      style: TextStyle(
                        color: widget.textColor.withAlpha(128),
                        fontSize: widget.fontSize * 0.8,
                      ),
                    ),
                  ],
                )
              : Text(
                  '🗑️  $label (${L10n.of(context).redactedTapToShow})',
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
