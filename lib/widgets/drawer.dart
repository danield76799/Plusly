import 'package:extera_next/config/themes.dart';
import 'package:extera_next/generated/l10n/l10n.dart';
import 'package:extera_next/utils/fluffy_share.dart';
import 'package:extera_next/widgets/avatar.dart';
import 'package:extera_next/widgets/matrix.dart';
import 'package:extera_next/widgets/qr_code_viewer.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:matrix/matrix.dart';

class ExteraDrawer extends StatefulWidget {
  final String? activeSpaceId;
  final void Function() onGoToChats;
  final void Function(String) onGoToSpaceId;
  final List<Room> rootSpaces;

  const ExteraDrawer({
    required this.activeSpaceId,
    required this.onGoToChats,
    required this.onGoToSpaceId,
    required this.rootSpaces,
    super.key,
  });

  @override
  State<StatefulWidget> createState() => _ExteraDrawerState();
}

class _ExteraDrawerState extends State<ExteraDrawer> {
  CachedProfileInformation? _profile;

  void _updateProfile(Client client) async {
    final userProfile = await client.getUserProfile(client.userID!);

    setState(() {
      _profile = userProfile;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final matrix = Matrix.of(context);

    final client = matrix.client;

    final isSettings =
        GoRouter.of(context).routeInformationProvider.value.uri.path.startsWith(
          '/rooms/settings',
        ) &&
        FluffyThemes.isColumnMode(context);

    if (_profile == null) {
      _updateProfile(client);
    }

    return Drawer(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    ListTile(
                      leading: Avatar(
                        mxContent: _profile?.avatarUrl,
                        name: _profile?.displayname ?? client.userID!,
                        client: client,
                        presenceUserId: client.userID!,
                      ),
                      title: Text(
                        _profile?.displayname ?? client.userID!,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle:
                          _profile?.displayname != null &&
                              _profile?.displayname != client.userID!
                          ? Text(
                              client.userID!,
                              overflow: TextOverflow.ellipsis,
                            )
                          : null,
                      trailing: IconButton(
                        onPressed: () {
                          showQrCodeViewer(context, client.userID!);
                        },
                        icon: const Icon(Icons.qr_code),
                      ),
                    ),
                    const Divider(),
                    ListTile(
                      leading: CircleAvatar(
                        backgroundColor: theme.colorScheme.surfaceContainerHigh,
                        child: const Icon(Icons.home_outlined),
                      ),
                      title: Text(L10n.of(context).chats),
                      selected: !isSettings && widget.activeSpaceId == null,
                      onTap: () {
                        widget.onGoToChats();
                      },
                    ),
                    ...widget.rootSpaces.map(
                      (space) => ListTile(
                        selected: space.id == widget.activeSpaceId,
                        title: Text(space.name),
                        leading: Avatar(
                          mxContent: space.avatar,
                          name: space.name,
                          key: ValueKey(space.id),
                        ),
                        onTap: () {
                          widget.onGoToSpaceId(space.id);
                        },
                      ),
                    ),
                    ListTile(
                      leading: CircleAvatar(
                        backgroundColor: theme.colorScheme.surfaceContainerHigh,
                        child: const Icon(Icons.add_outlined),
                      ),
                      title: Text(L10n.of(context).newSpace),
                      onTap: () {
                        context.go('/rooms/newspace');
                      },
                    ),
                  ],
                ),
              ),
              const Divider(),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: Row(
                    spacing: 4,
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            context.go('/rooms/settings');
                          },
                          label: Text(L10n.of(context).settings),
                          icon: const Icon(Icons.settings),
                          style: ElevatedButton.styleFrom(
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.horizontal(
                                left: Radius.circular(12),
                                right: Radius.zero,
                              ),
                            ),
                          ),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          FluffyShare.shareInviteLink(context);
                        },
                        style: ElevatedButton.styleFrom(
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.horizontal(
                              left: Radius.zero,
                              right: Radius.circular(12),
                            ),
                          ),
                        ),
                        child: const Icon(Icons.share),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
