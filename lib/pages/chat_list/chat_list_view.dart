import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';

import 'package:Pulsly/config/setting_keys.dart';
import 'package:Pulsly/config/themes.dart';
import 'package:Pulsly/generated/l10n/l10n.dart';
import 'package:Pulsly/pages/chat_list/chat_list.dart';
import 'package:Pulsly/utils/sync_debugger.dart';
import 'package:Pulsly/widgets/matrix.dart';
import 'package:Pulsly/widgets/navigation_rail.dart';
import 'chat_list_body.dart';

class ChatListView extends StatelessWidget {
  final ChatListController controller;

  const ChatListView(this.controller, {super.key});

  @override
  Widget build(BuildContext context) {
    final client = Matrix.of(context).client;
    final theme = Theme.of(context);

    return PopScope(
      canPop: !controller.isSearchMode && controller.activeSpaceId == null,
      onPopInvokedWithResult: (pop, _) {
        if (pop) return;
        if (controller.activeSpaceId != null) {
          controller.clearActiveSpace();
          return;
        }
        if (controller.isSearchMode) {
          controller.cancelSearch();
          return;
        }
      },
      child: Row(
        children: [
          if (FluffyThemes.isColumnMode(context) ||
              AppSettings.displayNavigationRail.value) ...[
            SpacesNavigationRail(
              activeSpaceId: controller.activeSpaceId,
              onGoToChats: controller.clearActiveSpace,
              onGoToSpaceId: controller.setActiveSpace,
            ),
            Container(color: Theme.of(context).dividerColor, width: 1),
          ],
          Expanded(
            child: GestureDetector(
              onTap: FocusManager.instance.primaryFocus?.unfocus,
              excludeFromSemantics: true,
              behavior: HitTestBehavior.translucent,
              onHorizontalDragEnd: (details) {
                final velocity = details.primaryVelocity ?? 0;
                if (velocity.abs() < 300) return; // ignore slow drags
                if (controller.isSearchMode || controller.activeSpaceId != null) {
                  return;
                }
                const filters = [
                  ActiveFilter.allChats,
                  ActiveFilter.unread,
                  ActiveFilter.groups,
                  ActiveFilter.pinned,
                  ActiveFilter.favorites,
                ];
                final currentIndex = filters.indexOf(controller.activeFilter);
                if (currentIndex == -1) return;
                if (velocity < 0 && currentIndex < filters.length - 1) {
                  // Swipe left → next tab
                  controller.setActiveFilter(filters[currentIndex + 1]);
                } else if (velocity > 0 && currentIndex > 0) {
                  // Swipe right → previous tab
                  controller.setActiveFilter(filters[currentIndex - 1]);
                }
              },
              child: Scaffold(
                body: Stack(
                  children: [
                    ChatListViewBody(controller),
                    if (!controller.isSearchMode &&
                        controller.activeSpaceId == null)
                      Positioned(
                        right: 16,
                        bottom: 46,
                        child: FloatingActionButton.extended(
                          onPressed: () =>
                              context.go('/rooms/newprivatechat'),
                          icon: Icon(
                            Icons.chat_outlined,
                            color: Theme.of(context).colorScheme.onPrimaryContainer,
                          ),
                          label: Text(
                            L10n.of(context).newChat,
                            style: TextStyle(color: Theme.of(context).colorScheme.onPrimaryContainer),
                          ),
                          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
