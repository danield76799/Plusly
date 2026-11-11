import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:matrix/matrix.dart';

import 'package:Pulsly/utils/badge_fixer.dart';
import 'package:Pulsly/utils/privacy_options.dart';
import 'package:Pulsly/utils/push_event_log.dart';
import 'package:Pulsly/utils/room_unread_extension.dart';
import 'package:Pulsly/widgets/matrix.dart';

/// De interface die [ChatReadMarker] nodig heeft van `ChatController`.
///
/// Een mixin kan niet `on ChatController` zijn én tegelijk door
/// `ChatController` via `with` worden opgenomen: dat is een circulaire
/// superinterface. Daarom staat hier een losse mixin die `ChatController`
/// óók via `with` opneemt. Zo kan [ChatReadMarker] in een apart bestand
/// wonen zonder dat `chat.dart` en dit bestand elkaar circulair importeren.
mixin ChatReadMarkerHost {
  Room get room;
  Timeline? get timeline;
  Client get sendingClient;
  String get roomId;
  String? get scrollUpBannerEventId;
  bool get isScrolledUp;
  void updateView();

  // Van State<...>:
  BuildContext get context;
  bool get mounted;
}

/// Lees-marker- en ongelezen-logica van `ChatController`.
///
/// Eerder stond dit midden in `chat.dart` (2779 regels). Dat is afgesplitst
/// naar een mixin zodat de lees-marker-logica — het versturen van de
/// `m.fully_read`-marker, de retry-loop, en de grens tussen gelezen en
/// ongelezen — op één plek staat en `chat.dart` kleiner en beter te overzien
/// is.
mixin ChatReadMarker on ChatReadMarkerHost {
  /// Bewaart de in-flight lees-marker zodat we er niet twee tegelijk sturen.
  Future<void>? _setReadMarkerFuture;

  String get readMarkerEventId => room.hasNewMessages ? room.fullyRead : '';

  /// Het event-id van het nieuwste bericht dat je zélf gelezen hebt,
  /// afgeleid uit je eigen read-receipts.
  ///
  /// Dit is betrouwbaarder dan [readMarkerEventId] voor de ongelezen-
  /// scheiding. `room.fullyRead` is de `m.fully_read`-marker en die loopt
  /// achter op de read-receipts: hij kan nog naar een bericht wijzen dat je
  /// al lang gelezen hebt. Dan stond er "4 ongelezen berichten" terwijl er
  /// in werkelijkheid 0 ongelezen waren. De eigen read-receipts zijn wél
  /// bijgewerkt zodra je een bericht leest.
  String? get lastOwnReadEventId {
    final tl = timeline;
    if (tl == null) return null;
    for (final event in tl.events) {
      // timeline.events is nieuwste-eerst; de eerste met een eigen receipt
      // is dus het laatst gelezen bericht.
      if (event.receipts.any((r) => r.user.senderId == sendingClient.userID)) {
        return event.eventId;
      }
    }
    return null;
  }

  /// Het event-id waarop de ongelezen-scheiding staat: het eerste bericht
  /// dat je bij het openen nog niet gezien had.
  ///
  /// Dit is een *snapshot* van het leespunt op het moment van openen. Dat
  /// moet een snapshot zijn en niet het live leespunt, want het gesprek
  /// wordt bij het openen meteen als gelezen gemarkeerd — met het live
  /// leespunt zou de scheiding dus binnen een seconde verdwijnen. WhatsApp
  /// laat de lijn staan zolang je in het gesprek bent, en dat is wat mensen
  /// verwachten: je wilt zien waar je gebleven was.
  String? unreadDividerEventId;

  /// Aantal berichten onder de ongelezen-scheiding — hetzelfde getal als in
  /// het label van de scheiding, maar dan als badge op de
  /// scroll-naar-onder-knop.
  final ValueNotifier<int> unreadCountNotifier = ValueNotifier<int>(0);

  /// Is dit event-id nog een lokale echo (door de server onbekend)?
  ///
  /// Lokale echo's krijgen een `~`-prefix (matrix-dart-sdk: client.dart
  /// generateUniqueTransactionId → sendEvent echo). Een `m.fully_read` op
  /// zo'n id negeert de server stil: hij kent het event niet. Gevolg was
  /// precies het gemeten gedrag (2026-10-01, unread=22 urenlang terug in de
  /// push-teller): lokaal gelezen, server bleef op de oude telling staan,
  /// en de volgende sync zette de kamers terug op ongelezen.
  static bool _isLocalEcho(String? id) =>
      id != null && id.startsWith('~');

  void setReadMarker({String? eventId}) {
    if (_setReadMarkerFuture != null) return;
    if (isScrolledUp) return;

    if (eventId == null &&
        !room.hasNewMessages &&
        room.notificationCount == 0 &&
        !room.markedUnread) {
      return;
    }

    // Do not send read markers when app is not in foreground
    if (kIsWeb && !Matrix.of(context).webHasFocus) return;
    if (!kIsWeb &&
        WidgetsBinding.instance.lifecycleState != AppLifecycleState.resumed) {
      return;
    }

    final timeline = this.timeline;
    if (timeline == null || timeline.events.isEmpty) return;

    // Optimistic local update: the server roundtrip can take seconds before
    // the next sync updates room.notificationCount / room.fullyRead. Reset
    // them now so the chat-list badge disappears immediately. This must run
    // for BOTH explicit (eventId given) and implicit (eventId == null, e.g.
    // on timeline load / scroll-to-bottom) calls, otherwise the badge stays
    // stale until the server sync arrives — which can be slow or fail.
    // Runs regardless of the "scroll up" banner below, so opening a room
    // always clears the unread badge even if older messages sit above the
    // read marker.
    var markerEventId = eventId ?? room.lastEvent?.eventId;
    // ECHO-GUARD: een lokale echo-ID kan niet naar de server. Is het laatste
    // event nog een echo, dan valt er in deze kamer nu op zijn minst een
    // eerder, wél-bekend event te vinden — gebruik dat. Bestaat dat niet
    // (echo is het énige event), dan is er niets te markeren; de badge reset
    // lokaal en de echte marker volgt na de send-bevestiging, die via
    // sendFuture.then → setReadMarker() opnieuw aankomt.
    if (_isLocalEcho(markerEventId)) {
      final serverEvent = timeline.events
          .where((e) => e.status.isSent || e.status.isSynced)
          .map((e) => e.eventId)
          .where((id) => !_isLocalEcho(id))
          .firstOrNull;
      if (serverEvent == null) {
        PushEventLog().add('read_marker', {
          'room': room.id,
          'result': 'overgeslagen-echo-zonder-server-event',
          'echo': markerEventId ?? '',
        });
        room.notificationCount = 0;
        updateView();
        return;
      }
      PushEventLog().add('read_marker', {
        'room': room.id,
        'result': 'echo-vervangen',
        'echo': markerEventId ?? '',
        'server_event': serverEvent,
      });
      markerEventId = serverEvent;
    }
    if (markerEventId != null) {
      room.notificationCount = 0;
      BadgeFixer.instance.bewaarLezing(room.id);
      unawaited(room.markeerLokaalGelezen());
      // Also persist locally so the badge stays 0 across rebuilds until the
      // server confirms with a sync.
      unawaited(
        room.client.setAccountDataPerRoom(
          room.client.userID!,
          room.id,
          'm.fully_read',
          {'event_id': markerEventId},
        ).catchError((e) {
          // GEMETEN (2026-10-02-log): de homeserver weigert m.fully_read via
          // de account-data-API met "M_BAD_JSON: Cannot set m.fully_read
          // through this API. Use /rooms/.../read_markers" — op ELKE kamer.
          // Dat is geen storing maar beleid: m.fully_read hoort via
          // /read_markers gezet te worden, en precies dát doet de retry-loop
          // hieronder altijd (result=ok in de log). Deze lokale poging is dus
          // per definitie fout — hij is alleen maar ruis — en logt daarom als
          // 'lokaal-overslaan' i.p.v. een schijnbare fout.
          PushEventLog().add('read_marker', {
            'room': room.id,
            'result': 'lokaal-overslaan',
            'reden': 'server-weigert-accountdata-m.fully_read',
          });
        }),
      );
      updateView();
    }

    // Don't send the actual server read marker if a "scroll up" banner is
    // shown (user hasn't seen messages above the marker yet). The optimistic
    // badge reset above already ran, so the chat list is cleared; the server
    // marker is simply deferred until the user scrolls up / taps the banner.
    if (scrollUpBannerEventId != null) {
      // Ook bij uitgestelde marker vastleggen dat de gebruiker deze kamer
      // geopend heeft, zodat de BadgeFixer terugzettingen corrigeert zolang
      // de banner actief is.
      BadgeFixer.instance.bewaarLezing(room.id);
      unawaited(room.markeerLokaalGelezen());
      return;
    }

    Logs().d('Set read marker...', eventId);
    // ignore: unawaited_futures
    _setReadMarkerFuture = _verstuurMarkerMetRetry(
      timeline,
      markerEventId,
    ).whenComplete(() {
      _setReadMarkerFuture = null;
    });

    if (timeline is RoomTimeline) {
      if (eventId == null || eventId == timeline.room.lastEvent?.eventId) {
        Matrix.of(
          context,
        ).backgroundPush?.cancelNotification(room.client, roomId);
        // This also cancels notifications for thread messages in this room.
      }
    }
  }

  /// Stuurt de server-marker met korte retry en zichtbare log.
  ///
  /// WAAROM. De vorige code stuurde de `/read_markers`-PUT fire-and-forget
  /// met alleen een `.catchError`-log in Logs(). Een stil-falende PUT
  /// (netwerkglitch op de bèta, bearer-wissel bij sync) bleef daardoor
  /// onzichtbaar — de server bleef de kamers op ongelezen zetten terwijl de
  /// app lokaal gelezen toonde. Nu: 3 pogingen met korte backoff, en elke
  /// uitkomst in de eventlog zodat een dump het bewijs levert.
  Future<void> _verstuurMarkerMetRetry(
    Timeline timeline,
    String? markerEventId,
  ) async {
    final pogingen = 3;
    for (var i = 1; i <= pogingen; i++) {
      try {
        await timeline
            .setReadMarker(
              eventId: markerEventId,
              public: shouldSendPublicReadReceipts(room.client, roomId),
            )
            .timeout(const Duration(seconds: 20));
        PushEventLog().add('read_marker', {
          'room': room.id,
          'event': markerEventId ?? '',
          'poging': '$i',
          'result': 'ok',
        });
        BadgeFixer.instance.bewaarLezing(room.id);
        unawaited(room.markeerLokaalGelezen());
        return;
      } catch (e, s) {
        // Netwerk-errors zijn verwachtbaar; echte bugs (onverwachte types)
        // mogen ook in de console-log, voor het geval er iets dieper zit.
        if (i == pogingen) {
          PushEventLog().add('read_marker', {
            'room': room.id,
            'event': markerEventId ?? '',
            'pogingen': '$pogingen',
            'result': 'mislukt',
            'fout': '$e',
          });
          Logs().w('setReadMarker failed after $pogingen tries', e, s);
          return;
        }
        Logs().w('setReadMarker attempt $i/$pogingen failed', e, s);
        await Future.delayed(Duration(seconds: 2 * i));
        if (!mounted) return;
      }
    }
  }
}
