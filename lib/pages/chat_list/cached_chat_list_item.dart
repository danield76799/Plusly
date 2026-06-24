import 'package:flutter/material.dart';

import 'package:Pulsly/widgets/avatar.dart';
import 'package:Pulsly/utils/date_time_extension.dart';

/// Displays a chat list item from cached data while the Matrix SDK is still
/// loading. Visually matches [ChatListItem] but uses the cached snapshot.
class CachedChatListItem extends StatelessWidget {
  final Map<String, dynamic> room;
  final void Function()? onTap;

  const CachedChatListItem({
    super.key,
    required this.room,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final name = (room['name'] as String?)?.isNotEmpty == true
        ? room['name'] as String
        : '...';
    final lastMessage = room['lastMessage'] as String? ?? '';
    final avatarUrl = room['avatarUrl'] as String?;
    final timestamp = room['lastTimestamp'] as int?;
    final unread = room['unread'] as bool? ?? false;
    final notificationCount = (room['notificationCount'] as num?)?.toInt() ?? 0;
    final isMuted = room['isMuted'] as bool? ?? false;
    final isFavourite = room['isFavourite'] as bool? ?? false;

    return ListTile(
      visualDensity: const VisualDensity(vertical: -0.5),
      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
      onTap: onTap,
      leading: Avatar(
        mxContent: avatarUrl != null ? Uri.tryParse(avatarUrl) : null,
        size: Avatar.defaultSize,
        name: name,
      ),
      title: Row(
        children: [
          Expanded(
            child: Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
          if (isMuted)
            const Padding(
              padding: EdgeInsets.only(left: 4.0),
              child: Icon(Icons.notifications_off_outlined, size: 16),
            ),
          if (isFavourite)
            Padding(
              padding: EdgeInsets.only(
                right: notificationCount > 0 ? 4.0 : 0.0,
              ),
              child: Icon(
                Icons.push_pin,
                size: 16,
                color: theme.colorScheme.primary,
              ),
            ),
          if (timestamp != null)
            Padding(
              padding: const EdgeInsets.only(left: 4.0),
              child: Text(
                DateTime.fromMillisecondsSinceEpoch(timestamp)
                    .localizedTimeShort(context),
                style: TextStyle(
                  fontSize: 12,
                  color: theme.colorScheme.outline,
                ),
              ),
            ),
        ],
      ),
      subtitle: Row(
        children: [
          Expanded(
            child: Text(
              lastMessage,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: theme.colorScheme.outline,
              ),
            ),
          ),
          if (notificationCount > 0 || unread)
            UnreadBadge(count: notificationCount, unread: unread),
        ],
      ),
    );
  }
}

class UnreadBadge extends StatelessWidget {
  final int count;
  final bool unread;

  const UnreadBadge({
    super.key,
    required this.count,
    required this.unread,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(left: 4),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        count > 0 ? count.toString() : '',
        style: TextStyle(
          color: theme.colorScheme.onPrimary,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
