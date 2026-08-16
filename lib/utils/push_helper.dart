import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_new_badger/flutter_new_badger.dart';
import 'package:flutter_shortcuts_new/flutter_shortcuts_new.dart';
import 'package:matrix/matrix.dart';

import 'package:Pulsly/config/app_config.dart';
import 'package:Pulsly/generated/l10n/l10n.dart';
import 'package:Pulsly/utils/client_download_content_extension.dart';
import 'package:Pulsly/utils/matrix_sdk_extensions/matrix_locals.dart';
import 'package:Pulsly/utils/notification_background_handler.dart';
import 'package:Pulsly/utils/platform_infos.dart';
import 'package:Pulsly/utils/visible_room.dart';

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
  bool includeReplyAction = true,
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
      includeReplyAction: includeReplyAction,
      onEventLoaded: onEventLoaded,
    );
  } catch (e, s) {
    // Background messages already showed a fast fallback inside _tryPushHelper
    // before any heavy work. If we are in the foreground path, however, a crash
    // here would otherwise be completely silent. Show a minimal fallback so the
    // user at least knows a message arrived and can open the app.
    if (clients != null) {
      unawaited(
        _buildFallbackNotification(
          notification,
          client: activeClient ?? clients.first,
          flutterLocalNotificationsPlugin: flutterLocalNotificationsPlugin,
        ).catchError((fallbackErr) {
          Logs().w('Fallback notification also failed', fallbackErr);
        }),
      );
    }
    Logs().e('Push Helper has crashed!', e, s);
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
  bool includeReplyAction = true,
  void Function(Event event)? onEventLoaded,
}) async {
  final isBackgroundMessage = clients == null;
  final isAppBackground =
      WidgetsBinding.instance.lifecycleState != AppLifecycleState.resumed;
  Logs().v(
    'Push helper has been started (background=$isBackgroundMessage, appBackground=$isAppBackground).',
    notification.toJson(),
  );

  // ── Foreground check ──
  // ChatPage sets VisibleRoom.current in initState and clears it in dispose
  // or when the app leaves resumed. VisibleRoom has NO timeout: the user may
  // sit in a DM for minutes, and we must keep suppressing notifications the
  // whole time. The lifecycle check below ensures we only suppress while the
  // app is actually in the foreground.
  if (notification.roomId != null &&
      notification.roomId!.isNotEmpty &&
      WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed) {
    final sameRoomByRouter =
        activeRoomId == notification.roomId && activeClient != null;
    final sameRoomByVisiblePage = VisibleRoom.isVisible(notification.roomId);
    if (sameRoomByRouter || sameRoomByVisiblePage) {
      Logs().v(
        'Room is in foreground. Stopping push helper here. '
        '(router=$sameRoomByRouter, visible=$sameRoomByVisiblePage, '
        'activeRoomId=$activeRoomId, visibleRoom=${VisibleRoom.current})',
      );
      return;
    }
  }

  // If we have no clients at all, all we can do is a minimal fallback.
  if (isBackgroundMessage) {
    Logs().i('[Push Helper] No clients available, showing minimal fallback');
    await _showBackgroundFallback(
      notification,
      instance: instance,
      flutterLocalNotificationsPlugin: flutterLocalNotificationsPlugin,
    );
    return;
  }

  // ── Resolve client ──
  // clients is guaranteed non-null here (isBackgroundMessage already returned).
  final client = _clientFromInstance(instance, clients);
  if (client == null) {
    Logs().e('No client could be found for instance $instance');
    return;
  }

  // ── Fast fallback for background pushes ──
  // Show a payload-based notification IMMEDIATELY (before roomsLoading or
  // event fetch) so the user sees something within the ~10s Android allows.
  // The rich path later calls show() with the SAME ID, which *replaces* this
  // fallback on Android (same ID = update, not duplicate). This is safe because
  // both paths use identical ID formula: '${client.clientName}_${roomId}'.hashCode.
  //
  // Skip the fallback for empty/count-sync pushes (no event_id and no room_id)
  // — there is no message to show, only a unread count update.
  final isEmptyPayload = (notification.eventId == null ||
          notification.eventId!.isEmpty) &&
      (notification.roomId == null || notification.roomId!.isEmpty);
  if (isAppBackground && !isEmptyPayload) {
    try {
      await _buildFallbackNotification(
        notification,
        client: client,
        flutterLocalNotificationsPlugin: flutterLocalNotificationsPlugin,
      );
      Logs().v('[Push Helper] Fast fallback shown for background push');
    } catch (e, s) {
      Logs().w('[Push Helper] Fast fallback failed, continuing to rich path', e, s);
    }
  }

  // Zorg dat rooms geladen zijn voordat we het push-event ophalen.
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
  //
  // Only abort the in-flight sync when the app is in the background. In the
  // foreground the UI may be interacting with an active sync; aborting it can
  // corrupt timeline/chat-list state. When backgroundSync is off or no sync is
  // running, oneShotSync(timeout: 0) starts/finishes immediately without a long
  // wait.
  if (isAppBackground) {
    client.abortSync();
  }
  final syncFuture = client.oneShotSync(timeout: Duration.zero);
  unawaited(
    syncFuture.whenComplete(() {
      // Check the CURRENT lifecycle, not the snapshot from when the push
      // arrived. The user may have opened the app while the sync was running.
      final stillBackground =
          WidgetsBinding.instance.lifecycleState != AppLifecycleState.resumed;
      if (stillBackground) {
        client.backgroundSync = false;
      } else {
        // App is in foreground — make sure sync stays on.
        client.backgroundSync = true;
      }
    }),
  );

  l10n ??= await L10n.delegate.load(PlatformDispatcher.instance.locale);

  updateAppBadge(notification.counts?.unread ?? 0);

  if (event == null) {
    // ── Handle empty/count-sync pushes (no event_id, no room_id) ──
    // The HS sends these to update unread counts. They have id="", sender="",
    // type=null. We must NOT show a notification for these — there is no
    // message to show. Only act on the unread count.
    final isEmptyCountSync = (notification.eventId == null ||
            notification.eventId!.isEmpty) &&
        (notification.roomId == null || notification.roomId!.isEmpty);

    if (isEmptyCountSync) {
      if (notification.counts?.unread == 0) {
        // Clearing indicator: all messages read. Cancel all notifications.
        Logs().v('Empty payload with unread=0. Clearing all notifications.');
        await flutterLocalNotificationsPlugin.cancelAll();
        updateAppBadge(0);
      } else {
        // Count sync with unread>0 but no event — just update the badge,
        // do NOT show a notification (there is no message to display).
        Logs().v(
          'Empty payload with unread=${notification.counts?.unread}. '
          'Updating badge only, no notification.',
        );
        updateAppBadge(notification.counts?.unread ?? 0);
      }
      return;
    }

    // ── Event push that could not be resolved ──
    // We have a room_id and possibly event_id, but getEventByPushNotification
    // returned null (e.g. encrypted event, sync not yet complete, or HS issue).
    if (notification.counts?.unread == 0) {
      Logs().v('Event not resolved and unread=0. Clearing notifications.');
      await flutterLocalNotificationsPlugin.cancelAll();
      return;
    }
    // Show a payload-based fallback notification.
    Logs().v('Push event not resolved. Showing payload-based notification.');
    await _buildFallbackNotification(
      notification,
      client: client,
      flutterLocalNotificationsPlugin: flutterLocalNotificationsPlugin,
    );
    if (PlatformInfos.isAndroid) {
      unawaited(
        updateSummaryNotification(
          clientName: client.clientName,
          l10n: l10n,
          flutterLocalNotificationsPlugin: flutterLocalNotificationsPlugin,
        ),
      );
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
  final id = notification.roomId != null && notification.roomId!.isNotEmpty
      ? '${client.clientName}_${notification.roomId}'.hashCode
      : client.clientName.hashCode;

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
            if (includeReplyAction)
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
  // Build the summary directly from the rich notification data we just showed.
  // Calling getActiveNotifications() immediately after show() is unreliable on
  // some Android versions: the OS may not have updated the active list yet,
  // so the summary would miss the latest notification and show stale content.
  if (PlatformInfos.isAndroid) {
    unawaited(
      updateSummaryNotification(
        clientName: client.clientName,
        l10n: l10n,
        flutterLocalNotificationsPlugin: flutterLocalNotificationsPlugin,
        latestTitle: title,
        latestBody: body,
      ),
    );
  }

  Logs().v('Push helper has been completed!');
}

/// Shows a fallback notification for background pushes. The notification
/// is shown IMMEDIATELY — we cannot afford to wait for
/// ClientManager.getClients() because Android may kill the background
/// handler after ~10 seconds.
///
/// The `instance` parameter is the client name (UnifiedPush uses it as
/// the instance identifier). We use it for the notification ID and groupKey
/// so the rich path (which uses client.clientName) replaces this fallback
/// instead of creating a duplicate.
Future<void> _showBackgroundFallback(
  PushNotification notification, {
  String? instance,
  required FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin,
}) async {
  final l10n = await L10n.delegate.load(PlatformDispatcher.instance.locale);

  // Use the instance (client name) so the notification ID matches the
  // rich path's ID, which uses client.clientName. This ensures the rich
  // path replaces this fallback instead of creating a duplicate.
  final clientName = instance ?? 'Plusly';

  final roomName = notification.roomName?.trim() ??
      notification.senderDisplayName?.trim() ??
      notification.sender?.trim();
  final senderName = notification.senderDisplayName?.trim() ??
      notification.sender?.trim() ??
      roomName ??
      '';
  final rawBody = (notification.content?['body'] as String?)?.trim();
  final looksEncrypted = rawBody == null ||
      rawBody.isEmpty ||
      rawBody.startsWith('{') ||
      (!rawBody.contains(' ') && rawBody.length > 40);
  final body = looksEncrypted ? l10n.newMessageInFluffyChat : rawBody;

  // Title = room name (e.g. "Kat (WA)"), not sender.
  final title = roomName?.isNotEmpty == true
      ? roomName!
      : (senderName.isNotEmpty ? senderName : l10n.newMessageInFluffyChat);
  final unread = notification.counts?.unread ?? 0;
  final titleWithCount = unread > 1 ? '$title ($unread)' : title;
  final displayTitle = titleWithCount.isNotEmpty &&
          titleWithCount != l10n.incomingMessages
      ? titleWithCount
      : l10n.newMessageInFluffyChat;

  final displayBody = body.isNotEmpty && body != l10n.incomingMessages
      ? body
      : l10n.newMessageInFluffyChat;

  final id = notification.roomId != null && notification.roomId!.isNotEmpty
      ? '${clientName}_${notification.roomId}'.hashCode
      : clientName.hashCode;

  // Use MessagingStyle for consistency with _buildFallbackNotification and
  // the rich path — same ID + same style = Android update, not duplicate.
  final messagingStyle = MessagingStyleInformation(
    Person(
      name: senderName.isNotEmpty ? senderName : displayTitle,
      key: notification.sender ?? notification.roomId,
    ),
    conversationTitle: roomName?.isNotEmpty == true ? roomName : null,
    messages: [
      Message(
        displayBody,
        DateTime.now(),
        Person(
          name: senderName.isNotEmpty ? senderName : displayTitle,
          key: notification.sender ?? notification.roomId,
        ),
      ),
    ],
  );

  // Show the notification FIRST, before any async work.
  await flutterLocalNotificationsPlugin.show(
    id: id,
    title: displayTitle,
    body: displayBody,
    notificationDetails: NotificationDetails(
      android: AndroidNotificationDetails(
        AppConfig.pushNotificationsChannelId,
        l10n.incomingMessages,
        groupKey: clientName,
        importance: Importance.max,
        priority: Priority.max,
        category: AndroidNotificationCategory.message,
        shortcutId: notification.roomId,
        styleInformation: messagingStyle,
      ),
      iOS: DarwinNotificationDetails(threadIdentifier: notification.roomId),
    ),
    payload: NotificationPushPayload(
      clientName,
      notification.roomId,
      notification.eventId,
    ).toString(),
  );

  updateAppBadge(notification.counts?.unread ?? 0);
}

Future<void> _buildFallbackNotification(
PushNotification notification, {
required Client client,
required FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin,
}) async {
  // Extract what we can directly from the Matrix push payload without
  // waiting for rooms/database to load.
  final l10n = await L10n.delegate.load(PlatformDispatcher.instance.locale);
  final roomName = notification.roomName?.trim() ??
      _roomDisplayName(client, notification.roomId, l10n);
  final senderName = notification.senderDisplayName?.trim() ??
      notification.sender?.trim() ??
      roomName ??
      '';
  // The push payload body is only readable for *unencrypted* rooms. For
  // E2EE rooms the gateway cannot decrypt it and sends ciphertext (often a
  // long base64/blob or a JSON object starting with '{'). Showing that to the
  // user is useless, so detect it and fall back to a generic message.
  final rawBody = (notification.content?['body'] as String?)?.trim();
  final looksEncrypted = rawBody == null ||
      rawBody.isEmpty ||
      rawBody.startsWith('{') ||
      // ciphertext has no spaces and is unusually long for a chat line
      (!rawBody.contains(' ') && rawBody.length > 40);
  final body = looksEncrypted
      ? l10n.newMessageInFluffyChat
      : rawBody;

  final fallbackRoomName = roomName ?? l10n.incomingMessages;
  final title = roomName?.isNotEmpty == true
      ? roomName!
      : (senderName.isNotEmpty ? senderName : fallbackRoomName);
  final unread = notification.counts?.unread ?? 0;
  final titleWithCount = unread > 1 ? '$title ($unread)' : title;
  final id = notification.roomId != null && notification.roomId!.isNotEmpty
      ? '${client.clientName}_${notification.roomId}'.hashCode
      : client.clientName.hashCode;

  final displayTitle = titleWithCount.isNotEmpty &&
          titleWithCount != l10n.incomingMessages
      ? titleWithCount
      : l10n.newMessageInFluffyChat;
  final displayBody = body.isNotEmpty && body != l10n.incomingMessages
      ? body
      : l10n.newMessageInFluffyChat;

  // Use MessagingStyle — same style as the rich path — so that when the
  // rich path calls show() with the same ID, Android treats it as an UPDATE
  // of this notification, not a new one. Mixing plain style (fallback) with
  // MessagingStyle (rich) on the same ID caused duplicate notifications on
  // some OEMs (Samsung, Xiaomi).
  final messagingStyle = MessagingStyleInformation(
    Person(
      name: senderName.isNotEmpty ? senderName : displayTitle,
      key: notification.sender ?? notification.roomId,
    ),
    conversationTitle: roomName?.isNotEmpty == true ? roomName : null,
    messages: [
      Message(
        displayBody,
        DateTime.now(),
        Person(
          name: senderName.isNotEmpty ? senderName : displayTitle,
          key: notification.sender ?? notification.roomId,
        ),
      ),
    ],
  );

  await flutterLocalNotificationsPlugin.show(
    id: id,
    title: displayTitle,
    body: displayBody,
    notificationDetails: NotificationDetails(
      android: AndroidNotificationDetails(
        AppConfig.pushNotificationsChannelId,
        l10n.incomingMessages,
        groupKey: client.clientName,
        importance: Importance.max,
        priority: Priority.max,
        category: AndroidNotificationCategory.message,
        shortcutId: notification.roomId,
        styleInformation: messagingStyle,
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
}

String? _roomDisplayName(Client client, String? roomId, L10n l10n) {
  if (roomId == null || roomId.isEmpty) return null;
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
  // UnifiedPush instances are client names. If the specific client isn't found
  // (e.g. after a multi-account change), fall back to the first client rather
  // than dropping the push silently.
  return clients.firstWhereOrNull(
        (client) => client.clientName == instance,
      ) ??
      clients.first;
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
/// The summary title/body are derived from the most recent individual
/// notification so the header shows a real sender/room instead of the generic
/// "Inkomende Berichten" placeholder.
///
/// [latestTitle] and [latestBody] are the values of the rich notification that
/// was just shown. We use them directly because reading
/// getActiveNotifications() immediately after show() can return stale data on
/// some Android versions. The inbox lines are still built from active
/// notifications plus the latest one, so the grouped list stays accurate.
Future<void> updateSummaryNotification({
  required FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin,
  required String clientName,
  required L10n l10n,
  String? latestTitle,
  String? latestBody,
}) async {
  List<ActiveNotification> activeNotifications;
  try {
    activeNotifications =
        (await flutterLocalNotificationsPlugin.getActiveNotifications())
            .where((n) => n.groupKey == clientName)
            .toList();
  } catch (e, s) {
    Logs().w('[Push Helper] getActiveNotifications failed', e, s);
    return;
  }

  // Build inbox lines from the active notifications we got back.
  final lines = activeNotifications
      .where(
        (n) =>
            n.title != null &&
            n.title!.isNotEmpty &&
            n.title != l10n.incomingMessages &&
            n.title != AppConfig.applicationName,
      )
      .map((n) {
        final title = n.title?.trim();
        final body = n.body?.trim();
        final realBody = body != null && body.isNotEmpty && body != l10n.incomingMessages
            ? body
            : l10n.newMessageInFluffyChat;
        if (title != null &&
            title.isNotEmpty &&
            realBody.isNotEmpty &&
            title != realBody) {
          return '$title: $realBody';
        }
        return title ?? realBody;
      })
      .where((line) => line.isNotEmpty)
      .toList();

  // Use the explicit latest title/body (from the notification we just showed)
  // for the summary preview, falling back to the active notifications list if
  // none were provided.
  final summaryTitle = latestTitle?.isNotEmpty == true &&
          latestTitle != l10n.incomingMessages &&
          latestTitle != AppConfig.applicationName
      ? latestTitle!
      : (lines.isNotEmpty
          ? lines.last
          : l10n.newMessageInFluffyChat);
  final summaryBody = latestBody?.isNotEmpty == true &&
          latestBody != l10n.incomingMessages
      ? latestBody!
      : (lines.isNotEmpty
          ? lines.last
          : l10n.newMessageInFluffyChat);

  // FIX #11: cancel stale summary and re-show with updated content
  await flutterLocalNotificationsPlugin.cancel(id: clientName.hashCode);

  await flutterLocalNotificationsPlugin.show(
    id: clientName.hashCode,
    title: summaryTitle,
    body: summaryBody,
    notificationDetails: NotificationDetails(
      android: AndroidNotificationDetails(
        AppConfig.pushNotificationsChannelId,
        l10n.incomingMessages,
        groupKey: clientName,
        setAsGroupSummary: true,
        styleInformation: InboxStyleInformation(
          lines.isNotEmpty ? lines : [l10n.incomingMessages],
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