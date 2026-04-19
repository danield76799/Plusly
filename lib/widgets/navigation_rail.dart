import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';
import 'package:matrix/matrix.dart';

import 'package:extera_next/config/app_config.dart';
import 'package:extera_next/config/themes.dart';
import 'package:extera_next/generated/l10n/l10n.dart';
import 'package:extera_next/pages/chat_list/navi_rail_item.dart';
import 'package:extera_next/utils/matrix_sdk_extensions/matrix_locals.dart';
import 'package:extera_next/utils/stream_extension.dart';
import 'package:extera_next/widgets/avatar.dart';
import 'package:extera_next/widgets/matrix.dart';

class SpacesNavigationRail extends StatefulWidget {
  final String? activeSpaceId;
  final void Function() onGoToChats;
  final void Function(String) onGoToSpaceId;

  const SpacesNavigationRail({
    required this.activeSpaceId,
    required this.onGoToChats,
    required this.onGoToSpaceId,
    super.key,
  });

  @override
  State<SpacesNavigationRail> createState() => _SpacesNavigationRailState();
}

class _SpacesNavigationRailState extends State<SpacesNavigationRail> {
  List<Room>? _cachedRootSpaces;

  List<Room> _computeRootSpaces(Client client) {
    final allSpaces = client.rooms.where((room) => room.isSpace).toList();

    // Build a set of all space IDs that are children of another space.
    // This is O(n * m) where n = spaces, m = avg children per space,
    // instead of the previous O(n^2 * m) nested .any() approach.
    final childSpaceIds = <String>{};
    for (final space in allSpaces) {
      for (final child in space.spaceChildren) {
        final roomId = child.roomId;
        if (roomId != null) {
          childSpaceIds.add(roomId);
        }
      }
    }

    // O(n) set lookup per space
    return allSpaces
        .where((space) => !childSpaceIds.contains(space.id))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final client = Matrix.of(context).client;
    final isSettings =
        GoRouter.of(context).routeInformationProvider.value.uri.path.startsWith(
          '/rooms/settings',
        ) &&
        FluffyThemes.isColumnMode(context);
    // workaround on settings button remaining selected.
    // who will even see it selected on mobile?
    return StreamBuilder(
      key: ValueKey(client.userID.toString()),
      stream: client.onSync.stream
          .where((s) => s.hasRoomUpdate)
          .rateLimit(const Duration(seconds: 1)),
      builder: (context, snapshot) {
        // Only recompute when sync delivers new data or cache is empty
        if (snapshot.hasData || _cachedRootSpaces == null) {
          _cachedRootSpaces = _computeRootSpaces(client);
        }
        final rootSpaces = _cachedRootSpaces!;

        return Container(
          width: FluffyThemes.navRailWidth,
          color: Theme.of(context).scaffoldBackgroundColor,
          child: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    scrollDirection: Axis.vertical,
                    itemCount: rootSpaces.length + 2,
                    itemBuilder: (context, i) {
                      if (i == 0) {
                        return NaviRailItem(
                          isSelected:
                              widget.activeSpaceId == null && !isSettings,
                          onTap: widget.onGoToChats,
                          icon: const Padding(
                            padding: EdgeInsets.all(10.0),
                            child: Icon(Icons.forum_outlined),
                          ),
                          selectedIcon: const Padding(
                            padding: EdgeInsets.all(10.0),
                            child: Icon(Icons.forum),
                          ),
                          toolTip: L10n.of(context).chats,
                          unreadBadgeFilter: (room) => true,
                        );
                      }
                      i--;
                      if (i == rootSpaces.length) {
                        return NaviRailItem(
                          isSelected: false,
                          onTap: () => context.go('/rooms/newspace'),
                          icon: const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Icon(Icons.add),
                          ),
                          toolTip: L10n.of(context).createNewSpace,
                        );
                      }
                      final space = rootSpaces[i];
                      final displayname = rootSpaces[i].getLocalizedDisplayname(
                        MatrixLocals(L10n.of(context)),
                      );
                      final spaceChildrenIds = space.spaceChildren
                          .map((c) => c.roomId)
                          .toSet();
                      return NaviRailItem(
                        toolTip: displayname,
                        isSelected: widget.activeSpaceId == space.id,
                        onTap: () => widget.onGoToSpaceId(rootSpaces[i].id),
                        unreadBadgeFilter: (room) =>
                            spaceChildrenIds.contains(room.id),
                        icon: Avatar(
                          mxContent: rootSpaces[i].avatar,
                          name: displayname,
                          border: BorderSide(
                            width: 1,
                            color: Theme.of(context).dividerColor,
                          ),
                          borderRadius: BorderRadius.circular(
                            AppConfig.borderRadius / 2,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                NaviRailItem(
                  isSelected: isSettings,
                  onTap: () => context.go('/rooms/settings'),
                  icon: const Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Icon(Icons.settings_outlined),
                  ),
                  selectedIcon: const Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Icon(Icons.settings),
                  ),
                  toolTip: L10n.of(context).settings,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
