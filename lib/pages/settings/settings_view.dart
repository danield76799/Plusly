import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:matrix/matrix.dart';
import 'package:url_launcher/url_launcher_string.dart';

import 'package:Pulsly/config/app_config.dart';
import 'package:Pulsly/config/setting_keys.dart';
import 'package:Pulsly/config/themes.dart';
import 'package:Pulsly/generated/l10n/l10n.dart';
import 'package:Pulsly/utils/fluffy_share.dart';
import 'package:Pulsly/utils/check_updates.dart' as check_updates;
import 'package:Pulsly/utils/platform_infos.dart';
import 'package:Pulsly/utils/push_log_buffer.dart';
import 'package:Pulsly/widgets/avatar.dart';
import 'package:Pulsly/widgets/list_divider.dart';
import 'package:Pulsly/widgets/matrix.dart';
import 'package:Pulsly/widgets/mxc_image.dart';
import 'package:Pulsly/widgets/navigation_rail.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../../widgets/mxc_image_viewer.dart';
import 'push_log_viewer_screen.dart';
import 'settings.dart';

class SettingsView extends StatelessWidget {
  final SettingsController controller;

  const SettingsView(this.controller, {super.key});

  static Future<void> _testPushNotification(BuildContext context) async {
    final matrix = Matrix.of(context);
    final push = matrix.backgroundPush;
    if (push == null) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Push systeem niet geïnitialiseerd')),
      );
      return;
    }

    // Check pusher status
    var pusherInfo = 'Onbekend';
    try {
      final client = matrix.client;
      final pushers = await client.getPushers();
      if (pushers == null || pushers.isEmpty) {
        pusherInfo = 'Geen pusher geregistreerd';
      } else {
        pusherInfo = '${pushers.length} pusher(s):\n';
        for (final p in pushers) {
          pusherInfo += '  • ${p.appId} → ${p.pushkey.length > 20 ? p.pushkey.substring(0, 20) : p.pushkey}...\n';
        }
      }
    } catch (e) {
      pusherInfo = 'Fout bij ophalen: $e';
    }

    // Show a local test notification
    try {
      PushLogBuffer.instance.i('Test push: showing local notification...');
      await push.localNotificationsPlugin.show(
        id: 999999, // unique test ID
        title: 'Test notificatie',
        body: 'Als je dit ziet werkt het notificatie-systeem!',
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'plusly_push',
            'Berichten',
            importance: Importance.max,
            priority: Priority.max,
            enableVibration: true,
            enableLights: true,
            ticker: 'Test push notificatie',
          ),
        ),
      );
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Test notificatie verzonden!\nPusher status: $pusherInfo'),
          duration: const Duration(seconds: 5),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Test mislukt: $e')),
      );
    }
  }

  /// Sends a real UnifiedPush message to the currently stored endpoint.
  /// This tests the chain from the gateway/distributor (Ntfy) to the app
  /// without depending on the homeserver. If `_onUpMessage()` fires, the full
  /// delivery path works.
  static Future<void> _testEndToEndPush(BuildContext context) async {
    final matrix = Matrix.of(context);
    final client = matrix.client;
    final push = matrix.backgroundPush;

    if (push == null) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Push systeem niet geïnitialiseerd')),
      );
      return;
    }

    PushLogBuffer.instance.i('E2E push test: starting...');
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'E2E push test gestart. Sluit de app nu en wacht 10-15 seconden...',
        ),
      ),
    );

    try {
      final store = await AppSettings.init();
      final endpoint = store.getString(
        client.clientName + AppSettings.unifiedPushEndpoint.key,
      );
      if (endpoint == null || endpoint.isEmpty) {
        throw Exception('Geen UnifiedPush endpoint gevonden');
      }

      PushLogBuffer.instance.i('E2E push test: endpoint=$endpoint');

      // Build a minimal Matrix push payload. The room/event IDs are fake — we
      // only care whether _onUpMessage() fires and a notification is shown.
      final payload = {
        'notification': {
          'event_id': '\$e2e-test-${DateTime.now().millisecondsSinceEpoch}',
          'room_id': '!e2e-test:example.com',
          'type': 'm.room.message',
          'sender': '@push-test:example.com',
          'sender_display_name': 'Push Test',
          'content': {
            'body': 'E2E push test',
            'msgtype': 'm.text',
          },
          'prio': 'high',
          'counts': {'unread': 1},
        },
      };

      final response = await http.post(
        Uri.parse(endpoint),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(payload),
      );

      PushLogBuffer.instance.i(
        'E2E push test: HTTP ${response.statusCode} — ${response.body.length > 100 ? response.body.substring(0, 100) : response.body}',
      );

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'E2E ping verstuurd (HTTP ${response.statusCode}). '
            'Controleer Push logs voor 🔥 _onUpMessage().',
          ),
        ),
      );
    } catch (e, s) {
      PushLogBuffer.instance.e('E2E push test failed: $e');
      Logs().e('E2E push test failed', e, s);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('E2E push test mislukt: $e')),
      );
    }
  }

  Widget _buildBannerPlaceholder(BuildContext context) {
    return Container(
      height: 360,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(AppConfig.borderRadius),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final borderRadius = BorderRadius.circular(AppConfig.borderRadius);

    final activeRoute = GoRouter.of(
      context,
    ).routeInformationProvider.value.uri.path;
    return Row(
      children: [
        if (FluffyThemes.isColumnMode(context)) ...[
          SpacesNavigationRail(
            activeSpaceId: null,
            onGoToChats: () => context.go('/rooms'),
            onGoToSpaceId: (spaceId) => context.go('/rooms?spaceId=$spaceId'),
          ),
          Container(color: Theme.of(context).dividerColor, width: 1),
        ],
        Expanded(
          child: Scaffold(
            appBar: FluffyThemes.isColumnMode(context)
                ? null
                : AppBar(
                    title: Text(L10n.of(context).settings),
                    leading: Center(
                      child: BackButton(onPressed: () => context.go('/rooms')),
                    ),
                  ),
            body: ListTileTheme(
              iconColor: theme.colorScheme.onSurface,
              child: Padding(
                padding: const .all(8),
                child: ListView(
                  key: const Key('SettingsListViewContent'),
                  children: <Widget>[
                    FutureBuilder<Profile>(
                      future: controller.profileFuture,
                      initialData: controller.cachedProfile, // Voorkomt flickering
                      builder: (context, snapshot) {
                        final profile = snapshot.data;
                        final avatar = profile?.avatarUrl;
                        final mxid =
                            Matrix.of(context).client.userID ??
                            L10n.of(context).user;
                        final displayname =
                            profile?.displayName ?? mxid.localpart ?? mxid;

                        return Stack(
                          clipBehavior: Clip.none,
                          children: [
                            FutureBuilder<String?>(
                              future: controller.bannerFuture,
                              builder: (context, snapshot) {
                                return Positioned.fill(
                                  child: snapshot.hasData
                                      ? MxcImage(
                                          uri: Uri.parse(snapshot.data!),
                                          fit: BoxFit.cover,
                                          isThumbnail: false,
                                          borderRadius: borderRadius,
                                        )
                                      : _buildBannerPlaceholder(context),
                                );
                              },
                            ),
                            Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(24.0),
                                  child: Stack(
                                    children: [
                                      Avatar(
                                        mxContent: avatar,
                                        name: displayname,
                                        size: Avatar.defaultSize * 2.5,
                                        onTap: avatar != null
                                            ? () => showDialog(
                                                context: context,
                                                useRootNavigator: false,
                                                builder: (_) =>
                                                    MxcImageViewer(avatar),
                                              )
                                            : null,
                                      ),
                                      if (profile != null)
                                        Positioned(
                                          bottom: 0,
                                          right: 0,
                                          child: FloatingActionButton.small(
                                            elevation: 2,
                                            onPressed:
                                                controller.setAvatarAction,
                                            heroTag: null,
                                            child: const Icon(
                                              Icons.camera_alt_outlined,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: const .only(right: 8),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      spacing: 4,
                                      children: [
                                        Material(
                                          color: controller.hasBanner
                                              ? theme.colorScheme.surface
                                                    .withAlpha(127)
                                              : null,
                                          borderRadius: BorderRadius.circular(
                                            24,
                                          ),
                                          clipBehavior: .hardEdge,
                                          child: TextButton.icon(
                                            onPressed:
                                                controller.setDisplaynameAction,
                                            icon: const Icon(
                                              Icons.edit_outlined,
                                              size: 16,
                                            ),
                                            style: TextButton.styleFrom(
                                              foregroundColor:
                                                  theme.colorScheme.onSurface,
                                              iconColor:
                                                  theme.colorScheme.onSurface,
                                              minimumSize: const Size(0, 24),
                                            ),
                                            label: Text(
                                              displayname,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(fontSize: 16),
                                            ),
                                          ),
                                        ),
                                        Material(
                                          color: controller.hasBanner
                                              ? theme.colorScheme.surface
                                                    .withAlpha(127)
                                              : null,
                                          borderRadius: BorderRadius.circular(
                                            24,
                                          ),
                                          clipBehavior: .hardEdge,
                                          child: TextButton.icon(
                                            onPressed: () => FluffyShare.share(
                                              mxid,
                                              context,
                                            ),
                                            icon: const Icon(
                                              Icons.copy_outlined,
                                              size: 14,
                                            ),
                                            style: TextButton.styleFrom(
                                              foregroundColor:
                                                  theme.colorScheme.secondary,
                                              iconColor:
                                                  theme.colorScheme.secondary,
                                              minimumSize: const Size(0, 12),
                                            ),
                                            label: Text(
                                              mxid,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Positioned(
                              right: 0,
                              top: 0,
                              child: FutureBuilder<String?>(
                                future: controller.bannerFuture,
                                builder: (context, snapshot) {
                                  return PopupMenuButton<String>(
                                    icon: const Icon(Icons.more_vert),
                                    onSelected: (value) {
                                      if (value == 'set_banner') {
                                        controller.setBannerAction();
                                      }
                                    },
                                    itemBuilder: (context) => [
                                      PopupMenuItem(
                                        value: 'set_banner',
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(Icons.image_outlined),
                                            const SizedBox(width: 12),
                                            Text(L10n.of(context).setBanner),
                                          ],
                                        ),
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
                    const SizedBox(height: 8),
                    Material(
                      color: theme.colorScheme.surfaceContainerHigh,
                      borderRadius: borderRadius,
                      clipBehavior: .hardEdge,
                      child: FutureBuilder<String?>(
                        future: controller.aboutFuture,
                        builder: (context, snapshot) {
                          final data = snapshot.data;
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: theme.colorScheme.primary,
                              child: Icon(
                                Icons.wysiwyg,
                                color: theme.colorScheme.onPrimary,
                              ),
                            ),
                            title: Text(data ?? L10n.of(context).notSet),
                            subtitle: Text(L10n.of(context).aboutUser),
                            trailing: const Icon(Icons.edit),
                            onTap: controller.setAboutAction,
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 8),
                    Material(
                      color: theme.colorScheme.surfaceContainerHigh,
                      borderRadius: borderRadius,
                      clipBehavior: .hardEdge,
                      child: Column(
                        children: [
                          FutureBuilder(
                            future: Matrix.of(context).client.getWellknown(),
                            builder: (context, snapshot) {
                              final accountManageUrl = snapshot
                                  .data
                                  ?.additionalProperties
                                  .tryGetMap<String, Object?>(
                                    'org.matrix.msc2965.authentication',
                                  )
                                  ?.tryGet<String>('account');
                              if (accountManageUrl == null) {
                                return const SizedBox.shrink();
                              }
                              return Column(
                                children: [
                                  ListTile(
                                    leading: const CircleAvatar(
                                      backgroundColor: Colors.cyan,
                                      child: Icon(
                                        Icons.account_circle_outlined,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    title: Text(L10n.of(context).manageAccount),
                                    trailing: const Icon(
                                      Icons.open_in_new_outlined,
                                    ),
                                    onTap: () => launchUrlString(
                                      accountManageUrl,
                                      mode: LaunchMode.inAppBrowserView,
                                    ),
                                  ),
                                  const ListDivider(),
                                ],
                              );
                            },
                          ),

                          ListTile(
                            title: Text(L10n.of(context).updateCheckTitle),
                            leading: CircleAvatar(
                              backgroundColor: theme.colorScheme.tertiary,
                              child: Icon(
                                Icons.update_outlined,
                                color: theme.colorScheme.onTertiary,
                              ),
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.refresh),
                              onPressed: () => check_updates.checkForUpdates(context),
                            ),
                            onTap: () => check_updates.checkForUpdates(context),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Material(
                      color: theme.colorScheme.surfaceContainerHigh,
                      borderRadius: borderRadius,
                      clipBehavior: .hardEdge,
                      child: Column(
                        children: [
                          ListTile(
                            leading: CircleAvatar(
                              backgroundColor: theme.colorScheme.primary,
                              child: Icon(
                                Icons.format_paint_outlined,
                                color: theme.colorScheme.onPrimary,
                              ),
                            ),
                            title: Text(L10n.of(context).changeTheme),
                            tileColor:
                                activeRoute.startsWith('/rooms/settings/style')
                                ? theme.colorScheme.surfaceContainerHigh
                                : null,
                            onTap: () => context.go('/rooms/settings/style'),
                          ),
                          const ListDivider(),
                          ListTile(
                            leading: CircleAvatar(
                              backgroundColor: theme.colorScheme.secondary,
                              child: Icon(
                                Icons.notifications_outlined,
                                color: theme.colorScheme.onSecondary,
                              ),
                            ),
                            title: Text(L10n.of(context).notifications),
                            tileColor:
                                activeRoute.startsWith(
                                  '/rooms/settings/notifications',
                                )
                                ? theme.colorScheme.surfaceContainerHigh
                                : null,
                            onTap: () =>
                                context.go('/rooms/settings/notifications'),
                          ),
                          const ListDivider(),
                          ListTile(
                            leading: CircleAvatar(
                              backgroundColor: theme.colorScheme.tertiary,
                              child: Icon(
                                Icons.devices_outlined,
                                color: theme.colorScheme.onTertiary,
                              ),
                            ),
                            title: Text(L10n.of(context).devices),
                            onTap: () => context.go('/rooms/settings/devices'),
                            tileColor:
                                activeRoute.startsWith(
                                  '/rooms/settings/devices',
                                )
                                ? theme.colorScheme.surfaceContainerHigh
                                : null,
                          ),
                          const ListDivider(),
                          ListTile(
                            leading: CircleAvatar(
                              backgroundColor: theme.colorScheme.secondary,
                              child: Icon(
                                Icons.forum_outlined,
                                color: theme.colorScheme.onSecondary,
                              ),
                            ),
                            title: Text(L10n.of(context).chat),
                            onTap: () => context.go('/rooms/settings/chat'),
                            tileColor:
                                activeRoute.startsWith('/rooms/settings/chat')
                                ? theme.colorScheme.surfaceContainerHigh
                                : null,
                          ),
                          const ListDivider(),
                          ListTile(
                            leading: CircleAvatar(
                              backgroundColor: theme.colorScheme.primary,
                              child: Icon(
                                Icons.toggle_on_outlined,
                                color: theme.colorScheme.onPrimary,
                              ),
                            ),
                            title: Text(L10n.of(context).featureSwitches),
                            onTap: () => context.go('/rooms/settings/features'),
                            tileColor:
                                activeRoute.startsWith(
                                  '/rooms/settings/features',
                                )
                                ? theme.colorScheme.surfaceContainerHigh
                                : null,
                          ),
                          const ListDivider(),
                          ListTile(
                            leading: CircleAvatar(
                              backgroundColor: theme.colorScheme.tertiary,
                              child: Icon(
                                Icons.shield_outlined,
                                color: theme.colorScheme.onTertiary,
                              ),
                            ),
                            title: Text(L10n.of(context).security),
                            onTap: () => context.go('/rooms/settings/security'),
                            tileColor:
                                activeRoute.startsWith(
                                  '/rooms/settings/security',
                                )
                                ? theme.colorScheme.surfaceContainerHigh
                                : null,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Material(
                      color: theme.colorScheme.surfaceContainerHigh,
                      borderRadius: borderRadius,
                      clipBehavior: .hardEdge,
                      child: Column(
                        children: [
                          ListTile(
                            leading: CircleAvatar(
                              backgroundColor: theme.colorScheme.primary,
                              child: Icon(
                                Icons.dns_outlined,
                                color: theme.colorScheme.onPrimary,
                              ),
                            ),
                            title: Text(
                              L10n.of(context).aboutHomeserver(
                                Matrix.of(context).client.userID?.domain ??
                                    'homeserver',
                              ),
                            ),
                            onTap: () =>
                                context.go('/rooms/settings/homeserver'),
                            tileColor:
                                activeRoute.startsWith(
                                  '/rooms/settings/homeserver',
                                )
                                ? theme.colorScheme.surfaceContainerHigh
                                : null,
                          ),
                          const ListDivider(),
                          ListTile(
                            leading: CircleAvatar(
                              backgroundColor: theme.colorScheme.secondary,
                              child: Icon(
                                Icons.privacy_tip_outlined,
                                color: theme.colorScheme.onSecondary,
                              ),
                            ),
                            title: Text(L10n.of(context).privacy),
                            onTap: () => launchUrlString(AppConfig.privacyUrl),
                          ),
                          const ListDivider(),
                          ListTile(
                            leading: CircleAvatar(
                              backgroundColor: theme.colorScheme.tertiary,
                              child: Icon(
                                Icons.info_outline,
                                color: theme.colorScheme.onTertiary,
                              ),
                            ),
                            title: Text(L10n.of(context).about),
                            onTap: () => PlatformInfos.showDialog(context),
                          ),
                          // ── Diagnostic: test push notification ──
                          const ListDivider(),
                          ListTile(
                            leading: CircleAvatar(
                              backgroundColor: theme.colorScheme.error,
                              child: Icon(
                                Icons.bug_report_outlined,
                                color: theme.colorScheme.onError,
                              ),
                            ),
                            title: const Text('Test push notificatie'),
                            subtitle: const Text('Stuur een lokale test notificatie'),
                            onTap: () => _testPushNotification(context),
                          ),
                          ListTile(
                            leading: CircleAvatar(
                              backgroundColor: theme.colorScheme.primary,
                              child: Icon(
                                Icons.send_outlined,
                                color: theme.colorScheme.onPrimary,
                              ),
                            ),
                            title: const Text('End-to-end push test'),
                            subtitle: const Text('Stuur een echte push via de homeserver'),
                            onTap: () => _testEndToEndPush(context),
                          ),
                          const ListDivider(),
                          ListTile(
                            leading: CircleAvatar(
                              backgroundColor: theme.colorScheme.error,
                              child: Icon(
                                Icons.list_alt_outlined,
                                color: theme.colorScheme.onError,
                              ),
                            ),
                            title: const Text('Push logs'),
                            subtitle: const Text('Bekijk push diagnostiek logs'),
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const PushLogViewerScreen(),
                              ),
                            ),
                          ),
                          const ListDivider(),
                          SwitchListTile.adaptive(
                            controlAffinity: ListTileControlAffinity.trailing,
                            value: controller.isRecoveryActive,
                            secondary: CircleAvatar(
                              backgroundColor:
                                  controller.showChatBackupBanner == null
                                  ? theme.colorScheme.surfaceContainerHighest
                                  : controller.isRecoveryActive
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.secondary,
                              child: controller.showChatBackupBanner == null
                                  ? SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color:
                                            theme.colorScheme.onSurfaceVariant,
                                      ),
                                    )
                                  : Icon(
                                      controller.isRecoveryActive
                                          ? Icons.check_circle_outlined
                                          : Icons.cloud_upload_outlined,
                                      color: controller.isRecoveryActive
                                          ? theme.colorScheme.onPrimary
                                          : theme.colorScheme.onSecondary,
                                    ),
                            ),
                            title: Text(
                              controller.isRecoveryActive
                                  ? 'Recovery Active'
                                  : L10n.of(context).chatBackup,
                            ),
                            subtitle: Text(
                              controller.showChatBackupBanner == null
                                  ? 'Checking recovery status...'
                                  : controller.isRecoveryActive
                                  ? 'Your messages are secured and can be recovered'
                                  : L10n.of(context).chatBackupDescription,
                            ),
                            onChanged:
                                controller.showChatBackupBanner == null ||
                                    controller.isRecoveryActive
                                ? null
                                : (_) => controller.firstRunBootstrapAction(),
                          ),

                          ListTile(
                            leading: CircleAvatar(
                              backgroundColor:
                                  theme.colorScheme.primaryContainer,
                              child: Icon(
                                Icons.schedule,
                                color: theme.colorScheme.onPrimaryContainer,
                              ),
                            ),
                            title: const Text('Scheduled Messages'),
                            subtitle: const Text(
                              'View and cancel scheduled messages',
                            ),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () =>
                                context.push('/rooms/settings/scheduled'),
                          ),

                          StatefulBuilder(
                            builder: (context, setInnerState) {
                              return SwitchListTile.adaptive(
                                controlAffinity: ListTileControlAffinity.trailing,
                                value: AppSettings.chatListCompactMode.value,
                                secondary: CircleAvatar(
                                  backgroundColor: theme.colorScheme.secondary,
                                  child: Icon(
                                    Icons.view_agenda_outlined,
                                    color: theme.colorScheme.onSecondary,
                                  ),
                                ),
                                title: const Text('Compact Chat List'),
                                subtitle: const Text(
                                  'Smaller avatars and spacing',
                                ),
                                onChanged: (value) {
                                  AppSettings.chatListCompactMode.setItem(value);
                                  setInnerState(() {});
                                },
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Material(
                      color: theme.colorScheme.surfaceContainerHigh,
                      borderRadius: borderRadius,
                      clipBehavior: .hardEdge,
                      child: Column(
                        children: [
                          ListTile(
                            leading: CircleAvatar(
                              backgroundColor: theme.colorScheme.error,
                              child: Icon(
                                Icons.logout_outlined,
                                color: theme.colorScheme.onError,
                              ),
                            ),
                            title: Text(L10n.of(context).logout),
                            onTap: controller.logoutAction,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
