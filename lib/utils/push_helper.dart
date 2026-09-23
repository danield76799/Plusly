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

/// FluffyChat-pariteit (upstream `push_helper.dart` r486-496,
/// `extension on PushNotification { int get notificationId }`):
/// ÉÉN canonieke notificatie-ID voor show() én élk cancel()-pad.
///
/// Waarom dit één functie moet zijn: Android past een `cancel(id)` alleen toe
/// op de melding met exact dat ID. Twee verschillende formules voor hetzelfde
/// kanaal betekenen dat een cancel de getoonde melding nooit raakt (melding
/// blijft staan) of juist een melding van een ánder account raakt. Afgeleid
/// van de opgeloste client i.p.v. de pusher-devicedata (`client_name`), omdat
/// Plusly's `setupPusher` die sleutel niet meestuurt — upstream's getter zou
/// hier stil terugvallen op de roomId-only variant, precies de oude bug.
int notificationIdFor(String? clientName, String? roomId) {
  if (roomId == null || roomId.isEmpty) return 0;
  if (clientName == null || clientName.isEmpty) return roomId.hashCode;
  return '${clientName}_$roomId'.hashCode;
}

/// Resolveert de l10n voor push-notificaties. Een detached/headless
/// push-engine krijgt de Android-locale-configuratie NIET mee (valt terug op
/// en_US), waardoor notificatie-teksten Engels waren op een Nederlands
/// toestel. De GUI persisteert zijn locale onder 'plusly_ui_locale'
/// (main.dart startGui); deze loader prefereert die. Val-back:
/// PlatformDispatcher-locale, zoals upstream FluffyChat.
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

class PushHelper {
  final PushNotification notification;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  final bool useNotificationActions;
  late Client client;
  late Event event;
  late bool isBackgroundMessage;
  L10n? l10n;

  PushHelper._(
    this.notification,
    this.flutterLocalNotificationsPlugin, {
    this.useNotificationActions = true,
  });

  static Future<void> pushHelper(
    PushNotification notification, {
    List<Client>? clients,
    L10n? l10n,
    String? activeRoomId,
    Client? activeClient,
    required FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin,
    String? instance,
    bool useNotificationActions = true,
  }) async {
    // FluffyChat-pariteit (upstream push_helper.dart r44-96): de hele helper
    // in een 30s-timeout met ÉÉN localized fallback-notificatie, en de
    // foreground-service wordt in de finally weer gestopt (r93-94).
    l10n ??= await loadPushL10n();
    try {
      // _newPushHandler geeft FutureOr<PushHelper?> terug; om .timeout te
      // kunnen gebruiken maken we hier expliciet een Future.
      final handler = await Future<PushHelper?>.value(
        _newPushHandler(
          notification,
          clients: clients,
          l10n: l10n,
          activeRoomId: activeRoomId,
          activeClient: activeClient,
          flutterLocalNotificationsPlugin: flutterLocalNotificationsPlugin,
          instance: instance,
          useNotificationActions: useNotificationActions,
        ),
      ).timeout(const Duration(seconds: 30));
      await handler?._showNotification();
    } catch (e, s) {
      Logs().e('Push Helper has crashed!', e, s);
      PushEventLog().add('push_crash', {
        'room': notification.roomId ?? '',
        'error': '$e',
      });
      if (notification.roomId != null) {
        await flutterLocalNotificationsPlugin.show(
          id: notificationIdFor(instance, notification.roomId),
          title: l10n.newMessageInFluffyChat,
          body: l10n.openAppToReadMessages,
          notificationDetails: NotificationDetails(
            iOS: DarwinNotificationDetails(
              threadIdentifier: '${instance}_${notification.roomId}',
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
              groupKey: instance,
            ),
          ),
        );
      }
      rethrow;
    } finally {
      // FluffyChat-pariteit (upstream push_helper.dart r93-94): de
      // background_push-service weer stoppen nu de helper klaar is (of
      // crashte). De refcount in ForegroundServices voorkomt dat een lopende
      // service van iets anders (bestand sturen, gesprek) gestopt wordt.
      await ForegroundServices.stopService('background_push');
    }
  }

  static FutureOr<PushHelper?> _newPushHandler(
    PushNotification notification, {
    List<Client>? clients,
    L10n? l10n,
    String? activeRoomId,
    Client? activeClient,
    required FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin,
    String? instance,
    bool useNotificationActions = true,
  }) async {
    final helper = PushHelper._(
      notification,
      flutterLocalNotificationsPlugin,
      useNotificationActions: useNotificationActions,
    );
    helper.l10n = l10n;

    try {
      helper.isBackgroundMessage = clients == null;
      Logs().v(
        'Push helper has been started (background=${helper.isBackgroundMessage}).',
        notification.toJson(),
      );

      clients ??= await ClientManager.getClients(
        initialize: false,
        store: await AppSettings.init(),
      );
      l10n ??= await loadPushL10n();

      final client = _clientFromInstance(instance, clients);
      if (client == null) {
        Logs().e('No client could be found for instance $instance');
        return null;
      }
      helper.client = client;

      // PLUSLY-CHANGE (multi-account, bewust afwijkend van upstream): staan
      // twee accounts in dezelfde room, dan tonen we één melding — de eerste
      // client die de room kent. Upstream is single-account
      // (`instances: ['default']`) en heeft dit vraagstuk niet.
      if (notification.roomId != null && clients.isNotEmpty) {
        final firstClientInRoom = clients.firstWhereOrNull(
          (c) => c.rooms.any((r) => r.id == notification.roomId),
        );
        if (firstClientInRoom != null && firstClientInRoom != client) {
          Logs().v(
            'Another client (${firstClientInRoom.clientName}) already handles '
            'notifications for room ${notification.roomId}. Skipping for ${client.clientName}.',
          );
          return null;
        }
      }

      // FluffyChat-pariteit (upstream push_helper.dart r191-196): zit de
      // gebruiker in die room én is de app op de voorgrond, dan geen
      // notificatie. PLUSLY-CHANGE: de activeClient-toets erbij, zodat een
      // account NIET de melding van een ander account onderdrukt.
      if (_isInForeground(notification, activeRoomId, activeClient, client)) {
        Logs().v(
          'Push foreground: suppress notification '
          'room=${notification.roomId} activeRoom=$activeRoomId '
          'activeClient=$activeClient notified=${client.clientName} '
          'lifecycle=${WidgetsBinding.instance.lifecycleState}',
        );
        PushEventLog().add('push_suppressed', {
          'room': notification.roomId ?? '',
          'activeRoom': activeRoomId ?? '',
          'lifecycle': WidgetsBinding.instance.lifecycleState.toString(),
        });
        return null;
      }

      // FluffyChat-pariteit (upstream r130-133): de push draagt de voorkeur
      // van de homeserver; meteen de badge bijwerken.
      updateAppBadge(notification.counts?.unread ?? 0);

      final event = await client.getEventByPushNotification(
        notification,
        // PLUSLY-CHANGE (bewust, commit 6e295baea): upstream gebruikt hier
        // `false`. Plusly zet het op `true` zodat een koud-gestart event wél
        // in de database belandt en de room hem direct toont. De SDK-vlag
        // raakt alléén de DB-opslag (client.dart:1932) — hij verklaart dus
        // GEEN gemiste of getoonde notificatie.
        storeInDatabase: true,
      );

      if (event == null) {
        // FluffyChat-pariteit (upstream r137-173): clearing-indicator.
        Logs().v(
          'Push event is null: clearing indicator '
          'room=${notification.roomId}',
        );
        PushEventLog().add('push_clearing', {
          'room': notification.roomId ?? '',
          'unread': '${notification.counts?.unread ?? 0}',
        });
        if (clients.length == 1 && notification.counts?.unread == 0) {
          // FluffyChat-pariteit (upstream r139-140): ALLEEN wissen bij één
          // account én unread==0. Upstream deed `unread == null || unread ==
          // 0` ongeacht het aantal accounts: een count-push waarvan UP het
          // unread-veld stripte, wiste dan élke actieve notificatie — de
          // melding was er even en verdween weer.
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
      helper.event = event;

      // PLUSLY-CHANGE (bewust): client-side push-rule evaluatie, crash-veilig.
      //
      // De SDK-evaluator (pushrule_evaluator.dart:389) doet
      // `event.room.client.userID!` — is client.userID null in een
      // background-context, dan crasht de evaluatie. Upstream laat de helper
      // dan in de buitenste catch belanden (generieke fallback-melding);
      // Plusly laat het event in dat geval DÓÓR, zodat de gebruiker de echte
      // afzender en inhoud ziet. Richting: deze tak kan alleen méér tonen,
      // nooit onderdrukken.
      if (!_shouldNotifyByPushRules(client, event)) {
        Logs().d(
          '[Push] Event gefilterd door client-side push rules '
          'room=${notification.roomId} type=${event.type}',
        );
        PushEventLog().add('push_rule_filtered', {
          'room': notification.roomId ?? '',
          'type': event.type,
        });
        return null;
      }

      Logs().v(
        'Push helper got notification event of type ${event.type}.',
      );
      PushEventLog().add('push_event', {
        'room': notification.roomId ?? '',
        'type': event.type,
      });
      return helper;
    } catch (e, s) {
      Logs().e('Push helper error', e, s);
      PushEventLog().add('push_error', {
        'room': notification.roomId ?? '',
        'error': '$e',
      });
      // PLUSLY-CHANGE: als het event niet gevonden kan worden (bijv. eigen
      // bericht dat nog onder transactie-ID staat i.p.v. event_id), toon dan
      // GEEN notificatie. Het bericht komt via sync toch wel in de app.
      if (e.toString().contains('Unable to find event')) {
        Logs().d(
          '[Push] Event niet gevonden, notificatie onderdrukt '
          'room=${notification.roomId}',
        );
        return null;
      }
      // FluffyChat upstream: rethrow — de buitenste pushHelper-catch toont
      // precies ÉÉN localized fallback-notificatie.
      rethrow;
    }
  }

  /// Selects the correct client from the list based on the instance string.
  /// Falls back to the first client if no instance is provided.
  static Client? _clientFromInstance(String? instance, List<Client> clients) {
    if (clients.isEmpty) return null;
    if (instance == null) return clients.first;
    return clients.firstWhereOrNull(
          (client) => client.clientName == instance,
        ) ??
        clients.first;
  }

  /// Client-side push-rule evaluatie, crash-veilig (zie de toelichting op de
  /// aanroep in [_newPushHandler]).
  static bool _shouldNotifyByPushRules(Client client, Event event) {
    try {
      return client.pushruleEvaluator.match(event).notify;
    } catch (e) {
      Logs().d(
        '[Push] Push-rule evaluatie crashte (userID null in background?), '
        'event doorgelaten room=${event.roomId}: $e',
      );
      PushEventLog().add('push_rule_eval_error', {
        'room': event.roomId ?? '',
        'error': '$e',
      });
      return true;
    }
  }

  Future<void> _showNotification() async {
    try {
      Logs().v(
        'Push showNotification start '
        'room=${notification.roomId} type=${event.type} '
        'lifecycle=${WidgetsBinding.instance.lifecycleState}',
      );
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

      // Calculate the body
      // FluffyChat-pariteit (upstream r201-210): een nog-versleuteld event
      // toont direct de generieke tekst. Upstream probeert GEEN ontsleuteling
      // na te jagen; Plusly deed dat (twee-fasen placeholder + retry) en is
      // hier teruggebracht op upstream-gedrag.
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

      await flutterLocalNotificationsPlugin.show(
        id: notificationId,
        title: title,
        body: body,
        notificationDetails: platformChannelSpecifics,
        payload: NotificationPushPayload(
          client.clientName,
          event.room.id,
          event.eventId,
        ).toString(),
      );

      // FluffyChat-pariteit (upstream r382-389): groeps-samenvatting op
      // Android bij 2+ actieve meldingen.
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
    } catch (e, s) {
      Logs().e('Push showNotification crashed', e, s);
      PushEventLog().add('push_error', {
        'room': notification.roomId ?? '',
        'error': '$e',
      });
      // FluffyChat upstream: rethrow — de buitenste pushHelper-catch toont
      // precies één localized fallback. Geen dubbele innerlijke handler.
      rethrow;
    }
  }

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
      // FluffyChat-pariteit (upstream r310): groepeer per account. De
      // clearing-scan en de samenvattings-melding filteren op deze sleutel,
      // dus dit moet exact de clientName zijn.
      groupKey: client.clientName,
      actions: event.type == EventTypes.RoomMember || !useNotificationActions
          ? null
          : <AndroidNotificationAction>[
              AndroidNotificationAction(
                PluslyNotificationActions.reply.name,
                l10n!.reply,
                inputs: [
                  AndroidNotificationActionInput(label: l10n!.writeAMessage),
                ],
                cancelNotification: false,
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
              ),
            ],
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

  static bool _isInForeground(
    PushNotification notification,
    String? activeRoomId,
    Client? activeClient,
    Client notifiedClient,
  ) {
    return notification.roomId != null &&
        activeRoomId == notification.roomId &&
        activeClient == notifiedClient &&
        WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed;
  }
}

/// FluffyChat-pariteit (upstream r393-402): app-badge bijwerken.
/// Crash-veilig: een badge is cosmetisch, een throw hier zou de hele
/// notificatie in de fallback-tak laten belanden.
void updateAppBadge(int unreadCount) {
  try {
    if (PlatformInfos.isAndroid || PlatformInfos.isMacOS || PlatformInfos.isIOS) {
      if (unreadCount == 0) {
        FlutterNewBadger.removeBadge();
      } else {
        FlutterNewBadger.setBadge(unreadCount);
      }
    }
  } catch (e) {
    Logs().d('[Push] badge kon niet bijgewerkt worden: $e');
  }
}

/// FluffyChat-pariteit (upstream r404-441): groeps-samenvattingsmelding op
/// Android. Bij 0 of 1 actieve meldingen in deze groep wissen we de
/// samenvatting; bij 2+ tonen we één Inbox-melding die als group summary
/// dient.
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
