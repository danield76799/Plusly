import 'package:flutter/material.dart';

import 'package:matrix/matrix.dart';

import 'package:Pulsly/config/setting_keys.dart';
import 'package:Pulsly/config/themes.dart';
import 'package:Pulsly/generated/l10n/l10n.dart';
import 'package:Pulsly/pages/chat/recording_input_row.dart';
import 'package:Pulsly/pages/chat/recording_view_model.dart';
import 'package:Pulsly/shortcuts/chat/paste_shortcut.dart';
import 'package:Pulsly/utils/platform_infos.dart';
import 'chat.dart';
import 'input_bar.dart';

class ChatInputRow extends StatelessWidget {
  final ChatController controller;

  static const double height = 56.0; // Touch target size

  const ChatInputRow(this.controller, {super.key});

  /// Eén actie in de selectiebalk.
  ///
  /// [destructive] kleurt de knop in de foutkleur: verwijderen mag niet
  /// verward worden met kopiëren of doorsturen.
  static Widget _selectButton(
    BuildContext context,
    ThemeData theme, {
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    bool destructive = false,
  }) {
    return SizedBox(
      height: height,
      child: Semantics(
        label: label,
        button: true,
        child: TextButton(
          style: TextButton.styleFrom(
            foregroundColor: destructive
                ? theme.colorScheme.error
                : theme.colorScheme.onSurface,
          ),
          onPressed: onPressed,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(icon, size: 18),
              const SizedBox(width: 4),
              Text(label),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
                  // Selectiebalk: acties op de gekozen berichten.
                  //
                  // Scrollbaar, want op een smalle telefoon past niet alles
                  // op één rij. Kopiëren en Link kopiëren staan vooraan:
                  // het kopiëren van meerdere berichten tegelijk is de
                  // reden dat je meerdere berichten selecteert.
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Row(
                        children: [
                          _selectButton(
                            context,
                            theme,
                            icon: Icons.copy_outlined,
                            label: L10n.of(context).copy,
                            onPressed: controller.copyEventsAction,
                          ),
                          _selectButton(
                            context,
                            theme,
                            icon: Icons.link,
                            label: L10n.of(context).copyLink,
                            onPressed: controller.copyLinkAction,
                          ),
                          _selectButton(
                            context,
                            theme,
                            icon: Icons.keyboard_arrow_left_outlined,
                            label: L10n.of(context).forward,
                            onPressed: controller.forwardEventsAction,
                          ),
                          if (controller.selectedEvents.length == 1 &&
                              controller.selectedEvents.first
                                  .getDisplayEvent(controller.timeline!)
                                  .status
                                  .isSent)
                            _selectButton(
                              context,
                              theme,
                              icon: Icons.keyboard_arrow_right,
                              label: L10n.of(context).reply,
                              onPressed: controller.replyAction,
                            ),
                          if (controller.selectedEvents.every(
                            (event) => event.status == EventStatus.error,
                          ))
                            _selectButton(
                              context,
                              theme,
                              icon: Icons.delete_forever_outlined,
                              label: L10n.of(context).delete,
                              destructive: true,
                              onPressed: controller.deleteErrorEventsAction,
                            )
                          else
                            _selectButton(
                              context,
                              theme,
                              icon: Icons.delete_outline,
                              label: L10n.of(context).delete,
                              destructive: true,
                              onPressed: controller.redactEventsAction,
                            ),
                        ],
                      ),
                    ),
                  ),
                ]
              : <Widget>[
                  // Input bar met bijlage-icoon en emoji-knop erin (WhatsApp stijl)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6.0,
                        vertical: 8.0,
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          color: theme.inputBarColor,
                          borderRadius: BorderRadius.circular(24.0),
                          border: Border.all(
                            color: controller.sendController.text.isNotEmpty
                                ? theme.inputBarAccent.withValues(alpha: 0.4)
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
                                            15,
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
                                        minWidth: 38,
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
                                          PopupMenuItem(
                                            value: 'schedule',
                                            child: ListTile(
                                              leading: const Icon(Icons.schedule_outlined),
                                              title: Text('Bericht inplannen'),
                                            ),
                                          ),
                                          // De lijst met geplande berichten
                                          // stond als aparte knop in de
                                          // invoerbalk. Die nam 56dp van de
                                          // breedte en daardoor was de
                                          // hinttekst ("Schrijf een berich...")
                                          // afgekapst. De knop is nu een item
                                          // in dit menu.
                                          PopupMenuItem(
                                            value: 'scheduled',
                                            child: ListTile(
                                              leading: const Icon(Icons.schedule_outlined),
                                              title: Text('Geplande berichten'),
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
                            // Geplande berichten is verplaatst naar het
                            // bijlage-menu hierboven: als losse knop kostte
                            // hij 56dp en was de hinttekst afgekapst.

                            // Emoji knop IN de input bar — altijd zichtbaar.
                            // Smaller dan de overige knoppen: 56dp was
                            // kostbare breedte in de invoerbalk.
                            Semantics(
                              label: L10n.of(context).emojis,
                              button: true,
                              child: Container(
                                height: 44,
                                width: 44,
                                alignment: Alignment.center,
                                child: IconButton(
                                  tooltip: L10n.of(context).emojis,
                                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                                  iconSize: 22,
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(
                                    minWidth: 44,
                                    minHeight: 44,
                                  ),
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
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Padding(
                    padding: const EdgeInsets.all(4),
                    child: SizedBox(
                      height: 48,
                      width: 48,
                      child: Material(
                        color: controller.sendController.text.isNotEmpty
                            ? theme.sendButtonColor
                            : theme.colorScheme.surface,
                        shape: const CircleBorder(),
                        elevation: controller.sendController.text.isNotEmpty ? 2 : 0,
                        shadowColor: theme.sendButtonColor.withValues(alpha: 0.3),
                        child: InkWell(
                          customBorder: const CircleBorder(),
                          onTap: PlatformInfos.platformCanRecord &&
                                  controller.sendController.text.isEmpty
                              ? () {
                                  // Show recording hint (mirrors old tap behaviour)
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      margin: const EdgeInsets.only(
                                        bottom: height + 20,
                                        left: 16,
                                        right: 16,
                                        top: 16,
                                      ),
                                      showCloseIcon: true,
                                      content: Text(
                                        L10n.of(context).longPressToRecordVoiceMessage,
                                      ),
                                    ),
                                  );
                                }
                              : controller.sendController.text.isNotEmpty
                                  ? controller.send
                                  : null,
                          onLongPress: PlatformInfos.platformCanRecord &&
                                  controller.sendController.text.isEmpty
                              ? () => recordingViewModel.startRecording(controller.room)
                              : null,
                          child: AnimatedSwitcher(
                            duration: MediaQuery.of(context).disableAnimations
                                ? Duration.zero
                                : const Duration(milliseconds: 200),
                            child: Icon(
                              controller.sendController.text.isNotEmpty
                                  ? Icons.send_rounded
                                  : recordingViewModel.recordingMode == RecordingMode.video
                                      ? Icons.videocam_outlined
                                      : Icons.mic_none_outlined,
                              key: ValueKey(controller.sendController.text.isNotEmpty),
                              color: controller.sendController.text.isNotEmpty
                                  ? theme.sendButtonIconColor
                                  : theme.colorScheme.primary,
                              size: 22,
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