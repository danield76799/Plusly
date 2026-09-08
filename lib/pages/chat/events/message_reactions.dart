import 'package:flutter/material.dart';

import 'package:collection/collection.dart' show IterableExtension;
import 'package:matrix/matrix.dart';

import 'package:Pulsly/config/app_config.dart';
import 'package:Pulsly/config/themes.dart';
import 'package:Pulsly/pages/chat/chat.dart';
import 'package:Pulsly/utils/adaptive_bottom_sheet.dart';
import 'package:Pulsly/widgets/avatar.dart';
import 'package:Pulsly/widgets/future_loading_dialog.dart';
import 'package:Pulsly/widgets/matrix.dart';
import 'package:Pulsly/widgets/mxc_image.dart';

class MessageReactions extends StatelessWidget {
  final Event event;
  final Timeline timeline;
  final ChatController? chatController;

  const MessageReactions(
    this.event,
    this.timeline, {
    this.chatController,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final allReactionEvents = event.aggregatedEvents(
      timeline,
      RelationshipTypes.reaction,
    );
    final reactionMap = <String, _ReactionEntry>{};
    final client = Matrix.of(context).client;

    for (final e in allReactionEvents) {
      final key = e.content
          .tryGetMap<String, dynamic>('m.relates_to')
          ?.tryGet<String>('key');
      if (key != null) {
        if (!reactionMap.containsKey(key)) {
          reactionMap[key] = _ReactionEntry(
            key: key,
            count: 0,
            reacted: false,
            reactionEvents: [],
          );
        }
        reactionMap[key]!.count++;
        reactionMap[key]!.reactionEvents!.add(e);
        reactionMap[key]!.reacted |= e.senderId == e.room.client.userID;
      }
    }

    final reactionList = reactionMap.values.toList();
    reactionList.sort((a, b) => b.count - a.count > 0 ? 1 : -1);
    final ownMessage = event.senderId == event.room.client.userID;
    return Wrap(
      spacing: 4.0,
      runSpacing: 4.0,
      alignment: ownMessage ? WrapAlignment.end : WrapAlignment.start,
      children: [
        ...reactionList.map(
          (r) => _Reaction(
            reactionKey: r.key,
            count: r.count,
            reacted: r.reacted,
            onTap: () {
              if (r.reacted) {
                final evt = allReactionEvents
                    .firstWhere(
          (e) => e.senderId == event.room.client.userID &&
                          e.content.tryGetMap('m.relates_to')?['key'] == r.key,,
          orElse: () => null,
        );
                if (evt != null) {
                  showFutureLoadingDialog(
                    context: context,
                    future: () => evt.redactEvent(),
                  );
                }
              } else {
                event.room.sendReaction(event.eventId, r.key);
              }
            },
            onLongPress: () async => await _AdaptiveReactorsDialog(
              client: client,
              reactionEntry: r,
              chatController: chatController,
            ).show(context),
          ),
        ),
        if (allReactionEvents.any((e) => e.status.isSending))
          const SizedBox(
            width: 24,
            height: 24,
            child: Padding(
              padding: EdgeInsets.all(4.0),
              child: CircularProgressIndicator.adaptive(strokeWidth: 1),
            ),
          ),
      ],
    );
  }
}

class _Reaction extends StatelessWidget {
  final String reactionKey;
  final int count;
  final bool? reacted;
  final void Function()? onTap;
  final void Function()? onLongPress;

  const _Reaction({
    required this.reactionKey,
    required this.count,
    required this.reacted,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = theme.brightness == Brightness.dark
        ? Colors.white
        : Colors.black;
    final color = reacted == true
        ? theme.bubbleColor
        : theme.colorScheme.surfaceContainerHigh;
    Widget content;

    var renderKey = Characters(reactionKey);
    if (renderKey.length > 10) {
      renderKey = renderKey.getRange(0, 9) + Characters('…');
    }

    final reactionIcon = reactionKey.startsWith('mxc://')
        ? MxcImage(
            uri: Uri.parse(reactionKey),
            width: 20,
            height: 20,
            animated: true,
            isThumbnail: false,
          )
        : Text(
            renderKey.toString(),
            style: TextStyle(
              color: reacted == true ? theme.onBubbleColor : textColor,
              fontSize: DefaultTextStyle.of(context).style.fontSize,
            ),
            textScaler: const TextScaler.linear(1.2),
          );

    content = Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        reactionIcon,
        const SizedBox(width: 8),
        Text(
          count.toString(),
          style: TextStyle(
            color: textColor,
            fontSize: DefaultTextStyle.of(context).style.fontSize,
            fontWeight: .bold,
          ),
          textScaler: const TextScaler.linear(1.1),
        ),
      ],
    );

    return InkWell(
      onTap: () => onTap != null ? onTap!() : null,
      onLongPress: () => onLongPress != null ? onLongPress!() : null,
      onSecondaryTap: () => onLongPress != null
          ? onLongPress!()
          : null, // It is better to make it a seperate option
      borderRadius: BorderRadius.circular(AppConfig.borderRadius / 2),
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(AppConfig.borderRadius / 2),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: content,
      ),
    );
  }
}

class _ReactionEntry {
  String key;
  int count;
  bool reacted;
  List<Event>? reactionEvents;

  _ReactionEntry({
    required this.key,
    required this.count,
    required this.reacted,
    this.reactionEvents,
  });
}

class _AdaptiveReactorsDialog extends StatelessWidget {
  final Client? client;
  final _ReactionEntry? reactionEntry;
  final ChatController? chatController;

  const _AdaptiveReactorsDialog({
    this.client,
    this.chatController,
    this.reactionEntry,
  });

  Future<bool?> show(BuildContext context) => showAdaptiveBottomSheet(
    context: context,
    builder: (context) => this,
    useRootNavigator: false,
  );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // final body = SingleChildScrollView(
    //   child: Wrap(
    //     spacing: 8.0,
    //     runSpacing: 4.0,
    //     alignment: WrapAlignment.center,
    //     children: <Widget>[
    //       for (final reactor in reactionEntry!.reactors!)
    //         Chip(
    //           avatar: Avatar(
    //             mxContent: reactor.avatarUrl,
    //             name: reactor.displayName,
    //             client: client,
    //             presenceUserId: reactor.stateKey,
    //           ),
    //           label: Text(reactor.displayName ?? reactor.id),
    //         ),
    //     ],
    //   ),
    // );

    final reactionEvents = reactionEntry!.reactionEvents;

    if (reactionEvents == null) {
      return Text("reactionEvents == null");
    }

    final title = reactionEntry!.key.startsWith('mxc://')
        ? MxcImage(uri: Uri.parse(reactionEntry!.key), width: 32, height: 32)
        : Text(reactionEntry!.key);

    return Scaffold(
      appBar: AppBar(title: title),
      body: Center(
        child: Padding(
          padding: const .all(8),
          child: Material(
            borderRadius: BorderRadius.circular(AppConfig.borderRadius),
            color: theme.colorScheme.surfaceContainerHigh,
            clipBehavior: .hardEdge,
            child: CustomScrollView(
              slivers: [
                SliverList.builder(
                  itemBuilder: (context, i) {
                    final event = reactionEvents[i];
                    final user = event.senderFromMemoryOrFallback;

                    return ListTile(
                      leading: Avatar(
                        mxContent: user.avatarUrl,
                        size: 32,
                        name: user.displayName ?? user.id,
                        key: ValueKey(user.id),
                      ),
                      trailing: chatController == null
                          ? null
                          : Row(
                              mainAxisSize: .min,
                              children: [
                                IconButton(
                                  onPressed: () {
                                    chatController?.replyAction(replyTo: event);
                                    Navigator.of(context).pop();
                                  },
                                  icon: const Icon(Icons.reply_outlined),
                                ),
                                if (event.canRedact)
                                  IconButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                      chatController?.redactEventsAction(
                                        event: event,
                                      );
                                    },
                                    color: theme.colorScheme.error,
                                    icon: const Icon(Icons.close),
                                  ),
                              ],
                            ),
                      title: Text(user.displayName ?? user.id),
                    );
                  },
                  itemCount: reactionEvents.length,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
