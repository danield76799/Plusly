import 'package:extera_next/widgets/emoji_picker.dart';
import 'package:extera_next/widgets/mxc_image.dart';
import 'package:flutter/material.dart';

import 'package:extera_next/generated/l10n/l10n.dart';
import 'package:matrix/matrix.dart';

import 'package:extera_next/config/themes.dart';
import 'package:extera_next/pages/chat/sticker_picker_dialog.dart';
import 'chat.dart';

class ChatEmojiPicker extends StatelessWidget {
  final ChatController controller;
  const ChatEmojiPicker(this.controller, {super.key});

  @override
  Widget build(BuildContext context) {
    final imagePacks = controller.room.getImagePacks(ImagePackUsage.emoticon);

    return AnimatedContainer(
      duration: FluffyThemes.animationDuration,
      curve: FluffyThemes.animationCurve,
      clipBehavior: Clip.hardEdge,
      decoration: const BoxDecoration(),
      height: controller.showEmojiPicker
          ? MediaQuery.sizeOf(context).height / 2
          : 0,
      child: controller.showEmojiPicker
          ? DefaultTabController(
              length: 2,
              child: Column(
                children: [
                  TabBar(
                    tabs: [
                      Tab(text: L10n.of(context).emojis),
                      Tab(text: L10n.of(context).stickers),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        MatrixEmojiPicker(
                          onEmojiSelected: controller.onEmojiSelected,
                          onBackspacePressed: controller.emojiPickerBackspace,
                          customCategories: imagePacks.entries
                              .map(
                                (entry) => CustomCategory(
                                  id: entry.key,
                                  name: entry.value.pack.displayName!,
                                  icon: CircleAvatar(
                                    child: MxcImage(
                                      uri: entry.value.images.values.first.url,
                                      width: 32,
                                      height: 32,
                                    ),
                                  ),
                                  emojis: entry.value.images.map((
                                    name,
                                    content,
                                  ) {
                                    return MapEntry(
                                      name,
                                      content.url.toString(),
                                    );
                                  }),
                                ),
                              )
                              .toList(),
                          customEmojiBuilder: (context, name, size) {
                            return MxcImage(
                              uri: Uri.parse(name),
                              width: 32,
                              height: 32,
                            );
                          },
                        ),
                        StickerPickerDialog(
                          room: controller.room,
                          onSelected: (sticker) {
                            controller.room.sendEvent({
                              'body': sticker.body,
                              'info': sticker.info ?? {},
                              'url': sticker.url.toString(),
                              'm.relates_to': controller.replyEvent != null
                                  ? {
                                      'm.in_reply_to': {
                                        'event_id':
                                            controller.replyEvent!.eventId,
                                      },
                                    }
                                  : null,
                            }, type: EventTypes.Sticker);
                            controller.cancelReplyEventAction();
                            controller.hideEmojiPicker();
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )
          : null,
    );
  }
}

class NoRecent extends StatelessWidget {
  const NoRecent({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          L10n.of(context).emoteKeyboardNoRecents,
          style: Theme.of(context).textTheme.bodyLarge,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
