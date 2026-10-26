import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:matrix/matrix.dart';

import 'package:Pulsly/generated/l10n/l10n.dart';
import 'package:Pulsly/pages/chat_list/chat_list_item.dart';
import 'package:Pulsly/utils/bridge_utils.dart';
import 'package:Pulsly/utils/room_unread_extension.dart';
import 'package:Pulsly/widgets/matrix.dart';

/// Overzicht van alle bridge-netwerken: de "Universal Hub"-weergave waarin
/// per netwerk te zien is hoeveel chats er zijn, hoeveel ongelezen berichten
/// er liggen en welke chats het recentst zijn.
///
/// Gevuld vanuit de chatlijst; de lijst zelf blijft op de achtergrond
/// staan zodat de gebruiker met de tabbalk kan terugschakelen.
class NetworksView extends StatelessWidget {
  final void Function(Room) onChatTap;
  final int maxChatsPerNetwork;

  const NetworksView({
    required this.onChatTap,
    this.maxChatsPerNetwork = 5,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final client = Matrix.of(context).client;

    final byNetwork = <String, List<Room>>{};
    for (final room in client.rooms) {
      if (room.isSpace) continue;
      final type = getBridgeType(room);
      if (type == null) continue;
      byNetwork.putIfAbsent(type, () => []).add(room);
    }

    if (byNetwork.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
        child: Column(
          children: [
            Icon(
              Icons.hub_outlined,
              size: 40,
              color: theme.colorScheme.outline,
            ),
            const SizedBox(height: 12),
            Text(
              L10n.of(context).networksNone,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    // Bekende netwerken eerst, in een vaste volgorde; onbekende achteraan.
    const order = [
      'whatsapp',
      'telegram',
      'signal',
      'discord',
      'slack',
      'linkedin',
      'matrix',
    ];
    final netwerken = byNetwork.keys.toList()
      ..sort((a, b) {
        final ia = order.indexOf(a);
        final ib = order.indexOf(b);
        if (ia != -1 && ib != -1) return ia.compareTo(ib);
        if (ia != -1) return -1;
        if (ib != -1) return 1;
        return a.compareTo(b);
      });

    for (final rooms in byNetwork.values) {
      rooms.sort(
        (a, b) => b.latestEventReceivedTime.compareTo(a.latestEventReceivedTime),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final type in netwerken) ...[
          _NetworkHeader(type: type, rooms: byNetwork[type]!),
          for (final room in byNetwork[type]!.take(maxChatsPerNetwork))
            ChatListItem(
              room,
              onTap: () => onChatTap(room),
              noBackgroundColor: true,
            ),
          if (byNetwork[type]!.length > maxChatsPerNetwork)
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 2, 16, 10),
              child: Text(
                L10n.of(
                  context,
                ).networksMoreChats(byNetwork[type]!.length - maxChatsPerNetwork),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          const Divider(height: 12, indent: 24, endIndent: 16),
        ],
        const SizedBox(height: 120),
      ],
    );
  }
}

class _NetworkHeader extends StatelessWidget {
  final String type;
  final List<Room> rooms;

  const _NetworkHeader({required this.type, required this.rooms});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = getBridgeTypeColor(type);
    final svg = getBridgeTypeSvg(type);
    final unread = rooms.where((r) => r.isEffectivelyUnreadSync).length;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
      child: Row(
        children: [
          if (svg != null)
            SvgPicture.asset(
              svg,
              width: 22,
              height: 22,
              fit: BoxFit.contain,
              colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
            )
          else
            Icon(getBridgeTypeIcon(type), size: 22, color: color),
          const SizedBox(width: 8),
          Text(
            getBridgeTypeLabel(type),
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${rooms.length}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const Spacer(),
          if (unread > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                color: theme.colorScheme.error,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                unread > 99 ? '99+' : '$unread',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onError,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
