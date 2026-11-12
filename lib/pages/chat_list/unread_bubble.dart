import 'package:flutter/material.dart';

import 'package:matrix/matrix.dart';

import 'package:Pulsly/config/themes.dart';

class UnreadBubble extends StatelessWidget {
  final Room room;
  final bool? unreadOverride;
  final int? countOverride;
  const UnreadBubble({required this.room, this.unreadOverride, this.countOverride, super.key});

  @override
  Widget build(BuildContext context) {
    final unread = unreadOverride ?? room.isUnread;
    final hasNotifications = (countOverride ?? room.notificationCount) > 0;
    final unreadBubbleSize = unread || room.hasNewMessages
        ? (countOverride ?? room.notificationCount) > 0
              ? 20.0
              : 14.0
        : 0.0;
    return AnimatedContainer(
      duration: FluffyThemes.animationDuration,
      curve: FluffyThemes.animationCurve,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 7),
      height: unreadBubbleSize,
      width: !hasNotifications && !unread && !room.hasNewMessages
          ? 0
          : (unreadBubbleSize - 9) * (countOverride ?? room.notificationCount).toString().length +
                9,
      decoration: BoxDecoration(
        color: room.highlightCount > 0
            ? const Color(0xFFFF4444) // Red for highlights (mentions)
            : hasNotifications || room.markedUnread
            ? Theme.of(context).whatsAppBadgeColor // WhatsApp-groen
            : Theme.of(
                context,
              ).whatsAppBadgeColor.withValues(alpha: 0.5), // Licht groen
        borderRadius: BorderRadius.circular(7),
      ),
      child: hasNotifications
          ? Text(
              (countOverride ?? room.notificationCount).toString(),
              style: TextStyle(
                color: Colors.white, // Always white text on red badges
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            )
          : const SizedBox.shrink(),
    );
  }
}
