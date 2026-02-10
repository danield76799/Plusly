// import 'dart:math';

import 'package:badges/badges.dart';
import 'package:extera_next/config/app_config.dart';
import 'package:extera_next/config/setting_keys.dart';
import 'package:extera_next/widgets/unread_rooms_badge.dart';
import 'package:flutter/material.dart';

import 'package:matrix/matrix.dart';

import 'package:extera_next/pages/chat_list/chat_list.dart';
import '../../widgets/matrix.dart';

class ChatListBottomNavbar extends StatelessWidget {
  final ChatListController controller;

  const ChatListBottomNavbar(this.controller, {super.key});

  @override
  Widget build(BuildContext context) {
    final client = Matrix.of(context).client;
    final theme = Theme.of(context);

    final spaces = client.rooms.where((r) => r.isSpace);
    final spaceDelegateCandidates = <String, Room>{};
    for (final space in spaces) {
      for (final spaceChild in space.spaceChildren) {
        final roomId = spaceChild.roomId;
        if (roomId == null) continue;
        spaceDelegateCandidates[roomId] = space;
      }
    }

    final filters = [
      if (AppSettings.separateChatTypes.value)
        ActiveFilter.messages
      else
        ActiveFilter.allChats,
      ActiveFilter.groups,
      ActiveFilter.unread,
      if (spaceDelegateCandidates.isNotEmpty &&
          !controller.widget.displayNavigationRail)
        ActiveFilter.spaces,
    ];

    final filterLambdas = {
      ActiveFilter.allChats: (Room room) => true,
      ActiveFilter.messages: (Room room) => room.isDirectChat,
      ActiveFilter.groups: (Room room) => !room.isDirectChat,
      ActiveFilter.unread: (Room room) => room.isUnread,
      ActiveFilter.spaces: (Room room) => false,
    };

    return Material(
      borderRadius: BorderRadius.circular(AppConfig.borderRadius),
      clipBehavior: .hardEdge,
      color: theme.colorScheme.surfaceContainerHigh,
      child: Padding(
        padding: const .all(4),
        child: Row(
          children: filters.map((filter) {
            final isActive = controller.activeFilter == filter;

            return Expanded(
              child: isActive
                  ? FilledButton.tonal(
                      onPressed: () => controller.setActiveFilter(filter),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppConfig.borderRadius - 4,
                          ),
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(filter.toIconData(false), size: 20),
                          const SizedBox(height: 4),
                          Text(
                            filter.toLocalizedString(context),
                            style: const TextStyle(fontSize: 13),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ],
                      ),
                    )
                  : TextButton(
                      onPressed: () => controller.setActiveFilter(filter),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppConfig.borderRadius,
                          ),
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          UnreadRoomsBadge(
                            filter: filterLambdas[filter]!,
                            badgePosition: BadgePosition.topEnd(),
                            child: Icon(
                              filter.toIconData(true),
                              size: 20,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            filter.toLocalizedString(context),
                            style: TextStyle(
                              fontSize: 13,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ],
                      ),
                    ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
