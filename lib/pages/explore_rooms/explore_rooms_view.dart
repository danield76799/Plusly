import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';
import 'package:matrix/matrix.dart';

import 'package:extera_next/generated/l10n/l10n.dart';
import 'package:extera_next/pages/explore_rooms/explore_rooms.dart';
import 'package:extera_next/utils/localized_exception_extension.dart';
import 'package:extera_next/widgets/avatar.dart';
import 'package:extera_next/widgets/layouts/max_width_body.dart';
import 'package:extera_next/widgets/matrix.dart';

class ExploreRoomsView extends StatelessWidget {
  final ExploreRoomsController controller;

  const ExploreRoomsView(this.controller, {super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final searchResponse = controller.searchResponse;

    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        leading: const Center(child: BackButton()),
        title: Text(L10n.of(context).publicRooms),
        backgroundColor: theme.scaffoldBackgroundColor,
      ),
      body: MaxWidthBody(
        withScrolling: false,
        innerPadding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: TextField(
                controller: controller.controller,
                onChanged: controller.searchRooms,
                decoration: InputDecoration(
                  hintText: L10n.of(context).search,
                  filled: true,
                  fillColor: theme.colorScheme.secondaryContainer,
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(99),
                  ),
                  hintStyle: TextStyle(
                    color: theme.colorScheme.onSecondaryContainer,
                    fontWeight: FontWeight.normal,
                  ),
                  prefixIcon: searchResponse == null
                      ? const Icon(Icons.search_outlined)
                      : FutureBuilder(
                          future: searchResponse,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState !=
                                ConnectionState.done) {
                              return const Padding(
                                padding: EdgeInsets.all(10.0),
                                child: SizedBox.square(
                                  dimension: 24,
                                  child: CircularProgressIndicator.adaptive(
                                    strokeWidth: 1,
                                  ),
                                ),
                              );
                            }
                            return const Icon(Icons.search_outlined);
                          },
                        ),
                  suffixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (controller.controller.text.isNotEmpty)
                        IconButton(
                          icon: const Icon(Icons.clear_outlined),
                          onPressed: () {
                            controller.controller.clear();
                            controller.searchRooms();
                          },
                        ),
                      TextButton.icon(
                        onPressed: controller.setServer,
                        style: TextButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(99),
                          ),
                          textStyle: const TextStyle(fontSize: 11),
                        ),
                        icon: const Icon(Icons.edit_outlined, size: 14),
                        label: Text(
                          controller.selectedServer ??
                              Matrix.of(context).client.homeserver?.host ??
                              '',
                          maxLines: 2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: FutureBuilder(
                future: searchResponse,
                builder: (context, snapshot) {
                  final result = snapshot.data;
                  final error = snapshot.error;

                  if (error != null) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            error.toLocalizedString(context),
                            textAlign: TextAlign.center,
                            style: TextStyle(color: theme.colorScheme.error),
                          ),
                        ),
                        const SizedBox(height: 12),
                        OutlinedButton.icon(
                          onPressed: controller.searchRooms,
                          icon: const Icon(Icons.refresh_outlined),
                          label: Text(L10n.of(context).tryAgain),
                        ),
                      ],
                    );
                  }

                  if (result == null) {
                    return const Center(
                      child: CircularProgressIndicator.adaptive(),
                    );
                  }

                  final rooms = result.chunk;

                  if (rooms.isEmpty) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.explore_outlined,
                          size: 86,
                          color: theme.colorScheme.secondary,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            L10n.of(context).noRoomsFound,
                            style: TextStyle(
                              color: theme.colorScheme.onSurface,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    );
                  }

                  return ListView.builder(
                    itemCount: rooms.length,
                    itemBuilder: (context, i) {
                      final room = rooms[i];
                      final displayname =
                          room.name ?? room.canonicalAlias ?? room.roomId;
                      final topic = room.topic;
                      final memberCount = room.numJoinedMembers;
                      final avatarUrl = room.avatarUrl;

                      return ListTile(
                        leading: Avatar(
                          name: displayname,
                          mxContent: avatarUrl,
                          size: 42,
                        ),
                        title: Text(
                          displayname,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (topic != null && topic.isNotEmpty)
                              Text(
                                topic,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            Padding(
                              padding: const EdgeInsets.only(top: 4.0),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.people_outline,
                                    size: 14,
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    L10n.of(
                                      context,
                                    ).countParticipants(memberCount),
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        trailing: controller.joinedRooms.contains(room.roomId)
                            ? OutlinedButton(
                                onPressed: () =>
                                    context.go('/rooms/${room.roomId}'),
                                style: OutlinedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(24.0),
                                  ),
                                ),
                                child: Text(L10n.of(context).open),
                              )
                            : FilledButton(
                                onPressed: () =>
                                    controller.joinRoomAction(room),
                                child: Text(L10n.of(context).joinRoom),
                              ),
                        onTap: () => _showRoomDetails(context, room),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showRoomDetails(BuildContext context, PublicRoomsChunk room) {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Avatar(
                  name: room.name ?? room.roomId,
                  mxContent: room.avatarUrl,
                  size: 64,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        room.name ?? room.canonicalAlias ?? room.roomId,
                        style: theme.textTheme.titleLarge,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (room.canonicalAlias != null)
                        Text(
                          room.canonicalAlias!,
                          style: theme.textTheme.bodySmall,
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (room.topic != null && room.topic!.isNotEmpty) ...[
              Text(
                L10n.of(context).chatDescription,
                style: theme.textTheme.labelLarge,
              ),
              const SizedBox(height: 8),
              Text(room.topic!),
              const SizedBox(height: 16),
            ],
            Row(
              children: [
                Icon(
                  Icons.people_outline,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 8),
                Text(
                  L10n.of(context).countParticipants(room.numJoinedMembers),
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
                  controller.joinRoomAction(room);
                },
                icon: const Icon(Icons.login_outlined),
                label: Text(L10n.of(context).joinRoom),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
