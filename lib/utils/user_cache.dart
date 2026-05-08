import 'package:flutter/material.dart';
import 'package:matrix/matrix.dart';

/// Centralized user cache to avoid repeated fetchSenderUser() calls.
/// Attach to your Client or Matrix widget.
class UserCache {
  final Map<String, User> _users = {};
  final Map<String, Future<User>> _inFlight = {};

  /// Get cached user or null if not cached
  User? get(String userId) => _users[userId];

  /// Cache a user
  void cache(User user) {
    _users[user.userId] = user;
  }

  /// Fetch user with deduplication - multiple calls for same userId
  /// will share the same Future
  Future<User?> fetchOrGet(
    Client client,
    String userId,
    Room room,
  ) async {
    // Return cached immediately
    if (_users.containsKey(userId)) return _users[userId]!;

    // Deduplicate in-flight requests
    if (_inFlight.containsKey(userId)) {
      return _inFlight[userId];
    }

    final future = _fetchUser(client, userId, room);
    _inFlight[userId] = future;

    try {
      final user = await future;
      if (user != null) _users[userId] = user;
      return user;
    } finally {
      _inFlight.remove(userId);
    }
  }

  Future<User?> _fetchUser(Client client, String userId, Room room) async {
    // Don't fetch for own user - we already know it
    if (userId == client.userID) {
      return User(client.userID!, room: room);
    }

    // Try to get from room first (cheaper than network)
    final roomUser = await room.getUserById(userId);
    if (roomUser != null) return roomUser;

    // Fallback: fetch from server
    try {
      final profile = await client.getUserProfile(userId);
      return User(
        userId,
        room: room,
        displayName: profile.displayname,
        avatarUrl: profile.avatarUrl,
      );
    } catch (_) {
      return User(userId, room: room);
    }
  }

  /// Preload users for a list of events
  Future<void> preloadUsers(List<Event> events, Client client) async {
    final uniqueIds = events.map((e) => e.senderId).toSet();
    await Future.wait(
      uniqueIds.map((id) => fetchOrGet(client, id, events.first.room)),
    );
  }

  void clear() {
    _users.clear();
    _inFlight.clear();
  }
}
