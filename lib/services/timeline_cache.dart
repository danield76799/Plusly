import 'dart:async';

import 'package:Pulsly/utils/client_download_content_extension.dart';
import 'package:matrix/matrix.dart';

class TimelineCache {
  static final Map<String, Timeline> _cache = {};
  // Track which avatars we've already kicked off a preload (dedup by room id).
  static final _avatarLoading = <String>{};

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

  /// Preload avatars for the first N rooms in the background.
  /// Kick off downloads early so profile pictures are ready the instant
  /// the chat list appears.  Duplicates are silently skipped.
  static Future<void> preloadAvatars(List<Room> rooms, {int limit = 40}) async {
    final toLoad = rooms
        .where((r) => r.isDirectChat || !r.isSpace)
        .take(limit)
        .toList();

    for (final room in toLoad) {
      if (_avatarLoading.contains(room.id)) continue;
      _avatarLoading.add(room.id);
      try {
        if (room.avatar == null) continue;
        // Fire-and-forget download. Cached copy is served instantly on next render.
        // Build #544 verified — this method works.
        unawaited(room.client.downloadMxcCached(room.avatar!, isThumbnail: true));
      } catch (_) {
        // not worth failing on — avatar will load later if needed
      }
    }
  }
}
