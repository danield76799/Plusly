import 'dart:math';
import 'dart:ui' as ui;

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:go_router/go_router.dart';
import 'package:matrix/matrix.dart';
import 'package:Pulsly/pages/chat/swipe_to_reply.dart';

import 'package:Pulsly/config/setting_keys.dart';
import 'package:Pulsly/config/themes.dart';
import 'package:Pulsly/generated/l10n/l10n.dart';
import 'package:Pulsly/pages/chat/chat.dart';
import 'package:Pulsly/pages/chat/events/gallery_content.dart';
import 'package:Pulsly/pages/chat/events/message_status_row.dart';
import 'package:Pulsly/pages/chat/events/room_creation_state_event.dart';
import 'package:Pulsly/utils/date_time_extension.dart';
import 'package:Pulsly/utils/matrix_sdk_extensions/event_extension.dart';
import 'package:Pulsly/utils/platform_infos.dart';
import 'package:Pulsly/utils/poll_events.dart';
import 'package:Pulsly/utils/privacy_options.dart';
import 'package:Pulsly/utils/string_color.dart';
import 'package:Pulsly/widgets/avatar.dart';
import 'package:Pulsly/widgets/matrix.dart';
import 'package:Pulsly/widgets/member_actions_popup_menu_button.dart';
import '../../../config/app_config.dart';
import '../quick_reactions_overlay.dart';
import 'message_content.dart';
import 'message_reactions.dart';
import 'reply_content.dart';
import 'state_message.dart';

class MessageBubble extends StatefulWidget {
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
  final List<Color> colors;
  final bool gradient;
  final bool singleSelected;
  final Thread? thread;
  final bool hasBeenRead;
  final List<Receipt>? readReceipts; // NEW: Read receipts for this message
  final ChatController? chatController;

  const MessageBubble(
    this.event, {
    this.nextEvent,
    this.previousEvent,
    this.displayReadMarker = false,
    this.longPressSelect = false,
    this.gradient = false,
    this.singleSelected = false,
    this.hasBeenRead = false,
    this.readReceipts, // NEW
    this.thread,
    this.chatController,
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
    required this.colors,
    super.key,
  });

  @override
  State<MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<MessageBubble> {
  Offset _tapPosition = Offset.zero;
  OverlayEntry? _quickReactionsOverlay;

  // Cached futures to avoid re-creating them on every build
  late Future<User?> _senderUserFuture;
  Future<User?>? _threadSenderFuture;
  
  // Cache the sender user to avoid rebuilding FutureBuilder
  User? _cachedSenderUser;

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
  void didUpdateWidget(MessageBubble oldWidget) {
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
    _cachedSenderUser = null; // Clear cache when re-initing
    _initThreadFuture();
  }

  Future<User?> fetchSenderUser() async {
    final client = Matrix.of(context).client;
    if (widget.event.senderId != client.userID) {
      return await widget.event.fetchSenderUser();
    }
    // we don't render avatar/displayname for own messages
    return User(client.userID!, room: widget.event.room);
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

  /// Calculates the width of the media content (image/video/sticker) for
  /// the given event, matching the logic in [MessageContent], [ImageBubble],
  /// and [EventVideoPlayer]. Returns null if the event is not a media type.
  double? _calculateMediaWidth(Event event) {
    if (event.redacted) return null;

    switch (event.messageType) {
      case MessageTypes.Image:
      case MessageTypes.Sticker:
        final maxSize = event.messageType == MessageTypes.Sticker
            ? 128.0 * AppSettings.stickerScale.value
            : 512.0;
        final w = event.content
            .tryGetMap<String, Object?>('info')
            ?.tryGet<int>('w');
        final h = event.content
            .tryGetMap<String, Object?>('info')
            ?.tryGet<int>('h');
        var imageWidth = maxSize;
        if (w != null && h != null) {
          if (w > h) {
            imageWidth = maxSize;
          } else {
            imageWidth = max(32, maxSize * (w / h));
          }
        }
        final hasDescription = event.fileDescription != null;
        const minBubbleWidth = 180.0;
        return hasDescription ? max(minBubbleWidth, imageWidth) : imageWidth;

      case MessageTypes.Video:
        final infoMap = event.content.tryGetMap<String, Object?>('info');
        final videoWidth = infoMap?.tryGet<int>('w') ?? 400;
        final videoHeight = infoMap?.tryGet<int>('h') ?? 300;
        const height = 300.0;
        return videoWidth * (height / videoHeight);

      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final event = widget.event;
    final timeline = widget.timeline;
    final theme = Theme.of(context);

    // Once this frame is painted, log how big the Message actually became.
    final capturedEventId = event.eventId;
    final capturedTxid = event.transactionId;
    final capturedType = event.type;
    final capturedStatus = event.status;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final ro = context.findRenderObject();
      final size = ro is RenderBox ? ro.size : null;
      Logs().d('[EchoDiag-Message] post-frame — eventId=$capturedEventId txid=$capturedTxid type=$capturedType status=$capturedStatus size=$size hasSize=${size != null && size.width > 0 && size.height > 0}');
    });

    if (!{
      EventTypes.Message,
      EventTypes.Sticker,
      EventTypes.Encrypted,
      EventTypes.CallInvite,
      PollEvents.pollStart,
    }.contains(event.type)) {
      Logs().d('[EchoDiag-Message] filtered by type — type=${event.type}');
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
    final alignment = ownMessage ? Alignment.topRight : Alignment.topLeft;
    final hasBeenRead = widget.hasBeenRead;

    final isOneOnOne =
        event.room.isDirectChat || event.room.getParticipants().length <= 4;

    var color = theme.incomingBubbleColor;
    final displayTime =
        event.type == EventTypes.RoomCreate ||
        widget.nextEvent == null ||
        !event.originServerTs.sameEnvironment(widget.nextEvent!.originServerTs);
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

    final previousEventSameSender =
        widget.previousEvent != null &&
        {
          EventTypes.Message,
          EventTypes.Sticker,
          EventTypes.Encrypted,
          PollEvents.pollStart,
        }.contains(widget.previousEvent!.type) &&
        widget.previousEvent!.senderId == event.senderId &&
        widget.previousEvent!.originServerTs.sameEnvironment(
          event.originServerTs,
        );

    final rowMainAxisAlignment = ownMessage
        ? MainAxisAlignment.end
        : MainAxisAlignment.start;

    final previousEventDifferentMinute = widget.previousEvent != null &&
        widget.previousEvent!.originServerTs
            .difference(event.originServerTs)
            .abs()
            .inMinutes >= 1;
    final showTimestamp = widget.previousEvent == null ||
        !previousEventSameSender ||
        previousEventDifferentMinute;

    final displayEvent = event.getDisplayEvent(timeline);

    final inReplyTo = event.inReplyToEventId(includingFallback: false);
    final hasReply = inReplyTo != null;
    final replyEvent = hasReply
        ? timeline.events.firstWhereOrNull(
            (e) => e.eventId == inReplyTo)
        : null;
    const hardCorner = Radius.circular(4);
    const roundedCorner = Radius.circular(AppConfig.borderRadius);

    // WhatsApp-style tails
    final borderRadius = BorderRadius.only(
      topLeft: (!ownMessage && !previousEventSameSender) ? Radius.zero : roundedCorner,
      topRight: roundedCorner,
      bottomLeft: roundedCorner,
      bottomRight: (ownMessage && !previousEventSameSender) ? Radius.zero : roundedCorner,
    );

    final noBubble =
        ({
              MessageTypes.Video,
              MessageTypes.Image,
              MessageTypes.Sticker,
            }.contains(event.messageType) &&
            event.fileDescription == null &&
            !event.redacted) ||
        (event.messageType == MessageTypes.Text &&
            event.relationshipType == null &&
            event.onlyEmotes &&
            event.numberEmotes > 0 &&
            event.numberEmotes <= 3);

    if (ownMessage) {
      color = displayEvent.status.isError
          ? theme.colorScheme.error
          : theme.bubbleColor;
    }

    final textColor = ownMessage
        ? (noBubble ? theme.colorScheme.onSurface : theme.onBubbleColor)
        : theme.colorScheme.onSurface;

    final statusColor = ownMessage && !noBubble
        ? theme.onBubbleColor.withValues(alpha: 0.85)
        : textColor.withValues(alpha: 0.7);

    final linkColor = ownMessage
        ? theme.brightness == Brightness.light
              ? theme.colorScheme.primaryFixed
              : theme.colorScheme.onTertiaryContainer
        : theme.colorScheme.primary;

    final showReactionsRow = event.hasAggregatedEvents(
      timeline,
      RelationshipTypes.reaction,
    );

    final messageStatusRow = MessageStatusRow(
      timestamp: event.originServerTs,
      edited: event.hasAggregatedEvents(timeline, RelationshipTypes.edit),
      ownMessage: ownMessage,
      hasBeenRead: hasBeenRead,
      status: event.status,
      color: statusColor,
    );

    final row = FutureBuilder<User?>(
      future: _senderUserFuture,
      builder: (context, snapshot) {
        if (snapshot.hasData && _cachedSenderUser == null) {
          _cachedSenderUser = snapshot.data;
        }
        final user = _cachedSenderUser ?? event.senderFromMemoryOrFallback;
        final displayname =
            _cachedSenderUser?.calcDisplayname() ??
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
                    _showQuickReactionsOverlay(event);
                  }
                },
                onSecondaryTap: () => widget.onSelect(event, _// laat lichte fix voor lappen
_tapPosition),
                borderRadius: BorderRadius.circular(AppConfig.borderRadius / 2),
                child: Material(
                  borderRadius: BorderRadius.circular(
                    AppConfig.borderRadius / 2,
                  ),
                  color: widget.selected || widget.highlightMarker
                      ? theme.colorScheme.secondaryContainer.withAlpha(128)
                      : Colors.transparent,
                ),
              ),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: rowMainAxisAlignment,
              children: [
                if (widget.longPressSelect)
                  SizedBox(
                    height: 32,
                    width: Avatar.defaultSize,
                    child: Checkbox.adaptive(
                      value: widget.selected,
                      shape: const CircleBorder(),
                      onChanged: (_) => widget.onSelect(event, null),
                    ),
                  )
                else if (!ownMessage && previousEventSameSender)
                  SizedBox(width: Avatar.defaultSize)
                else if (!ownMessage && !isOneOnOne)
                  Avatar(
                    mxContent: user.avatarUrl,
                    name: user.calcDisplayname(),
                    onTap: () => showMemberActionsPopupMenu(
                      context: context,
                      user: user,
                      onMention: widget.onMention,
                    ),
                    presenceUserId: user.stateKey,
                    presenceBackgroundColor: widget.wallpaperMode
                        ? Colors.transparent
                        : null,
                  ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (!previousSendeSameSender && !ownMessage && !isOneOnOne)
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0, bottom: 4),
                          child: Text(
                            displayname,
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.1,
                              color: (theme.brightness == Brightness.light
                                  ? displayname.color
                                  : displayname.lightColorText),
                              shadows: !widget.wallpaperMode
                                  ? null
                                  : [
                                      const Shadow(
                                        offset: Offset(0.0, 0.0),
                                        blurRadius: 3,
                                        color: Colors.black,
                                      ),
                                    ],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      Container(
                        alignment: alignment,
                        padding: const EdgeInsets.only(left: 8),
                        child: GestureDetector(
                          onTapDown: (details) =>
                              _tapPosition = details.globalPosition,
                          onTap: widget.longPressSelect
                              ? () => widget.onSelect(event, _tapPosition)
                              : null,
                          onDoubleTap: AppSettings.doubleTapToReact.value &&
                              event.room.canSendDefaultMessages &&
                              !widget.longPressSelect
                          ? () {
                              HapticFeedback.lightImpact();
                              final emoji = AppSettings.doubleTapReaction.value;
                              final existingReaction = event
                                  .aggregatedEvents(
                                    timeline,
                                    RelationshipTypes.reaction,
                                  )
                                  .firstWhereOrNull(
                                    (e) =>
                                        e.senderId == event.room.client.userID &&
                                        e.content
                                            .tryGetMap<String, Object?>(
                                              'm.relates_to',
                                            )
                                            ?.tryGet<String>('key') ==
                                    emoji,
                                  );
                              if (existingReaction != null) {
                                existingReaction.redactEvent();
                              } else {
                                event.room.sendReaction(
                                  event.eventId,
                                  emoji,
                                );
                              }
                            }
                          : null,
                          onLongPress: widget.longPressSelect
                              ? null
                              : () {
                                  HapticFeedback.heavyImpact();
                                  widget.onSelect(event, _tapPosition);
                                },
                          child: () {
                            final galleryBubbleWidth =
                                displayEvent.messageType == galleryMessageType &&
                                    !displayEvent.redacted
                                ? GalleryContent.gridWidth(
                                    GalleryContent.gridColumnCount(
                                      galleryItems(displayEvent).where(
                                        (item) => {
                                          MessageTypes.Image,
                                          MessageTypes.Video,
                                        }.contains(
                                          galleryItemtypeToMsgtype(
                                            item.tryGet<String>(
                                              'itemtype',
                                            ) ??
                                                'm.file',
                                          ),
                                        ),
                                      ).length,
                                    ),
                                  ) +
                                    4
                                : null;
                            final bubbleInner = Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(
                                  AppConfig.borderRadius,
                                ),
                              ),
                              constraints: BoxConstraints(
                                maxWidth:
                                    galleryBubbleWidth ??
                                    (hasReply
                                        ? _calculateMediaWidth(displayEvent)
                                        : null) ??
                                    MediaQuery.sizeOf(context).width * 0.75,
                              ),
                              child: IntrinsicWidth(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    if (hasReply)
                                      FutureBuilder<Event?>(
                                        future: replyEvent != null
                                            ? Future.value(replyEvent)
                                            : event.getReplyEvent(timeline),
                                        builder: (BuildContext context, snapshot) {
                                          final displayReplyEvent =
                                              snapshot.data ??
                                              Event(
                                                eventId: inReplyTo,
                                                content: {
                                                  'msgtype': 'm.text',
                                                  'body': '...',
                                                },
                                                senderId: event.senderId,
                                                type: 'm.room.message',
                                                room: event.room,
                                                status: EventStatus.sent,
                                                originServerTs:
                                                    DateTime.now(),
                                              );
                                          return Padding(
                                            padding: const EdgeInsets.only(
                                              left: 16,
                                              right: 16,
                                              top: 8,
                                              bottom: 8,
                                            ),
                                            child: Material(
                                              color: Colors.transparent,
                                              borderRadius:
                                                  ReplyContent.borderRadius,
                                              child: InkWell(
                                                borderRadius:
                                                    ReplyContent.borderRadius,
                                                onTap: () => widget
                                                    .scrollToEventId(
                                                      displayReplyEvent.eventId,
                                                    ),
                                                child: AbsorbPointer(
                                                  child: ReplyContent(
                                                    displayReplyEvent,
                                                    noBubble: noBubble,
                                                    ownMessage: ownMessage,
                                                    timeline: timeline,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                      if (event.content
                                          .tryGetMap<String, Object?>('m.forwarded')
                                          ?.tryGet<String>('user_id') !=
                                          null)
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            left: 16,
                                            right: 16,
                                            top: 8,
                                            bottom: 4,
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons.forward_outlined,
                                                size: 14,
                                                color: textColor.withValues(alpha: 0.7),
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                L10n.of(context).forward,
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: textColor.withValues(alpha: 0.7),
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            top: 0,
                                          ),
                                          child: MessageContent(
                                            displayEvent,
                                            textColor: textColor,
                                            linkColor: linkColor,
                                            textPadding: 6,
                                            onInfoTab: widget.onInfoTab,
                                            borderRadius: borderRadius,
                                            timeline: timeline,
                                            loadMedia: loadMedia,
                                            onLoadMedia: () {
                                              setState(() {
                                                loadMedia = true;
                                              });
                                            },
                                            selectable: PlatformInfos.isMobile
                                                ? widget.longPressSelect
                                                : true,
                                          ),
                                        ),
                                        if (showTimestamp)
                                          Padding(
                                            padding: EdgeInsets.only(
                                              top: 4,
                                              right: ownMessage ? 8 : 4,
                                              left: ownMessage ? 4 : 8,
                                            ),
                                            child: Align(
                                              alignment: Alignment.centerRight,
                                              child: messageStatusRow,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                                final bubbleColor = AppSettings
                                    .enableChatFrostedGlass.value &&
                                    AppSettings.wallpaperPath.value.isNotEmpty
                                ? color.withValues(alpha: 0.7)
                                : color;
                                final bubble = ClipRRect(
                                  borderRadius: borderRadius,
                                  child: Material(
                                    color: noBubble
                                        ? Colors.transparent
                                        : bubbleColor,
                                    borderRadius: borderRadius,
                                    clipBehavior: Clip.antiAlias,
                                    child: BubbleBackground(
                                      colors: widget.colors,
                                      ignore: noBubble ||
                                          !ownMessage ||
                                          !widget.gradient ||
                                          MediaQuery.highContrastOf(context),
                                      scrollController: widget.scrollController,
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 6.0,
                                          horizontal: 10.0,
                                        ),
                                        child: bubbleInner,
                                      ),
                                    ),
                                  ),
                                );
                                return bubble;
                              }(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        // Reaction Pill Overlay
        if (showReactionsRow)
          Positioned(
            bottom: -8,
            right: ownMessage ? 8 : null,
            left: ownMessage ? null : 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: theme.colorScheme.outlineVariant),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 2,
                  ),
                ],
              ),
              child: MessageReactions(event, timeline),
            ),
          ),
      ],
    );
  }

  void _showQuickReactionsOverlay(Event event) {
    if (_quickReactionsOverlay != null) return;
    _quickReactionsOverlay = OverlayEntry(
      builder: (context) => QuickReactionsOverlay(
        event: event,
        onDismiss: () {
          _quickReactionsOverlay?.remove();
          _quickReactionsOverlay = null;
        },
        onSelect: widget.chatController == null
            ? null
            : () => widget.chatController!.onMultiSelect(event),
      ),
    );
    Overlay.of(context).insert(_quickReactionsOverlay!);
  }

  @override
  void dispose() {
    _quickReactionsOverlay?.remove();
    super.dispose();
  }
}

class BubbleBackground extends StatelessWidget {
  const BubbleBackground({
    super.key,
    required this.colors,
    required this.ignore,
    required this.child,
    this.scrollController,
  });

  final ScrollController? scrollController;
  final List<Color> colors;
  final bool ignore;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (ignore) return child;
    return RepaintBoundary(
      child: CustomPaint(
        painter: BubblePainter(
          repaint: scrollController,
          colors: colors,
          context: context,
        ),
        child: child,
      ),
    );
  }
}

class BubblePainter extends CustomPainter {
  BubblePainter({
    required this.context,
    required this.colors,
    required super.repaint,
  });

  final BuildContext context;
  final List<Color> colors;
  ScrollableState? _scrollable;

  @override
  void paint(Canvas canvas, Size size) {
    final scrollable = _scrollable ??= Scrollable.of(context);
    final scrollableBox = scrollable.context.findRenderObject() as RenderBox;
    final scrollableRect = Offset.zero & scrollableBox.size;
    final bubbleBox = context.findRenderObject() as RenderBox;

    final origin = bubbleBox.localToGlobal(
      Offset.zero,
      ancestor: scrollableBox,
    );
    final paint = Paint()
      ..shader = ui.Gradient.linear(
        scrollableRect.topCenter,
        scrollableRect.bottomCenter,
        AppSettings.enableChatFrostedGlass.value
            ? colors.map((x) => x.withValues(alpha: 0.6)).toList()
            : colors.map((x) => x.withValues(alpha: 0.85)).toList(),
        [0.0, 1.0],
        TileMode.clamp,
        Matrix4.translationValues(-origin.dx, -origin.dy, 0.0).storage,
      );
    canvas.drawRect(Offset.zero & size, paint);
  }

  @override
  bool shouldRepaint(BubblePainter oldDelegate) {
    final scrollable = Scrollable.of(context);
    final oldScrollable = _scrollable;
    _scrollable = scrollable;
    return scrollable.position != oldScrollable?.position;
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
    if (!widget.animateIn) return widget.child;
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