import 'package:flutter/material.dart';
import 'package:matrix/matrix.dart';

import 'package:Pulsly/utils/user_cache.dart';
import 'package:Pulsly/widgets/avatar.dart';
import 'package:Pulsly/widgets/matrix.dart';
import 'package:Pulsly/config/app_config.dart';
import 'package:Pulsly/config/setting_keys.dart';
import 'package:Pulsly/config/themes.dart';
import 'package:Pulsly/generated/l10n/l10n.dart';
import 'package:Pulsly/utils/date_time_extension.dart';
import 'package:Pulsly/utils/platform_infos.dart';
import 'package:Pulsly/utils/poll_events.dart';
import 'package:Pulsly/utils/string_color.dart';
import 'message_content.dart';
import 'message_reactions.dart';
import 'message_read_receipts.dart';
import 'reply_content.dart';
import 'state_message.dart';
import 'package:swipe_to_action/swipe_to_action.dart';

/// Optimized Message widget that uses UserCache instead of
/// creating FutureBuilders for every message.
class MessageOptimized extends StatefulWidget {
  final Event event;
  final Event? nextEvent;
  final Event? previousEvent;
  final bool displayReadMarker;
  final void Function(Event, Offset?) onSelect;
  final void Function(Event) onInfoTab;
  final void Function(String) scrollToEventId;
  final void Function() onSwipe;
  final void Function() onMention;
  final bool longPressSelect;
  final bool selected;
  final Timeline timeline;
  final bool highlightMarker;
  final bool animateIn;
  final bool wallpaperMode;
  final List<Color> colors;
  final bool gradient;
  final bool singleSelected;
  final Thread? thread;
  final bool hasBeenRead;
  final List<Receipt>? readReceipts;

  const MessageOptimized(
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
    this.colors = const [],
    super.key,
  });

  @override
  State<MessageOptimized> createState() => _MessageOptimizedState();
}

class _MessageOptimizedState extends State<MessageOptimized> {
  Offset _tapPosition = Offset.zero;
  User? _cachedUser;
  bool loadMedia = false;

  @override
  void initState() {
    super.initState();
    loadMedia = shouldAutoLoadMedia(
      widget.event.room.client,
      widget.event.room.id,
    );
    _loadUser();
  }

  @override
  void didUpdateWidget(MessageOptimized oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.event.senderId != widget.event.senderId) {
      _loadUser();
    }
  }

  void _loadUser() {
    final client = Matrix.of(context).client;
    final cache = UserCacheProvider.of(context);
    
    // Use cached user immediately if available
    _cachedUser = cache.get(widget.event.senderId);
    
    // Fetch in background if not cached
    if (_cachedUser == null) {
      cache.fetchOrGet(client, widget.event.senderId, widget.event.room)
        .then((user) {
          if (mounted && user != null) {
            setState(() {
              _cachedUser = user;
            });
          }
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    final event = widget.event;
    final theme = Theme.of(context);
    final client = Matrix.of(context).client;
    final ownMessage = event.senderId == client.userID;

    // Use cached user if available, fallback to memory
    final user = _cachedUser ?? event.senderFromMemoryOrFallback;
    final displayname = _cachedUser?.calcDisplayname() ?? 
        event.senderFromMemoryOrFallback.calcDisplayname();

    // ... rest of build method similar to original but without FutureBuilder<User>
    // since user is now cached

    return Container(
      // Simplified - full implementation would include all the message UI
      child: Text('$displayname: ${event.body}'),
    );
  }
}

/// Provider to make UserCache available in the widget tree
class UserCacheProvider extends InheritedWidget {
  final UserCache cache;

  const UserCacheProvider({
    required this.cache,
    required super.child,
    super.key,
  });

  static UserCache of(BuildContext context) {
    final provider = context.dependOnInheritedWidgetOfExactType<UserCacheProvider>();
    assert(provider != null, 'No UserCacheProvider found in context');
    return provider!.cache;
  }

  @override
  bool updateShouldNotify(UserCacheProvider oldWidget) => 
      oldWidget.cache != cache;
}