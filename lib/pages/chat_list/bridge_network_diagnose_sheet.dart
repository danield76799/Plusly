import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:matrix/matrix.dart';

import 'package:Pulsly/generated/l10n/l10n.dart';
import 'package:Pulsly/utils/bridge_utils.dart';
import 'package:Pulsly/widgets/matrix.dart';

/// Diagnose-overzicht van de bridge-netwerken.
///
/// Toont per netwerk hoeveel chats er zijn en welk signaal de herkenning
/// draagt (state-event, bridge-bot of alias). Daarnaast worden chats
/// getoond die wél een netwerkwoord in hun naam hebben maar géén brugsignaal
/// — dat zijn kandidaten die de filter nog niet ziet.
class BridgeNetworkDiagnoseSheet extends StatelessWidget {
  const BridgeNetworkDiagnoseSheet({super.key});

  /// Kamers die op een brug lijken (netwerkwoord in naam/topic/alias) maar
  /// geen herkenbaar brugsignaal hebben.
  static bool looksLikeBridge(Room room) {
    final haystack = [
      room.name,
      room.topic,
      room.canonicalAlias,
    ].join(' ').toLowerCase();
    for (final netwerk in [
      'whatsapp',
      'telegram',
      'signal',
      'discord',
      'slack',
      'linkedin',
    ]) {
      if (haystack.contains(netwerk)) return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final client = Matrix.of(context).client;
    final rooms = client.rooms.where((room) => !room.isSpace).toList();

    final byNetwork = <String, List<Room>>{};
    final unrecognized = <Room>[];
    for (final room in rooms) {
      final type = getBridgeType(room);
      if (type != null) {
        byNetwork.putIfAbsent(type, () => []).add(room);
      } else if (looksLikeBridge(room)) {
        unrecognized.add(room);
      }
    }

    final netwerken = byNetwork.keys.toList()
      ..sort(
        (a, b) => byNetwork[b]!.length.compareTo(byNetwork[a]!.length),
      );

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.6,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return Material(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          clipBehavior: Clip.antiAlias,
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                L10n.of(context).bridgeDiagnoseTitle,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                L10n.of(context).bridgeDiagnoseSubtitle,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16),
              if (netwerken.isEmpty && unrecognized.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Text(
                    L10n.of(context).bridgeDiagnoseNoNetworks,
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
              for (final netwerk in netwerken) ...[
                _NetworkSection(
                  netwerk: netwerk,
                  rooms: byNetwork[netwerk]!,
                ),
                const SizedBox(height: 12),
              ],
              if (unrecognized.isNotEmpty) ...[
                Text(
                  '${L10n.of(context).bridgeDiagnoseUnrecognized} '
                  '(${unrecognized.length})',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.error,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  L10n.of(context).bridgeDiagnoseUnrecognizedHelp,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 8),
                for (final room in unrecognized.take(20))
                  ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.help_outline, size: 20),
                    title: Text(
                      room.name.isEmpty ? room.id : room.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      room.canonicalAlias.isEmpty
                          ? room.topic
                          : room.canonicalAlias,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _NetworkSection extends StatelessWidget {
  final String netwerk;
  final List<Room> rooms;

  const _NetworkSection({required this.netwerk, required this.rooms});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = getBridgeTypeColor(netwerk);
    final svg = getBridgeTypeSvg(netwerk);

    // Het signaal is voor alle kamers van een netwerk meestal hetzelfde:
    // neem het meest voorkomende.
    final signalCounts = <String, int>{};
    for (final room in rooms) {
      final signal = bridgeDetectionSignal(room) ?? 'onbekend';
      signalCounts[signal] = (signalCounts[signal] ?? 0) + 1;
    }
    final topSignal = signalCounts.entries.isEmpty
        ? null
        : (signalCounts.entries.toList()
              ..sort((a, b) => b.value.compareTo(a.value)))
            .first;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (svg != null)
                SvgPicture.asset(
                  svg,
                  width: 20,
                  height: 20,
                  fit: BoxFit.contain,
                  colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
                )
              else
                Icon(getBridgeTypeIcon(netwerk), size: 20, color: color),
              const SizedBox(width: 8),
              Text(
                getBridgeTypeLabel(netwerk),
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const Spacer(),
              Text(
                '${rooms.length}',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          if (topSignal != null) ...[
            const SizedBox(height: 6),
            Text(
              topSignal.key,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontFamily: 'monospace',
              ),
            ),
            if (signalCounts.length > 1) ...[
              const SizedBox(height: 4),
              Text(
                '${signalCounts.length} '
                '${L10n.of(context).bridgeDiagnoseSignals}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }
}
