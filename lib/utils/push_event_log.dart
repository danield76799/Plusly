import 'dart:collection';

import 'package:shared_preferences/shared_preferences.dart';

class PushEventLog {
  static final PushEventLog _instance = PushEventLog._internal();
  factory PushEventLog() => _instance;
  PushEventLog._internal();

  static const _key = 'plusly_push_event_log';
  static const int _maxEvents = 80;

  final List<Map<String, String>> _events = [];

  void add(String kind, Map<String, String> extra) {
    _events.add({
      'ts': DateTime.now().toIso8601String(),
      'kind': kind,
      ...extra,
    });
    if (_events.length > _maxEvents) _events.removeRange(0, _events.length - _maxEvents);
    _persist();
  }

  List<Map<String, String>> get events => List.unmodifiable(_events);

  Future<void> clear() async {
    _events.clear();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }

  Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(
        _key,
        _events
            .map((e) => '${e['ts']}|${e['kind']}|${e.entries.where((x) => x.key != 'ts' && x.key != 'kind').map((x) => '${x.key}=${x.value}').join('&')}')
            .toList(),
      );
    } catch (_) {}
  }

  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getStringList(_key);
      if (raw == null) return;
      _events.clear();
      for (final line in raw) {
        final parts = line.split('|').toList();
        if (parts.length < 3) continue;
        final ts = parts[0];
        final kind = parts[1];
        final extraStr = parts.sublist(2).join('|');
        final map = <String, String>{'ts': ts, 'kind': kind};
        if (extraStr.isNotEmpty) {
          for (final kv in extraStr.split('&')) {
            final idx = kv.indexOf('=');
            if (idx <= 0) continue;
            map[kv.substring(0, idx)] = kv.substring(idx + 1);
          }
        }
        _events.add(map);
      }
    } catch (_) {}
  }
}
