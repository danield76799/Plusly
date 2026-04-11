// ignore_for_file: deprecated_member_use

import 'package:extera_next/config/app_config.dart';
import 'package:extera_next/config/setting_keys.dart';
import 'package:extera_next/generated/l10n/l10n.dart';
import 'package:extera_next/pages/chat_list/chat_list.dart';
import 'package:extera_next/pages/chat_list/chat_list_header.dart';
import 'package:extera_next/pages/chat_list/chat_list_legacy_header.dart';
import 'package:extera_next/utils/matrix_sdk_extensions/interesting_presences_extension.dart';
import 'package:extera_next/utils/show_profile.dart';
import 'package:extera_next/utils/stream_extension.dart';
import 'package:extera_next/widgets/avatar.dart';
import 'package:extera_next/widgets/list_divider.dart';
import 'package:extera_next/widgets/matrix.dart';
import 'package:extera_next/widgets/rich_presence_card.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:matrix/matrix.dart';

class PeopleView extends StatefulWidget {
  final void Function() onBack;
  final void Function(Room) onChatTap;
  final ChatListController chatListController;

  const PeopleView({
    required this.onBack,
    required this.onChatTap,
    required this.chatListController,
    super.key,
  });

  @override
  State<StatefulWidget> createState() => _PeopleViewState();
}

class _PeopleViewState extends State<PeopleView> {
  final ScrollController scrollController = ScrollController();

  Widget _buildProfileItem(
    BuildContext context,
    String userId,
    CachedProfileInformation? profile,
  ) {
    final client = Matrix.of(context).client;
    final directChatId = client.getDirectChatFromUserId(userId);

    return InkWell(
      onTap: () => showProfile(
        context: context,
        profile: Profile(
          userId: userId,
          avatarUrl: profile?.avatarUrl,
          displayName: profile?.displayname,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: CircleAvatar(
              child: Avatar(
                mxContent: profile?.avatarUrl,
                presenceUserId: userId,
                name: profile?.displayname ?? userId,
              ),
            ),
            trailing: directChatId != null
                ? IconButton(
                    onPressed: () => context.go('/rooms/$directChatId'),
                    icon: const Icon(Icons.chat_outlined),
                  )
                : null,
            title: Text(profile?.displayname ?? userId),
            subtitle: client.presences[userId]?.statusMsg != null
                ? Text(client.presences[userId]!.statusMsg!)
                : null,
          ),
          if (profile?.additionalProperties.containsKey(
                'com.ip-logger.msc4320.rpc',
              ) ??
              false)
            RichPresenceContent(
              richPresenceData:
                  profile!.additionalProperties['com.ip-logger.msc4320.rpc']!
                      as Map<String, dynamic>,
              noBackground: true,
            ),
        ],
      ),
    );
  }

  /// Builds a Material container section with a header and a list of profile items.
  /// Returns an empty SizedBox if [userIds] is empty.
  Widget _buildSection({
    required BuildContext context,
    required String title,
    required List<String> userIds,
    required Map<String, CachedProfileInformation?> profileMap,
    required BorderRadius borderRadius,
    required ThemeData theme,
  }) {
    if (userIds.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Material(
        borderRadius: borderRadius,
        clipBehavior: Clip.hardEdge,
        color: theme.colorScheme.surfaceContainerHighest,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(
                title,
                style: TextStyle(
                  color: theme.colorScheme.secondary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            for (int i = 0; i < userIds.length; i++) ...[
              const ListDivider(),
              _buildProfileItem(context, userIds[i], profileMap[userIds[i]]),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final client = Matrix.of(context).client;
    final interestingPresences = client.interestingPresences;
    final borderRadius = BorderRadius.circular(AppConfig.borderRadius);

    return SafeArea(
      child: StreamBuilder(
        stream: client.onSync.stream.rateLimit(const Duration(seconds: 3)),
        builder: (context, snapshot) {
          final onlinePeople = interestingPresences
              .where(
                (mxid) =>
                    client.presences[mxid]?.presence == PresenceType.online,
              )
              .toList();
          final unavailablePeople = interestingPresences
              .where(
                (mxid) =>
                    client.presences[mxid]?.presence ==
                    PresenceType.unavailable,
              )
              .toList();
          const profileLimit = 10;
          final allUserIds = <String>{
            ...onlinePeople.take(profileLimit),
            ...unavailablePeople.take(profileLimit),
          }.toList();

          return CustomScrollView(
            controller: scrollController,
            slivers: [
              if (AppSettings.useLegacyChatListAppBar.value)
                ChatListLegacyHeader(controller: widget.chatListController)
              else
                ChatListHeader(controller: widget.chatListController),
              SliverToBoxAdapter(
                child: FutureBuilder<List<CachedProfileInformation>>(
                  future: Future.wait(
                    allUserIds.map(
                      (userId) => client.getUserProfile(
                        userId,
                        maxCacheAge: const Duration(hours: 1),
                      ),
                    ),
                  ),
                  builder: (context, snapshot) {
                    final profileMap = <String, CachedProfileInformation?>{};
                    if (snapshot.hasData) {
                      for (var i = 0; i < allUserIds.length; i++) {
                        profileMap[allUserIds[i]] = snapshot.data
                            ?.elementAtOrNull(i);
                      }
                    }

                    final l10n = L10n.of(context);

                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildSection(
                          context: context,
                          title: l10n.peopleOnline(onlinePeople.length),
                          userIds: onlinePeople,
                          profileMap: profileMap,
                          borderRadius: borderRadius,
                          theme: theme,
                        ),
                        _buildSection(
                          context: context,
                          title: l10n.peopleUnavailable(
                            unavailablePeople.length,
                          ),
                          userIds: unavailablePeople,
                          profileMap: profileMap,
                          borderRadius: borderRadius,
                          theme: theme,
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
