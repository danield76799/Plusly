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
    // Don't show a duplicate/broken fallback notification.
    // The main flow already showed a properly formatted notification
    // before throwing. If it threw before showing, we'd rather show nothing
    // than a confusing "Open app to read messages" placeholder.
    Logs().w(
      'Push helper threw — NOT showing fallback to avoid duplicate/confusing notification',
      e,
      s,
    );
    if (e is! TimeoutException && e is! IOException) {
      Logs().e('Push Helper has crashed!', e, s);
    }
    // Don't rethrow — caller would try to show its own notification
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

  // Fast background path: if we have a push payload, show a notification
  // immediately without waiting for rooms/database to load. This avoids losing
  // notifications when Android kills the background handler.
  if (isBackgroundMessage && notification.roomId != null) {
    unawaited(
      (_buildFallbackNotification(
        notification,
        client: client,
        flutterLocalNotificationsPlugin: flutterLocalNotificationsPlugin,
      ) as Future)
          .catchError((e) {
        Logs().w('Fallback notification failed', e);
      }),
    );
    // In background we don't need the rich notification; stop here to keep
    // the handler fast and under the OS time budget.
    return;
  }

  // Zorg dat rooms geladen zijn voordat we het push-event ophalen.
  // Bij een koude start kan dit even duren; de fallback above already notified.
  await client.roomsLoading;

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
  // FluffyChat pattern: do NOT store in database from the push helper.
  // The event will arrive through the regular sync triggered by oneShotSync(),
  // which is more reliable for encrypted messages and room ordering.
  var event = await client.getEventByPushNotification(
    notification,
    storeInDatabase: false,
  );

  // Bij een koude start kan roomsLoading wel klaar zijn maar de sync nog niet
  // de kamer bevatten. Als we een room_id hebben maar geen event, forceren
  // we een sync en wachten tot de kamer beschikbaar is.
  if (event == null &&
      notification.roomId != null &&
      client.getRoomById(notification.roomId!) == null) {
    Logs().v('Push event not resolved yet; forcing sync for room');
    try {
      await client
          .waitForRoomInSync(notification.roomId!)
          .timeout(const Duration(seconds: 10));
      event = await client.getEventByPushNotification(
        notification,
        storeInDatabase: false,
      );
    } catch (_) {
      // Event komt later wel via sync; toon notificatie op basis van payload.
    }
  }

  // ── Start sync so the room moves to the top of the chat list immediately ──
  // The Matrix SDK's oneShotSync() reuses the in-flight long-poll sync (which
  // has a 30s timeout). If we just call oneShotSync(), we'd wait up to 30s for
  // the current sync cycle to finish before the new message appears in the list.
  // Abort the in-flight long-poll first, then do an immediate sync (timeout 0 =
  // no long-poll wait) so the new message is fetched right away.
  final wasBackgroundSync = client.syncPending;
  client.abortSync();
  final syncFuture = client.oneShotSync(timeout: Duration.zero);
  unawaited(
    syncFuture.whenComplete(() {
      if (isBackgroundMessage) {
        client.backgroundSync = false;
      } else if (wasBackgroundSync) {
        // Restore the continuous sync loop that abortSync() stopped.
        client.backgroundSync = true;
      }
    }),
  );

  l10n ??= await L10n.delegate.load(PlatformDispatcher.instance.locale);

  updateAppBadge(notification.counts?.unread ?? 0);

  if (event == null) {
    Logs().v('Notification is a clearing indicator.');
    if (notification.counts?.unread == null ||
        notification.counts?.unread == 0) {
      await flutterLocalNotificationsPlugin.cancelAll();
    } else {
      await client.roomsLoading;
      await syncFuture;
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
      ? await flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
            ?.getActiveNotificationMessagingStyle(id: id)
      : null;
  messagingStyleInformation?.messages?.add(newMessage);

  final roomName = event.room.getLocalizedDisplayname(MatrixLocals(l10n));

  // ── Build notification details ──
  // Single global channel (FluffyChat pattern) — no per-room channels
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

  // Always pass explicit title and body on Android too. The
  // AndroidNotificationDetails (messaging style) handles the rich rendering,
  // but leaving title/body null can cause some OEMs/Android versions to not
  // display the notification at all or fall back to a generic placeholder.
  await flutterLocalNotificationsPlugin.show(
    id: id,
    title: title,
    body: body,
    notificationDetails: platformChannelSpecifics,
    payload: NotificationPushPayload(
      client.clientName,
      event.room.id,
      event.eventId,
    ).toString(),
  );

  // ── Await sync so chat list updates before we finish ──
  // FIX #4: await oneShotSync in normal path too, so room moves to top
  await syncFuture;

  // No need to restore backgroundSync here; whenComplete already handled it.

  // ── Summary notification (FluffyChat pattern) ──
  // Run summary update in background after sync so active notifications are
  // accurate, but don't block the push helper completion.
  if (PlatformInfos.isAndroid) {
    unawaited(
      updateSummaryNotification(
        clientName: client.clientName,
        l10n: l10n,
        flutterLocalNotificationsPlugin: flutterLocalNotificationsPlugin,
      ),
    );
  }

  Logs().v('Push helper has been completed!');
}

Future<void>? _buildFallbackNotification(
  PushNotification notification, {
  required Client client,
  required FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin,
}) async {
  // Extract what we can directly from the Matrix push payload without
  // waiting for rooms/database to load.
  final l10n = await L10n.delegate.load(PlatformDispatcher.instance.locale);
  final senderName = notification.senderDisplayName?.trim() ??
      notification.sender?.trim() ??
      _roomDisplayName(client, notification.roomId, l10n) ??
      '';
  final body = (notification.content?['body'] as String?)?.trim();
  if (senderName.isEmpty && (body == null || body.isEmpty)) {
    return;
  }

  final roomName = _roomDisplayName(client, notification.roomId, l10n) ?? l10n.incomingMessages;
  final id = '${client.clientName}_${notification.roomId}'.hashCode;

  await flutterLocalNotificationsPlugin.show(
    id: id,
    title: senderName.isNotEmpty ? senderName : roomName,
    body: body ?? l10n.newMessageInFluffyChat,
    notificationDetails: NotificationDetails(
      android: AndroidNotificationDetails(
        AppConfig.pushNotificationsChannelId,
        l10n.incomingMessages,
        groupKey: client.clientName,
        importance: Importance.high,
        priority: Priority.max,
        category: AndroidNotificationCategory.message,
        shortcutId: notification.roomId,
      ),
      iOS: DarwinNotificationDetails(threadIdentifier: notification.roomId),
    ),
    payload: NotificationPushPayload(
      client.clientName,
      notification.roomId,
      notification.eventId,
    ).toString(),
  );

  updateAppBadge(notification.counts?.unread ?? 0);
  return;
}

String? _roomDisplayName(Client client, String? roomId, L10n l10n) {
  if (roomId == null) return null;
  try {
    final room = client.getRoomById(roomId);
    if (room == null) return null;
    return room.getLocalizedDisplayname(MatrixLocals(l10n));
  } catch (_) {
    return null;
  }
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
    title: l10n.incomingMessages,
    body: l10n.incomingMessages,
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