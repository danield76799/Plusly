
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
  static Future<void> preloadRooms(List<Room> rooms, {int limit = 40}) async {
    final toLoad = rooms
        .where((r) => r.isDirectChat || !r.isSpace)
        .take(limit)
        .toList();

    for (final room in toLoad) {
      try {
        final t = await room.getTimeline();
        _cache[room.id] = t;
      } catch (_) {
        // Skip rooms that fail — they'll load when the user opens them
      }
    }
  }
}
