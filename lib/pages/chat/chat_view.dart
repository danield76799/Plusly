import 'dart:io';
import 'dart:ui' as ui;

import 'package:extera_next/utils/stream_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:matrix/matrix.dart';

import 'package:extera_next/config/setting_keys.dart';
import 'package:extera_next/config/themes.dart';
import 'package:extera_next/generated/l10n/l10n.dart';
import 'package:extera_next/pages/chat/chat.dart';
import 'package:extera_next/pages/chat/chat_app_bar_list_tile.dart';
import 'package:extera_next/pages/chat/chat_app_bar_title.dart';
import 'package:extera_next/pages/chat/chat_event_list.dart';
import 'package:extera_next/pages/chat/encryption_button.dart';
import 'package:extera_next/pages/chat/jitsi_popup_button.dart';
import 'package:extera_next/pages/chat/pinned_events.dart';
import 'package:extera_next/pages/chat/reply_display.dart';
import 'package:extera_next/pages/dialer/back_to_call_button.dart';
import 'package:extera_next/utils/url_launcher.dart';
import 'package:extera_next/widgets/avatar.dart';
import 'package:extera_next/widgets/chat_settings_popup_menu.dart';
import 'package:extera_next/widgets/matrix.dart';
import 'package:extera_next/widgets/mini_audio_player.dart';
import 'package:extera_next/widgets/unread_rooms_badge.dart';
import 'chat_emoji_picker.dart';
import 'chat_input_row.dart';

enum _EventContextAction {
  info,
  recover,
  report,
  endPoll,
  copyLink,
  readReceipts,
}

class ChatView extends StatefulWidget {
  final ChatController controller;

  const ChatView(this.controller, {super.key});

  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  // A shorthand so we don’t have to write `widget.controller` everywhere.
  ChatController get _c => widget.controller;

  List<Widget> _appBarActions(BuildContext context) {
    if (_c.selectMode) {
      return [
        if (_c.canEditSelectedEvents)
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: L10n.of(context).edit,
            onPressed: _c.editSelectedEventAction,
          ),
        IconButton(
          icon: const Icon(Icons.copy_outlined),
          tooltip: L10n.of(context).copy,
          onPressed: _c.copyEventsAction,
        ),
        if (_c.selectedEvents.length > 1)
          IconButton(
            icon: const Icon(Icons.link),
            tooltip: L10n.of(context).copyLink,
            onPressed: _c.copyLinkAction,
          ),
        if (_c.canSaveSelectedEvent)
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.download),
              tooltip: L10n.of(context).downloadFile,
              onPressed: () => _c.saveSelectedEvent(context),
            ),
          ),
        if (_c.canPinSelectedEvents)
          IconButton(
            icon: const Icon(Icons.push_pin_outlined),
            onPressed: _c.pinEvent,
            tooltip: L10n.of(context).pinMessage,
          ),
        if (_c.canRedactSelectedEvents)
          IconButton(
            icon: const Icon(Icons.delete_outlined),
            tooltip: L10n.of(context).redactMessage,
            onPressed: _c.redactEventsAction,
          ),
        if (_c.selectedEvents.length == 1)
          PopupMenuButton<_EventContextAction>(
            onSelected: (action) {
              switch (action) {
                case _EventContextAction.info:
                  _c.showEventInfo();
                  _c.clearSelectedEvents();
                  break;
                case _EventContextAction.report:
                  _c.reportEventAction();
                  break;
                case _EventContextAction.recover:
                  _c.recoverEventAction();
                  break;
                case _EventContextAction.copyLink:
                  _c.copyLinkAction();
                  break;
                case _EventContextAction.endPoll:
                  _c.endPollAction();
                  break;
                case _EventContextAction.readReceipts:
                  _c.showReadReceipts();
                  break;
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: _EventContextAction.info,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.info_outlined),
                    SizedBox(width: 12),
                    // Text will be localized at runtime
                    // (cannot be const)
                  ],
                ),
              ),
              PopupMenuItem(
                value: _EventContextAction.readReceipts,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [Icon(Icons.done_all), SizedBox(width: 12)],
                ),
              ),
              PopupMenuItem(
                value: _EventContextAction.copyLink,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [Icon(Icons.link), SizedBox(width: 12)],
                ),
              ),
            ],
          ),
      ];
    } else if (!_c.room.isArchived) {
      return [
        if (AppSettings.experimentalVoip.value &&
            Matrix.of(context).voipPlugin != null &&
            _c.room.isDirectChat)
          IconButton(
            onPressed: _c.onPhoneButtonTap,
            icon: const Icon(Icons.call_outlined),
            tooltip: L10n.of(context).placeCall,
          )
        else if (AppSettings.experimentalJitsi.value)
          JitsiPopupButton(_c.room),
        EncryptionButton(_c.room),
        ChatSettingsPopupMenu(_c.room, true),
      ];
    }
    return [];
  }

  Widget _buildInviteView(BuildContext context) {
    final theme = Theme.of(context);
    final room = _c.room;
    final membershipEvent = room.getState(
      EventTypes.RoomMember,
      room.client.userID!,
    );
    final topic = room.topic;
    final reason = membershipEvent?.content.tryGet<String>('reason');
    final displayName = room.getLocalizedDisplayname();

    if (screenWidth == null || screenHeight == null) {
      final view = View.of(context);
      screenWidth ??= view.physicalSize.width / view.devicePixelRatio;
      screenHeight ??= view.physicalSize.height / view.devicePixelRatio;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(L10n.of(context).newInvitation),
        automaticallyImplyLeading: false,
        leading: FluffyThemes.isColumnMode(context)
            ? null
            : const Center(child: BackButton()),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 32),
                Avatar(
                  mxContent: AppSettings.hideAvatarsInInvites.value
                      ? null
                      : room.avatar,
                  name: displayName,
                  size: 96,
                  client: room.client,
                ),
                const SizedBox(height: 24),
                Text(
                  displayName,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                if (membershipEvent != null)
                  Text(
                    L10n.of(context).youInvitedBy(membershipEvent.senderId),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  )
                else if (room.directChatMatrixID != null)
                  Text(
                    L10n.of(context).newChatRequest,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  )
                else
                  Text(
                    L10n.of(context).inviteGroupChat,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                if (reason != null && reason.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Card.outlined(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.format_quote_outlined,
                            color: theme.colorScheme.onSurfaceVariant,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  L10n.of(context).reason,
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(reason, style: theme.textTheme.bodyMedium),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                if (topic.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Card.outlined(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            L10n.of(context).chatDescription,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 8),
                          SelectableLinkify(
                            text: topic,
                            options: const LinkifyOptions(humanize: false),
                            linkStyle: TextStyle(
                              color: theme.colorScheme.primary,
                              decorationColor: theme.colorScheme.primary,
                            ),
                            style: theme.textTheme.bodyMedium,
                            onOpen: (url) =>
                                UrlLauncher(context, url.url).launchUrl(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () => _c.acceptInvite(),
                    icon: const Icon(Icons.check_circle_outline),
                    label: Text(L10n.of(context).accept),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.tonalIcon(
                    onPressed: () => _c.declineInvite(),
                    icon: const Icon(Icons.cancel_outlined),
                    label: Text(L10n.of(context).decline),
                    style: FilledButton.styleFrom(
                      foregroundColor: theme.colorScheme.error,
                      backgroundColor: theme.colorScheme.errorContainer,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => _c.ignoreInvite(),
                    icon: const Icon(Icons.block_outlined),
                    label: Text(L10n.of(context).block),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: theme.colorScheme.error,
                      side: BorderSide(color: theme.colorScheme.error),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24.0),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  double? screenWidth;
  double? screenHeight;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Invite view?
    if (_c.room.membership == .invite) {
      return _buildInviteView(context);
    }

    final bottomSheetPadding = FluffyThemes.isColumnMode(context) ? 16.0 : 8.0;
    final scrollUpBannerEventId = _c.scrollUpBannerEventId;

    final wallpaperPath = AppSettings.wallpaperPath.value;

    return PopScope(
      canPop: _c.selectedEvents.isEmpty && !_c.showEmojiPicker,
      onPopInvokedWithResult: (pop, _) async {
        if (pop) return;
        if (_c.selectedEvents.isNotEmpty) {
          _c.clearSelectedEvents();
        } else if (_c.showEmojiPicker) {
          _c.emojiPickerAction();
        }
      },
      child: FutureBuilder(
        future: _c.loadTimelineFuture,
        builder: (BuildContext context, snapshot) {
          var appbarBottomHeight = 0.0;
          if (_c.room.pinnedEventIds.isNotEmpty) {
            appbarBottomHeight += ChatAppBarListTile.fixedHeight;
          }

          return Scaffold(
            extendBodyBehindAppBar: AppSettings.enableChatFrostedGlass.value,
            appBar: AppBar(
              backgroundColor: AppSettings.enableChatFrostedGlass.value
                  ? Colors.transparent
                  : null,
              elevation: AppSettings.enableChatFrostedGlass.value ? 0 : null,
              scrolledUnderElevation: AppSettings.enableChatFrostedGlass.value
                  ? 0
                  : null,
              flexibleSpace: AppSettings.enableChatFrostedGlass.value
                  ? ClipRect(
                      child: BackdropFilter(
                        filter: ui.ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                        child: Container(
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surface.withAlpha(
                              theme.brightness == Brightness.dark ? 180 : 200,
                            ),
                            border: Border(
                              bottom: BorderSide(
                                color: theme.colorScheme.outlineVariant
                                    .withAlpha(80),
                                width: 0.5,
                              ),
                            ),
                          ),
                        ),
                      ),
                    )
                  : null,
              actionsIconTheme: IconThemeData(
                color: _c.selectedEvents.isEmpty
                    ? null
                    : theme.colorScheme.tertiary,
              ),
              automaticallyImplyLeading: false,
              centerTitle: AppSettings.enableAppBarCenterTitle.value,
              leading: _c.selectMode
                  ? IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: _c.clearSelectedEvents,
                      tooltip: L10n.of(context).close,
                      color: theme.colorScheme.tertiary,
                    )
                  : FluffyThemes.isColumnMode(context)
                  ? null
                  : StreamBuilder<Object>(
                      stream: Matrix.of(context).client.onSync.stream
                          .where((s) => s.hasRoomUpdate)
                          .rateLimit(const Duration(seconds: 1)),
                      builder: (context, _) => UnreadRoomsBadge(
                        filter: (r) => r.id != _c.roomId,
                        badgePosition: .topEnd(top: 4, end: 8),
                        child: const Center(child: BackButton()),
                      ),
                    ),
              titleSpacing: FluffyThemes.isColumnMode(context) ? 24 : 0,
              title: ChatAppBarTitle(_c),
              actions: _appBarActions(context),
              bottom: PreferredSize(
                preferredSize: Size.fromHeight(appbarBottomHeight),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [PinnedEvents(_c)],
                ),
              ),
            ),
            floatingActionButton: ValueListenableBuilder<bool>(
              valueListenable: _c.scrolledUpNotifier,
              builder: (context, scrolledUp, _) {
                final show =
                    (scrolledUp || _c.timeline?.allowNewEvent == false) &&
                    _c.selectedEvents.isEmpty;
                if (!show) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(bottom: 56.0),
                  child: FloatingActionButton(
                    onPressed: _c.scrollDown,
                    heroTag: null,
                    mini: true,
                    backgroundColor: theme.colorScheme.surface,
                    foregroundColor: theme.colorScheme.onSurface,
                    child: const Icon(Icons.arrow_downward_outlined),
                  ),
                );
              },
            ),
            body: DropTarget(
              onDragDone: _c.onDragDone,
              onDragEntered: _c.onDragEntered,
              onDragExited: _c.onDragExited,
              child: Stack(
                children: <Widget>[
                  if (wallpaperPath.isNotEmpty)
                    Positioned.fill(
                      child: ClipRect(
                        child: OverflowBox(
                          alignment: Alignment.topCenter,
                          maxHeight: screenHeight,
                          maxWidth: screenWidth,
                          child: Opacity(
                            opacity: AppSettings.wallpaperOpacity.value,
                            child: ImageFiltered(
                              imageFilter: ui.ImageFilter.blur(
                                sigmaX: AppSettings.wallpaperBlur.value,
                                sigmaY: AppSettings.wallpaperBlur.value,
                              ),
                              child: Image.file(
                                File(wallpaperPath),
                                fit: BoxFit.cover,
                                height: screenHeight,
                                width: screenWidth,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  Positioned.fill(
                    child: GestureDetector(
                      onTap: _c.clearSingleSelectedEvent,
                      child: ChatEventList(
                        controller: _c,
                        showThreadRoots: _c.showThreadRoots,
                      ),
                    ),
                  ),

                  if (_c.room.canSendDefaultMessages &&
                      _c.room.membership == Membership.join)
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: IgnorePointer(
                        child: Container(
                          height: 50,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                theme.colorScheme.surface.withValues(alpha: 0),
                                theme.colorScheme.surface.withValues(
                                  alpha: 0.6,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: _MeasureSize(
                      onChange: (size) {
                        final oldHeight = _c.inputBarHeight.value;
                        final newHeight = size.height;
                        if (oldHeight == newHeight) return;
                        _c.inputBarHeight.value = newHeight;

                        // Keep the list scrolled to the bottom if we were already
                        // there, otherwise the newly‑added input bar would cover a
                        // message.
                        final sc = _c.scrollController;
                        if (sc.hasClients && sc.offset <= 0.0) {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            if (sc.hasClients) sc.jumpTo(0.0);
                          });
                        }
                      },
                      child: SafeArea(
                        top: false,
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: bottomSheetPadding,
                            vertical: bottomSheetPadding / 2,
                          ),
                          child: Align(
                            alignment: Alignment.center,
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(
                                maxWidth: FluffyThemes.columnWidth * 2.5,
                              ),
                              child: _c.room.isExtinct
                                  ? (AppSettings.enableChatFrostedGlass.value
                                        ? _FloatingInputShell(
                                            child: ElevatedButton.icon(
                                              icon: const Icon(
                                                Icons.chevron_right,
                                              ),
                                              label: Text(
                                                L10n.of(context).enterNewChat,
                                              ),
                                              onPressed: _c.goToNewRoomAction,
                                            ),
                                          )
                                        : ElevatedButton.icon(
                                            icon: const Icon(
                                              Icons.chevron_right,
                                            ),
                                            label: Text(
                                              L10n.of(context).enterNewChat,
                                            ),
                                            onPressed: _c.goToNewRoomAction,
                                          ))
                                  : _c.room.canSendDefaultMessages &&
                                        _c.room.membership == Membership.join &&
                                        !_c.showThreadRoots
                                  ? (() {
                                      final inputChild =
                                          _c.room.isAbandonedDMRoom == true
                                          ? Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceEvenly,
                                              children: [
                                                TextButton.icon(
                                                  style: TextButton.styleFrom(
                                                    padding:
                                                        const EdgeInsets.all(
                                                          16,
                                                        ),
                                                    foregroundColor:
                                                        theme.colorScheme.error,
                                                  ),
                                                  icon: const Icon(
                                                    Icons.archive_outlined,
                                                  ),
                                                  onPressed: _c.leaveChat,
                                                  label: Text(
                                                    L10n.of(context).leave,
                                                  ),
                                                ),
                                                TextButton.icon(
                                                  style: TextButton.styleFrom(
                                                    padding:
                                                        const EdgeInsets.all(
                                                          16,
                                                        ),
                                                  ),
                                                  icon: const Icon(
                                                    Icons.forum_outlined,
                                                  ),
                                                  onPressed: _c.recreateChat,
                                                  label: Text(
                                                    L10n.of(context).reopenChat,
                                                  ),
                                                ),
                                              ],
                                            )
                                          : Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                ReplyDisplay(_c),
                                                ChatInputRow(_c),
                                                ChatEmojiPicker(_c),
                                              ],
                                            );
                                      return AppSettings
                                              .enableChatFrostedGlass
                                              .value
                                          ? _FloatingInputShell(
                                              child: inputChild,
                                            )
                                          : Material(
                                              clipBehavior: Clip.hardEdge,
                                              color: theme
                                                  .colorScheme
                                                  .surfaceContainerHigh,
                                              borderRadius:
                                                  BorderRadius.circular(24),
                                              child: inputChild,
                                            );
                                    })()
                                  : const SizedBox.shrink(),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  if (_c.dragging)
                    Container(
                      color: theme.scaffoldBackgroundColor.withAlpha(230),
                      alignment: Alignment.center,
                      child: const Icon(Icons.upload_outlined, size: 100),
                    ),

                  Positioned(
                    top:
                        MediaQuery.of(context).padding.top +
                        kToolbarHeight +
                        appbarBottomHeight +
                        22,
                    left: 0,
                    right: 0,
                    child: SizedBox(
                      child: Align(
                        alignment: Alignment.center,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const BackToCallButton(),
                            const MiniAudioPlayer(),
                            if (scrollUpBannerEventId != null)
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  FilledButton(
                                    onPressed: () {
                                      _c.scrollToEventId(scrollUpBannerEventId);
                                      _c.discardScrollUpBannerEventId();
                                    },
                                    style: FilledButton.styleFrom(
                                      shadowColor: Colors.black,
                                      elevation: 4,
                                    ),
                                    child: Row(
                                      children: const [
                                        Icon(Icons.arrow_upward),
                                        SizedBox(width: 18),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _FloatingInputShell extends StatelessWidget {
  final Widget child;
  const _FloatingInputShell({required this.child});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return PhysicalModel(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(28),
      clipBehavior: Clip.hardEdge,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              color: theme.colorScheme.surfaceContainerHigh.withAlpha(
                theme.brightness == Brightness.dark ? 160 : 190,
              ),
              border: Border.all(
                color: theme.colorScheme.outlineVariant.withAlpha(60),
                width: 0.8,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(
                    theme.brightness == Brightness.dark ? 60 : 20,
                  ),
                  blurRadius: 24,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

class _MeasureSize extends SingleChildRenderObjectWidget {
  final ValueChanged<Size> onChange;

  const _MeasureSize({required this.onChange, required super.child});

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _MeasureSizeRenderObject(onChange);

  @override
  void updateRenderObject(
    BuildContext context,
    _MeasureSizeRenderObject renderObject,
  ) {
    renderObject.onChange = onChange;
  }
}

class _MeasureSizeRenderObject extends RenderProxyBox {
  ValueChanged<Size> onChange;
  Size? _oldSize;

  _MeasureSizeRenderObject(this.onChange);

  @override
  void performLayout() {
    super.performLayout();
    final newSize = size;
    if (newSize != _oldSize) {
      _oldSize = newSize;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        onChange(newSize);
      });
    }
  }
}
