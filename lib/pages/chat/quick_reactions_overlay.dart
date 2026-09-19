import 'package:flutter/material.dart';
import 'package:matrix/matrix.dart';

/// Quick-reactions overlay — Instagram/CometChat-stijl.
/// Wordt getoond boven een bericht-bubble bij tap-and-hold.
/// 5 emoji's in een rij, tap = direct versturen.
class QuickReactionsOverlay extends StatelessWidget {
  final Event event;
  final VoidCallback onDismiss;

  const QuickReactionsOverlay({
    required this.event,
    required this.onDismiss,
    super.key,
  });

  static const _reactions = ['❤️', '👍', '😂', '🎉', '😮'];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onDismiss,
      behavior: HitTestBehavior.translucent,
      child: Container(
        color: Colors.black.withAlpha(80),
        child: Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 32),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: cs.surface.withAlpha(245),
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(40),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: _reactions.map((emoji) {
                return Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () async {
                      await event.room.sendReaction(event.eventId, emoji);
                      onDismiss();
                    },
                    customBorder: const CircleBorder(),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(emoji, style: const TextStyle(fontSize: 28)),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}
