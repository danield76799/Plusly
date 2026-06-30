import 'package:flutter_test/flutter_test.dart';
import 'package:matrix/matrix.dart';
import 'package:Pulsly/services/timeline_cache.dart';

// Fake Timeline die de Timeline interface implementeert
class FakeTimeline implements Timeline {
  final String roomId;
  FakeTimeline(this.roomId);

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

    test('getTimeline na clearAll retourneert null', () {
      TimelineCache.setTimeline('!room:server', FakeTimeline('!room:server'));
      TimelineCache.clearAll();
      expect(TimelineCache.getTimeline('!room:server'), isNull);
    });
  });
}
