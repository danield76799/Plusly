import 'package:flutter/material.dart';
import 'package:matrix/matrix.dart';

import 'package:Pulsly/config/themes.dart';
import 'package:Pulsly/utils/date_time_extension.dart';

/// Voettekst van een bericht: de tijd, optioneel een bewerkingsicoon en de
/// afleverstatus (vinkjes).
///
/// Let op: hier géén `spacing` op de [Wrap] gebruiken. RenderWrap rekent die
/// niet mee in zijn intrinsic width, waardoor de bubbel te smal wordt en de
/// tijd links uit de bubbel loopt (afgekapte "14:00"). De ruimte tussen de
/// onderdelen zit daarom als echte [SizedBox] erin.
class MessageStatusRow extends StatelessWidget {
  final DateTime timestamp;
  final bool edited;
  final bool ownMessage;
  final bool hasBeenRead;
  final EventStatus status;
  final Color color;

  const MessageStatusRow({
    required this.timestamp,
    required this.ownMessage,
    required this.hasBeenRead,
    required this.status,
    required this.color,
    this.edited = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.end,
      crossAxisAlignment: WrapCrossAlignment.center,
      runSpacing: 2,
      children: [
        Text(
          timestamp.localizedMessageTime(context),
          style: TextStyle(color: color, fontSize: 12),
        ),
        if (edited) ...[
          const SizedBox(width: 4),
          Icon(Icons.edit_outlined, color: color, size: 14),
        ],
        if (ownMessage) ...[
          const SizedBox(width: 4),
          Icon(
            status == EventStatus.sending
                ? Icons.watch_later_outlined
                : status == EventStatus.error
                ? Icons.error_outline
                : hasBeenRead
                ? Icons.done_all
                : Icons.check,
            // Twee vinkjes = groen (gelezen), één vinkje = oranje (verzonden)
            color:
                status == EventStatus.sending || status == EventStatus.error
                ? color
                : hasBeenRead
                ? Theme.of(context).readReceiptBlue
                : Colors.orange,
            size: 14,
          ),
        ],
      ],
    );
  }
}
