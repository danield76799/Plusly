import 'dart:math';
import 'dart:ui' as ui;

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:matrix/matrix.dart';

import 'package:Pulsly/config/setting_keys.dart';
import 'package:Pulsly/config/themes.dart';
import 'package:Pulsly/generated/l10n/l10n.dart';
import 'package:Pulsly/pages/chat/chat.dart';
import 'package:Pulsly/pages/chat/events/bubble_tail.dart';
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
  final List<Receipt>? readReceipts;
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
    this.readReceipts,
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
  late Future<User?> _senderUserFuture;
  User? _cachedSenderUser;
  bool loadMedia = false;

  @override
  void initState() {
    super.initState();
    loadMedia = shouldAutoLoadMedia(widget.event.room.client, widget.event.room.id);
    _initFutures();
  }

  @override
  void didUpdateWidget(MessageBubble oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.event != widget.event) {
      _initFutures();
    }
  }

  void _initFutures() {
    _senderUserFuture = fetchSenderUser();
    _cachedSenderUser = null;
  }

  Future<User?> fetchSenderUser() async {
    final client = Matrix.of(context).client;
    if (widget.event.senderId != client.userID) {
      return await widget.event.fetchSenderUser();
    }
    return User(client.userID!, room: widget.event.room);
  }

  double? _calculateMediaWidth(Event event) {
    if (event.redacted) return null;
    switch (event.messageType) {
      case MessageTypes.Image:
      case MessageTypes.Sticker:
        final maxSize = event.messageType == MessageTypes.Sticker
            ? 128.0 * AppSettings.stickerScale.value
            : 512.0;
        final w = event.content.tryGetMap<String, Object?>('info')?.tryGet<int>('w');
        final h = event.content.tryGetMap<String, Object?>('info')?.tryGet<int>('h');
        var imageWidth = maxSize;
        if (w != null && h != null) {
          imageWidth = w > h ? maxSize : max(32, maxSize * (w / h));
        }
        return event.fileDescription != null ? max(180.0, imageWidth) : imageWidth;
      case MessageTypes.Video:
        final infoMap = event.content.tryGetMap<String, Object?>('info');
        final videoWidth = infoMap?.tryGet<int>('w') ?? 400;
        final videoHeight = infoMap?.tryGet<int>('h') ?? 300;
        return videoWidth * (300.0 / videoHeight);
      default:
        return null;
    }
  }

  Widget _buildBubble(BuildContext context, Event event, Timeline timeline, ThemeData theme,
      Color color, Color textColor, Color linkColor, BorderRadius borderRadius,
      bool noBubble, bool ownMessage, bool hasReply, Event? replyEvent,
      String? inReplyTo, bool showTimestamp, Widget messageStatusRow, bool showTail) {
    
    final displayEvent = event.getDisplayEvent(timeline);
    final galleryBubbleWidth = displayEvent.messageType == galleryMessageType && !displayEvent.redacted
        ? GalleryContent.gridWidth(GalleryContent.gridColumnCount(galleryItems(displayEvent).where((item) => {MessageTypes.Image, MessageTypes.Video}.contains(galleryItemtypeToMsgtype(item.tryGet<String>('itemtype') ?? 'm.file'))).length)) + 4
        : null;

    final bubbleInner = Container(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(AppConfig.borderRadius)),
      constraints: BoxConstraints(
        maxWidth: galleryBubbleWidth ?? (hasReply ? _calculateMediaWidth(displayEvent) : null) ?? MediaQuery.sizeOf(context).width * 0.75,
      ),
      child: IntrinsicWidth(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            if (hasReply)
              FutureBuilder<Event?>(
                future: replyEvent != null ? Future.value(replyEvent) : event.getReplyEvent(timeline),
                builder: (context, snapshot) {
                  final displayReplyEvent = snapshot.data ?? Event(eventId: inReplyTo!, content: {'msgtype': 'm.text', 'body': '...'}, senderId: event.senderId, type: 'm.room.message', room: event.room, status: EventStatus.sent, originServerTs: DateTime.now());
                  return Padding(
                    padding: const EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 8),
                    child: Material(
                      color: Colors.transparent,
                      borderRadius: ReplyContent.borderRadius,
                      child: InkWell(
                        borderRadius: ReplyContent.borderRadius,
                        onTap: () => widget.scrollToEventId(displayReplyEvent.eventId),
                        child: AbsorbPointer(
                          child: ReplyContent(displayReplyEvent, noBubble: noBubble, ownMessage: ownMessage, timeline: timeline),
                        ),
                      ),
                    ),
                  );
                },
              ),
            if (event.content.tryGetMap<String, Object?>('m.forwarded')?.tryGet<String>('user_id') != null)
              Padding(
                padding: const EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.forward_outlined, size: 14, color: textColor.withValues(alpha: 0.7)),
                    const SizedBox(width: 4),
                    Text(L10n.of(context).forward, style: TextStyle(fontSize: 12, color: textColor.withValues(alpha: 0.7), fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
            Padding(
              padding: const EdgeInsets.only(top: 0),
              child: MessageContent(
                displayEvent,
                textColor: textColor,
                linkColor: linkColor,
                textPadding: 6,
                onInfoTab: widget.onInfoTab,
                borderRadius: borderRadius,
                timeline: timeline,
                loadMedia: loadMedia,
                onLoadMedia: () => setState(() => loadMedia = true),
                selectable: PlatformInfos.isMobile ? widget.longPressSelect : true,
              ),
            ),
            if (showTimestamp)
              Padding(
                padding: EdgeInsets.only(top: 4, right: ownMessage ? 8 : 4, left: ownMessage ? 4 : 8),
                child: Align(alignment: Alignment.centerRight, child: messageStatusRow),
              ),
          ],
        ),
      ),
    );

    final bubbleColor = AppSettings.enableChatFrostedGlass.value && AppSettings.wallpaperPath.value.isNotEmpty ? color.withValues(alpha: 0.7) : color;

    // WhatsApp-vorm: een klein staartje onder de buitenste hoek van de
    // bubbel. De staart zit ACHTER de bubbel, zodat de bubbel zijn hoek
    // erover tekent; alleen het stukje onder de bubbel blijft zichtbaar.
    final bubble = ClipRRect(
      borderRadius: borderRadius,
      child: Material(
        color: noBubble ? Colors.transparent : bubbleColor,
        borderRadius: borderRadius,
        clipBehavior: Clip.antiAlias,
        child: BubbleBackground(
          colors: widget.colors,
          ignore: noBubble || !ownMessage || !widget.gradient || MediaQuery.highContrastOf(context),
          scrollController: widget.scrollController,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 10.0),
            child: bubbleInner,
          ),
        ),
      ),
    );

    if (noBubble) return bubble;

    // Alleen het onderste bericht van een blok krijgt een staartje; de
    // berichten erboven lopen naadloos in het blok over.
    return Stack(
      clipBehavior: Clip.none,
      children: [
        if (showTail)
          Positioned(
            bottom: -3,
            left: ownMessage ? null : -2,
            right: ownMessage ? -2 : null,
            child: BubbleTail(color: bubbleColor, ownMessage: ownMessage),
          ),
        bubble,
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final event = widget.event;
    final timeline = widget.timeline;
    final theme = Theme.of(context);

    if (!{EventTypes.Message, EventTypes.Sticker, EventTypes.Encrypted, EventTypes.CallInvite, PollEvents.pollStart}.contains(event.type)) {
      if (event.type.startsWith('m.call.')) return const SizedBox.shrink();
      if (event.type == EventTypes.RoomCreate) return RoomCreationStateEvent(event: event);
      return StateMessage(event, selected: widget.selected, controller: widget.chatController);
    }

    if (event.type == EventTypes.Message && event.messageType == EventTypes.KeyVerificationRequest) {
      return StateMessage(event, selected: widget.selected, controller: widget.chatController);
    }

    final client = Matrix.of(context).client;
    final ownMessage = event.senderId == client.userID;
    final alignment = ownMessage ? Alignment.topRight : Alignment.topLeft;
    final isOneOnOne = event.room.isDirectChat || event.room.getParticipants().length <= 4;

    var color = theme.incomingBubbleColor;

    // WhatsApp-groepering: opeenvolgende berichten van dezelfde afzender
    // vormen één aaneengesloten blok. De hoeken die aan het blok grenzen
    // worden vierkant, en alleen het onderste bericht van het blok krijgt
    // een staartje.
    //
    // In de omgekeerde lijst is `previousEvent` het bericht erONDER (nieuwer)
    // en `nextEvent` het bericht erBOVEN (ouder).
    final previousEventSameSender = widget.previousEvent != null &&
        {EventTypes.Message, EventTypes.Sticker, EventTypes.Encrypted, PollEvents.pollStart}.contains(widget.previousEvent!.type) &&
        widget.previousEvent!.senderId == event.senderId &&
        widget.previousEvent!.originServerTs.sameEnvironment(event.originServerTs);

    final nextEventSameSender = widget.nextEvent != null &&
        {EventTypes.Message, EventTypes.Sticker, EventTypes.Encrypted, PollEvents.pollStart}.contains(widget.nextEvent!.type) &&
        widget.nextEvent!.senderId == event.senderId &&
        widget.nextEvent!.originServerTs.sameEnvironment(event.originServerTs);

    final rowMainAxisAlignment = ownMessage ? MainAxisAlignment.end : MainAxisAlignment.start;
    final showTimestamp = widget.previousEvent == null || !previousEventSameSender ||
        widget.previousEvent!.originServerTs.difference(event.originServerTs).abs().inMinutes >= 1;

    final inReplyTo = event.inReplyToEventId(includingFallback: false);
    final hasReply = inReplyTo != null;
    final replyEvent = hasReply ? timeline.events.firstWhereOrNull((e) => e.eventId == inReplyTo) : null;
    
    const roundedCorner = Radius.circular(AppConfig.bubbleRadius);
    final borderRadius = BorderRadius.only(
      topLeft: nextEventSameSender ? Radius.zero : roundedCorner,
      topRight: nextEventSameSender ? Radius.zero : roundedCorner,
      bottomLeft: previousEventSameSender ? Radius.zero : roundedCorner,
      bottomRight: previousEventSameSender ? Radius.zero : roundedCorner,
    );

    final noBubble = ({MessageTypes.Video, MessageTypes.Image, MessageTypes.Sticker}.contains(event.messageType) &&
            event.fileDescription == null && !event.redacted) ||
        (event.messageType == MessageTypes.Text && event.relationshipType == null &&
            event.onlyEmotes && event.numberEmotes > 0 && event.numberEmotes <= 3);

    // Eigen bubbel: WhatsApp-groen als de gebruiker dat aanzet, anders de
    // Material-You-containerkleur.
    final useWhatsAppGreen =
        ownMessage && AppSettings.whatsAppGreenOwnBubble.value;
    final onBubbleColor = useWhatsAppGreen
        ? theme.whatsAppOnBubbleColor
        : theme.onBubbleColor;

    if (ownMessage) {
      color = event.getDisplayEvent(timeline).status.isError
          ? theme.colorScheme.error
          : useWhatsAppGreen
          ? theme.whatsAppBubbleColor
          : theme.bubbleColor;
    }
    final textColor = ownMessage ? (noBubble ? theme.colorScheme.onSurface : onBubbleColor) : theme.colorScheme.onSurface;
    final statusColor = ownMessage && !noBubble ? onBubbleColor.withValues(alpha: 0.85) : textColor.withValues(alpha: 0.7);
    final linkColor = ownMessage ? (theme.brightness == Brightness.light ? theme.colorScheme.primaryFixed : theme.colorScheme.onTertiaryContainer) : theme.colorScheme.primary;

    final showReactionsRow = event.hasAggregatedEvents(timeline, RelationshipTypes.reaction);
    final messageStatusRow = MessageStatusRow(
      timestamp: event.originServerTs,
      edited: event.hasAggregatedEvents(timeline, RelationshipTypes.edit),
      ownMessage: ownMessage,
      hasBeenRead: widget.hasBeenRead,
      status: event.status,
      color: statusColor,
    );

    return FutureBuilder<User?>(
      future: _senderUserFuture,
      builder: (context, snapshot) {
        if (snapshot.hasData && _cachedSenderUser == null) _cachedSenderUser = snapshot.data;
        final user = _cachedSenderUser ?? event.senderFromMemoryOrFallback;
        final displayname = user.calcDisplayname();

        return Stack(
          clipBehavior: Clip.none,
          children: [
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
                    name: displayname,
                    onTap: () => showMemberActionsPopupMenu(context: context, user: user, onMention: widget.onMention),
                    presenceUserId: user.stateKey,
                    presenceBackgroundColor: widget.wallpaperMode ? Colors.transparent : null,
                  ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (!previousEventSameSender && !ownMessage && !isOneOnOne)
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0, bottom: 4),
                          child: Text(
                            displayname,
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.1,
                              color: theme.brightness == Brightness.light ? displayname.color : displayname.lightColorText,
                              shadows: !widget.wallpaperMode ? null : [const Shadow(offset: Offset(0, 0), blurRadius: 3, color: Colors.black)],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      Container(
                        alignment: alignment,
                        padding: const EdgeInsets.only(left: 8),
                        child: GestureDetector(
                          onTapDown: (details) => _tapPosition = details.globalPosition,
                          onTap: widget.longPressSelect ? () => widget.onSelect(event, _tapPosition) : null,
                          onDoubleTap: AppSettings.doubleTapToReact.value && event.room.canSendDefaultMessages && !widget.longPressSelect
                              ? () {
                                  HapticFeedback.lightImpact();
                                  final emoji = AppSettings.doubleTapReaction.value;
                                  final existingReaction = event.aggregatedEvents(timeline, RelationshipTypes.reaction)
                                      .firstWhereOrNull((e) => e.senderId == event.room.client.userID && e.content.tryGetMap<String, Object?>('m.relates_to')?.tryGet<String>('key') == emoji);
                                  if (existingReaction != null) {
                                    existingReaction.redactEvent();
                                  } else {
                                    event.room.sendReaction(event.eventId, emoji);
                                  }
                                }
                              : null,
                          onLongPress: widget.longPressSelect ? null : () {
                            HapticFeedback.heavyImpact();
                            widget.onSelect(event, _tapPosition);
                          },
                          child: _buildBubble(context, event, timeline, theme, color, textColor, linkColor, borderRadius, noBubble, ownMessage, hasReply, replyEvent, inReplyTo, showTimestamp, messageStatusRow, !previousEventSameSender),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
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
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 2)],
                  ),
                  child: MessageReactions(event, timeline),
                ),
              ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}

class BubbleBackground extends StatelessWidget {
  const BubbleBackground({super.key, required this.colors, required this.ignore, required this.child, this.scrollController});
  final ScrollController? scrollController;
  final List<Color> colors;
  final bool ignore;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (ignore) return child;
    return RepaintBoundary(
      child: CustomPaint(
        painter: BubblePainter(repaint: scrollController, colors: colors, context: context),
        child: child,
      ),
    );
  }
}

class BubblePainter extends CustomPainter {
  BubblePainter({required this.context, required this.colors, required super.repaint});
  final BuildContext context;
  final List<Color> colors;
  ScrollableState? _scrollable;

  @override
  void paint(Canvas canvas, Size size) {
    final scrollable = _scrollable ??= Scrollable.of(context);
    final scrollableBox = scrollable.context.findRenderObject() as RenderBox;
    final scrollableRect = Offset.zero & scrollableBox.size;
    final bubbleBox = context.findRenderObject() as RenderBox;
    final origin = bubbleBox.localToGlobal(Offset.zero, ancestor: scrollableBox);
    final paint = Paint()
      ..shader = ui.Gradient.linear(
        scrollableRect.topCenter,
        scrollableRect.bottomCenter,
        AppSettings.enableChatFrostedGlass.value ? colors.map((x) => x.withValues(alpha: 0.6)).toList() : colors.map((x) => x.withValues(alpha: 0.85)).toList(),
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
  const _AnimateIn({required this.animateIn, required this.halfOpacity, required this.child});

  @override
  State<_AnimateIn> createState() => __AnimateInState();
}

class __AnimateInState extends State<_AnimateIn> {
  bool _animationFinished = false;
  @override
  Widget build(BuildContext context) {
    if (!widget.animateIn) return widget.child;
    if (!_animationFinished) {
      WidgetsBinding.instance.addPostFrameCallback((_) => setState(() => _animationFinished = true));
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