import 'package:flutter/material.dart';

import 'package:badges/badges.dart';
import 'package:matrix/matrix.dart';

import 'package:Pulsly/config/app_config.dart';
import 'package:Pulsly/config/setting_keys.dart';
import 'package:Pulsly/pages/chat_list/chat_list.dart';
import 'package:Pulsly/widgets/unread_rooms_badge.dart';

class ChatListBottomNavbar extends StatelessWidget {
  final ChatListController controller;

  const ChatListBottomNavbar(this.controller, {super.key});

  @override
  Widget build(BuildContext context) {

    final filters = [
      if (AppSettings.separateChatTypes.value)
        ActiveFilter.messages
      else
        ActiveFilter.allChats,
      if (AppSettings.separateChatTypes.value) ActiveFilter.groups,
      ActiveFilter.unread,
      ActiveFilter.favorites,
    ];

    final filterLambdas = {
      ActiveFilter.allChats: (Room room) => true,
      ActiveFilter.messages: (Room room) => room.isDirectChat,
      ActiveFilter.groups: (Room room) => room.isSpace,
      ActiveFilter.unread: (Room room) => room.isUnread,
      ActiveFilter.favorites: (Room room) => false,
    };

    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      borderRadius: BorderRadius.circular(AppConfig.borderRadius),
      clipBehavior: Clip.hardEdge,
      color: colorScheme.primaryContainer.withValues(alpha: 0.30),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Row(
          children: filters.map((filter) {
            final isActive = controller.activeFilter == filter;

            // Pre-calculate styles
            final backgroundColor = isActive
                ? colorScheme.primaryContainer
                : Colors.transparent;

            final foregroundColor = isActive
                ? colorScheme.primary
                : colorScheme.outline;

            final currentBorderRadius = BorderRadius.circular(
              isActive ? AppConfig.borderRadius - 4 : AppConfig.borderRadius,
            );

            return Expanded(
              key: ValueKey(filter),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    borderRadius: currentBorderRadius,
                  ),
                  child: Material(
                    type: MaterialType.transparency,
                    child: InkWell(
                      onTap: () => controller.setActiveFilter(filter),
                      borderRadius: currentBorderRadius,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            UnreadRoomsBadge(
                              filter: filterLambdas[filter]!,
                              badgePosition: BadgePosition.topEnd(),
                              child: Icon(
                                filter.toIconData(!isActive),
                                size: 26,
                                color: foregroundColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
