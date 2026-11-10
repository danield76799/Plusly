import 'package:flutter/material.dart';

import 'package:Pulsly/utils/date_time_extension.dart';

/// WhatsApp-achtige datum-scheiding tussen dagen in een gesprek.
///
/// WhatsApp zet een klein "pil"-label tussen twee dagen: "Vandaag",
/// "Gisteren", de weekdag of de datum. Dat is het duidelijkste signaal dat
/// een gesprek over meerdere dagen loopt — Plusly miste dat en liet alles
/// als één doorlopende muur zien.
class DateSeparator extends StatelessWidget {
  final DateTime timestamp;

  const DateSeparator({super.key, required this.timestamp});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 6, bottom: 10),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest.withValues(
              alpha: 0.95,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            timestamp.localizedMonthDay(context),
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
