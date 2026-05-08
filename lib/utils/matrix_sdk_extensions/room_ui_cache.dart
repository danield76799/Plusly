import 'package:matrix/matrix.dart';
import '../bridge_utils.dart';

/// Extension on Room to cache expensive UI computations.
/// Call [invalidateUICache] when room data changes (sync updates).
extension RoomUICache on Room {
  String? _cachedDisplayname;
  String? _cachedLastMessage;
  bool? _cachedIsBridge;
  String? _cachedBridgeType;
  Uri? _cachedAvatar;
  int? _cachedUnreadCount;

  /// Cached displayname - avoids recomputing localized name on every build
  String getCachedDisplayname(MatrixLocals locals) {
    if (_cachedDisplayname == null) {
      _cachedDisplayname = getLocalizedDisplayname(locals);
    }
    return _cachedDisplayname!;
  }

  /// Cached last message preview - expensive string processing
  String? getCachedLastMessage(MatrixLocals locals, Event? lastEvent) {
    if (lastEvent == null) return null;
    if (_cachedLastMessage == null || _lastMessageEventId != lastEvent.eventId) {
      _lastMessageEventId = lastEvent.eventId;
      _cachedLastMessage = lastEvent.getLocalizedBody(
        locals,
        hideReply: true,
        hideEdit: true,
        plaintextBody: true,
        removeMarkdown: true,
      );
    }
    return _cachedLastMessage;
  }

  String? _lastMessageEventId;

  /// Cached bridge detection
  bool getCachedIsBridge() {
    _cachedIsBridge ??= isBridgeRoom(this);
    return _cachedIsBridge!;
  }

  /// Cached bridge type
  String? getCachedBridgeType() {
    if (_cachedIsBridge == null) {
      _cachedIsBridge = isBridgeRoom(this);
    }
    if (_cachedIsBridge! && _cachedBridgeType == null) {
      _cachedBridgeType = getBridgeType(this) ?? 'other';
    }
    return _cachedBridgeType;
  }

  /// Cached avatar URI
  Uri? getCachedAvatar() {
    _cachedAvatar ??= avatar;
    return _cachedAvatar;
  }

  /// Cached unread count (only recalculates when notification count changes)
  int getCachedUnreadCount() {
    if (_cachedUnreadCount != notificationCount) {
      _cachedUnreadCount = notificationCount;
    }
    return _cachedUnreadCount ?? 0;
  }

  /// Call this when room receives sync update to invalidate all caches
  void invalidateUICache() {
    _cachedDisplayname = null;
    _cachedLastMessage = null;
    _lastMessageEventId = null;
    _cachedIsBridge = null;
    _cachedBridgeType = null;
    _cachedAvatar = null;
    _cachedUnreadCount = null;
  }
}
