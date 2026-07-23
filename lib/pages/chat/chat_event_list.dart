import 'package:flutter/material.dart';

import 'package:scroll_to_index/scroll_to_index.dart';

import 'package:Pulsly/config/setting_keys.dart';
import 'package:Pulsly/config/themes.dart';
import 'package:Pulsly/generated/l10n/l10n.dart';
import 'package:Pulsly/pages/chat/chat.dart';
import 'package:Pulsly/pages/chat/events/message.dart';
import 'package:Pulsly/pages/chat/seen_by_row.dart';
import 'package:Pulsly/pages/chat/typing_indicators.dart';
import 'package:Pulsly/utils/matrix_sdk_extensions/filtered_timeline_extension.dart';
import 'package:Pulsly/utils/platform_infos.dart';
import 'package:Pulsly/utils/room_status_extension.dart';

class ChatEventList extends StatelessWidget {
  final ChatController controller;
  final bool showThreadRoots;

  const ChatEventList({
    super.key,
    required this.controller,
    this.showThreadRoots = false,
  });

  @override
  Widget build(BuildContext context) {
    final timeline = controller.timeline;

    if (timeline == null) {
      return const Center(child: CircularProgressIndicator.adaptive());
    }

    // Touch timelineTick so any timeline mutation (e.g. a sent message)
    // forces this list to rebuild. timeline.events mutates in place, so
    // Flutter would otherwise treat the update as a no-op.
    // ignore: unused_local_variable
    final tick = controller.timelineTick;
    final theme = Theme.of(context);

    final colors = [theme.secondaryBubbleColor, theme.bubbleColor];

    final latestReadEvent = controller.room.getLatestReadMessage(timeline);

    final horizontalPadding = FluffyThemes.isColumnMode(context) ? 8.0 : 0.0;

    var events = timeline.events;

    if (showThreadRoots) {
      events = events.filterThreadRoots();
    } else {
      events = events.filterByThreaded(controller.thread != null);
    }

    events = events.filterByVisibleInGui();

    final threads = controller.room.threads;

    final thisEventsKeyMap = <String, int>{};
    for (var i = 0; i < events.length; i++) {
      thisEventsKeyMap[events[i].eventId] = i;
    }

    final hasWallpaper = AppSettings.wallpaperPath.value.isNotEmpty;

    final latestReadEventIndex = latestReadEvent != null
        ? events.indexWhere((event) => event.eventId == latestReadEvent)
        : -1;

    return CustomScrollView(
      controller: controller.scrollController,
      reverse: true,
      keyboardDismissBehavior: PlatformInfos.isIOS
          ? ScrollViewKeyboardDismissBehavior.onDrag
          : ScrollViewKeyboardDismissBehavior.manual,
      slivers: [
        // SeenByRow + dynamic bottom spacer that adjusts to the input bar height.
        // Because the list is reverse: true, this first sliver sits at
        // the visual bottom (just above the floating input bar).
        SliverToBoxAdapter(
          child: ValueListenableBuilder<double>(
            valueListenable: controller.inputBarHeight,
            builder: (context, height, _) => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SeenByRow(controller),
                SizedBox(height: height + 8),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: EdgeInsets.only(
            top: AppSettings.enableChatFrostedGlass.value
                ? MediaQuery.of(context).padding.top + 16
                : 16,
            left: horizontalPadding,
            right: horizontalPadding,
          ),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (BuildContext context, int i) {
                if (i == 0) {
                  if (timeline.canRequestFuture) {
                    return Center(
                      child: ElevatedButton(
                        onPressed: controller.requestFuture,
                        child: timeline.isRequestingFuture
                            ? const LinearProgressIndicator()
                            : Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.arrow_downward),
                                  const SizedBox(width: 5),
                                  Text(L10n.of(context).loadMore),
                                ],
                              ),
                      ),
                    );
                  }
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [TypingIndicators(controller)],
                  );
                }

                if (i == events.length + 1) {
                  // Auto-request history when within 50 events of the top,
                  // matching FluffyChat behaviour — no "Load More" button needed.
                  if (timeline.canRequestHistory && !timeline.isRequestingHistory) {
                    final visibleIndex = events.lastIndexWhere(
                      (event) => event.isVisibleInGui,
                    );
                    if (visibleIndex > events.length - 50) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (controller.mounted) controller.requestHistory();
                      });
                    }
                  }
                  if (timeline.isRequestingHistory) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.only(top: 16.0),
                        child: CircularProgressIndicator.adaptive(strokeWidth: 2),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                }
                i--;

                final event = events[i];
                final animateIn =
                    i == 0 &&
                    (DateTime.now().millisecondsSinceEpoch -
                            event.originServerTs.millisecondsSinceEpoch) <
                        1000 &&
                    controller.firstUpdateReceived;

                final thread = threads.containsKey(event.eventId)
                    ? threads[event.eventId]
                    : null;

                return AutoScrollTag(
                  key: ValueKey(event.transactionId ?? event.eventId),
                  index: i,
                  controller: controller.scrollController,
                  child: Message(
                    event,
                    animateIn: animateIn,
                    thread: thread,
                    singleSelected:
                        controller.selectedEvents.length == 1 &&
                        controller.selectedEvents.first.eventId ==
                            event.eventId,
                    onSwipe: () => controller.replyAction(replyTo: event),
                    hasBeenRead:
                        latestReadEventIndex != -1 &&
                        latestReadEventIndex <= i,
                    readReceipts: event.receipts.toList(),
                    onInfoTab: controller.showEventInfo,
                    onMention: () => controller.sendController.text +=
                        '${event.senderFromMemoryOrFallback.mention} ',
                    highlightMarker:
                        controller.scrollToEventIdMarker == event.eventId,
                    onSelect: controller.onSelectMessage,
                    scrollToEventId: (String eventId) =>
                        controller.scrollToEventId(eventId),
                    longPressSelect: controller.selectedEvents.isNotEmpty,
                    selected: controller.selectedEvents.any(
                      (e) => e.eventId == event.eventId,
                    ),
                    timeline: timeline,
                    displayReadMarker:
                        controller.readMarkerEventId == event.eventId,
                    nextEvent: i + 1 < events.length ? events[i + 1] : null,
                    previousEvent: i > 0 ? events[i - 1] : null,
                    wallpaperMode: hasWallpaper,
                    colors: colors,
                    gradient: AppSettings.enableGradient.value,
                  ),
                );
              },
              childCount: events.length + 2,
              findChildIndexCallback: (key) =>
                  controller.findChildIndexCallback(key, thisEventsKeyMap),
            ),
          ),
        ),
      ],
    );
  }
}
