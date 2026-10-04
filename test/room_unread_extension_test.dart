import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:matrix/matrix.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:Pulsly/utils/room_unread_extension.dart';

/// Mock-room met minimaal gedrag om `RoomUnreadX` te testen.
class _FakeRoom implements Room {
  @override
  final String id;
  @override
  int notificationCount;
  @override
  int highlightCount;
  @override
  Event? lastEvent;
  @override
  bool markedUnread;

  _FakeRoom({
    required this.id,
    this.notificationCount = 0,
    this.highlightCount = 0,
    this.lastEvent,
    this.markedUnread = false,
  });

  @override
  bool get isUnread => notificationCount > 0 || markedUnread;

  @override
  bool get hasNewMessages => notificationCount > 0; // vereenvoudigd

  // Nodig omdat Room veel meer heeft; alles wat niet gebruikt wordt krijgt
  // een ongebruikt object. We gebruiken noSuchMethod om de test compact te
  // houden.
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeEvent implements Event {
  @override
  final DateTime originServerTs;

  _FakeEvent(this.originServerTs);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    // De statische cache leeft over testgrenzen heen; zonder deze reset
    // lekt een lees-moment van de ene test naar de volgende.
    RoomUnreadX.debugClearCache();
  });

  test('geen lokale lees-tijd: valt terug op SDK-status', () async {
    final room = _FakeRoom(
      id: '!a:server',
      notificationCount: 5,
      lastEvent: _FakeEvent(DateTime(2026, 10, 4, 12)),
    );

    expect(room.isEffectivelyUnreadSync, true);
    expect(await room.isEffectivelyUnread, true);
    expect(room.effectiveNotificationCountSync, 5);
    expect(await room.effectiveNotificationCount, 5);
  });

  test('lokaal gelezen, geen nieuw event = forceren gelezen', () async {
    final room = _FakeRoom(
      id: '!b:server',
      notificationCount: 299,
      lastEvent: _FakeEvent(DateTime(2026, 10, 3, 12)),
    );
    await room.markeerLokaalGelezen();

    expect(room.isEffectivelyUnreadSync, false);
    expect(await room.isEffectivelyUnread, false);
    expect(room.effectiveNotificationCountSync, 0);
    expect(await room.effectiveNotificationCount, 0);
  });

  test('lokaal gelezen, maar WEL nieuw event na lezen = nog ongelezen', () async {
    final leesMoment = DateTime(2026, 10, 4, 12, 0, 0);
    final room = _FakeRoom(
      id: '!c:server',
      notificationCount: 3,
      lastEvent: _FakeEvent(leesMoment.subtract(const Duration(minutes: 5))),
    );

    // Overschrijf het cache-moment expliciet naar het bekende leesmoment,
    // want markeerLokaalGelezen gebruikt DateTime.now() in de echte code.
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('plusly_last_read_v1_!c:server', leesMoment.toIso8601String());

    // Simuleer een nieuw bericht dat na het lezen binnenkomt.
    room.lastEvent = _FakeEvent(leesMoment.add(const Duration(minutes: 5)));
    room.notificationCount = 1;

    expect(room.isEffectivelyUnreadSync, true);
    expect(await room.isEffectivelyUnread, true);
    expect(room.effectiveNotificationCountSync, 1);
    expect(await room.effectiveNotificationCount, 1);
  });

  test('markedUnread wordt ook onderdrukt als event oud is', () async {
    final room = _FakeRoom(
      id: '!d:server',
      notificationCount: 0,
      markedUnread: true,
      lastEvent: _FakeEvent(DateTime(2026, 10, 2, 10)),
    );
    await room.markeerLokaalGelezen();

    expect(room.isEffectivelyUnreadSync, false);
    expect(await room.isEffectivelyUnread, false);
  });

  test('verwijderLokaalGelezen maakt de override ongedaan', () async {
    final room = _FakeRoom(
      id: '!e:server',
      notificationCount: 42,
      lastEvent: _FakeEvent(DateTime(2026, 10, 1, 8)),
    );
    await room.markeerLokaalGelezen();
    await room.verwijderLokaalGelezen();

    expect(room.isEffectivelyUnreadSync, true);
    expect(await room.isEffectivelyUnread, true);
    expect(room.effectiveNotificationCountSync, 42);
    expect(await room.effectiveNotificationCount, 42);
  });

  test('persistente cache overleeft herinstantiëring', () async {
    final room1 = _FakeRoom(
      id: '!f:server',
      notificationCount: 100,
      lastEvent: _FakeEvent(DateTime(2026, 9, 1)),
    );
    await room1.markeerLokaalGelezen();

    // Nieuwe fake-room instantie met zelfde id leest dezelfde SharedPreferences.
    final room2 = _FakeRoom(
      id: '!f:server',
      notificationCount: 100,
      lastEvent: _FakeEvent(DateTime(2026, 9, 1)),
    );

    expect(room2.isEffectivelyUnreadSync, false);
    expect(await room2.isEffectivelyUnread, false);
  });

  test('koude start zonder hydrate: override is leeg (regressie-bewijs)',
      () async {
    final room1 = _FakeRoom(
      id: '!g:server',
      notificationCount: 299,
      lastEvent: _FakeEvent(DateTime(2026, 9, 1)),
    );
    await room1.markeerLokaalGelezen();

    // Simuleer een échte herstart: het proces-geheugen is weg, alleen
    // SharedPreferences blijft. De vorige test kon dit niet aantonen omdat
    // de statische cache binnen hetzelfde proces blijft leven.
    RoomUnreadX.debugClearCache();

    final room2 = _FakeRoom(
      id: '!g:server',
      notificationCount: 299,
      lastEvent: _FakeEvent(DateTime(2026, 9, 1)),
    );

    // Dit was de bug: zonder hydrate valt de UI terug op de SDK-teller en
    // toont de kamer weer als ongelezen.
    expect(room2.isEffectivelyUnreadSync, true);
    expect(room2.effectiveNotificationCountSync, 299);
  });

  test('hydrate() herstelt de override na een koude start', () async {
    final room1 = _FakeRoom(
      id: '!h:server',
      notificationCount: 463,
      lastEvent: _FakeEvent(DateTime(2026, 9, 1)),
    );
    await room1.markeerLokaalGelezen();

    // Herstart: geheugen leeg, SharedPreferences intact.
    RoomUnreadX.debugClearCache();
    await RoomUnreadX.hydrate();

    final room2 = _FakeRoom(
      id: '!h:server',
      notificationCount: 463,
      lastEvent: _FakeEvent(DateTime(2026, 9, 1)),
    );

    expect(room2.isEffectivelyUnreadSync, false);
    expect(room2.effectiveNotificationCountSync, 0);
    expect(await room2.isEffectivelyUnread, false);
  });

  test('hydrate() laat een nieuw event na het lees-moment intact', () async {
    final leesMoment = DateTime(2026, 9, 1, 12);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'plusly_last_read_v1_!i:server',
      leesMoment.toIso8601String(),
    );

    RoomUnreadX.debugClearCache();
    await RoomUnreadX.hydrate();

    final room = _FakeRoom(
      id: '!i:server',
      notificationCount: 2,
      lastEvent: _FakeEvent(leesMoment.add(const Duration(hours: 1))),
    );

    expect(room.isEffectivelyUnreadSync, true);
    expect(room.effectiveNotificationCountSync, 2);
  });

  test('hydrate() negeert corrupte waarden zonder te gooien', () async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('plusly_last_read_v1_!j:server', 'geen-datum');
    await prefs.setString(
      'plusly_last_read_v1_!k:server',
      DateTime(2026, 9, 1).toIso8601String(),
    );

    RoomUnreadX.debugClearCache();
    await RoomUnreadX.hydrate();

    final corrupt = _FakeRoom(
      id: '!j:server',
      notificationCount: 5,
      lastEvent: _FakeEvent(DateTime(2026, 8, 1)),
    );
    final gezond = _FakeRoom(
      id: '!k:server',
      notificationCount: 5,
      lastEvent: _FakeEvent(DateTime(2026, 8, 1)),
    );

    // Corrupte regel valt terug op SDK-status; gezonde regel doet mee.
    expect(corrupt.isEffectivelyUnreadSync, true);
    expect(gezond.isEffectivelyUnreadSync, false);
  });

  test('markeerLokaalGelezenVoor werkt op id (BadgeFixer-pad)', () async {
    RoomUnreadX.debugClearCache();
    await RoomUnreadX.markeerLokaalGelezenVoor('!l:server');

    final room = _FakeRoom(
      id: '!l:server',
      notificationCount: 81,
      lastEvent: _FakeEvent(DateTime(2026, 8, 1)),
    );

    expect(room.isEffectivelyUnreadSync, false);
    expect(RoomUnreadX.leesTijdSync('!l:server'), isNotNull);
  });
}
