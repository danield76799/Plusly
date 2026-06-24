import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:matrix/matrix.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Lightweight cache for the chat list so the app can display chats
/// instantly on startup while the Matrix SDK is still loading/syncing.
class ChatListCacheService {
  static const _key = 'chat_list_cache_v1';
  static const _maxItems = 20;

  static Future<void> saveRooms(List<Room> rooms) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final items = rooms
          .where((r) => r.isDirectChat || !r.isSpace)
          .take(_maxItems)
          .map((r) {
            final lastEvent = r.lastEvent;
            return {
              'id': r.id,
              'name': r.displayname,
              'avatarUrl': r.avatar?.toString(),
              'lastMessage': lastEvent?.body ?? '',
              'lastTimestamp': (lastEvent?.originServerTs as int?) ?? 0,
              'unread': r.isUnread,
              'notificationCount': r.notificationCount,
              'isDirectChat': r.isDirectChat,
              'isFavourite': r.isFavourite,
              'isMuted': r.pushRuleState != PushRuleState.notify,
            };
          })
          .toList();

      await prefs.setString(
        _key,
        jsonEncode({
          'rooms': items,
          'savedAt': DateTime.now().toIso8601String(),
        }),
      );
    } catch (e, stackTrace) {
      // Caching is best-effort; never crash the app.
      debugPrint('Failed to save chat list cache: $e\\n$stackTrace');
    }
  }

  static Future<List<Map<String, dynamic>>?> loadRooms() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_key);
      if (raw == null || raw.isEmpty) return null;
      final data = jsonDecode(raw) as Map<String, dynamic>;
      final rooms = (data['rooms'] as List?)?.cast<Map<String, dynamic>>();
      return rooms;
    } catch (e, stackTrace) {
      debugPrint('Failed to load chat list cache: $e\\n$stackTrace');
      return null;
    }
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
