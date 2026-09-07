import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:go_router/go_router.dart';
import 'package:matrix/matrix.dart';
import 'package:swipe_to_action/swipe_to_action.dart';

import 'package:Pulsly/config/setting_keys.dart';
import 'package:Pulsly/config/themes.dart';
import 'package:Pulsly/generated/l10n/l10n.dart';
import 'package:Pulsly/pages/chat/chat.dart';
import 'package:Pulsly/pages/chat/events/file_sending_indicator.dart';
import 'package:Pulsly/pages/chat/events/room_creation_state_event.dart';
import 'package:Pulsly/utils/date_time_extension.dart';
import 'package:Pulsly/utils/platform_infos.dart';
import 'package:Pulsly/utils/poll_events.dart';
import 'package:Pulsly/utils/privacy_options.dart';
import 'package:Pulsly/utils/string_color.dart';
import 'package:Pulsly/widgets/avatar.dart';
import 'package:Pulsly/widgets/matrix.dart';
import 'package:Pulsly/widgets/member_actions_popup_menu_button.dart';
import '../../../config/app_config.dart';
import 'message_content.dart';
import 'message_reactions.dart';
import 'reply_content.dart';
import 'state_message.dart';

class MessageModern extends StatefulWidget {
  final Event event;
  final Event? nextEvent;
  final Event? previousEvent;
  final bool displayReadMarker;
  final void Function(Event, Offset?) onSelect;
  final void Function(Event) onInfoTab;
  final void Function(String) scrollToEventId;
  final void Function(Event) onSwipe;
  final void Function() onMention;
  final bool longPressSelect;
  final bool selected;
  final Timeline timeline;
  final bool highlightMarker;
  final bool animateIn;
  final bool wallpaperMode;
  final ScrollController? scrollController;
  final ChatController? chatController;
  final List<Color> colors;
  final bool gradient;
  final bool singleSelected;
  final Thread? thread;
  final bool hasBeenRead;
  final bool? exampleMessage;

  const MessageModern(
    this.event, {
    this.nextEvent,
    this.previousEvent,
    this.displayReadMarker = false,
    this.longPressSelect = false,
    this.gradient = false,
    this.singleSelected = false,
    this.hasBeenRead = false,
    this.exampleMessage = false,
    this.thread,
    required this.onSelect,
    required this.onInfoTab,
    required this.scrollToEventId,
    required this.onSwipe,
    this.selected = false,
    required this.timeline,
    this.highlightMarker = false,
    this.animateIn = false,
    this.wallpaperMode = false,
    required this.onMention,
    this.scrollController,
    this.chatController,
    required this.colors,
    super.key,
  });

  @override
  State<MessageModern> createState() => _MessageModernState();
}

class _MessageModernState extends State<MessageModern> {
  Offset _tapPosition = Offset.zero;

  // Cached futures to avoid re-creating them on every build
  late Future<User?> _senderUserFuture;
  Future<Event?>? _replyEventFuture;
  Future<User?>? _threadSenderFuture;

  bool loadMedia = false;

  @override
  void initState() {
    super.initState();
    loadMedia = shouldAutoLoadMedia(
      widget.event.room.client,
      widget.event.room.id,
    );
    _initFutures();
  }

  @override
  void didUpdateWidget(MessageModern oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.event != widget.event) {
      _initFutures();
    } else {
      // Only re-init thread future if thread changed
      if (oldWidget.thread?.lastEvent?.eventId !=
          widget.thread?.lastEvent?.eventId) {
        _initThreadFuture();
      }
    }
  }

  void _initFutures() {
    _senderUserFuture = fetchSenderUser();
    _initReplyFuture();
    _initThreadFuture();
  }

  Future<User?> fetchSenderUser() async {
    final client = Matrix.of(context).client;
    if (widget.event.senderId != client.userID) {
      return await widget.event.fetchSenderUser();
    }
    final cachedProfile = await client.getUserProfile(client.userID!);
    return User(
      client.userID!,
      room: widget.event.room,
      avatarUrl: cachedProfile.avatarUrl?.toString(),
      displayName: cachedProfile.displayname,
    );
  }

  void _initReplyFuture() {
    if (widget.event.inReplyToEventId(includingFallback: false) != null) {
      _replyEventFuture = widget.event.getReplyEvent(widget.timeline);
    } else {
      _replyEventFuture = null;
    }
  }

  void _initThreadFuture() {
    final threadLastEvent = widget.thread?.lastEvent;
    if (threadLastEvent != null &&
        threadLastEvent.relationshipEventId == widget.event.eventId) {
      _threadSenderFuture = threadLastEvent.fetchSenderUser();
    } else {
      _threadSenderFuture = null;
    }
  }

  void _scrollToEvent(Event event, Event? scrolledFrom) {
    if (event.status == EventStatus.error) return; // didn't load yet
    widget.scrollToEventId(event.eventId);
  }

  @override
  Widget build(BuildContext context) {
    final event = widget.event;
    final timeline = widget.timeline;
    final theme = Theme.of(context);

    if (!{
      EventTypes.Message,
      EventTypes.Sticker,
      EventTypes.Encrypted,
      EventTypes.CallInvite,
      PollEvents.pollStart,
    }.contains(event.type)) {
      if (event.type.startsWith('m.call.')) {
        return const SizedBox.shrink();
      }
      if (event.type == EventTypes.RoomCreate) {
        return RoomCreationStateEvent(event: event);
      }
      return StateMessage(
        event,
        selected: widget.selected,
        controller: widget.chatController,
      );
    }

    if (event.type == EventTypes.Message &&
        event.messageType == EventTypes.KeyVerificationRequest) {
      return StateMessage(
        event,
        selected: widget.selected,
        controller: widget.chatController,
      );
    }

    final client = Matrix.of(context).client;
    final ownMessage = event.senderId == client.userID;
    final hasBeenRead = widget.hasBeenRead;

    final displayTime =
        (event.type == EventTypes.RoomCreate ||
            widget.nextEvent == null ||
            !event.originServerTs.sameEnvironment(
              widget.nextEvent!.originServerTs,
            )) &&
        widget.exampleMessage != true;
    final nextEventSameSender =
        widget.nextEvent != null &&
        {
          EventTypes.Message,
          EventTypes.Sticker,
          EventTypes.Encrypted,
          PollEvents.pollStart,
        }.contains(widget.nextEvent!.type) &&
        widget.nextEvent!.senderId == event.senderId &&
        !displayTime;

    // final previousEventSameSender =
    //     widget.previousEvent != null &&
    //     {
    //       EventTypes.Message,
    //       EventTypes.Sticker,
    //       EventTypes.Encrypted,
    //       PollEvents.pollStart,
    //     }.contains(widget.previousEvent!.type) &&
    //     widget.previousEvent!.senderId == event.senderId &&
    //     widget.previousEvent!.originServerTs.sameEnvironment(
    //       event.originServerTs,
    //     );

    final displayEvent = event.getDisplayEvent(timeline);

    final showReactionsRow = event.hasAggregatedEvents(
      timeline,
      RelationshipTypes.reaction,
    );

    Widget buildStatusRow({required Color color}) => Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: .end,
      mainAxisAlignment: .end,
      children: [
        if (event.hasAggregatedEvents(timeline, RelationshipTypes.edit))
          Padding(
            padding: const EdgeInsets.only(left: 3.0),
            child: Icon(Icons.edit_outlined, color: color, size: 12),
          ),
        if (ownMessage)
          Padding(
            padding: const EdgeInsets.only(left: 3.0),
            child: event.fileSendingStatus != null
                ? FileSendingStatusIndicator(
                    event.fileSendingStatus!,
                    color: color,
                    size: 13,
                  )
                : Icon(
                    event.status == EventStatus.sending
                        ? Icons.watch_later_outlined
                        : event.status == EventStatus.error
                        ? Icons.error_outline
                        : hasBeenRead
                        ? Icons.done_all
                        : Icons.check,
                    color: color,
                    size: 13,
                  ),
          ),
        Text(
          event.originServerTs.localizedTimeOfDay(context),
          style: TextStyle(color: color, fontSize: 11, height: 1.0),
        ),
      ],
    );

    final statusColor = theme.colorScheme.onSurfaceVariant;
    final messageStatusRow = buildStatusRow(color: statusColor);

    final row = FutureBuilder<User?>(
      future: _senderUserFuture,
      builder: (context, snapshot) {
        final user = snapshot.data ?? event.senderFromMemoryOrFallback;
        final displayname =
            snapshot.data?.calcDisplayname() ??
            event.senderFromMemoryOrFallback.calcDisplayname();
        return Stack(
          children: [
            Positioned(
              top: 0,
              bottom: 0,
              left: 0,
              right: 0,
              child: InkWell(
                onTapDown: (details) => _tapPosition = details.globalPosition,
                onSecondaryTapDown: (details) =>
                    _tapPosition = details.globalPosition,
                onTap: () => widget.onSelect(event, _tapPosition),
                onLongPress: () {
                  if (PlatformInfos.isMobile) {
                    widget.onSelect(event, _tapPosition);
                  }
                },
                onSecondaryTap: () => widget.onSelect(event, _tapPosition),
                child: Material(
                  color: widget.selected || widget.highlightMarker
                      ? theme.colorScheme.secondaryContainer.withAlpha(128)
                      : Colors.transparent,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                vertical: nextEventSameSender ? 1.0 : 8.0,
                horizontal: 8.0,
              ),
              child: Row(
                crossAxisAlignment: .start,
                mainAxisAlignment: .start,
                children: [
                  if (widget.longPressSelect)
                    SizedBox(
                      height: 36,
                      width: 36,
                      child: Checkbox.adaptive(
                        value: widget.selected,
                        shape: const CircleBorder(),
                        onChanged: (_) => widget.onSelect(event, null),
                      ),
                    )
                  else if (nextEventSameSender)
                    const SizedBox(width: 36)
                  else
                    Avatar(
                      mxContent: user.avatarUrl,
                      name: user.calcDisplayname(),
                      size: 36,
                      onTap: () {
                        if (widget.exampleMessage != true) {
                          showMemberActionsPopupMenu(
                            context: context,
                            user: user,
                            onMention: widget.onMention,
                          );
                        }
                      },
                      presenceUserId: user.stateKey,
                      presenceBackgroundColor: widget.wallpaperMode
                          ? Colors.transparent
                          : null,
                    ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Stack(
                      children: [
                        Column(
                          crossAxisAlignment: .start,
                          mainAxisSize: .min,
                          children: [
                            if (!nextEventSameSender)
                              Text(
                                displayname,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: (theme.brightness == Brightness.light
                                      ? displayname.color
                                      : displayname.lightColorText),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            const SizedBox(height: 4),
                            GestureDetector(
                              onTapDown: (details) =>
                                  _tapPosition = details.globalPosition,
                              onLongPress: widget.longPressSelect
                                  ? null
                                  : () {
                                      HapticFeedback.heavyImpact();
                                      widget.onSelect(event, _tapPosition);
                                    },
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  if (_replyEventFuture != null)
                                    FutureBuilder<Event?>(
                                      future: _replyEventFuture,
                                      builder: (BuildContext context, snapshot) {
                                        final replyEvent = snapshot.hasData
                                            ? snapshot.data!
                                            : Event(
                                                eventId:
                                                    event.inReplyToEventId() ??
                                                    '\$fake_event_id',
                                                content: {
                                                  'msgtype': 'm.text',
                                                  'body': '...',
                                                },
                                                senderId: event.senderId,
                                                type: 'm.room.message',
                                                room: event.room,
                                                status: EventStatus.error,
                                                originServerTs: DateTime.now(),
                                              );
                                        return Padding(
                                          padding: const EdgeInsets.only(
                                            bottom: 4,
                                          ),
                                          child: Material(
                                            color: Colors.transparent,
                                            child: InkWell(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                    AppConfig.borderRadius - 10,
                                                  ),
                                              onTap: () => _scrollToEvent(
                                                replyEvent,
                                                event,
                                              ),
                                              child: AbsorbPointer(
                                                child: ReplyContent(
                                                  replyEvent,
                                                  noBubble: true,
                                                  ownMessage: ownMessage,
                                                  timeline: timeline,
                                                ),
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  MessageContent(
                                    displayEvent,
                                    textColor: theme.colorScheme.onSurface,
                                    linkColor: theme.colorScheme.primary,
                                    onInfoTab: widget.onInfoTab,
                                    timeline: timeline,
                                    loadMedia: loadMedia,
                                    onLoadMedia: () {
                                      setState(() {
                                        loadMedia = true;
                                      });
                                    },
                                                                        borderRadius: BorderRadius.zero,
                                    selectable: PlatformInfos.isMobile
                                        ? widget.longPressSelect
                                        : true,
                                  ),
                                ],
                              ),
                            ),
                            if (widget.thread != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 4.0),
                                child: InkWell(
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        (widget.thread?.hasNewMessages ?? false)
                                            ? Icons.mark_chat_unread_outlined
                                            : Icons.chat_bubble_outline,
                                        color:
                                            theme.colorScheme.onSurfaceVariant,
                                        size: 16,
                                      ),
                                      const SizedBox(width: 6),
                                      if (_threadSenderFuture != null)
                                        FutureBuilder<User?>(
                                          future: _threadSenderFuture,
                                          builder: (context, snapshot) {
                                            final threadUser =
                                                snapshot.data ??
                                                event
                                                    .senderFromMemoryOrFallback;
                                            return Avatar(
                                              mxContent: threadUser.avatarUrl,
                                              name: threadUser
                                                  .calcDisplayname(),
                                              size: 16,
                                            );
                                          },
                                        ),
                                      const SizedBox(width: 6),
                                      Text(
                                        widget.thread!.lastEvent != null
                                            ? widget
                                                          .thread!
                                                          .lastEvent!
                                                          .text
                                                          .length >
                                                      32
                                                  ? "${widget.thread!.lastEvent!.text.substring(0, 32)}..."
                                                  : widget
                                                        .thread!
                                                        .lastEvent!
                                                        .text
                                            : 'Thread',
                                        style: TextStyle(
                                          color: theme
                                              .colorScheme
                                              .onSurfaceVariant,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                  onTap: () => context.push(
                                    '/rooms/${event.roomId}/threads/${event.eventId}',
                                  ),
                                ),
                              ),
                          ],
                        ),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: messageStatusRow,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );

    Widget container;
    if (showReactionsRow ||
        displayTime ||
        widget.selected ||
        widget.displayReadMarker) {
      container = Column(
        mainAxisSize: .min,
        crossAxisAlignment: .start,
        children: <Widget>[
          if (displayTime || widget.selected)
            Padding(
              padding: displayTime
                  ? const EdgeInsets.symmetric(vertical: 8.0)
                  : EdgeInsets.zero,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Material(
                    borderRadius: BorderRadius.circular(
                      AppConfig.borderRadius * 2,
                    ),
                    color: theme.colorScheme.surface.withAlpha(128),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8.0,
                        vertical: 2.0,
                      ),
                      child: Text(
                        event.originServerTs.localizedTime(context),
                        style: TextStyle(
                          fontSize: 12 * AppSettings.fontSizeFactor.value,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.secondary,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          row,
          if (showReactionsRow)
            Padding(
              padding: const EdgeInsets.only(
                top: 4.0,
                left: 24 + 16.0,
                right: 12.0,
              ),
              child: MessageReactions(
                event,
                timeline,
                chatController: widget.chatController,
              ),
            ),
          if (widget.displayReadMarker)
            Row(
              children: [
                Expanded(
                  child: Divider(
                    color: theme.colorScheme.surfaceContainerHighest,
                  ),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 16.0,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(
                      AppConfig.borderRadius / 3,
                    ),
                    color: theme.colorScheme.surface.withAlpha(128),
                  ),
                  child: Text(
                    L10n.of(context).newMessages,
                    style: TextStyle(
                      fontSize: 12 * AppSettings.fontSizeFactor.value,
                    ),
                  ),
                ),
                Expanded(
                  child: Divider(
                    color: theme.colorScheme.surfaceContainerHighest,
                  ),
                ),
              ],
            ),
        ],
      );
    } else {
      container = row;
    }

    return _AnimateIn(
      animateIn: widget.animateIn,
      halfOpacity: event.status == EventStatus.sending ? true : false,
      child: Swipeable(
        key: ValueKey(event.eventId),
        background: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.0),
          child: Center(child: Icon(Icons.check_outlined)),
        ),
        direction: AppSettings.swipeRightToLeftToReply.value
            ? SwipeDirection.endToStart
            : SwipeDirection.startToEnd,
        onSwipe: (_) => widget.onSwipe(event),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(
              maxWidth: FluffyThemes.columnWidth * 2.5,
            ),
            child: container,
          ),
        ),
      ),
    );
  }
}

class _AnimateIn extends StatefulWidget {
  final bool animateIn;
  final bool halfOpacity;
  final Widget child;
  const _AnimateIn({
    required this.animateIn,
    required this.halfOpacity,
    required this.child,
  });

  @override
  State<_AnimateIn> createState() => __AnimateInState();
}

class __AnimateInState extends State<_AnimateIn> {
  bool _animationFinished = false;
  @override
  Widget build(BuildContext context) {
    if (!widget.animateIn) {
      return widget.halfOpacity
          ? Opacity(opacity: 0.5, child: widget.child)
          : widget.child;
    }
    if (!_animationFinished) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          _animationFinished = true;
        });
      });
    }
    return AnimatedOpacity(
      duration: FluffyThemes.animationDuration,
      curve: FluffyThemes.animationCurve,
      opacity: _animationFinished ? (widget.halfOpacity ? 0.5 : 1) : 0,
      child: AnimatedSize(
        duration: FluffyThemes.animationDuration,
        curve: FluffyThemes.animationCurve,
        child: _animationFinished ? widget.child : const SizedBox.shrink(),
      ),
    );
  }
}
