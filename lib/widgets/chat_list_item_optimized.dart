import 'package:flutter/material.dart';
import 'package:matrix/matrix.dart';

import '../utils/bridge_utils.dart';
import '../utils/matrix_sdk_extensions/matrix_locals.dart';
import '../utils/matrix_sdk_extensions/room_ui_cache.dart';
import 'avatar.dart';
import 'hover_builder.dart';
import '../generated/l10n/l10n.dart';

/// Optimized ChatListItem that uses cached room properties
/// to avoid expensive computations on every rebuild.
class ChatListItemOptimized extends StatelessWidget {
  final Room room;
  final Room? space;
  final String? filter;
  final VoidCallback? onTap;
  final void Function(BuildContext context)? onLongPress;
  final bool activeChat;
  final bool firstElement;
  final bool lastElement;
  final bool compactMode;

  const ChatListItemOptimized(
    this.room, {
    this.space,
    this.filter,
    this.onTap,
    this.onLongPress,
    this.activeChat = false,
    this.firstElement = false,
    this.lastElement = false,
    this.compactMode = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final client = room.client;

    // Use cached displayname instead of computing every time
    final displayname = room.getCachedDisplayname(
      MatrixLocals(L10n.of(context)),
    );

    // Use cached bridge detection
    final isBridge = room.getCachedIsBridge();
    final bridgeType = isBridge ? room.getCachedBridgeType() : null;
    final bridgeIcon = bridgeType != null ? getBridgeTypeIcon(bridgeType) : null;
    final bridgeColor = bridgeType != null ? getBridgeTypeColor(bridgeType) : null;

    // Use cached last message
    final lastEvent = room.lastEvent;
    final lastMessage = room.getCachedLastMessage(
      MatrixLocals(L10n.of(context)),
      lastEvent,
    );

    // Use cached unread count
    final isUnread = room.isUnreadOrInvited;
    final unreadCount = room.getCachedUnreadCount();

    // Use cached avatar
    final avatarUri = room.getCachedAvatar();

    return HoverBuilder(
      builder: (context, isHovering) => Material(
        color: activeChat
            ? theme.colorScheme.primaryContainer
            : isHovering
                ? theme.colorScheme.surfaceContainerHighest
                : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress != null ? () => onLongPress!(context) : null,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: 16,
              vertical: compactMode ? 8 : 10,
            ),
            child: Row(
              children: [
                // Avatar with platform icon overlay
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Avatar(
                      mxContent: avatarUri,
                      size: compactMode ? 40 : 48,
                      name: displayname,
                      client: client,
                    ),
                    if (bridgeIcon != null && bridgeColor != null)
                      Positioned(
                        right: -2,
                        bottom: -2,
                        child: Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: bridgeColor,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: theme.colorScheme.surface,
                              width: 2,
                            ),
                          ),
                          child: Icon(
                            bridgeIcon,
                            size: 12,
                            color: Colors.white,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 12),
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Contact name
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              displayname,
                              style: TextStyle(
                                fontSize: compactMode ? 14 : 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          // Unread badge
                          if (unreadCount > 0)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                unreadCount > 99 ? '99+' : unreadCount.toString(),
                                style: TextStyle(
                                  color: theme.colorScheme.onPrimary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      // Last message preview
                      if (lastMessage != null)
                        Text(
                          lastMessage,
                          style: TextStyle(
                            fontSize: compactMode ? 12 : 14,
                            fontWeight: isUnread
                                ? FontWeight.w600
                                : FontWeight.normal,
                            color: const Color(0xFF4A4A4A),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
