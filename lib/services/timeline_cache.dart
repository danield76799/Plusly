
import 'package:matrix/matrix.dart';

class TimelineCache {
  // Map of roomId to its last known timeline
  static final Map<String, Timeline> _cache = {};

  static Timeline? getTimeline(String roomId) {
    return _cache[roomId];
  }

  static void setTimeline(String roomId, Timeline timeline) {
    _cache[roomId] = timeline;
  }

  static void clearTimeline(String roomId) {
    _cache.remove(roomId);
  }

  static void clearAll() {
    _cache.clear();
  }

  /// Preload the first N rooms' timelines in the background.
  /// Call this once at app startup (non-blocking).
  /// Loads in parallel batches of 10 to avoid overwhelming the server.
  static Future<void> preloadRooms(List<Room> rooms, {int limit = 40}) async {
    final toLoad = rooms
        .where((r) => r.isDirectChat || !r.isSpace)
        .take(limit)
        .toList();

    const batchSize = 10;
    for (var i = 0; i < toLoad.length; i += batchSize) {
      final batch = toLoad.skip(i).take(batchSize);
      final results = await Future.wait(
        batch.map((room) => room.getTimeline().then(
              (t) => MapEntry(room.id, t),
              onError: (_) => null,
            )),
        eagerError: false,
      );
      for (final entry in results) {
        if (entry != null) {
          _cache[entry.key] = entry.value;
        }
      }
    }
  }
}
