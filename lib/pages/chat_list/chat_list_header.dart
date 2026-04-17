import 'package:flutter/material.dart';

import 'package:matrix/matrix.dart';

import 'package:extera_next/config/app_config.dart';
import 'package:extera_next/config/themes.dart';
import 'package:extera_next/generated/l10n/l10n.dart';
import 'package:extera_next/pages/chat_list/chat_list.dart';
import 'package:extera_next/pages/chat_list/client_chooser_button.dart';
import 'package:extera_next/utils/sync_status_localization.dart';
import '../../widgets/matrix.dart';

class ChatListHeader extends StatelessWidget {
  final ChatListController controller;
  final bool globalSearch;

  const ChatListHeader({
    super.key,
    required this.controller,
    this.globalSearch = true,
  });

  @override
  Widget build(BuildContext context) {
    return SliverPersistentHeader(
      pinned: true,
      floating: true,
      delegate: _ChatListHeaderDelegate(
        controller: controller,
        globalSearch: globalSearch,
        topPadding: MediaQuery.of(context).padding.top,
      ),
    );
  }
}

class _ChatListHeaderDelegate extends SliverPersistentHeaderDelegate {
  final ChatListController controller;
  final bool globalSearch;
  final double topPadding;

  bool isShrink = false;

  static const double _headerHeight = 64.0; // Compacte hoogte

  _ChatListHeaderDelegate({
    required this.controller,
    required this.globalSearch,
    required this.topPadding,
  });

  @override
  double get minExtent => _headerHeight + topPadding;

  @override
  double get maxExtent => _headerHeight + topPadding;

  @override
  bool shouldRebuild(covariant _ChatListHeaderDelegate oldDelegate) => true;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final theme = Theme.of(context);
    final client = Matrix.of(context).client;

    return Material(
      elevation: shrinkOffset > 0 ? 4 : 0,
      surfaceTintColor: theme.colorScheme.surfaceTint,
      color: theme.colorScheme.surface,
      child: Padding(
        padding: EdgeInsets.only(top: topPadding),
        child: SizedBox(
          height: _headerHeight,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                // Titel links
                Text(
                  AppConfig.applicationName,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 12),
                
                // Kleinere zoekbalk in het midden
                Expanded(
                  child: StreamBuilder(
                    stream: client.onSyncStatus.stream,
                    builder: (context, snapshot) {
                      final status =
                          client.onSyncStatus.value ??
                          const SyncStatusUpdate(
                            SyncStatus.waitingForResponse,
                          );
                      final hide =
                          client.onSync.value != null &&
                          status.status != SyncStatus.error &&
                          client.prevBatch != null;
                      return SizedBox(
                        height: 36, // Kleinere hoogte
                        child: TextField(
                          controller: controller.searchController,
                          focusNode: controller.searchFocusNode,
                          textInputAction: TextInputAction.search,
                          style: const TextStyle(fontSize: 13),
                          onChanged: (text) => controller.onSearchEnter(
                            text,
                            globalSearch: false,
                          ),
                          onSubmitted: (text) => controller.onSearchEnter(
                            text,
                            globalSearch: globalSearch,
                          ),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: theme.colorScheme.secondaryContainer,
                            border: OutlineInputBorder(
                              borderSide: BorderSide.none,
                              borderRadius: BorderRadius.circular(99),
                            ),
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            hintText: hide
                                ? L10n.of(context).searchChatsRooms
                                : status.calcLocalizedString(context),
                            hintStyle: TextStyle(
                              fontSize: 13,
                              color: status.error != null
                                  ? theme.colorScheme.error
                                  : theme.colorScheme.onSecondaryContainer,
                              fontWeight: FontWeight.normal,
                            ),
                            prefixIcon: hide
                                ? controller.isSearchMode
                                      ? IconButton(
                                          tooltip: L10n.of(context).cancel,
                                          icon: const Icon(
                                            Icons.close_outlined,
                                            size: 18,
                                          ),
                                          onPressed: controller.cancelSearch,
                                          color: theme
                                              .colorScheme
                                              .onSecondaryContainer,
                                          padding: EdgeInsets.zero,
                                          constraints: const BoxConstraints(
                                            minWidth: 32,
                                            minHeight: 32,
                                          ),
                                        )
                                      : IconButton(
                                          onPressed: controller.startSearch,
                                          icon: Icon(
                                            Icons.search_outlined,
                                            size: 18,
                                            color: theme
                                                .colorScheme
                                                .onSecondaryContainer,
                                          ),
                                          padding: EdgeInsets.zero,
                                          constraints: const BoxConstraints(
                                            minWidth: 32,
                                            minHeight: 32,
                                          ),
                                        )
                                : Container(
                                    margin: const EdgeInsets.all(6),
                                    width: 6,
                                    height: 6,
                                    child: Center(
                                      child:
                                          CircularProgressIndicator.adaptive(
                                            constraints: const BoxConstraints.tightFor(
                                              width: 20,
                                              height: 20,
                                            ),
                                            strokeWidth: 2,
                                            value: status.progress,
                                            valueColor: status.error != null
                                                ? AlwaysStoppedAnimation<
                                                    Color
                                                  >(theme.colorScheme.error)
                                                : null,
                                          ),
                                    ),
                                  ),
                            suffixIcon:
                                controller.isSearchMode && globalSearch
                                ? controller.isSearching
                                      ? const Padding(
                                          padding: EdgeInsets.symmetric(
                                            vertical: 6.0,
                                            horizontal: 8,
                                          ),
                                          child: SizedBox.square(
                                            dimension: 16,
                                            child:
                                                CircularProgressIndicator.adaptive(
                                                  strokeWidth: 2,
                                                ),
                                          ),
                                        )
                                      : TextButton.icon(
                                          onPressed: controller.setServer,
                                          style: TextButton.styleFrom(
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(99),
                                            ),
                                            textStyle: const TextStyle(
                                              fontSize: 10,
                                            ),
                                            padding: const EdgeInsets.symmetric(horizontal: 8),
                                            minimumSize: Size.zero,
                                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                          ),
                                          icon: const Icon(
                                            Icons.edit_outlined,
                                            size: 12,
                                          ),
                                          label: Text(
                                            controller.searchServer ??
                                                Matrix.of(
                                                  context,
                                                ).client.homeserver!.host,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        )
                                : null,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                
                const SizedBox(width: 8),
                
                // Avatar rechts
                ClientChooserButton(controller),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
