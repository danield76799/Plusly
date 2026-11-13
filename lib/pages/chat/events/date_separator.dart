import 'package:flutter/material.dart';

import 'package:Pulsly/utils/date_time_extension.dart';

/// WhatsApp-achtige datum-scheiding tussen dagen in een gesprek.
///
/// WhatsApp zet een klein, subtiel "pil"-label tussen twee dagen: "Vandaag",
/// "Gisteren", de weekdag of de datum. Dat is het duidelijkste signaal dat
/// een gesprek over meerdere dagen loopt — Plusly miste dat en liet alles
/// als één doorlopende muur zien.
///
/// De pil is bewust compact en licht doorschijnend, net als bij WhatsApp:
/// een zware, bijna-opake capsule valt te veel op tussen de berichten.
class DateSeparator extends StatelessWidget {
  final DateTime timestamp;

  const DateSeparator({super.key, required this.timestamp});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      // Symmetrische, compacte tussenruimte.
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest.withValues(
              alpha: 0.85,
            ),
            borderRadius: BorderRadius.circular(10),
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
