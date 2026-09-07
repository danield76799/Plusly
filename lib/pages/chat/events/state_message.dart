import 'package:flutter/material.dart';

import 'package:matrix/matrix.dart';

import 'package:Pulsly/config/setting_keys.dart';
import 'package:Pulsly/generated/l10n/l10n.dart';
import 'package:Pulsly/pages/chat/chat.dart';
import 'package:Pulsly/pages/chat/events/message_reactions.dart';
import 'package:Pulsly/utils/matrix_sdk_extensions/matrix_locals.dart';
import '../../../config/app_config.dart';

class StateMessage extends StatefulWidget {
  final Event event;
  final bool selected;
  final ChatController? controller;
  const StateMessage(
    this.event, {
    required this.selected,
    this.controller,
    super.key,
  });

  @override
  State<StatefulWidget> createState() => _StateMessageState();
}

class _StateMessageState extends State<StateMessage> {
  Event get event => widget.event;

  Offset? _tapPosition;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const .symmetric(horizontal: 8.0),
      child: Center(
        child: Column(
          mainAxisSize: .min,
          children: [
            Padding(
              padding: const .all(4),
              child: Material(
                color: widget.selected
                    ? theme.colorScheme.surfaceContainerHigh
                    : theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(AppConfig.borderRadius / 3),
                child: InkWell(
                  borderRadius: BorderRadius.circular(
                    AppConfig.borderRadius / 3,
                  ),
                  onSecondaryTapDown: (details) {
                    _tapPosition = details.globalPosition;
                  },
                  onTapDown: (details) {
                    _tapPosition = details.globalPosition;
                  },
                  onLongPress: () {
                    widget.controller?.onSelectMessage(event, _tapPosition);
                  },
                  onSecondaryTap: () {
                    widget.controller?.onSelectMessage(event, _tapPosition);
                  },
                  child: Padding(
                    padding: const .symmetric(horizontal: 8.0, vertical: 4.0),
                    child: Text(
                      event.calcLocalizedBodyFallback(
                        MatrixLocals(L10n.of(context)),
                      ),
                      textAlign: .center,
                      maxLines: 2,
                      overflow: .ellipsis,
                      style: TextStyle(
                        fontSize: 12 * AppSettings.fontSizeFactor.value,
                        decoration: event.redacted ? .lineThrough : null,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            if (widget.controller?.timeline != null)
              MessageReactions(
                event,
                widget.controller!.timeline!,
                chatController: widget.controller,
              ),
          ],
        ),
      ),
    );
  }
}
