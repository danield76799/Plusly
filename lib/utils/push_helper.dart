// Push-afhandeling — FluffyChat-structuur.
//
// Herbouwd naar upstream FluffyChat (utils/push_helper.dart): één dunne
// wrapper met een 30s-timeout en precies één fallback-notificatie, en
// daarbinnen één lineaire flow:
//
//   client -> event ophalen -> push rules -> room-foreground -> tonen
//
// Plusly's versie was aangegroeid tot 799 regels met opeengestapelde
// correcties (fase-1 placeholder + ontsleutel-retry-lus + handmatige
// event_id-dedupe + geneste crash-handlers) die elkaar deels tegenspraken.
// Elke laag was een reactie op het symptoom van de vorige.
//
// Wat bewust van Plusly blijft — echte eisen, geen plasters:
// - meerdere accounts: de `instance`/clientName-selectie en de client-dedupe
//   in setupPusher. Upstream gaat uit van één account en leest clientName
//   uit de push zelf.
// - `notificationIdFor`: één ID-formule voor show én cancel, anders past
//   Android een cancel nooit toe en blijft de melding staan.
// - `loadPushL10n`: de headless engine krijgt de Android-locale niet mee;
//   zonder dit waren notificaties Engels op een Nederlands toestel.
// - `NotificationPushPayload` + `PluslyNotificationActions`: gebruikt door
//   notification_background_handler.dart (tap-afhandeling).
// - `_getAvatarFile` via Plusly's downloadMxcCached-extensie.
// - PushEventLog: het diagnoselog (zie push_event_log.dart).
//
// Vervallen t.o.v. de oude Plusly-versie:
// - de handmatige `_shownEventIds`-dedupe — upstream lost dubbele pushers op
//   in setupPusher door oude pushers te verwijderen, wat de oorzaak is i.p.v.
//   het symptoom
// - de gefaseerde placeholder + ontsleutel-retry-lus — upstream toont bij een
//   versleuteld event direct de generieke tekst en wacht niet op megolm
// - geneste crash-handlers — die gaven dubbele spook-notificaties

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:collection/collection.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_new_badger/flutter_new_badger.dart';
import 'package:flutter_shortcuts_new/flutter_shortcuts_new.dart';
import 'package:http/http.dart' as http;
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

/// Laatst ontvangen push per account (upstream FluffyChat gebruikt dit als
/// deduplicatie-signaal; hier voor diagnostiek en toekomstig gebruik).
final Map<String, DateTime> lastReceivedPushNotification = {};

Future<void> pushHelper(
  PushNotification notification, {
  List<Client>? clients,
  L10n? l10n,
  String? activeRoomId,
  Client? activeClient,
  String? instance,
  required FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin,
  bool useNotificationActions = true,
}) async {
  l10n ??= await loadPushL10n();

  try {
    // Upstream FluffyChat: de hele helper in één 30s-timeout. Loopt hij vast
    // — bijvoorbeeld op een megolm-sleutel die nooit komt — dan faalt hij
    // zichtbaar i.p.v. stil te blijven hangen.
    await _tryPushHelper(
      notification,
      clients: clients,
      l10n: l10n,
      activeRoomId: activeRoomId,
      activeClient: activeClient,
      instance: instance,
      flutterLocalNotificationsPlugin: flutterLocalNotificationsPlugin,
      useNotificationActions: useNotificationActions,
    ).timeout(const Duration(seconds: 30));
  } catch (e, s) {
    if (PlatformInfos.isAndroid &&
        e is! TimeoutException &&
        e is! IOException &&
        e is! http.ClientException) {
      Logs().e('Push Helper has crashed!', e, s);
      PushEventLog().add('push_crash', {
        'room': notification.roomId ?? '',
        'error': '$e',
      });
    }

    // Precies ÉÉN fallback-notificatie, alleen als er een room te openen is.
    // Een teller-push (geen roomId) heeft geen event om te tonen en mag hier
    // dus niets produceren.
    if (notification.roomId != null) {
      await flutterLocalNotificationsPlugin.show(
        id: notificationIdFor(instance, notification.roomId),
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
            category: AndroidNotificationCategory.message,
          ),
        ),
      );
    }
    rethrow;
  } finally {
    // Upstream: de background_push-service stoppen nu de helper klaar is (of
    // crashte). De refcount in ForegroundServices voorkomt dat een service
    // van een ander (bv. gesprek) meegestopt wordt.
    await ForegroundServices.stopService('background_push');
  }
}

Future<void> _tryPushHelper(
  PushNotification notification, {
  List<Client>? clients,
  L10n? l10n,
  String? activeRoomId,
  Client? activeClient,
  String? instance,
  required FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin,
  bool useNotificationActions = true,
}) async {
  final isBackgroundMessage = clients == null;
  Logs().v(
    'Push helper has been started (background=$isBackgroundMessage).',
    notification.toJson(),
  );

  // Upstream kiest de client op basis van de `client_name` uit de push zelf.
  // Plusly is multi-account en krijgt het instance mee uit de UP-callback;
  // die heeft voorrang, met clientName als terugval.
  final clientName = instance ?? notification.clientName;
  final store = await AppSettings.init();

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

  lastReceivedPushNotification[client.clientName] = DateTime.now();

  l10n ??= await loadPushL10n();

  Logs().v('Load event...');
  final event = await client.getEventByPushNotification(
    notification,
    // PLUSLY-CHANGE (commit 6e295baea): altijd in de DB opslaan. Bij
    // storeInDatabase:false werd het event wel getoond maar niet gepersisteerd;
    // het openen van de DM laadt de tijdlijn uit de DB (getEventList) en miste
    // het bericht dan tot een latere sync. De SDK retourneert het event in
    // beide gevallen — deze vlag gaat alleen over opslaan.
    storeInDatabase: true,
  );

  updateAppBadge(notification.counts?.unread ?? 0);

  if (event == null) {
    // Upstream: een push zonder event is een opruim-signaal — de server zegt
    // dat er niets ongelezen meer is. Geen notificatie tonen, alleen opruimen.
    Logs().v('Notification is a clearing indicator.');
    PushEventLog().add('push_clearing', {
      'room': notification.roomId ?? '',
      'unread': '${notification.counts?.unread ?? 0}',
    });
    if (clients?.length == 1 && (notification.counts?.unread == 0)) {
      await flutterLocalNotificationsPlugin.cancelAll();
    } else {
      // Zorg dat de client volledig geladen en gesynct is voordat we
      // notificaties opruimen.
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
              '${client.clientName}_${room.id}'.hashCode ==
              activeNotification.id,
        );
        if (room != null && !room.isUnreadOrInvited) {
          await flutterLocalNotificationsPlugin.cancel(
            id: activeNotification.id!,
          );
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

  Logs().v('Push helper got notification event of type ${event.type}.');

  // Upstream: client-side push-rule evaluatie. De server gebruikte dezelfde
  // ruleset om deze push te sturen; dit filtert o.a. gemute kamers en
  // mentions-only lokaal nog eens.
  if (!_shouldNotifyByPushRules(client, event)) {
    Logs().i('Push helper: filtered by client-side push rules.');
    PushEventLog().add('push_rule_filtered', {
      'room': notification.roomId ?? '',
      'type': event.type,
    });
    return;
  }

  // De gebruiker zit al in deze room met dit account: geen notificatie.
  final inForeground = notification.roomId != null &&
      activeRoomId == notification.roomId &&
      (activeClient == null || activeClient == client) &&
      WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed;
  if (inForeground) {
    Logs().v('Room is in foreground. Stop push helper here.');
    PushEventLog().add('push_suppressed', {
      'room': notification.roomId ?? '',
      'activeRoom': activeRoomId ?? '',
      'lifecycle': WidgetsBinding.instance.lifecycleState.toString(),
    });
    return;
  }

  final matrixLocals = MatrixLocals(l10n);

  // Body. Bij een nog-versleuteld event is er geen leesbare inhoud; upstream
  // toont dan de generieke tekst en wacht niet op de megolm-sleutel.
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

  final title = event.room.getLocalizedDisplayname(matrixLocals);
  final notificationId = notificationIdFor(client.clientName, event.room.id);

  PushEventLog().add('push_event', {
    'room': notification.roomId ?? '',
    'type': event.type,
  });

  await flutterLocalNotificationsPlugin.show(
    id: notificationId,
    title: PlatformInfos.isAndroid ? null : title,
    body: PlatformInfos.isAndroid ? null : body,
    notificationDetails: await _getPlatformChannelSpecifics(
      client,
      event,
      notification,
      flutterLocalNotificationsPlugin,
      notificationId,
      body,
      title,
      l10n,
      useNotificationActions: useNotificationActions,
    ),
    payload: NotificationPushPayload(
      client.clientName,
      event.room.id,
      event.eventId,
    ).toString(),
  );

  // Samenvattingsnotificatie op Android (upstream push_helper.dart:382-389).
  if (PlatformInfos.isAndroid) {
    await updateSummaryNotification(
      clientName: client.clientName,
      l10n: l10n,
      flutterLocalNotificationsPlugin: flutterLocalNotificationsPlugin,
    );
  }

  Logs().v('Push helper has been completed!');
  PushEventLog().add('push_shown', {
    'room': notification.roomId ?? '',
    'id': '$notificationId',
  });
}

/// Upstream FluffyChat: client-side push-rule evaluatie.
///
/// De SDK-evaluator (pushrule_evaluator.dart) doet
/// `event.room.client.userID!` — in de background/detached context is
/// client.userID NULL, waardoor de evaluator crasht. De homeserver heeft de
/// push rules AL toegepast toen hij besloot deze push te sturen, dus deze
/// evaluatie is een verfijning: als zij niet kan draaien laten we het event
/// DÓÓR in plaats van de notificatie te verliezen.
bool _shouldNotifyByPushRules(Client client, Event event) {
  try {
    return client.pushruleEvaluator.match(event).notify;
  } catch (e) {
    Logs().d(
      '[Push] Push-rule evaluatie faalde (userID null in background?), '
      'event doorgelaten room=${event.roomId}: $e',
    );
    PushEventLog().add('push_rule_eval_error', {
      'room': event.roomId ?? '',
      'error': '$e',
    });
    return true;
  }
}

Future<NotificationDetails> _getPlatformChannelSpecifics(
  Client client,
  Event event,
  PushNotification notification,
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin,
  int notificationId,
  String body,
  String title,
  L10n l10n, {
  required bool useNotificationActions,
}) async {
  final matrixLocals = MatrixLocals(l10n);

  final avatar = event.room.avatar;
  final senderAvatar = event.room.isDirectChat
      ? avatar
      : event.senderFromMemoryOrFallback.avatarUrl;

  final roomAvatarFile = await _getAvatarFile(client, avatar);
  final senderAvatarFile = event.room.isDirectChat
      ? roomAvatarFile
      : await _getAvatarFile(client, senderAvatar);

  final senderName = event.senderFromMemoryOrFallback.calcDisplayname();

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
            .getActiveNotificationMessagingStyle(id: notificationId)
      : null;
  messagingStyleInformation?.messages?.add(newMessage);

  final roomName = event.room.getLocalizedDisplayname(matrixLocals);
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
    actions: (event.type == EventTypes.RoomMember || !useNotificationActions)
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
            AndroidNotificationAction(
              PluslyNotificationActions.mute.name,
              l10n.muteChat,
            ),
          ],
  );

  if (PlatformInfos.isAndroid && messagingStyleInformation == null) {
    await _setShortcut(event, title, roomAvatarFile);
  }

  const iOSPlatformChannelSpecifics = DarwinNotificationDetails();
  return NotificationDetails(
    android: androidPlatformChannelSpecifics,
    iOS: iOSPlatformChannelSpecifics,
  );
}

/// Upstream FluffyChat (push_helper.dart:393-402).
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

/// Upstream FluffyChat (push_helper.dart:404-441).
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
    // Er staat al een samenvattingsnotificatie.
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

/// PLUSLY-CHANGE (FluffyChat-pariteit): resolveert de l10n voor push-
/// notificaties. Een detached/headless push-engine krijgt de Android-
/// locale-configuratie NIET mee (valt terug op en_US), waardoor
/// notificatie-teksten Engels waren op een Nederlands toestel. De GUI
/// persisteert zijn locale onder 'plusly_ui_locale' (main.dart startGui);
/// deze loader prefereert die. Val-back: PlatformDispatcher-locale,
/// zoals upstream FluffyChat.
Future<L10n> loadPushL10n() async {
  try {
    final store = await AppSettings.init();
    final code = store.getString('plusly_ui_locale');
    if (code != null && code.isNotEmpty) {
      return lookupL10n(Locale(code));
    }
  } catch (e) {
    Logs().d('[Push] opgeslagen locale niet gelezen: $e');
  }
  return lookupL10n(PlatformDispatcher.instance.locale);
}

/// Canonieke notificatie-ID, identiek aan FluffyChat's
/// `PushNotification.notificationId` en aan [BackgroundPush.cancelNotification]
/// en [notificationTapBackground].
///
/// Eén formule voor show én cancel: twee verschillende ID's voor hetzelfde
/// kanaal betekent dat Android een cancel nooit op de getoonde notificatie
/// toepast en de melding blijft staan. Bovendien overschrijft bij meerdere
/// accounts de notificatie van het ene account die van het andere in dezelfde
/// room als de clientnaam niet in de ID zit.
int notificationIdFor(String? clientName, String? roomId) {
  if (roomId == null) return 0;
  if (clientName == null) return roomId.hashCode;
  return '${clientName}_$roomId'.hashCode;
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

/// Creates a shortcut for Android platform but does not block displaying the
/// notification. This is optional but provides a nicer view of the
/// notification popup.
Future<void> _setShortcut(
  Event event,
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

extension on PushNotification {
  String? get clientName =>
      devices?.firstOrNull?.data?.tryGet<String>('client_name');
}

Future<Uint8List?> _getAvatarFile(Client client, Uri? avatar) async {
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
