import 'package:flutter/material.dart';

import 'package:matrix/matrix.dart';

import 'package:Pulsly/config/setting_keys.dart';
import 'package:Pulsly/generated/l10n/l10n.dart';
import 'package:Pulsly/utils/matrix_sdk_extensions/matrix_locals.dart';

class ReplyContent extends StatelessWidget {
  final Event replyEvent;
  final bool ownMessage;
  final Timeline? timeline;
  final Color? textColor;
  final bool noBubble;

  const ReplyContent(
    this.replyEvent, {
    this.textColor,
    this.noBubble = false,
    this.ownMessage = false,
    super.key,
    this.timeline,
  });

  static const BorderRadius borderRadius = BorderRadius.only(
    topLeft: Radius.circular(6),
    bottomLeft: Radius.circular(6),
  );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final timeline = this.timeline;
    final displayEvent = timeline != null
        ? replyEvent.getDisplayEvent(timeline)
        : replyEvent;
    final fontSize =
        AppSettings.fontSizeFactor.value * AppSettings.messageFontSize.value;

    // Subtle bar color: opacity-based so it blends with any bubble color.
    final barColor = (textColor ?? theme.colorScheme.onSurface)
        .withValues(alpha: ownMessage ? 0.35 : 0.25);
    // Very light background tint to separate the reply from the bubble body.
    final bgColor = (textColor ?? theme.colorScheme.onSurface)
        .withValues(alpha: 0.06);

    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: IntrinsicHeight(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Thin indicator bar — 3px, rounded left edge.
            Container(
              width: 3,
              decoration: BoxDecoration(
                color: barColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(6),
                  bottomLeft: Radius.circular(6),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FutureBuilder<User?>(
                      initialData: displayEvent.senderFromMemoryOrFallback,
                      future: displayEvent.fetchSenderUser(),
                      builder: (context, snapshot) {
                        return Text(
                          snapshot.data?.calcDisplayname() ??
                              displayEvent.senderFromMemoryOrFallback
                                  .calcDisplayname(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: fontSize - 1,
                            color: barColor,
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 1),
                    Text(
                      displayEvent
                          .calcLocalizedBodyFallback(
                            MatrixLocals(L10n.of(context)),
                            withSenderNamePrefix: false,
                            hideReply: true,
                            plaintextBody: true,
                          )
                          .split('\n')
                          .first,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: TextStyle(
                        fontSize: fontSize - 1,
                        color: (textColor ?? theme.colorScheme.onSurface)
                            .withValues(alpha: 0.65),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
