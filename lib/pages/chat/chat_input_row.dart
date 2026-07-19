import 'package:flutter/material.dart';

import 'package:matrix/matrix.dart';

import 'package:Pulsly/config/setting_keys.dart';
import 'package:Pulsly/generated/l10n/l10n.dart';
import 'package:Pulsly/pages/chat/recording_input_row.dart';
import 'package:Pulsly/pages/chat/recording_view_model.dart';
import 'package:Pulsly/pages/chat/video_note_recording_dialog.dart';
import 'package:Pulsly/shortcuts/chat/paste_shortcut.dart';
import 'package:Pulsly/utils/platform_infos.dart';
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
                                        Text(L10n.of(context).reply),
                                        const Icon(Icons.keyboard_arrow_right),
                                      ],
                                    ),
                                  ),
                                ),
                              )
                            : SizedBox(
                                height: height,
                                child: Semantics(
                                  label: L10n.of(context).tryToSendAgain,
                                  button: true,
                                  child: TextButton(
                                    style: selectedTextButtonStyle,
                                    onPressed: controller.sendAgainAction,
                                    child: Row(
                                      children: <Widget>[
                                        Text(L10n.of(context).tryToSendAgain),
                                        const SizedBox(width: 4),
                                        const Icon(Icons.send_outlined, size: 16),
                                      ],
                                    ),
                                  ),
                                ),
                              )
                      : const SizedBox.shrink(),
                ]
              : <Widget>[
                  // Input bar met bijlage-icoon en emoji-knop erin (WhatsApp stijl)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10.0,
                        vertical: 8.0,
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(24.0),
                          border: Border.all(
                            color: controller.sendController.text.isNotEmpty
                                ? theme.colorScheme.primary.withValues(alpha: 0.3)
                                : theme.colorScheme.outline.withValues(alpha: 0.2),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: theme.colorScheme.shadow.withValues(alpha: 0.05),
                              blurRadius: 8.0,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
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
                                    maxLines: 5,
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
                                        bottom: 12.0,
                                        top: 12.0,
                                      ),
                                      counter: const SizedBox.shrink(),
                                      hintText: L10n.of(context).writeAMessage,
                                      hintStyle: TextStyle(
                                        fontSize:
                                            15 * AppSettings.fontSizeFactor.value,
                                        color: theme.colorScheme.onSurface
                                            .withValues(alpha: 0.5),
                                      ),
                                      hintMaxLines: 1,
                                      border: InputBorder.none,
                                      enabledBorder: InputBorder.none,
                                      filled: false,
                                      // Symmetric, generous spacing around the
                                      // paperclip so it lines up visually with
                                      // the emoji button on the right edge.
                                      prefixIconConstraints: const BoxConstraints(
                                        minWidth: 44,
                                        minHeight: 44,
                                      ),
                                      prefixIcon: PopupMenuButton<String>(
                                        tooltip: L10n.of(context).sendFile,
                                        onSelected: controller.onAddPopupMenuButtonSelected,
                                        itemBuilder: (BuildContext context) => [
                                          PopupMenuItem(
                                            value: 'camera',
                                            child: ListTile(
                                              leading: const Icon(Icons.camera_alt_outlined),
                                              title: Text(L10n.of(context).openCamera),
                                            ),
                                          ),
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
                                        child: Icon(
                                          Icons.attach_file,
                                          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                                        ),
                                      ),
                                    ),
                                    onChanged: controller.onInputBarChanged,
                                  ),
                                ),
                              ),
                            ),
                            // Emoji knop IN de input bar (rechts)
                            AnimatedContainer(
                              duration: MediaQuery.of(context).disableAnimations
                                  ? Duration.zero
                                  : FluffyThemes.animationDuration,
                              curve: FluffyThemes.animationCurve,
                              width: controller.sendController.text.isNotEmpty
                                  ? 0
                                  : height,
                              child: controller.sendController.text.isNotEmpty
                                  ? const SizedBox.shrink()
                                  : Semantics(
                                      label: 'Open emoji picker',
                                      button: true,
                                      child: Container(
                                        height: height,
                                        width: height,
                                        alignment: Alignment.center,
                                        child: IconButton(
                                          tooltip: L10n.of(context).emojis,
                                          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                                          icon: Icon(
                                            controller.showEmojiPicker
                                                ? Icons.emoji_emotions
                                                : Icons.emoji_emotions_outlined,
                                            key: ValueKey(controller.showEmojiPicker),
                                          ),
                                          onPressed: controller.emojiPickerAction,
                                        ),
                                      ),
                                    ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    height: height,
                    width: height,
                    alignment: Alignment.center,
                    child:
                        PlatformInfos.platformCanRecord &&
                            controller.sendController.text.isEmpty
                        ? Semantics(
                            label: recordingViewModel.recordingMode == RecordingMode.video
                                ? 'Record video note'
                                : 'Record voice message',
                            button: true,
                            child: IconButton(
                              tooltip:
                                  recordingViewModel.recordingMode ==
                                      RecordingMode.video
                                  ? L10n.of(context).videoNote
                                  : L10n.of(context).voiceMessage,
                              onPressed: () {
                                // On tap: show tip and toggle mode if video notes enabled
                                final videoNotesEnabled =
                                    AppSettings.enableVideoNotes.value &&
                                    PlatformInfos.isMobile;
                                if (videoNotesEnabled) {
                                  final newMode =
                                      recordingViewModel.recordingMode ==
                                          RecordingMode.audio
                                      ? RecordingMode.video
                                      : RecordingMode.audio;
                                  recordingViewModel.setRecordingMode(newMode);
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
                                        newMode == RecordingMode.video
                                            ? L10n.of(
                                                context,
                                              ).longPressToRecordVideoNote
                                            : L10n.of(
                                                context,
                                              ).longPressToRecordVoiceMessage,
                                      ),
                                    ),
                                  );
                                } else {
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
                                        L10n.of(
                                          context,
                                        ).longPressToRecordVoiceMessage,
                                      ),
                                    ),
                                  );
                                }
                              },
                              onLongPress: () {
                                // On long press: start recording
                                if (recordingViewModel.recordingMode ==
                                    RecordingMode.video) {
                                  showDialog(
                                    context: context,
                                    builder: (context) =>
                                        VideoNoteRecordingDialog(
                                          room: controller.room,
                                          onVideoSend: controller.onVideoNoteSend,
                                        ),
                                  );
                                } else {
                                  recordingViewModel.startRecording(controller.room);
                                }
                              },
                              icon: AnimatedSwitcher(
                                duration: MediaQuery.of(context).disableAnimations
                                    ? Duration.zero
                                    : const Duration(milliseconds: 200),
                                child: Container(
                                  // Subtle filled circle gives the mic button
                                  // contrast against the deep-black background
                                  // and ties it to the outgoing-bubble accent.
                                  padding: const EdgeInsets.all(8.0),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.primary
                                        .withValues(alpha: 0.15),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    recordingViewModel.recordingMode ==
                                            RecordingMode.video
                                        ? Icons.videocam_outlined
                                        : Icons.mic_none_outlined,
                                    key: ValueKey(
                                      recordingViewModel.recordingMode,
                                    ),
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                              ),
                            ),
                          )
                        : Semantics(
                            label: 'Send message',
                            button: true,
                            child: Container(
                              height: 56,
                              width: 56,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                gradient: controller.sendController.text.isNotEmpty
                                    ? const LinearGradient(
                                        colors: [Color(0xFF49AFC2), Color(0xFF6FC5D8)],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      )
                                    : null,
                                color: controller.sendController.text.isEmpty
                                    ? theme.bubbleColor
                                    : null,
                                borderRadius: BorderRadius.circular(28.0),
                                boxShadow: controller.sendController.text.isNotEmpty
                                    ? [
                                        BoxShadow(
                                          color: const Color(0xFF49AFC2).withValues(alpha: 0.3),
                                          blurRadius: 8.0,
                                          offset: const Offset(0, 2),
                                        ),
                                      ]
                                    : null,
                              ),
                              child: Material(
                                color: Colors.transparent,
                                borderRadius: BorderRadius.circular(28.0),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(28.0),
                                  onTap: controller.sendController.text.isNotEmpty
                                      ? controller.send
                                      : null,
                                  onLongPress: controller.sendController.text.isNotEmpty
                                      ? () => controller.sendScheduleAction()
                                      : null,
                                  child: Container(
                                    height: 48,
                                    width: 48,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: controller.sendController.text.isNotEmpty
                                          ? const Color(0xFF00A884)  // WhatsApp green
                                          : Colors.transparent,
                                      shape: BoxShape.circle,
                                    ),
                                    child: AnimatedSwitcher(
                                      duration: MediaQuery.of(context).disableAnimations
                                          ? Duration.zero
                                          : const Duration(milliseconds: 200),
                                      child: Icon(
                                        Icons.send_outlined,
                                        key: ValueKey(controller.sendController.text.isNotEmpty),
                                        color: controller.sendController.text.isNotEmpty
                                            ? Colors.white
                                            : theme.onBubbleColor,
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                ),
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