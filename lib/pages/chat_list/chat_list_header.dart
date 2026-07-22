import 'package:flutter/material.dart';

import 'package:matrix/matrix.dart';

import 'package:flutter_svg/flutter_svg.dart';

import 'package:Pulsly/config/themes.dart';
import 'package:Pulsly/generated/l10n/l10n.dart';
import 'package:Pulsly/pages/chat_list/chat_list.dart';
import 'package:Pulsly/pages/chat_list/client_chooser_button.dart';

import 'package:Pulsly/utils/sync_status_localization.dart';
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

  static const double _titleHeight = 56.0;
  static const double _searchBarHeight = 48.0; // 40 + 8 padding
  static const double _tabBarHeight = 48.0;

  _ChatListHeaderDelegate({
    required this.controller,
    required this.globalSearch,
    required this.topPadding,
  });

  @override
  double get minExtent => _titleHeight + _tabBarHeight + topPadding;

  @override
  double get maxExtent => _titleHeight + _searchBarHeight + _tabBarHeight + topPadding;

  @override
  bool shouldRebuild(covariant _ChatListHeaderDelegate oldDelegate) =>
      oldDelegate.controller != controller ||
      oldDelegate.globalSearch != globalSearch ||
      oldDelegate.topPadding != topPadding;

  /// Keeps the active filter tab visible when the tab bar overflows.
  /// Without auto-scroll, "Opgeslagen" is unreachable on narrow screens.
  final ScrollController _tabScrollController = ScrollController();

  // Called by the SliverPersistentHeader when the delegate is disposed.
  void dispose() {
    _tabScrollController.dispose();
  }

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final theme = Theme.of(context);
    final client = Matrix.of(context).client;

    // 0.0 = fully collapsed, 1.0 = fully expanded
    final progress = controller.isSearchMode
        ? 1.0
        : (1.0 - (shrinkOffset / _searchBarHeight)).clamp(0.0, 1.0);

    return Material(
      elevation: shrinkOffset > 0 ? 4 : 0,
      surfaceTintColor: theme.colorScheme.surfaceTint,
      color: theme.colorScheme.surface,
      child: Padding(
        padding: EdgeInsets.only(top: topPadding),
        child: Column(
          children: [
            SizedBox(
              height: _titleHeight,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    // Plusly logo: turquoise icoon + tekst die de theme
                    // kleur volgt (onSurface) zodat het in dark mode wit is.
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SvgPicture.asset(
                          'assets/plusly_icon_only.svg',
                          height: 32,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Plusly',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            letterSpacing: -1,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    // Tijd weergave
                    StreamBuilder(
                      stream: Stream.periodic(const Duration(seconds: 1)),
                      builder: (context, snapshot) {
                        final now = DateTime.now();
                        final timeString =
                            '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
                        return Text(
                          timeString,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onSurface,
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 16),
                    if (progress == 0.0 && !controller.isSearchMode)
                      IconButton(
                        onPressed: () {
                          controller.scrollController.animateTo(
                            0,
                            duration: FluffyThemes.animationDuration,
                            curve: FluffyThemes.animationCurve,
                          );
                          controller.isSearchMode = true;
                          controller.searchFocusNode.requestFocus();
                        },
                        icon: const Icon(Icons.search),
                      ),
                    ClientChooserButton(controller),
                  ],
                ),
              ),
            ),

            ClipRect(
              child: Align(
                alignment: Alignment.topCenter,
                heightFactor: progress,
                child: Opacity(
                  opacity: progress,
                  child: Padding(
                    padding: const EdgeInsets.only(
                      left: 16,
                      right: 16,
                      bottom: 8,
                    ),
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
                          height: 40,
                          child: TextField(
                            controller: controller.searchController,
                            focusNode: controller.searchFocusNode,
                            textInputAction: TextInputAction.search,
                            style: const TextStyle(fontSize: 14),
                            onChanged: (text) => controller.onSearchEnter(
                              text,
                              globalSearch: true,
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
                                horizontal: 12,
                                vertical: 8,
                              ),
                              hintText: hide
                                  ? L10n.of(context).searchChatsRooms
                                  : status.calcLocalizedString(context),
                              hintStyle: TextStyle(
                                fontSize: 14,
                                color: status.error != null
                                    ? theme.colorScheme.error
                                    : theme.colorScheme.onSecondaryContainer
                                          .withValues(alpha: 0.95),
                                fontWeight: FontWeight.normal,
                              ),
                              prefixIcon: hide
                                  ? controller.isSearchMode
                                        ? IconButton(
                                            tooltip: L10n.of(context).cancel,
                                            icon: const Icon(
                                              Icons.close_outlined,
                                              size: 20,
                                            ),
                                            onPressed: controller.cancelSearch,
                                            color: theme
                                                .colorScheme
                                                .onSecondaryContainer,
                                          )
                                        : IconButton(
                                            onPressed: controller.startSearch,
                                            icon: Icon(
                                              Icons.search_outlined,
                                              size: 20,
                                              color: theme
                                                  .colorScheme
                                                  .onSecondaryContainer,
                                            ),
                                          )
                                  : Container(
                                      margin: const EdgeInsets.all(8),
                                      width: 8,
                                      height: 8,
                                      child: Center(
                                        child:
                                            CircularProgressIndicator.adaptive(
                                              constraints: const .tightFor(
                                                width: 24,
                                                height: 32,
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
                                              vertical: 8.0,
                                              horizontal: 10,
                                            ),
                                            child: SizedBox.square(
                                              dimension: 20,
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
                                                fontSize: 11,
                                              ),
                                            ),
                                            icon: const Icon(
                                              Icons.edit_outlined,
                                              size: 14,
                                            ),
                                            label: Text(
                                              controller.searchServer ??
                                                  Matrix.of(
                                                    context,
                                                  ).client.homeserver!.host,
                                              maxLines: 2,
                                            ),
                                          )
                                  : null,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),

            // Tab Bar with 4 tabs
            SizedBox(
              height: _tabBarHeight,
              child: _buildTabBar(context, theme),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar(BuildContext context, ThemeData theme) {
    final filters = [
      ActiveFilter.allChats,
      ActiveFilter.unread,
      ActiveFilter.groups,
      ActiveFilter.pinned,
      ActiveFilter.favorites,
    ];
    final activeIndex = filters.indexOf(controller.activeFilter);

    // Auto-scroll the active tab into view after layout. Without this,
    // tabs that are off-screen on narrow devices can't be activated
    // visually even though the underlying SingleChildScrollView allows
    // horizontal scrolling.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_tabScrollController.hasClients) return;
      if (activeIndex < 0) return;
      // Approximate target offset: each tab is ~104px wide (16+text+16+8 padding).
      // Clamp to range so we never overshoot the scroll position.
      const tabWidth = 104.0;
      final viewport = _tabScrollController.position.viewportDimension;
      final target = (activeIndex * tabWidth - viewport / 2 + tabWidth / 2)
          .clamp(0.0, _tabScrollController.position.maxScrollExtent);
      if ((_tabScrollController.offset - target).abs() > 16) {
        _tabScrollController.animateTo(
          target,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });

    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: theme.dividerColor,
            width: 1,
          ),
        ),
      ),
      child: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          // Rebuild to update fade indicator on scroll.
          // We avoid setState because this is a StatelessWidget; instead,
          // the fade is driven by ShaderMask + LinearGradient which
          // depends on the ScrollController offset.
          return false;
        },
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              controller: _tabScrollController,
              scrollDirection: Axis.horizontal,
              child: Row(
                children: filters.map((filter) {
                    final isActive = controller.activeFilter == filter;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                      child: InkWell(
                        onTap: () => controller.setActiveFilter(filter),
                        borderRadius: BorderRadius.circular(10),
                        overlayColor: WidgetStateProperty.resolveWith((states) {
                          if (states.contains(WidgetState.pressed)) {
                            return theme.colorScheme.primary.withValues(alpha: 0.12);
                          }
                          if (states.contains(WidgetState.hovered)) {
                            return theme.colorScheme.primary.withValues(alpha: 0.08);
                          }
                          return Colors.transparent;
                        }),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: isActive
                                ? theme.colorScheme.primaryContainer
                                : null,
                            borderRadius: BorderRadius.circular(10),
                            border: Border(
                              bottom: BorderSide(
                                color: isActive
                                    ? theme.colorScheme.primary
                                    : Colors.transparent,
                                width: 2,
                              ),
                            ),
                          ),
                          child: Center(
                            child: Text(
                              filter.toLocalizedString(context),
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: isActive
                                    ? theme.colorScheme.primary
                                    : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              );
          },
        ),
      ),
    );
  }
}
