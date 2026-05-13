import 'package:flutter/material.dart';

import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:matrix/matrix.dart';

import 'package:Pulsly/config/setting_keys.dart';
import 'package:Pulsly/generated/l10n/l10n.dart';
import 'package:Pulsly/pages/chat/recording_input_row.dart';
import 'package:Pulsly/pages/chat/recording_view_model.dart';
import 'package:Pulsly/pages/chat/video_note_recording_dialog.dart';
import 'package:Pulsly/shortcuts/chat/paste_shortcut.dart';
import 'package:Pulsly/utils/platform_infos.dart';
import 'package:Pulsly/widgets/avatar.dart';
import 'package:Pulsly/widgets/matrix.dart';
import '../../config/themes.dart';
import 'chat.dart';
import 'input_bar.dart';

class ChatInputRow extends StatelessWidget {
  final ChatController controller;

  static const double height = 56.0; // Touch target size

  const ChatInputRow(this.controller, {super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final selectedTextButtonStyle = TextButton.styleFrom(
      foregroundColor: theme.colorScheme.onSurface,
    );

    return RecordingViewModel(
      builder: (context, recordingViewModel) {
        if (recordingViewModel.isRecording) {
          return RecordingInputRow(
            state: recordingViewModel,
            onSend: controller.onVoiceMessageSend,
            onVideoSend: controller.onVideoNoteSend,
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: controller.selectMode
              ? <Widget>[
                  if (controller.selectedEvents.every(
                    (event) => event.status == EventStatus.error,
                  ))
                    SizedBox(
                      height: height,
                      child: Semantics(
                        label: L10n.of(context).delete,
                        button: true,
                        child: TextButton(
                          style: TextButton.styleFrom(
                            foregroundColor: theme.colorScheme.error,
                          ),
                          onPressed: controller.deleteErrorEventsAction,
                          child: Row(
                            children: <Widget>[
                              const Icon(Icons.delete_forever_outlined),
                              Text(L10n.of(context).delete),
                            ],
                          ),
                        ),
                      ),
                    )
                  else
                    SizedBox(
                      height: height,
                      child: Semantics(
                        label: L10n.of(context).forward,
                        button: true,
                        child: TextButton(
                          style: selectedTextButtonStyle,
                          onPressed: controller.forwardEventsAction,
                          child: Row(
                            children: <Widget>[
                              const Icon(Icons.keyboard_arrow_left_outlined),
                              Text(L10n.of(context).forward),
                            ],
                          ),
                        ),
                      ),
                    ),
                  controller.selectedEvents.length == 1
                      ? controller.selectedEvents.first
                                .getDisplayEvent(controller.timeline!)
                                .status
                                .isSent
                            ? SizedBox(
                                height: height,
                                child: Semantics(
                                  label: L10n.of(context).reply,
                                  button: true,
                                  child: TextButton(
                                    style: selectedTextButtonStyle,
                                    onPressed: controller.replyAction,
                                    child: Row(
                                      children: <Widget>[
                                        const Icon(Icons.reply_outlined),
                                        Text(L10n.of(context).reply),
                                      ],
                                    ),
                                  ),
                                ),
                              )
                            : SizedBox(
                                height: height,
                                child: Semantics(
                                  label: L10n.of(context).edit,
                                  button: true,
                                  child: TextButton(
                                    style: selectedTextButtonStyle,
                                    onPressed: controller.editSelectedEventAction,
                                    child: Row(
                                      children: <Widget>[
                                        const Icon(Icons.edit_outlined),
                                        Text(L10n.of(context).edit),
                                      ],
                                    ),
                                  ),
                                ),
                              )
                      : const SizedBox.shrink(),
                  SizedBox(
                    height: height,
                    child: Semantics(
                      label: L10n.of(context).copy,
                      button: true,
                      child: TextButton(
                        style: selectedTextButtonStyle,
                        onPressed: () => controller.copyEventsAction(context),
                        child: Row(
                          children: <Widget>[
                            const Icon(Icons.copy_outlined),
                            Text(L10n.of(context).copy),
                          ],
                        ),
                      ),
                    ),
                  ),
                  if (controller.selectedEvents.length == 1 &&
                      controller.selectedEvents.first
                          .getDisplayEvent(controller.timeline!)
                          .status
                          .isSent)
                    SizedBox(
                      height: height,
                      child: Semantics(
                        label: L10n.of(context).pin,
                        button: true,
                        child: TextButton(
                          style: selectedTextButtonStyle,
                          onPressed: controller.pinEvent,
                          child: Row(
                            children: <Widget>[
                              const Icon(Icons.push_pin_outlined),
                              Text(L10n.of(context).pin),
                            ],
                          ),
                        ),
                      ),
                    ),
                  if (controller.canRedactSelectedEvents)
                    SizedBox(
                      height: height,
                      child: Semantics(
                        label: L10n.of(context).redact,
                        button: true,
                        child: TextButton(
                          style: TextButton.styleFrom(
                            foregroundColor: theme.colorScheme.error,
                          ),
                          onPressed: controller.redactEventsAction,
                          child: Row(
                            children: <Widget>[
                              const Icon(Icons.delete_outlined),
                              Text(L10n.of(context).redact),
                            ],
                          ),
                        ),
                      ),
                    ),
                ]
              : <Widget>[
                  if (Matrix.of(context).hasComplexBundles &&
                      Matrix.of(context).currentBundle!.length > 1)
                    Container(
                      height: height,
                      width: height,
                      alignment: Alignment.center,
                      child: _ChatAccountPicker(controller),
                    ),
                  // Emoji button (WhatsApp style)
                  Container(
                    height: height,
                    width: height,
                    alignment: Alignment.center,
                    child: Semantics(
                      label: 'Emoji',
                      button: true,
                      child: IconButton(
                        icon: const Icon(Icons.emoji_emotions_outlined),
                        color: Theme.of(context).colorScheme.onSurface,
                        onPressed: () {
                          // Toggle emoji picker
                          controller.showEmojiPicker = !controller.showEmojiPicker;
                          controller.setState(() {});
                        },
                      ),
                    ),
                  ),
                  // Text input with camera and attachment inside (WhatsApp style)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4.0,
                        vertical: 8.0,
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(24.0),
                          border: Border.all(
                            color: controller.sendController.text.isNotEmpty
                                ? theme.colorScheme.primary.withOpacity(0.3)
                                : theme.colorScheme.outline.withOpacity(0.2),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: theme.colorScheme.shadow.withOpacity(0.05),
                              blurRadius: 8.0,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            // Attachment menu inside text field
                            PopupMenuButton<String>(
                              icon: const Icon(Icons.attach_file),
                              color: theme.colorScheme.surface,
                              onSelected: controller.onAddPopupMenuButtonSelected,
                              itemBuilder: (BuildContext context) => [
                                PopupMenuItem(
                                  value: 'image',
                                  child: ListTile(
                                    leading: const Icon(Icons.photo_outlined),
                                    title: Text(L10n.of(context).sendImage),
                                  ),
                                ),
                                PopupMenuItem(
                                  value: 'video',
                                  child: ListTile(
                                    leading: const Icon(Icons.video_library_outlined),
                                    title: Text(L10n.of(context).sendVideo),
                                  ),
                                ),
                                PopupMenuItem(
                                  value: 'camera',
                                  child: ListTile(
                                    leading: const Icon(Icons.camera_alt_outlined),
                                    title: Text(L10n.of(context).openCamera),
                                  ),
                                ),
                                PopupMenuItem(
                                  value: 'camera-video',
                                  child: ListTile(
                                    leading: const Icon(Icons.videocam_outlined),
                                    title: Text(L10n.of(context).openVideoCamera),
                                  ),
                                ),
                                PopupMenuItem(
                                  value: 'location',
                                  child: ListTile(
                                    leading: const Icon(Icons.location_on_outlined),
                                    title: Text(L10n.of(context).shareLocation),
                                  ),
                                ),
                                PopupMenuItem(
                                  value: 'file',
                                  child: ListTile(
                                    leading: const Icon(Icons.attachment_outlined),
                                    title: Text(L10n.of(context).sendFile),
                                  ),
                                ),
                                PopupMenuItem(
                                  value: 'poll',
                                  child: ListTile(
                                    leading: const Icon(Icons.poll_outlined),
                                    title: Text(L10n.of(context).startPoll),
                                  ),
                                ),
                              ],
                            ),
                            // Text input
                            Expanded(
                              child: Semantics(
                                label: 'Paste image from clipboard',
                                button: true,
                                child: ChatPasteShortcut(
                                  onPaste: () {
                                    controller.sendImageFromClipBoard(null);
                                  },
                                  child: InputBar(
                                    room: controller.room,
                                    minLines: 1,
                                    maxLines: 8,
                                    autofocus: !PlatformInfos.isMobile,
                                    keyboardType: TextInputType.multiline,
                                    textInputAction:
                                        AppSettings.sendOnEnter.value &&
                                            PlatformInfos.isMobile
                                        ? TextInputAction.send
                                        : null,
                                    onSubmitted: controller.onInputBarSubmitted,
                                    onSubmitImage: controller.sendImageFromClipBoard,
                                    focusNode: controller.inputFocus,
                                    controller: controller.sendController,
                                    decoration: InputDecoration(
                                      contentPadding: const EdgeInsets.only(
                                        left: 4.0,
                                        right: 4.0,
                                        bottom: 8.0,
                                        top: 8.0,
                                      ),
                                      counter: const SizedBox.shrink(),
                                      hintText: L10n.of(context).writeAMessage,
                                      hintMaxLines: 1,
                                      border: InputBorder.none,
                                      enabledBorder: InputBorder.none,
                                      filled: false,
                                    ),
                                    onChanged: controller.onInputBarChanged,
                                  ),
                                ),
                              ),
                            ),
                            // Camera button inside text field
                            IconButton(
                              icon: const Icon(Icons.camera_alt_outlined),
                              color: Theme.of(context).colorScheme.onSurface,
                              onPressed: () => controller.onAddPopupMenuButtonSelected('camera'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Send / Microphone button (WhatsApp style - green circle)
                  Container(
                    height: height,
                    width: height,
                    margin: const EdgeInsets.only(left: 4),
                    decoration: BoxDecoration(
                      color: controller.sendController.text.isNotEmpty
                          ? theme.colorScheme.primary
                          : theme.colorScheme.primaryContainer,
                      shape: BoxShape.circle,
                    ),
                    child: Semantics(
                      label: controller.sendController.text.isEmpty
                          ? (recordingViewModel.recordingMode == RecordingMode.video
                              ? 'Record video note'
                              : 'Record voice message')
                          : L10n.of(context).send,
                      button: true,
                      child: AnimatedSwitcher(
                        duration: MediaQuery.of(context).disableAnimations
                            ? Duration.zero
                            : const Duration(milliseconds: 200),
                        child: controller.sendController.text.isNotEmpty
                            ? IconButton(
                                key: const ValueKey('send'),
                                icon: const Icon(Icons.send),
                                color: theme.colorScheme.onPrimary,
                                onPressed: controller.send,
                              )
                            : IconButton(
                                key: const ValueKey('mic'),
                                icon: Icon(
                                  recordingViewModel.recordingMode == RecordingMode.video
                                      ? Icons.videocam
                                      : Icons.mic,
                                  color: theme.colorScheme.onPrimaryContainer,
                                ),
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      margin: const EdgeInsets.only(
                                        bottom: height + 16,
                                        left: 16,
                                        right: 16,
                                        top: 16,
                                      ),
                                      showCloseIcon: true,
                                      content: Text(
                                        recordingViewModel.recordingMode == RecordingMode.video
                                            ? L10n.of(context).longPressToRecordVideoNote
                                            : L10n.of(context).longPressToRecordVoiceMessage,
                                      ),
                                    ),
                                  );
                                },
                                onLongPress: () {
                                  if (recordingViewModel.recordingMode == RecordingMode.video) {
                                    showDialog(
                                      context: context,
                                      builder: (context) => VideoNoteRecordingDialog(
                                        room: controller.room,
                                        onVideoSend: controller.onVideoNoteSend,
                                      ),
                                    );
                                  } else {
                                    recordingViewModel.startRecording(controller.room);
                                  }
                                },
                              ),
                      ),
                    ),
                  ),
                ],
        );
      },
    );
  }
}

class _ChatAccountPicker extends StatelessWidget {
  final ChatController controller;
  const _ChatAccountPicker(this.controller);

  @override
  Widget build(BuildContext context) {
    final clients = Matrix.of(context).currentBundle!;
    if (clients.length == 1) {
      final client = clients.first;
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Avatar(
          mxContent: client.userID.avatarUrl,
          name: client.userID.localpart,
          size: 32,
        ),
      );
    }
    return PopupMenuButton<String>(
      onSelected: (clientID) {
        final client = clients.firstWhere(
          (client) => client.userID == clientID,
        );
        Matrix.of(context).setActiveClient(client);
      },
      itemBuilder: (BuildContext context) => clients
          .map(
            (client) => PopupMenuItem<String>(
              value: client.userID,
              child: Row(
                children: [
                  Avatar(
                    mxContent: client.userID.avatarUrl,
                    name: client.userID.localpart,
                    size: 32,
                  ),
                  const SizedBox(width: 12),
                  Text(client.userID.localpart ?? client.userID),
                ],
              ),
            ),
          )
          .toList(),
      child: Avatar(
        mxContent: Matrix.of(context).client.userID.avatarUrl,
        name: Matrix.of(context).client.userID.localpart,
        size: 32,
      ),
    );
  }
}
