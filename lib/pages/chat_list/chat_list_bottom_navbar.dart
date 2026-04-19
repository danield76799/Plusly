import 'package:flutter/material.dart';

import 'package:badges/badges.dart';
import 'package:matrix/matrix.dart';

import 'package:extera_next/config/app_config.dart';
import 'package:extera_next/config/setting_keys.dart';
import 'package:extera_next/pages/chat_list/chat_list.dart';
import 'package:extera_next/widgets/unread_rooms_badge.dart';
import '../../widgets/matrix.dart';

class ChatListBottomNavbar extends StatefulWidget {
  final ChatListController controller;

  const ChatListBottomNavbar(this.controller, {super.key});

  @override
  State<ChatListBottomNavbar> createState() => _ChatListBottomNavbarState();
}

class _ChatListBottomNavbarState extends State<ChatListBottomNavbar> {
  ChatListController get _c => widget.controller;

  List<Room> spaces = [];
  Map<String, Room> spaceDelegateCandidates = {};

  @override
  void initState() {
    final client = Matrix.of(context).client;

    spaces = client.rooms.where((r) => r.isSpace).toList();
    for (final space in spaces) {
      for (final spaceChild in space.spaceChildren) {
        final roomId = spaceChild.roomId;
        if (roomId == null) continue;
        spaceDelegateCandidates[roomId] = space;
      }
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final filters = [
      if (AppSettings.separateChatTypes.value)
        ActiveFilter.messages
      else
        ActiveFilter.allChats,
      if (AppSettings.separateChatTypes.value) ActiveFilter.groups,
      ActiveFilter.unread,
      if (spaceDelegateCandidates.isNotEmpty &&
          !_c.widget.displayNavigationRail)
        ActiveFilter.spaces,
      if (AppSettings.enablePeopleTab.value) ActiveFilter.people,
    ];

    final filterLambdas = {
      ActiveFilter.allChats: (Room room) => true,
      ActiveFilter.messages: (Room room) => room.isDirectChat,
      ActiveFilter.groups: (Room room) => !room.isDirectChat,
      ActiveFilter.unread: (Room room) => room.isUnread,
      ActiveFilter.spaces: (Room room) => false,
      ActiveFilter.people: (Room room) => false,
    };

    return Material(
      borderRadius: BorderRadius.circular(AppConfig.borderRadius),
      clipBehavior: Clip.hardEdge,
      color: theme.colorScheme.surfaceContainerHigh,
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Row(
          children: filters.map((filter) {
            final isActive = _c.activeFilter == filter;

            final backgroundColor = isActive
                ? theme.colorScheme.secondaryContainer
                : Colors.transparent;

            final foregroundColor = isActive
                ? theme.colorScheme.onSecondaryContainer
                : theme.colorScheme.onSurfaceVariant;

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
                  clipBehavior: Clip.hardEdge,
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    borderRadius: currentBorderRadius,
                  ),
                  child: Material(
                    type: MaterialType.transparency,
                    child: InkWell(
                      onTap: () => _c.setActiveFilter(filter),
                      borderRadius: currentBorderRadius,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (isActive)
                              Icon(
                                filter.toIconData(false),
                                size: 20,
                                color: foregroundColor,
                              )
                            else
                              UnreadRoomsBadge(
                                filter: filterLambdas[filter]!,
                                badgePosition: BadgePosition.topEnd(),
                                child: Icon(
                                  filter.toIconData(true),
                                  size: 20,
                                  color: foregroundColor,
                                ),
                              ),
                            const SizedBox(height: 4),
                            Text(
                              filter.toLocalizedString(context),
                              style: TextStyle(
                                fontSize: 13,
                                color: foregroundColor,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
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
