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
}
