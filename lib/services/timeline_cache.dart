
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
}
