import 'package:flutter/material.dart';

import 'package:matrix/matrix.dart';

import 'package:Pulsly/generated/l10n/l10n.dart';

/// Kleine "Doorgestuurd"-markering boven een bericht-inhoud, zoals in
/// WhatsApp/Telegram. Wordt alleen getoond als het bericht met
/// `m.forwarded` is verzonden (zie chat.dart bij het doorsturen).
class ForwardedBadge extends StatelessWidget {
  const ForwardedBadge({super.key, required this.event, required this.textColor});

  final Event event;
  final Color textColor;

  bool get isForwarded =>
      event.content.tryGetMap<String, Object?>('m.forwarded')?.tryGet<String>('user_id') !=
      null;

  @override
  Widget build(BuildContext context) {
    if (!isForwarded) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.forward_outlined, size: 14, color: textColor.withValues(alpha: 0.7)),
          const SizedBox(width: 4),
          Text(
            L10n.of(context).forwarded,
            style: TextStyle(
              fontSize: 12,
              color: textColor.withValues(alpha: 0.7),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
