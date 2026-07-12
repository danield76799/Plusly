import 'dart:async';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Deduplicatie service voor push notificaties.
///
/// Voorkomt dubbele notificaties door recente event IDs te tracken.
/// Gebruikt een persistente opslag (SharedPreferences) zodat deduplicatie
/// ook werkt na een app restart of tussen background-fetch en foreground app.
class PushDeduplicator {
  /// Hoe lang een event ID wordt onthouden
  static const Duration _window = Duration(minutes: 5);

  /// Maximale cache grootte
  static const int _maxSize = 200;

  /// SharedPreferences key voor de cache
  static const String _cacheKey = 'push_dedup_cache_v2';

  SharedPreferences? _store;
  Map<String, DateTime> _cache = {};
  Timer? _saveTimer;

  /// Initialiseer met SharedPreferences
  Future<void> init() async {
    _store ??= await SharedPreferences.getInstance();
    _load();
    _cleanup();
  }

  /// Check of dit event al is verwerkt
  bool isDuplicate(String eventId) {
    // Lege of onbekende event IDs worden nooit als duplicate beschouwd
    // (voorkomt dat alle onbekende pushes als "dezelfde" worden gezien)
    if (eventId.isEmpty) return false;

    if (_cache.containsKey(eventId)) {
      // Update timestamp (LRU)
      _cache[eventId] = DateTime.now();
      _scheduleSave();
      return true;
    }

    // Voeg toe aan cache
    _cache[eventId] = DateTime.now();

    // Beperk cache grootte — verwijder oudste
    while (_cache.length > _maxSize) {
      final oldest = _cache.entries
          .reduce((a, b) => a.value.isBefore(b.value) ? a : b);
      _cache.remove(oldest.key);
    }

    _scheduleSave();
    return false;
  }

  /// Plan een save (debounced — niet elke push een disk write)
  void _scheduleSave() {
    _saveTimer?.cancel();
    _saveTimer = Timer(const Duration(seconds: 1), _save);
  }

  void _load() {
    try {
      final raw = _store?.getString(_cacheKey);
      if (raw == null) return;
      final decoded = json.decode(raw) as Map<String, dynamic>;
      _cache = decoded.map(
        (k, v) => MapEntry(k, DateTime.fromMillisecondsSinceEpoch(v as int)),
      );
    } catch (_) {
      _cache = {};
    }
  }

  Future<void> _save() async {
    try {
      final encoded = json.encode(
        _cache.map((k, v) => MapEntry(k, v.millisecondsSinceEpoch)),
      );
      await _store?.setString(_cacheKey, encoded);
    } catch (_) {}
  }

  /// Verwijder oude entries
  void _cleanup() {
    final now = DateTime.now();
    final expired = _cache.entries
        .where((e) => now.difference(e.value) > _window)
        .map((e) => e.key)
        .toList();

    for (final key in expired) {
      _cache.remove(key);
    }
  }

  /// Reset cache
  void clear() {
    _cache.clear();
    _store?.remove(_cacheKey);
  }

  /// Aantal entries in cache (voor debugging)
  int get size => _cache.length;
}
