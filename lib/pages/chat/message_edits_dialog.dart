import 'package:extera_next/config/app_config.dart';
import 'package:extera_next/generated/l10n/l10n.dart';
import 'package:extera_next/pages/chat/chat.dart';
import 'package:extera_next/pages/chat/events/message_content.dart';
import 'package:flutter/material.dart';
import 'package:matrix/matrix.dart';

class MessageEditsDialog extends StatelessWidget {
  final Event event;
  final Set<Event> events;
  final ChatController controller;

  const MessageEditsDialog({
    super.key,
    required this.event,
    required this.events,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
    // return Scaffold(
    //   appBar: AppBar(
    //     title: Text(L10n.of(context).nEdits(events.length)),
    //   ),
    //   body: Padding(padding: const .all(8),
    //     child: Material(
    //       clipBehavior: .hardEdge,
    //       borderRadius: BorderRadius.circular(AppConfig.borderRadius),
    //       color: Theme.of(context).colorScheme.surfaceContainerHigh,
    //       child: ListView.builder(
    //         itemCount: events.length,
    //         itemBuilder: (context, index) {
    //           final editEvent = events.elementAt(index);
    //           return MessageContent(
    //             editEvent,
    //             borderRadius: BorderRadius.circular(AppConfig.borderRadius),
    //             timeline: controller.timeline!,

    //           );
    //         },
    //       ),
    //     )
    //   ),
    // );
  }

}