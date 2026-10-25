import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:Pulsly/generated/l10n/l10n.dart';
import 'package:Pulsly/utils/bridge_utils.dart';

class BridgeFilterBar extends StatelessWidget {
  final Set<String> allBridgeTypes;
  final Set<String> visibleBridgeTypes;
  final void Function(Set<String>) onChanged;
  final Map<String, int>
  unreadCounts; // Nieuw: ongelezen counts per bridge type
  final VoidCallback? onDiagnose;

  const BridgeFilterBar({
    required this.allBridgeTypes,
    required this.visibleBridgeTypes,
    required this.onChanged,
    this.unreadCounts = const {}, // Default leeg
    this.onDiagnose,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (allBridgeTypes.isEmpty) return const SizedBox.shrink();

    final sortedTypes = allBridgeTypes.toList()
      ..sort((a, b) {
        const order = [
          'matrix',
          'whatsapp',
          'telegram',
          'signal',
          'discord',
          'slack',
          'linkedin',
          'irc',
        ];
        final ia = order.indexOf(a);
        final ib = order.indexOf(b);
        if (ia != -1 && ib != -1) return ia.compareTo(ib);
        if (ia != -1) return -1;
        if (ib != -1) return 1;
        return a.compareTo(b);
      });

    // "Alles" is geselecteerd zodra elk netwerk zichtbaar is.
    final allVisible = allBridgeTypes.every(visibleBridgeTypes.contains);

    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: sortedTypes.length + 1 + (onDiagnose != null ? 1 : 0),
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          // Eerste chip: "Alles" — reset de netwerkfilter in één tik.
          if (i == 0) {
            return FilterChip(
              showCheckmark: false,
              avatar: Icon(
                Icons.public,
                size: 16,
                color: allVisible
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              label: Text(L10n.of(context).all),
              selected: allVisible,
              onSelected: (_) => onChanged(Set<String>.from(allBridgeTypes)),
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
              selectedColor: theme.colorScheme.primaryContainer,
              checkmarkColor: theme.colorScheme.primary,
              labelStyle: TextStyle(
                color: allVisible
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                fontWeight: allVisible ? FontWeight.w600 : FontWeight.normal,
              ),
              side: BorderSide.none,
            );
          }
          // Laatste knop: netwerkdiagnose (welk signaal herkent welke chat?).
          if (onDiagnose != null && i == sortedTypes.length + 1) {
            return Center(
              child: IconButton(
                icon: const Icon(Icons.info_outline, size: 18),
                tooltip: L10n.of(context).bridgeDiagnoseTooltip,
                visualDensity: VisualDensity.compact,
                onPressed: onDiagnose,
              ),
            );
          }
          final type = sortedTypes[i - 1];
          final isSelected = visibleBridgeTypes.contains(type);
          final color = getBridgeTypeColor(type);
          final unreadCount = unreadCounts[type] ?? 0;
          final svg = getBridgeTypeSvg(type);

          return FilterChip(
            avatar: Stack(
              clipBehavior: Clip.none,
              children: [
                if (svg != null)
                  SvgPicture.asset(
                    svg,
                    width: 16,
                    height: 16,
                    fit: BoxFit.contain,
                    colorFilter: ColorFilter.mode(
                      isSelected ? color : theme.colorScheme.onSurface,
                      BlendMode.srcIn,
                    ),
                  )
                else
                  Icon(
                    getBridgeTypeIcon(type),
                    size: 16,
                    color: isSelected ? color : theme.colorScheme.onSurface,
                  ),
                // Badge voor ongelezen
                if (unreadCount > 0)
                  Positioned(
                    right: -6,
                    top: -4,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.error,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        unreadCount > 99 ? '99+' : unreadCount.toString(),
                        style: TextStyle(
                          color: theme.colorScheme.onError,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            label: Text(getBridgeTypeLabel(type)),
            selected: isSelected,
            onSelected: (selected) {
              final newSet = Set<String>.from(visibleBridgeTypes);
              if (selected) {
                newSet.add(type);
              } else {
                newSet.remove(type);
              }
              onChanged(newSet);
            },
            backgroundColor: theme.colorScheme.surfaceContainerHighest,
            selectedColor: color.withValues(alpha: 0.2),
            checkmarkColor: color,
            labelStyle: TextStyle(
              color: isSelected
                  ? color
                  : theme.colorScheme.onSurface,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
            side: BorderSide.none,
          );
        },
      ),
    );
  }
}
