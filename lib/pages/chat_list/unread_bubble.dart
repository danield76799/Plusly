import 'package:flutter/material.dart';

import 'package:matrix/matrix.dart';

import 'package:Pulsly/generated/l10n/l10n.dart';


class UnreadBubble extends StatelessWidget {
  final Room room;
  final bool? unreadOverride;
  final int? countOverride;
  const UnreadBubble({required this.room, this.unreadOverride, this.countOverride, super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final unread = unreadOverride ?? room.isUnread;
    final count = countOverride ?? room.notificationCount;
    final heeftAantal = count > 0;
    final actief = unread || room.hasNewMessages || room.markedUnread;
    if (!actief) return const SizedBox.shrink();

    final kleur = room.highlightCount > 0
        ? theme.colorScheme.error
        : theme.colorScheme.primary;
    final tekst = count > 99 ? '99+' : '$count';

    return Semantics(
      label: heeftAantal
          ? L10n.of(context).unreadMessages(count)
          : L10n.of(context).unread,
      child: Container(
        height: 22,
        constraints: const BoxConstraints(minWidth: 22),
        padding: heeftAantal
            ? const EdgeInsets.symmetric(horizontal: 7)
            : EdgeInsets.zero,
        width: heeftAantal ? null : 12,
        decoration: BoxDecoration(
          color: kleur,
          borderRadius: BorderRadius.circular(11),
        ),
        alignment: Alignment.center,
        child: heeftAantal
            ? Text(
                tekst,
                style: TextStyle(
                  color: theme.colorScheme.onPrimary,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  height: 1.0,
                ),
                textAlign: TextAlign.center,
              )
            : null,
      ),
    );
  }
}
