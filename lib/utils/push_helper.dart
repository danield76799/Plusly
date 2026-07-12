import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_new_badger/flutter_new_badger.dart';
import 'package:flutter_shortcuts_new/flutter_shortcuts_new.dart';
import 'package:matrix/matrix.dart';

import 'package:Pulsly/config/app_config.dart';
import 'package:Pulsly/config/setting_keys.dart';
import 'package:Pulsly/generated/l10n/l10n.dart';
import 'package:Pulsly/utils/client_download_content_extension.dart';
import 'package:Pulsly/utils/client_manager.dart';
import 'package:Pulsly/utils/matrix_sdk_extensions/matrix_locals.dart';
import 'package:Pulsly/utils/notification_background_handler.dart';
import 'package:Pulsly/utils/platform_infos.dart';

const notificationAvatarDimension = 128;

/// ─── FluffyChat-style push helper ───────────────────────────────────────────
/// Single show() call, global channel, summary notification, no pre-fetch.

Future<void> pushHelper(
  PushNotification notification, {
  List<Client>? clients,
  L10n? l10n,
  String? activeRoomId,
  Client? activeClient,
  required FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin,
  String? instance,
  bool useNotificationActions = true,
  void Function(Event event)? onEventLoaded,
}) async {
  try {
    await _tryPushHelper(
      notification,
      clients: clients,
      l10n: l10n,
      activeRoomId: activeRoomId,
      activeClient: activeClient,
      flutterLocalNotificationsPlugin: flutterLocalNotificationsPlugin,
      instance: instance,
      useNotificationActions: useNotificationActions,
      onEventLoaded: onEventLoaded,
    );
  } catch (e, s) {
    l10n ??= await lookupL10n(PlatformDispatcher.instance.locale);
    await flutterLocalNotificationsPlugin.show(
      id: notification.hashCode,
      title: l10n.newMessageInFluffyChat,
      body: l10n.openAppToReadMessages,
      notificationDetails: NotificationDetails(
        iOS: const DarwinNotificationDetails(),
        android: AndroidNotificationDetails(
          AppConfig.pushNotificationsChannelId,
          l10n.incomingMessages,
          number: notification.counts?.unread,
          ticker: l10n.unreadChatsInApp(
            AppConfig.applicationName,
            (notification.counts?.unread ?? 0).toString(),
          ),
          importance: Importance.high,
          priority: Priority.max,
          shortcutId: notification.roomId,
        ),
      ),
    );

    if (e is! TimeoutException && e is! IOException) {
      Logs().e('Push Helper has crashed!', e, s);
    }
    rethrow;
  }
}

Future<void> _tryPushHelper(
  PushNotification notification, {
  List<Client>? clients,
  L10n? l10n,
  String? activeRoomId,
  Client? activeClient,
  required FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin,
  String? instance,
  bool useNotificationActions = true,
  void Function(Event event)? onEventLoaded,
}) async {
  final isBackgroundMessage = clients == null;
  Logs().v(
    'Push helper has been started (background=$isBackgroundMessage).',
    notification.toJson(),
  );

  // ── Foreground check ──
  if (notification.roomId != null &&
      activeRoomId == notification.roomId &&
      activeClient != null &&
      WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed) {
    Logs().v('Room is in foreground. Stop push helper here.');
    return;
  }

  // ── Resolve client ──
  clients ??= await ClientManager.getClients(
    initialize: false,
    store: await AppSettings.init(),
  );

  final client = _clientFromInstance(instance, clients);
  if (client == null) {
    Logs().e('No client could be found for instance $instance');
    return;
  }

  // ── Deduplicate across multi-account ──
  if (notification.roomId != null && clients.isNotEmpty) {
    final firstClientInRoom = clients.firstWhereOrNull(
      (c) => c.rooms.any((r) => r.id == notification.roomId),
    );
    if (firstClientInRoom != null && firstClientInRoom != client) {
      Logs().v(
        'Another client (${firstClientInRoom.clientName}) already handles '
        'notifications for room ${notification.roomId}. Skipping for ${client.clientName}.',
      );
      return;
    }
  }

  // ── Fetch the event ──
  final event = await client.getEventByPushNotification(
    notification,
    storeInDatabase: isBackgroundMessage,  // FIX #7: persist in background
  );

  // ── Sync so the room moves to the top of the chat list immediately ──
  final awaitingOneShotSync = client.oneShotSync();

  l10n ??= await L10n.delegate.load(PlatformDispatcher.instance.locale);

  updateAppBadge(notification.counts?.unread ?? 0);

  if (event == null) {
    Logs().v('Notification is a clearing indicator.');
    if (notification.counts?.unread == null ||
        notification.counts?.unread == 0) {
      await flutterLocalNotificationsPlugin.cancelAll();
    } else {
      await client.roomsLoading;
      await awaitingOneShotSync;
      final activeNotifications = await flutterLocalNotificationsPlugin
          .getActiveNotifications();
      // FIX #22: use the filtered list
      final clientNotifications = activeNotifications
          .where((n) => n.groupKey == client.clientName)
          .toList();
      var needsUpdateForSummaryNotification = false;
      for (final activeNotification in clientNotifications) {
        final room = client.rooms.singleWhereOrNull(
          (room) =>
              '${client.clientName}_${room.id}'.hashCode ==
              activeNotification.id,
        );
        if (room != null && !room.isUnreadOrInvited) {
          await flutterLocalNotificationsPlugin.cancel(id: activeNotification.id!);  // FIX #12: await cancel
          if (PlatformInfos.isAndroid) needsUpdateForSummaryNotification = true;
        }
      }
      if (needsUpdateForSummaryNotification) {
        await updateSummaryNotification(
          clientName: client.clientName,
          l10n: l10n,
          flutterLocalNotificationsPlugin: flutterLocalNotificationsPlugin,
        );
      }
    }
    return;
  }

  // FIX #6: Check push rules — skip muted rooms
  if (!client.pushruleEvaluator.match(event).notify) {
    Logs().v('Push rule says do not notify for this event. Skipping.');
    return;
  }

  onEventLoaded?.call(event);
  Logs().v('Push helper got notification event of type ${event.type}.');

  // ── Call events ──
  if (event.type.startsWith('m.call')) {
    client.backgroundSync = true;
  }
  if (event.type == EventTypes.CallHangup) {
    client.backgroundSync = false;
  }
  if (event.type.startsWith('m.call') && event.type != EventTypes.CallInvite) {
    Logs().v('Push message is a m.call but not invite. Do not display.');
    return;
  }
  // FIX #23: removed redundant second call-type check

  final matrixLocals = MatrixLocals(l10n);

  // ── Calculate body ──
  final body = event.type == EventTypes.Encrypted
      ? l10n.newMessageInFluffyChat
      : await event.calcLocalizedBody(
          matrixLocals,
          plaintextBody: true,
          withSenderNamePrefix: false,
          hideReply: true,
          hideEdit: true,
          removeMarkdown: true,
        );

  // ── Avatars ──
  final avatar = event.room.avatar;
  final senderAvatar = event.room.isDirectChat
      ? avatar
      : event.senderFromMemoryOrFallback.avatarUrl;

  final roomAvatarFile = await _tryDownloadNotificationAvatar(client, avatar);
  final senderAvatarFile = event.room.isDirectChat
      ? roomAvatarFile
      : await _tryDownloadNotificationAvatar(client, senderAvatar);

  final senderName = event.senderFromMemoryOrFallback.calcDisplayname();

  // ── Notification ID: unique per client+room (FluffyChat pattern) ──
  final id = '${client.clientName}_${notification.roomId}'.hashCode;

  // ── Messaging style (append to existing conversation) ──
  final newMessage = Message(
    body,
    event.originServerTs,
    Person(
      bot: event.messageType == MessageTypes.Notice,
      key: event.senderId,
      name: senderName,
      icon: senderAvatarFile == null
          ? null
          : ByteArrayAndroidIcon(senderAvatarFile),
    ),
  );

  final messagingStyleInformation = PlatformInfos.isAndroid
      ? await AndroidFlutterLocalNotificationsPlugin()
            .getActiveNotificationMessagingStyle(id: id)
      : null;
  messagingStyleInformation?.messages?.add(newMessage);

  final roomName = event.room.getLocalizedDisplayname(MatrixLocals(l10n));

  // ── Channel groups ──
  final notificationGroupId = event.room.isDirectChat
      ? 'directChats'
      : 'groupChats';
  final groupName = event.room.isDirectChat ? l10n.directChats : l10n.groups;

  final messageRooms = AndroidNotificationChannelGroup(
    notificationGroupId,
    groupName,
  );
  final roomsChannel = AndroidNotificationChannel(
    event.room.id,
    roomName,
    groupId: notificationGroupId,
  );

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >()
      ?.createNotificationChannelGroup(messageRooms);
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >()
      ?.createNotificationChannel(roomsChannel);

  // ── Build notification details ──
  final androidPlatformChannelSpecifics = AndroidNotificationDetails(
    AppConfig.pushNotificationsChannelId,
    l10n.incomingMessages,
    number: notification.counts?.unread,
    category: AndroidNotificationCategory.message,
    shortcutId: event.room.id,
    styleInformation:
        messagingStyleInformation ??
        MessagingStyleInformation(
          Person(
            name: senderName,
            icon: roomAvatarFile == null
                ? null
                : ByteArrayAndroidIcon(roomAvatarFile),
            key: event.roomId,
            important: event.room.isFavourite,
          ),
          conversationTitle: event.room.isDirectChat ? null : roomName,
          groupConversation: !event.room.isDirectChat,
          messages: [newMessage],
        ),
    ticker: event.calcLocalizedBodyFallback(
      matrixLocals,
      plaintextBody: true,
      withSenderNamePrefix: !event.room.isDirectChat,
      hideReply: true,
      hideEdit: true,
      removeMarkdown: true,
    ),
    importance: Importance.high,
    priority: Priority.max,
    groupKey: client.clientName,
    actions: event.type == EventTypes.RoomMember || !useNotificationActions
        ? null
        : <AndroidNotificationAction>[
            AndroidNotificationAction(
              PluslyNotificationActions.reply.name,
              l10n.reply,
              inputs: [
                AndroidNotificationActionInput(label: l10n.writeAMessage),
              ],
              cancelNotification: false,
              allowGeneratedReplies: true,
              semanticAction: SemanticAction.reply,
            ),
            AndroidNotificationAction(
              PluslyNotificationActions.markAsRead.name,
              l10n.markAsRead,
              semanticAction: SemanticAction.markAsRead,
            ),
          ],
  );
  final iOSPlatformChannelSpecifics = DarwinNotificationDetails(
    threadIdentifier: event.room.id,
  );
  final platformChannelSpecifics = NotificationDetails(
    android: androidPlatformChannelSpecifics,
    iOS: iOSPlatformChannelSpecifics,
  );

  final title = event.room.getLocalizedDisplayname(MatrixLocals(l10n));

  // ── Shortcut (first notification for this room) ──
  if (PlatformInfos.isAndroid && messagingStyleInformation == null) {
    await _setShortcut(event, l10n, title, roomAvatarFile);
  }

  final needsTitleAndBody = !PlatformInfos.isAndroid;

  // ── SINGLE show() call (FluffyChat pattern) ──
  await flutterLocalNotificationsPlugin.show(
    id: id,
    title: needsTitleAndBody ? title : null,
    body: needsTitleAndBody ? body : null,
    notificationDetails: platformChannelSpecifics,
    payload: NotificationPushPayload(
      client.clientName,
      event.room.id,
      event.eventId,
    ).toString(),
  );

  // ── Await sync so chat list updates before we finish ──
  // FIX #4: await oneShotSync in normal path too, so room moves to top
  await awaitingOneShotSync;

  // ── Summary notification (FluffyChat pattern) ──
  if (PlatformInfos.isAndroid) {
    await updateSummaryNotification(
      clientName: client.clientName,
      l10n: l10n,
      flutterLocalNotificationsPlugin: flutterLocalNotificationsPlugin,
    );
  }

  Logs().v('Push helper has been completed!');
}

/// ─── Helpers ────────────────────────────────────────────────────────────────

Client? _clientFromInstance(String? instance, List<Client> clients) {
  if (clients.isEmpty) return null;
  if (instance == null) return clients.first;
  // FIX #16: don't fallback to first client — return null if no match
  return clients.firstWhereOrNull((client) => client.clientName == instance);
}

void updateAppBadge(int unreadCount) {
  if (PlatformInfos.isAndroid || PlatformInfos.isMacOS || PlatformInfos.isIOS) {
    if (unreadCount == 0) {
      FlutterNewBadger.removeBadge();
    } else {
      FlutterNewBadger.setBadge(unreadCount);
    }
    return;
  }
}

/// Shows a grouped summary notification at the top of the notification shade.
Future<void> updateSummaryNotification({
  required FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin,
  required String clientName,
  required L10n l10n,
}) async {
  final activeNotifications =
      (await flutterLocalNotificationsPlugin.getActiveNotifications())
          .where((n) => n.groupKey == clientName)
          .toList();

  if (activeNotifications.length <= 1) {
    await flutterLocalNotificationsPlugin.cancel(id: clientName.hashCode);
    return;
  }

  // FIX #11: cancel stale summary and re-show with updated content
  await flutterLocalNotificationsPlugin.cancel(id: clientName.hashCode);

  await flutterLocalNotificationsPlugin.show(
    id: clientName.hashCode,
    notificationDetails: NotificationDetails(
      android: AndroidNotificationDetails(
        AppConfig.pushNotificationsChannelId,
        l10n.incomingMessages,
        groupKey: clientName,
        setAsGroupSummary: true,
        styleInformation: InboxStyleInformation(
          activeNotifications.map((n) => n.body ?? '').toList(),
        ),
        autoCancel: false,
      ),
    ),
  );
}

Future<void> _setShortcut(
  Event event,
  L10n l10n,
  String title,
  Uint8List? avatarFile,
) async {
  final flutterShortcuts = FlutterShortcuts();
  await flutterShortcuts.initialize(debug: !kReleaseMode);
  await flutterShortcuts.pushShortcutItem(
    shortcut: ShortcutItem(
      id: event.room.id,
      action: AppConfig.inviteLinkPrefix + event.room.id,
      shortLabel: title,
      conversationShortcut: true,
      icon: avatarFile == null ? null : base64Encode(avatarFile),
      shortcutIconAsset: avatarFile == null
          ? ShortcutIconAsset.androidAsset
          : ShortcutIconAsset.memoryAsset,
      isImportant: event.room.isFavourite,
    ),
  );
}

Future<Uint8List?> _tryDownloadNotificationAvatar(
  Client client,
  Uri? avatar,
) async {
  if (avatar == null) return null;
  try {
    return await client.downloadMxcCached(
      avatar,
      thumbnailMethod: ThumbnailMethod.crop,
      width: notificationAvatarDimension,
      height: notificationAvatarDimension,
      animated: false,
      isThumbnail: true,
      rounded: true,
    ).timeout(const Duration(seconds: 3));
  } catch (e, s) {
    Logs().e('Unable to get avatar picture', e, s);
    return null;
  }
}

/// ─── Payload ────────────────────────────────────────────────────────────────

class NotificationPushPayload {
  final String? clientName, roomId, eventId;

  NotificationPushPayload(this.clientName, this.roomId, this.eventId);

  factory NotificationPushPayload.fromString(String payload) {
    final parts = payload.split('|');
    if (parts.length != 3) {
      return NotificationPushPayload(null, null, null);
    }
    return NotificationPushPayload(parts[0], parts[1], parts[2]);
  }

  @override
  String toString() => '$clientName|$roomId|$eventId';
}