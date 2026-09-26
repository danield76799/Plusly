import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:collection/collection.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_new_badger/flutter_new_badger.dart';
import 'package:flutter_shortcuts_new/flutter_shortcuts_new.dart';
import 'package:matrix/matrix.dart';

import 'package:Pulsly/config/app_config.dart';
import 'package:Pulsly/config/setting_keys.dart';
import 'package:Pulsly/generated/l10n/l10n.dart';
import 'package:Pulsly/utils/client_download_content_extension.dart';
import 'package:Pulsly/utils/client_manager.dart';
import 'package:Pulsly/utils/foreground_services.dart';
import 'package:Pulsly/utils/matrix_sdk_extensions/matrix_locals.dart';
import 'package:Pulsly/utils/notification_background_handler.dart';
import 'package:Pulsly/utils/platform_infos.dart';
import 'package:Pulsly/utils/push_event_log.dart';

const notificationAvatarDimension = 128;

/// Upstream FluffyChat r486-496: `extension on PushNotification`.
extension PushNotificationExtension on PushNotification {
  /// Upstream r487-488: clientName uit de pusher-devicedata.
  String? get clientName =>
      devices?.firstOrNull?.data?.tryGet<String>('client_name');

  /// Upstream r489-495: notificationId afgeleid van clientName + roomId.
  int get notificationId {
    final roomId = this.roomId;
    if (roomId == null || roomId.isEmpty) return 0;
    final name = clientName;
    if (name == null || name.isEmpty) return roomId.hashCode;
    return '${name}_$roomId'.hashCode;
  }
}

/// Lokale helper voor call sites zonder PushNotification-object.
int notificationIdFor(String? clientName, String? roomId) {
  if (roomId == null || roomId.isEmpty) return 0;
  if (clientName == null || clientName.isEmpty) return roomId.hashCode;
  return '${clientName}_$roomId'.hashCode;
}

Future<L10n> loadPushL10n() async {
  return lookupL10n(PlatformDispatcher.instance.locale);
}

class PushHelper {
  final PushNotification notification;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  late Client client;
  late Event event;
  L10n? l10n;

  PushHelper._(
    this.notification,
    this.flutterLocalNotificationsPlugin,
  );

  /// Upstream FluffyChat r35-96: pushHelper — 30s-timeout rond de hele
  /// helper, ÉÉN localized fallback-notificatie bij een crash, en de
  /// foreground-service weer stoppen in de finally.
  static Future<void> pushHelper(
    PushNotification notification, {
    List<Client>? clients,
    L10n? l10n,
    String? activeRoomId,
    required FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin,
    String? instance,
  }) async {
    l10n ??= await loadPushL10n();
    try {
      // Upstream r44-51: de timeout geldt voor de HÉLE pipeline —
      // handler bouwen + tonen zitten beide in de getimede future.
      await (
        _newPushHandler(
          notification,
          clients: clients,
          l10n: l10n,
          activeRoomId: activeRoomId,
          flutterLocalNotificationsPlugin: flutterLocalNotificationsPlugin,
          instance: instance,
        ) as Future
      ).timeout(const Duration(seconds: 30));
    } catch (e, s) {
      Logs().e('Push Helper has crashed!', e, s);
      if (notification.roomId != null) {
        await flutterLocalNotificationsPlugin.show(
          id: notificationIdFor(notification.clientName, notification.roomId),
          title: l10n.newMessageInFluffyChat,
          body: l10n.openAppToReadMessages,
          notificationDetails: NotificationDetails(
            iOS: DarwinNotificationDetails(
              threadIdentifier: '${notification.clientName}_${notification.roomId}',
            ),
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
              category: AndroidNotificationCategory.message,
              groupKey: notification.clientName,
            ),
          ),
        );
      }
      rethrow;
    } finally {
      await ForegroundServices.stopService('background_push');
    }
  }

  /// Upstream FluffyChat r98-391: _tryPushHelper.
  static FutureOr<PushHelper?> _newPushHandler(
    PushNotification notification, {
    List<Client>? clients,
    L10n? l10n,
    String? activeRoomId,
    required FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin,
    String? instance,
  }) async {
    final helper = PushHelper._(
      notification,
      flutterLocalNotificationsPlugin,
    );
    helper.l10n = l10n;

    final isBackgroundMessage = clients == null;
    Logs().v(
      'Push helper has been started (background=$isBackgroundMessage).',
      notification.toJson(),
    );

    // Upstream r111-123: client-resolutie op basis van de client_name in
    // de pushpayload; alleen als die ontbreekt valt hij terug op de eerste
    // bekende client. De UnifiedPush-instance-string wordt hier niet gebruikt.
    final store = await AppSettings.init();
    final clientName = notification.clientName;
    final client = clientName == null
        ? (clients?.first ??
              (await ClientManager.getClients(
                initialize: false,
                store: store,
              )).first)
        : (clients?.firstWhereOrNull(
              (client) => client.clientName == clientName,
            ) ??
              await ClientManager.createClient(clientName, store));
    helper.client = client;

    // Upstream r127: l10n laden vóór het event (gebruikt in de
    // clearing-tak en de samenvattingsmelding).
    l10n ??= await loadPushL10n();
    helper.l10n = l10n;

    // Upstream r129-133: event laden (storeInDatabase: false, zoals upstream).
    Logs().v('Load event...');
    final event = await client.getEventByPushNotification(
      notification,
      storeInDatabase: false,
    );

    // Upstream r135: badge bijwerken.
    updateAppBadge(notification.counts?.unread ?? 0);

    if (event == null) {
      // Upstream r137-174: clearing-indicator.
      Logs().v('Notification is a clearing indicator.');
      PushEventLog().add('push_clearing', {
        'room': notification.roomId ?? '',
        'unread': '${notification.counts?.unread ?? 0}',
      });
      if (clients?.length == 1 && (notification.counts?.unread == 0)) {
        await flutterLocalNotificationsPlugin.cancelAll();
      } else {
        // Make sure client is fully loaded and synced before dismiss
        // notifications:
        await client.roomsLoading;
        await client
            .oneShotSync()
            .timeout(const Duration(seconds: 8))
            .catchError((_) => null);

        final activeNotifications = await flutterLocalNotificationsPlugin
            .getActiveNotifications();
        activeNotifications.removeWhere(
          (notification) => notification.groupKey != client.clientName,
        );
        var needsUpdateForSummaryNotification = false;
        for (final activeNotification in activeNotifications) {
          final room = client.rooms.singleWhereOrNull(
            (room) =>
                notificationIdFor(client.clientName, room.id) ==
                activeNotification.id,
          );
          if (room != null && !room.isUnreadOrInvited) {
            flutterLocalNotificationsPlugin.cancel(
              id: activeNotification.id!,
            );
            if (PlatformInfos.isAndroid) {
              needsUpdateForSummaryNotification = true;
            }
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
      return null;
    }

    // Upstream r177-182: client-side push-rule evaluatie. Niet crash-veilig
    // verpakt — een crash belandt in de buitenste catch met de localized
    // fallback, precies zoals upstream.
    if (!client.pushruleEvaluator.match(event).notify) {
      Logs().i('Push helper: filtered by client-side push rules.');
      PushEventLog().add('push_rule_filtered', {
        'room': notification.roomId ?? '',
        'type': event.type,
      });
      return null;
    }

    // Upstream r191-196: zit de gebruiker in die room én is de app op de
    // voorgrond, dan geen notificatie.
    if (notification.roomId != null &&
        activeRoomId == notification.roomId &&
        WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed) {
      Logs().v('Room is in foreground. Stop push helper here.');
      PushEventLog().add('push_suppressed', {
        'room': notification.roomId ?? '',
        'activeRoom': activeRoomId ?? '',
        'lifecycle': WidgetsBinding.instance.lifecycleState.toString(),
      });
      return null;
    }

    helper.event = event;
    PushEventLog().add('push_event', {
      'room': notification.roomId ?? '',
      'type': event.type,
    });
    // Upstream r362-390: toon de notificatie. In de class-based wrapper is dit
    // een methode op de helper; in upstream zit dezelfde code inline na de
    // return van _tryPushHelper. Roep hem hier aan zodat de 30s-timeout in
    // pushHelper de hele pipeline afdekt.
    await helper._showNotification();
    return null;
  }

  /// Upstream r362-390: _showNotification.
  Future<void> _showNotification() async {
    // Upstream r123-145: call-afhandeling.
    if (event.type.startsWith('m.call')) {
      // make sure bg sync is on (needed to update hold, unhold events)
      // prevent over write from app life cycle change
      client.backgroundSync = true;
    }

    if (event.type == EventTypes.CallHangup) {
      client.backgroundSync = false;
    }

    if (event.type.startsWith('m.call') &&
        event.type != EventTypes.CallInvite) {
      Logs().v('Push message is a m.call but not invite. Do not display.');
      return;
    }

    if ((event.type.startsWith('m.call') &&
            event.type != EventTypes.CallInvite) ||
        event.type == 'org.matrix.call.sdp_stream_metadata_changed') {
      Logs().v('Push message was for a call, but not call invite.');
      return;
    }

    l10n ??= await loadPushL10n();
    final matrixLocals = MatrixLocals(l10n!);

    // Upstream r201-210: body-berekening — een nog-versleuteld event toont
    // de generieke tekst; geen retry/ontsleutelings-jacht.
    final body = event.type == EventTypes.Encrypted
        ? l10n!.newMessageInFluffyChat
        : await event.calcLocalizedBody(
            matrixLocals,
            plaintextBody: true,
            withSenderNamePrefix: false,
            hideReply: true,
            hideEdit: true,
            removeMarkdown: true,
          );

    final title = event.room.getLocalizedDisplayname(matrixLocals);
    final roomName = event.room.getLocalizedDisplayname(matrixLocals);

    final notificationGroupId = event.room.isDirectChat
        ? 'directChats'
        : 'groupChats';
    final groupName = event.room.isDirectChat
        ? l10n!.directChats
        : l10n!.groups;

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

    final notificationId = notificationIdFor(client.clientName, event.room.id);

    final platformChannelSpecifics = await _getPlatformChannelSpecifics(
      notificationId,
      body,
      title,
      roomName,
    );

    // Upstream r368-380: op Android draagt de MessagingStyle al titel én
    // inhoud; title/body worden dan NIET meegestuurd.
    final needsTitleAndBody = !PlatformInfos.isAndroid;

    await flutterLocalNotificationsPlugin.show(
      id: notificationId,
      title: needsTitleAndBody ? title : null,
      body: needsTitleAndBody ? body : null,
      notificationDetails: platformChannelSpecifics,
      payload: NotificationPushPayload(
        client.clientName,
        event.room.id,
        event.eventId,
      ).toString(),
    );

    // Upstream r382-389: groeps-samenvatting op Android bij 2+ actieve
    // meldingen.
    if (PlatformInfos.isAndroid) {
      await updateSummaryNotification(
        clientName: client.clientName,
        l10n: l10n!,
        flutterLocalNotificationsPlugin: flutterLocalNotificationsPlugin,
      );
    }

    Logs().v('Push helper has been completed!');
    PushEventLog().add('push_shown', {
      'room': notification.roomId ?? '',
      'id': '$notificationId',
    });
  }

  /// Upstream r212-360: platform-channel specifics.
  Future<NotificationDetails> _getPlatformChannelSpecifics(
    int notificationId,
    String notificationBody,
    String notificationTitle,
    String roomName,
  ) async {
    // The person object for the android message style notification
    final avatar = event.room.avatar;
    final senderAvatar = event.room.isDirectChat
        ? avatar
        : event.senderFromMemoryOrFallback.avatarUrl;

    // Upstream r218-226: de gesprekseigenaar (ownUser) is de lokale
    // gebruiker; diens avatar hoort op de MessagingStyle-Person.
    final ownUser = event.room.unsafeGetUserFromMemoryOrFallback(
      client.userID ?? '',
    );
    final userAvatarFile = await _getAvatarFile(client, ownUser.avatarUrl);
    final roomAvatarFile = await _getAvatarFile(client, avatar);
    final senderAvatarFile = event.room.isDirectChat
        ? roomAvatarFile
        : await _getAvatarFile(client, senderAvatar);

    final senderName = event.senderFromMemoryOrFallback.calcDisplayname();

    // Show notification
    final newMessage = Message(
      notificationBody,
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
              .getActiveNotificationMessagingStyle(id: notificationId)
        : null;
    messagingStyleInformation?.messages?.add(newMessage);

    if (PlatformInfos.isAndroid && messagingStyleInformation == null) {
      await _setShortcut(notificationTitle, roomAvatarFile);
    }

    final matrixLocals = MatrixLocals(l10n!);

    final androidPlatformChannelSpecifics = AndroidNotificationDetails(
      AppConfig.pushNotificationsChannelId,
      l10n!.incomingMessages,
      number: notification.counts?.unread,
      subText: client.clientName,
      category: AndroidNotificationCategory.message,
      shortcutId: event.room.id,
      styleInformation:
          messagingStyleInformation ??
          MessagingStyleInformation(
            // Upstream r288-295: de gesprekseigenaar is de lokale gebruiker.
            Person(
              name: ownUser.calcDisplayname(),
              icon: userAvatarFile == null
                  ? null
                  : ByteArrayAndroidIcon(userAvatarFile),
              key: event.room.client.userID,
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
      // Upstream r310: groepeer per account.
      groupKey: client.clientName,
      // Upstream r311-341: acties ALLEEN op bericht-types, via een switch.
      actions: switch (event.type) {
        EventTypes.Message ||
        EventTypes.Encrypted ||
        EventTypes.Sticker => <AndroidNotificationAction>[
          AndroidNotificationAction(
            PluslyNotificationActions.reply.name,
            l10n!.reply,
            inputs: [
              AndroidNotificationActionInput(label: l10n!.writeAMessage),
            ],
            allowGeneratedReplies: true,
            semanticAction: SemanticAction.reply,
          ),
          AndroidNotificationAction(
            PluslyNotificationActions.markAsRead.name,
            l10n!.markAsRead,
            semanticAction: SemanticAction.markAsRead,
          ),
          AndroidNotificationAction(
            PluslyNotificationActions.mute.name,
            l10n!.muteChat,
            semanticAction: SemanticAction.mute,
          ),
        ],
        _ => null,
      },
    );
    const iOSPlatformChannelSpecifics = DarwinNotificationDetails();
    return NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );
  }

  /// Creates a shortcut for Android platform but does not block displaying the
  /// notification. This is optional but provides a nicer view of the
  /// notification popup.
  Future<void> _setShortcut(String title, Uint8List? avatarFile) async {
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

  static Future<Uint8List?> _getAvatarFile(Client client, Uri? avatar) async {
    try {
      return avatar == null
          ? null
          : await client
                .downloadMxcCached(
                  avatar,
                  thumbnailMethod: ThumbnailMethod.crop,
                  width: notificationAvatarDimension,
                  height: notificationAvatarDimension,
                  animated: false,
                  isThumbnail: true,
                  rounded: true,
                )
                .timeout(const Duration(seconds: 3));
    } catch (e, s) {
      Logs().e('Unable to get avatar picture', e, s);
      return null;
    }
  }
}

/// Upstream r393-402: app-badge bijwerken.
void updateAppBadge(int unreadCount) {
  if (PlatformInfos.isAndroid || PlatformInfos.isMacOS || PlatformInfos.isIOS) {
    if (unreadCount == 0) {
      FlutterNewBadger.removeBadge();
    } else {
      FlutterNewBadger.setBadge(unreadCount);
    }
  }
}

/// Upstream r404-441: groeps-samenvattingsmelding op Android.
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

  if (activeNotifications.any(
    (notification) => notification.id == clientName.hashCode,
  )) {
    // Already have a visible summary notification!
    return;
  }

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