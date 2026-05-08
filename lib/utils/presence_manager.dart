import 'dart:async';

import 'package:flutter/material.dart';
import 'package:matrix/matrix.dart';

/// Centralized presence manager that uses a single stream subscription
/// instead of one per widget.
class PresenceManager {
  final Client client;
  final Map<String, List<void Function(CachedPresence?)>> _listeners = {};
  StreamSubscription<CachedPresence>? _sub;
  final Map<String, CachedPresence?> _cache = {};

  PresenceManager(this.client) {
    _sub = client.onPresenceChanged.stream.listen((presence) {
      _cache[presence.userid] = presence;
      final callbacks = _listeners[presence.userid];
      callbacks?.forEach((cb) => cb(presence));
    });
  }

  /// Add a listener for a specific user's presence
  void addListener(
    String userId,
    void Function(CachedPresence?) callback,
  ) {
    _listeners.putIfAbsent(userId, () => []).add(callback);

    // Return cached value immediately if available
    if (_cache.containsKey(userId)) {
      callback(_cache[userId]);
      return;
    }

    // Fetch initial presence
    client.fetchCurrentPresence(userId).then((presence) {
      _cache[userId] = presence;
      callback(presence);
    });
  }

  /// Remove a specific listener
  void removeListener(
    String userId,
    void Function(CachedPresence?) callback,
  ) {
    _listeners[userId]?.remove(callback);
    if (_listeners[userId]?.isEmpty ?? false) {
      _listeners.remove(userId);
      _cache.remove(userId);
    }
  }

  /// Get cached presence without listening
  CachedPresence? getCached(String userId) => _cache[userId];

  void dispose() {
    _sub?.cancel();
    _listeners.clear();
    _cache.clear();
  }
}

/// Widget that uses PresenceManager instead of creating its own stream subscription
class PresenceBuilderOptimized extends StatefulWidget {
  final Widget Function(BuildContext context, CachedPresence? presence) builder;
  final String? userId;
  final Client? client;

  const PresenceBuilderOptimized({
    required this.builder,
    this.userId,
    this.client,
    super.key,
  });

  @override
  State<PresenceBuilderOptimized> createState =>
      _PresenceBuilderOptimizedState();
}

class _PresenceBuilderOptimizedState extends State<PresenceBuilderOptimized> {
  CachedPresence? _presence;
  PresenceManager? _manager;

  void _updatePresence(CachedPresence? presence) {
    if (!mounted) return;
    setState(() {
      _presence = presence;
    });
  }

  @override
  void initState() {
    super.initState();
    _init();
  }

  void _init() {
    final client = widget.client ?? Matrix.of(context).client;
    final userId = widget.userId;

    if (userId != null) {
      // Get or create the global PresenceManager
      _manager = PresenceManagerProvider.of(context);
      _manager?.addListener(userId, _updatePresence);
    }
  }

  @override
  void didUpdateWidget(PresenceBuilderOptimized oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.userId != widget.userId) {
      if (oldWidget.userId != null) {
        _manager?.removeListener(oldWidget.userId!, _updatePresence);
      }
      _init();
    }
  }

  @override
  void dispose() {
    if (widget.userId != null) {
      _manager?.removeListener(widget.userId!, _updatePresence);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.builder(context, _presence);
}

/// Provider widget to make PresenceManager available in the tree
class PresenceManagerProvider extends InheritedWidget {
  final PresenceManager manager;

  const PresenceManagerProvider({
    required this.manager,
    required super.child,
    super.key,
  });

  static PresenceManager of(BuildContext context) {
    final provider =
        context.dependOnInheritedWidgetOfExactType<PresenceManagerProvider>();
    assert(provider != null, 'No PresenceManagerProvider found in context');
    return provider!.manager;
  }

  @override
  bool updateShouldNotify(PresenceManagerProvider oldWidget) =>
      oldWidget.manager != manager;
}
