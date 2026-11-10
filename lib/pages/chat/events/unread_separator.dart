import 'package:flutter/material.dart';

import 'package:Pulsly/config/app_config.dart';
import 'package:Pulsly/generated/l10n/l10n.dart';

/// Scheiding tussen gelezen en ongelezen berichten.
///
/// WhatsApp zet op die plek een horizontale lijn met het aantal ongelezen
/// berichten erin. Dat is het enige moment waarop je in één oogopslag ziet
/// waar je gebleven was — zonder die lijn loopt oud en nieuw door elkaar.
///
/// De lijn staat op het moment van openen: het eerste bericht dat je nog
/// niet gezien had. Dat punt blijft staan zolang je in het gesprek bent,
/// ook als er intussen nieuwe berichten binnenkomen — precies zoals in
/// WhatsApp.
class UnreadSeparator extends StatelessWidget {
  final int count;

  const UnreadSeparator({super.key, required this.count});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = theme.colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 8),
      child: Row(
        children: [
          Expanded(child: Divider(color: color.withValues(alpha: 0.35))),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppConfig.borderRadius),
              ),
              child: Text(
                L10n.of(context).unreadMessages(count),
                style: theme.textTheme.labelMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          Expanded(child: Divider(color: color.withValues(alpha: 0.35))),
        ],
      ),
    );
  }
}
