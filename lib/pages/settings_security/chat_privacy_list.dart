import 'package:extera_next/generated/l10n/l10n.dart';
import 'package:extera_next/pages/chat_list/chat_list_item.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:matrix/matrix.dart';

class ChatPrivacyList extends StatelessWidget {
  final Client client;

  const ChatPrivacyList({required this.client, super.key});

  List<String> get roomIds {
    // xyz.extera.room_privacy_settings.
    var keys = client.accountData.keys.toList();
    keys = keys
        .where((s) => s.startsWith('xyz.extera.room_privacy_settings.'))
        .where((eventKey) {
          final content = client.accountData[eventKey]!.content;
          return content.keys.isNotEmpty;
        })
        .map((s) => s.substring(33))
        .toList();
    return keys;
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 8.0,
      borderRadius: .circular(12),
      clipBehavior: .antiAlias, // Ensures ink splashes don't bleed
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: .min,
          children: [
            ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: roomIds.length,
              itemBuilder: (context, index) {
                final roomId = roomIds[index];
                final room = client.getRoomById(roomId);
                if (room == null) return const SizedBox.shrink();
                return ChatListItem(
                  room,
                  noBackgroundColor: true,
                  onTap: () {
                    context.pop();
                    context.push('/rooms/$roomId/details/privacy');
                  },
                );
              },
            ),
            const Divider(),
            ListView(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              children: [
                ListTile(
                  leading: const Icon(Icons.cancel),
                  title: Text(L10n.of(context).cancel),
                  onTap: () {
                    context.pop();
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
