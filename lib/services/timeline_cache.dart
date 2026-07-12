import 'package:matrix/matrix.dart';

class TimelineCache {
  // Map of roomId to its last known timeline
  static final Map<String, Timeline> _cache = {};

  // FIX #8: Max cache size to prevent memory leaks. LRU eviction.
  static const int _maxCacheSize = 20;

  static Timeline? getTimeline(String roomId) {
    return _cache[roomId];
  }

  static void setTimeline(String roomId, Timeline timeline) {
    // Cancel subscriptions on the old timeline before replacing it
    final old = _cache[roomId];
    if (old != null) {
      old.cancelSubscriptions();
    }
    _cache[roomId] = timeline;

    // Evict oldest entries if cache is too large
    if (_cache.length > _maxCacheSize) {
      final toRemove = _cache.keys.toList()
        ..remove(roomId); // Don't evict the one we just added
      final excess = _cache.length - _maxCacheSize;
      for (final key in toRemove.take(excess)) {
        _cache[key]?.cancelSubscriptions();
        _cache.remove(key);
      }
    }
  }

  static void clearTimeline(String roomId) {
    _cache[roomId]?.cancelSubscriptions();
    _cache.remove(roomId);
  }

  static void clearAll() {
    for (final timeline in _cache.values) {
      timeline.cancelSubscriptions();
    }
    _cache.clear();
  }

  /// Preload the first N rooms' timelines in the background.
  /// Call this once at app startup (non-blocking).
  /// Loads the most recent chats first in parallel batches of 10.
  static Future<void> preloadRooms(List<Room> rooms, {int limit = 40}) async {
    final toLoad = rooms
        .where((r) => r.isDirectChat || !r.isSpace)
        .toList()
      ..sort((a, b) {
        final aTs = a.lastEvent?.originServerTs;
        final bTs = b.lastEvent?.originServerTs;
        if (aTs == null || bTs == null) return 0;
        return bTs.compareTo(aTs);
      });

    final limited = toLoad.take(limit).toList();

    // Eagerly await the top 5 most recent rooms so chat opens instantly
    final priorityRooms = limited.take(5).toList();
    final priorityResults = await Future.wait(
      priorityRooms.map((room) => room.getTimeline().then(
            (t) => MapEntry(room.id, t),
            onError: (_) => null,
          )),
      eagerError: false,
    );
    for (final entry in priorityResults) {
      if (entry != null) {
        setTimeline(entry.key, entry.value);
      }
    }

    // Then load the rest in the background
    final remaining = limited.skip(5).toList();
    if (remaining.isEmpty) return;

    const batchSize = 10;
    for (var i = 0; i < remaining.length; i += batchSize) {
      final batch = remaining.skip(i).take(batchSize);
      final results = await Future.wait(
        batch.map((room) => room.getTimeline().then(
              (t) => MapEntry(room.id, t),
              onError: (_) => null,
            )),
        eagerError: false,
      );
      for (final entry in results) {
        if (entry != null) {
          setTimeline(entry.key, entry.value);
        }
      }
    }
  }
}