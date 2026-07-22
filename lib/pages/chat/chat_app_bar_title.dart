import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';
import 'package:matrix/matrix.dart';

import 'package:Pulsly/config/setting_keys.dart';
import 'package:Pulsly/config/themes.dart';
import 'package:Pulsly/generated/l10n/l10n.dart';
import 'package:Pulsly/pages/chat/chat.dart';
import 'package:Pulsly/utils/date_time_extension.dart';
import 'package:Pulsly/utils/matrix_sdk_extensions/matrix_locals.dart';
import 'package:Pulsly/utils/sync_status_localization.dart';
import 'package:Pulsly/widgets/avatar.dart';
import 'package:Pulsly/widgets/overflow_marquee.dart';
import 'package:Pulsly/widgets/presence_builder.dart';

class ChatAppBarTitle extends StatelessWidget {
  final ChatController controller;
  const ChatAppBarTitle(this.controller, {super.key});

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
    final displayName = controller.thread == null
        ? room.getLocalizedDisplayname(MatrixLocals(L10n.of(context)))
        : '${controller.thread!.rootEvent.senderFromMemoryOrFallback.displayName ?? controller.thread!.rootEvent.senderId}: ${controller.thread!.rootEvent.text}';
    final avatar = controller.thread == null
        ? Avatar(
            mxContent: room.avatar,
            name: room.getLocalizedDisplayname(MatrixLocals(L10n.of(context))),
            size: centerTitle ? 28 : 32,
          )
        : Icon(
            Icons.chat_bubble_outline,
            color: Theme.of(context).colorScheme.onSurface.withAlpha(200),
            size: centerTitle ? 18 : 20,
          );

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
                    Hero(tag: 'content_banner', child: avatar),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        displayName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
                _SyncStatusText(room: room, centerTitle: centerTitle),
              ],
            )
          : Row(
              children: [
                Hero(tag: 'content_banner', child: avatar),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        displayName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 16),
                      ),
                      _SyncStatusText(room: room, centerTitle: centerTitle),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

/// Isolated sync-status subtitle. Its own StreamBuilder means the parent
/// app-bar title (and the AnimatedSize that changes its height) does NOT
/// rebuild on every sync status change — only this small widget does.
class _SyncStatusText extends StatelessWidget {
  final Room room;
  final bool centerTitle;

  const _SyncStatusText({required this.room, required this.centerTitle});

  @override
  Widget build(BuildContext context) {
    final client = room.client;
    return StreamBuilder<SyncStatusUpdate>(
      stream: client.onSyncStatus.stream,
      builder: (context, snapshot) {
        final status = client.onSyncStatus.value ??
            const SyncStatusUpdate(SyncStatus.waitingForResponse);
        final hide = FluffyThemes.isColumnMode(context) ||
            (client.onSync.value != null &&
                status.status != SyncStatus.error &&
                client.prevBatch != null);
        if (hide) {
          return PresenceBuilder(
            userId: room.directChatMatrixID,
            builder: (context, presence) {
              final lastActiveTimestamp = presence?.lastActiveTimestamp;
              final style = Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontSize: centerTitle ? 11 : 12,
                  );
              if (presence?.currentlyActive == true) {
                return OverflowMarquee(
                  text:
                      "${L10n.of(context).currentlyActive}${presence?.statusMsg != null ? " | ${presence?.statusMsg}" : ""}",
                  style: style!,
                  velocity: 20.0,
                  height: (style.fontSize ?? (centerTitle ? 11 : 12)) + 2,
                );
              }
              if (lastActiveTimestamp != null) {
                return OverflowMarquee(
                  text:
                      L10n.of(context).lastActiveAgo(
                        lastActiveTimestamp.localizedTimeShort(context),
                      ) +
                      (presence?.statusMsg != null
                          ? " | ${presence?.statusMsg}"
                          : ""),
                  style: style!,
                  velocity: 20.0,
                  height: (style.fontSize ?? (centerTitle ? 11 : 12)) + 2,
                );
              }
              return const SizedBox.shrink();
            },
          );
        }
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox.square(
              dimension: 10,
              child: CircularProgressIndicator.adaptive(
                strokeWidth: 1,
                value: status.progress,
                valueColor: status.error != null
                    ? AlwaysStoppedAnimation<Color>(
                        Theme.of(context).colorScheme.error,
                      )
                    : null,
              ),
            ),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                status.calcLocalizedString(context),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: centerTitle ? 11 : 12,
                  color: status.error != null
                      ? Theme.of(context).colorScheme.error
                      : null,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
