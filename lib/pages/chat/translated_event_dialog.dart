import 'package:flutter/material.dart';

import 'package:matrix/matrix.dart';

import 'package:extera_next/config/themes.dart';
import 'package:extera_next/generated/l10n/l10n.dart';
import 'package:extera_next/pages/chat/events/message.dart';
import 'package:extera_next/widgets/layouts/max_width_body.dart';

class TranslatedEventDialog extends StatefulWidget {
  final Event event;
  final String engine;
  final Timeline timeline;

  const TranslatedEventDialog({
    required this.event,
    required this.timeline,
    required this.engine,
    super.key,
  });

  @override
  TranslatedEventDialogState createState() => TranslatedEventDialogState();
}

class TranslatedEventDialogState extends State<TranslatedEventDialog> {
  Event get event => widget.event;
  Timeline get timeline => widget.timeline;
  String get engine => widget.engine;

  TranslatedEventDialogState();
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final colors = [theme.secondaryBubbleColor, theme.bubbleColor];

    final message = Message(
      event,
      colors: colors,
      onInfoTab: (Event ev) => {},
      onMention: () => {},
      onSelect: (Event ev, Offset? tapPosition) => {},
      onSwipe: (Event? ev) => {},
      scrollToEventId: (String p0) => {},
      timeline: timeline,
      animateIn: false,
      displayReadMarker: false,
      highlightMarker: false,
      longPressSelect: false,
      selected: false,
      wallpaperMode: false,
      gradient: false,
    );

    return Scaffold(
      appBar: AppBar(title: Text(L10n.of(context).translatedMessage)),
      body: MaxWidthBody(
        child: Column(
          mainAxisSize: .max,
          children: [
            message,
            Text(L10n.of(context).translatedWith(engine), style: TextStyle(color: theme.hintColor)),
          ],
        ),
      ),
    );
  }
}
