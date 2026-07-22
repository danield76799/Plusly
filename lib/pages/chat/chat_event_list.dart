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

    // Touch timelineTick so the parent setState (which bumps it inside
    // ChatController.updateView) always rebuilds this list. Without this
    // hook Flutter would happily treat the update as a no-op and the
    // freshly sent event would never make it into the visible list.
    // ignore: unused_local_variable
    final tick = controller.timelineTick;

    if (timeline == null) {
      return const Center(child: CircularProgressIndicator.adaptive());
    }
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

    // Cache the filtered list — only re-filter when the timeline tick
    // changes (i.e. when updateView() bumps it after a new event).
    // Without this, every rebuild re-filters potentially hundreds of
    // events through filterByThreaded + filterByVisibleInGui.
    if (controller.cachedFilteredEvents != null &&
        controller.cachedEventsTick == tick) {
      events = controller.cachedFilteredEvents!;
    } else {
      events = events.filterByVisibleInGui();
      controller.cachedFilteredEvents = events;
      controller.cachedEventsTick = tick;
    }

    final threads = controller.room.threads;

    // Compute isOneOnOne once for the whole list — avoids calling
    // getParticipants() (O(n) over room members) for every message bubble.
    final isOneOnOne = controller.room.isDirectChat ||
        controller.room.getParticipants().length <= 4;

    // Cache the events key map — only rebuild when the tick changes.
    Map<String, int> thisEventsKeyMap;
    if (controller.cachedEventsKeyMap != null &&
        controller.cachedEventsTick == tick) {
      thisEventsKeyMap = controller.cachedEventsKeyMap!;
    } else {
      thisEventsKeyMap = <String, int>{};
      for (var i = 0; i < events.length; i++) {
        thisEventsKeyMap[events[i].eventId] = i;
        if (events[i].transactionId != null) {
          thisEventsKeyMap[events[i].transactionId!] = i;
        }
      }
      controller.cachedEventsKeyMap = thisEventsKeyMap;
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
                SeenByRow(event: timeline.events.first),
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
                  return RepaintBoundary(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [TypingIndicators(controller)],
                    ),
                  );
                }

                if (i == events.length + 1) {
                  if (timeline.canRequestHistory && !timeline.isRequestingHistory) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (controller.mounted) controller.requestHistory();
                    });
                    final hasScrollBanner =
                        controller.scrollUpBannerEventId != null;
                    return Padding(
                      padding: EdgeInsets.only(
                        top: hasScrollBanner ? 72.0 : 0.0,
                      ),
                      child: Center(
                        child: ElevatedButton(
                          onPressed: controller.requestHistory,
                          child: timeline.isRequestingHistory
                              ? const LinearProgressIndicator()
                              : Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.arrow_upward),
                                    const SizedBox(width: 5),
                                    Text(L10n.of(context).loadMore),
                                  ],
                                ),
                        ),
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
                  child: RepaintBoundary(
                    child: Message(
                      event,
                      key: ValueKey(event.eventId),
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
                      readReceipts: event.receipts.toList(), // NEW: Pass read receipts to Message
                      isOneOnOne: isOneOnOne,
                      // onQuote: () {
                      //   controller.replyAction(replyTo: event);
                      //   controller.sendController.text = "> ";
                      // },
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
