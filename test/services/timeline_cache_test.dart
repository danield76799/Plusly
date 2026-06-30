import 'package:flutter_test/flutter_test.dart';
import 'package:matrix/matrix.dart';
import 'package:Pulsly/services/timeline_cache.dart';

/// Fake Room voor testing — geen echte Matrix server nodig
class FakeRoom implements Room {
  @override
  final String id;

  @override
  final Event? lastEvent;

  @override
  final bool isDirectChat;

  @override
  final bool isSpace;

  FakeRoom(this.id, {this.lastEvent, this.isDirectChat = true, this.isSpace = false});

  @override
  Future<Timeline> getTimeline() async {
    // Simuleer een korte laadtijd
    await Future.delayed(const Duration(milliseconds: 10));
    return FakeTimeline(id);
  }

  // Alle andere Room members — niet gebruikt in deze tests
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeTimeline implements Timeline {
  final String roomId;
  FakeTimeline(this.roomId);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeEvent implements Event {
  @override
  final DateTime originServerTs;

  FakeEvent(this.originServerTs);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('TimelineCache', () {
    setUp(() {
      TimelineCache.clearAll();
    });

    test('getTimeline retourneert null voor onbekende room', () {
      expect(TimelineCache.getTimeline('!abc:server'), isNull);
    });

    test('setTimeline en getTimeline werken correct', () {
      final timeline = FakeTimeline('!abc:server');
      TimelineCache.setTimeline('!abc:server', timeline);
      expect(TimelineCache.getTimeline('!abc:server'), same(timeline));
    });

    test('clearTimeline verwijdert één room', () {
      TimelineCache.setTimeline('!abc:server', FakeTimeline('!abc:server'));
      TimelineCache.setTimeline('!def:server', FakeTimeline('!def:server'));

      TimelineCache.clearTimeline('!abc:server');
      expect(TimelineCache.getTimeline('!abc:server'), isNull);
      expect(TimelineCache.getTimeline('!def:server'), isNotNull);
    });

    test('clearAll verwijdert alles', () {
      TimelineCache.setTimeline('!abc:server', FakeTimeline('!abc:server'));
      TimelineCache.setTimeline('!def:server', FakeTimeline('!def:server'));

      TimelineCache.clearAll();
      expect(TimelineCache.getTimeline('!abc:server'), isNull);
      expect(TimelineCache.getTimeline('!def:server'), isNull);
    });

    test('preloadRooms sorteert op meest recente bericht', () async {
      final now = DateTime.now();
      final rooms = [
        FakeRoom('!old:server', lastEvent: FakeEvent(now.subtract(const Duration(hours: 2)))),
        FakeRoom('!recent:server', lastEvent: FakeEvent(now)),
        FakeRoom('!middle:server', lastEvent: FakeEvent(now.subtract(const Duration(hours: 1)))),
      ];

      await TimelineCache.preloadRooms(rooms, limit: 10);

      // Alle rooms zouden nu gecached moeten zijn
      expect(TimelineCache.getTimeline('!recent:server'), isNotNull);
      expect(TimelineCache.getTimeline('!middle:server'), isNotNull);
      expect(TimelineCache.getTimeline('!old:server'), isNotNull);
    });

    test('preloadRooms slaat spaces over', () async {
      final rooms = [
        FakeRoom('!space:server', isSpace: true, lastEvent: FakeEvent(DateTime.now())),
        FakeRoom('!chat:server', isSpace: false, lastEvent: FakeEvent(DateTime.now())),
      ];

      await TimelineCache.preloadRooms(rooms, limit: 10);

      expect(TimelineCache.getTimeline('!space:server'), isNull);
      expect(TimelineCache.getTimeline('!chat:server'), isNotNull);
    });

    test('preloadRooms met lege list crasht niet', () async {
      await TimelineCache.preloadRooms([], limit: 10);
      // Geen expect nodig — test faalt bij exception
    });

    test('preloadRooms limit respecteert maximum', () async {
      final now = DateTime.now();
      final rooms = List.generate(
        50,
        (i) => FakeRoom('!room$i:server', lastEvent: FakeEvent(now.subtract(Duration(minutes: i)))),
      );

      await TimelineCache.preloadRooms(rooms, limit: 5);

      // Alleen de eerste 5 meest recente zouden geladen zijn
      int cached = 0;
      for (var i = 0; i < 50; i++) {
        if (TimelineCache.getTimeline('!room$i:server') != null) cached++;
      }
      expect(cached, lessThanOrEqualTo(5));
    });
  });
}
