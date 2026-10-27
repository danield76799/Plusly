import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';
import 'package:matrix/matrix.dart';

import 'package:Pulsly/config/setting_keys.dart';
import 'package:Pulsly/config/themes.dart';
import 'package:Pulsly/generated/l10n/l10n.dart';
import 'package:Pulsly/pages/chat/chat.dart';
import 'package:Pulsly/utils/matrix_sdk_extensions/matrix_locals.dart';
import 'package:Pulsly/utils/sync_status_localization.dart';
import 'package:Pulsly/widgets/avatar.dart';
import 'package:Pulsly/widgets/clock_text.dart';

class ChatAppBarTitle extends StatelessWidget {
  final ChatController controller;
  const ChatAppBarTitle(this.controller, {super.key});

  /// De tweede regel onder de naam in de kop: een klok met de huidige
  /// tijd, net als in de kop van de chatlijst (home).
  ///
  /// Vóór deze wijziging stond hier de presencedata ("Laatst gezien om
  /// 20:01"), en die verscheen alleen terwijl er gesynchroniseerd werd — in
  /// een brugkamer, waar meestal geen presencedata is, was de regel daardoor
  /// vrijwel altijd leeg. De gebruiker vroeg om een klok, zoals op de home.
  ///
  /// Een echte sync-fout blijft zichtbaar (in de foutkleur): die mag niet
  /// stilletjes verdwijnen.
  Widget _buildStatusLine(
    BuildContext context, {
    required bool compact,
  }) {
    final room = controller.room;
    final theme = Theme.of(context);
    return StreamBuilder(
      stream: room.client.onSyncStatus.stream,
      builder: (context, snapshot) {
        final status =
            room.client.onSyncStatus.value ??
            const SyncStatusUpdate(SyncStatus.waitingForResponse);
        if (status.status == SyncStatus.error) {
          return Text(
            status.calcLocalizedString(context),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: compact ? 11 : 12,
              color: theme.colorScheme.error,
            ),
          );
        }
        return ClockText(
          fontSize: compact ? 11 : 13,
          fontWeight: FontWeight.w600,
          color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final room = controller.room;
    if (controller.selectedEvents.isNotEmpty) {
      return Text(
        controller.selectedEvents.length.toString(),
        style: TextStyle(color: Theme.of(context).colorScheme.tertiary),
      );
    }
    final centerTitle = AppSettings.enableAppBarCenterTitle.value;
    return InkWell(
      hoverColor: Colors.transparent,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onTap: () {
        if (controller.thread != null) {
          if (context.canPop()) {
            context.pop();
          } else {
            context.go('/rooms/${room.id}');
          }
          return;
        }
        if (!controller.isArchived) {
          if (FluffyThemes.isThreeColumnMode(context)) {
            controller.toggleDisplayChatDetailsColumn();
          } else {
            context.go('/rooms/${room.id}/details');
          }
        }
      },
      child: centerTitle
          ? Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Hero(
                      tag: 'content_banner',
                      child: controller.thread == null
                          ? Avatar(
                              mxContent: room.avatar,
                              name: room.getLocalizedDisplayname(
                                MatrixLocals(L10n.of(context)),
                              ),
                              size: 28,
                            )
                          : Icon(
                              Icons.chat_bubble_outline,
                              color: Theme.of(context).colorScheme.onSurface.withAlpha(200),
                              size: 18,
                            ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        controller.thread == null
                            ? room.getLocalizedDisplayname(
                                MatrixLocals(L10n.of(context)),
                              )
                            : '${controller.thread!.rootEvent.senderFromMemoryOrFallback.displayName ?? controller.thread!.rootEvent.senderId}: ${controller.thread!.rootEvent.text}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
                _buildStatusLine(context, compact: true),
              ],
            )
          : Row(
              children: [
                Hero(
                  tag: 'content_banner',
                  child: controller.thread == null
                      ? Avatar(
                          mxContent: room.avatar,
                          name: room.getLocalizedDisplayname(
                            MatrixLocals(L10n.of(context)),
                          ),
                          size: 32,
                        )
                      : Icon(
                          Icons.chat_bubble_outline,
                          color: Theme.of(context).colorScheme.onSurface.withAlpha(200),
                          size: 20,
                        ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        controller.thread == null
                            ? room.getLocalizedDisplayname(
                                MatrixLocals(L10n.of(context)),
                              )
                            : '${controller.thread!.rootEvent.senderFromMemoryOrFallback.displayName ?? controller.thread!.rootEvent.senderId}: ${controller.thread!.rootEvent.text}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 16),
                      ),
                      _buildStatusLine(context, compact: false),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
