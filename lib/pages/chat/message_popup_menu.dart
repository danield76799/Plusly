// import 'package:extera_next/generated/l10n/l10n.dart';
// import 'package:extera_next/widgets/matrix.dart';
// import 'package:flutter/material.dart';
// import 'package:matrix/matrix.dart';

// class MessagePopupMenu extends StatefulWidget {
//   final Room room;
//   final Event event;
//   final Widget child;

//   const MessagePopupMenu(
//       {required this.room,
//       required this.event,
//       required this.child,
//       super.key});

//   @override
//   MessagePopupMenuState createState() => MessagePopupMenuState();
// }

// class MessagePopupMenuState extends State<MessagePopupMenu> {
//   @override
//   Widget build(BuildContext context) {
//     final client = Matrix.of(context).client;
//     final room = widget.room;
//     final event = widget.event;

//     return PopupMenuButton<_EventContextAction>(
//       onSelected: (action) {},
//       tooltip: '',
//       splashRadius: 0,
//       padding: EdgeInsets.zero,
//       enableFeedback: false,
//       itemBuilder: (context) => [
//         if (room.canSendDefaultMessages)
//           PopupMenuItem(
//             value: _EventContextAction.reply,
//             child: Row(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 const Icon(Icons.reply_outlined),
//                 const SizedBox(width: 12),
//                 Text(L10n.of(context).reply),
//               ],
//             ),
//           ),
//         if (room.canSendDefaultMessages)
//           PopupMenuItem(
//             value: _EventContextAction.discuss,
//             child: Row(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 const Icon(Icons.chat_bubble_outline),
//                 const SizedBox(width: 12),
//                 Text(L10n.of(context).discuss),
//               ],
//             ),
//           ),
//         if (event.senderId == client.userID && room.canSendDefaultMessages)
//           PopupMenuItem(
//             value: _EventContextAction.edit,
//             child: Row(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 const Icon(Icons.edit_outlined),
//                 const SizedBox(width: 12),
//                 Text(L10n.of(context).discuss),
//               ],
//             ),
//           ),
//         if (room.canChangeStateEvent(EventTypes.RoomPinnedEvents))
//           PopupMenuItem(
//             value: _EventContextAction.pin,
//             child: Row(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 const Icon(Icons.push_pin_outlined),
//                 const SizedBox(width: 12),
//                 Text(L10n.of(context).pin),
//               ],
//             ),
//           ),
//         PopupMenuItem(
//           value: _EventContextAction.copy,
//           child: Row(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               const Icon(Icons.copy),
//               const SizedBox(width: 12),
//               Text(L10n.of(context).copy),
//             ],
//           ),
//         ),
//         PopupMenuItem(
//           value: _EventContextAction.link,
//           child: Row(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               const Icon(Icons.link),
//               const SizedBox(width: 12),
//               Text(L10n.of(context).copyLink),
//             ],
//           ),
//         ),
//         PopupMenuItem(
//           value: _EventContextAction.translate,
//           child: Row(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               const Icon(Icons.translate),
//               const SizedBox(width: 12),
//               Text(L10n.of(context).translateMessage),
//             ],
//           ),
//         ),
//         PopupMenuItem(
//           value: _EventContextAction.redact,
//           child: Row(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               const Icon(Icons.translate),
//               const SizedBox(width: 12),
//               Text(L10n.of(context).redactMessage),
//             ],
//           ),
//         ),
//       ],
//       child: widget.child,
//     );
//   }
// }

// enum _EventContextAction {
//   reply,
//   discuss,
//   edit,
//   copy,
//   link,
//   translate,
//   pin,
//   redact
// }
