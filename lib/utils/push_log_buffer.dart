import 'dart:collection';
import 'package:flutter/foundation.dart';

/// In-memory ring buffer for push diagnostic logs.
/// Stores the last [maxEntries] log entries so the user can view them
/// without ADB access.
class PushLogBuffer {
  static const int maxEntries = 200;

  static final PushLogBuffer _instance = PushLogBuffer._();
  static PushLogBuffer get instance => _instance;

  final Queue<LogEntry> _entries = Queue<LogEntry>();

  PushLogBuffer._();

  void i(String message) => _add('I', message);
  void w(String message) => _add('W', message);
  void e(String message) => _add('E', message);

  void _add(String level, String message) {
    _entries.add(LogEntry(
      timestamp: DateTime.now(),
      level: level,
      message: message,
    ));
    while (_entries.length > maxEntries) {
      _entries.removeFirst();
    }
    debugPrint('[PushLog] $level: $message');
  }

  List<LogEntry> get entries => _entries.toList();

  void clear() => _entries.clear();
}

class LogEntry {
  final DateTime timestamp;
  final String level;
  final String message;

  const LogEntry({
    required this.timestamp,
    required this.level,
    required this.message,
  });

  String get formatted {
    final t = '${timestamp.hour.toString().padLeft(2, '0')}:'
        '${timestamp.minute.toString().padLeft(2, '0')}:'
        '${timestamp.second.toString().padLeft(2, '0')}';
    return '$t [$level] $message';
  }
}
