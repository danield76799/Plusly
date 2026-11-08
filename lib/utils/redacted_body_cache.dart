import 'dart:async';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Bewaart de originele tekst van berichten, zodat een verwijderd bericht
/// alsnog te lezen is.
///
/// Waarom dit nodig is: als een bericht wordt verwijderd (Matrix-redaction),
/// stript de SDK de inhoud van het event. In `matrix-dart-sdk` doet
/// `Event.setRedactionEvent()` dit:
///
/// ```dart
/// void setRedactionEvent(Event redactedBecause) {
///   unsigned = {'redacted_because': redactedBecause.toJson()};
///   prevContent = null;
///   ...
///   final contentKeyWhiteList = <String>[];   // leeg voor m.room.message
/// ```
///
/// Daarna is `content['body']` weg en levert `Event.body` de letterlijke
/// string `'Redacted'` op. De originele tekst is dan niet meer terug te
/// halen uit het event zelf.
///
/// Daarom bewaren we de body zodra we een bericht zien (`store`) en lezen we
/// die er weer uit op het moment dat het bericht verwijderd blijkt (`lookup`).
/// De cache wordt ongeveer twee weken bewaard in SharedPreferences, zodat een
/// bericht ook na een app-herstart nog te herstellen is.
///
/// Let op: net als de conceptberichten (`draft_<roomId>` in SharedPreferences)
/// staat hier de berichttekst onversleuteld lokaal op het toestel.
class RedactedBodyCache {
  RedactedBodyCache._();

  static final RedactedBodyCache instance = RedactedBodyCache._();

  static const String _prefsKey = 'redacted_body_cache_v1';

  /// Maximaal aantal bewaarde berichten. Bij overschrijding verdwijnt het
  /// oudste (insertion order), zodat het geheugengebruik begrensd blijft.
  static const int _maxEntries = 500;

  /// Een bericht blijft maximaal dit aantal dagen terugvindbaar.
  static const int _maxAgeDays = 14;

  final Map<String, _CacheEntry> _entries = {};

  SharedPreferences? _prefs;
  bool _loaded = false;
  Timer? _saveTimer;
  bool _dirty = false;

  /// Haalt de body van een event op uit de cache.
  ///
  /// Geeft null terug als de body nooit bewaard is (bijvoorbeeld omdat het
  /// bericht al verwijderd was voordat de app het ooit zag).
  String? lookup(String key) {
    _ensureLoaded();
    final entry = _entries[key];
    if (entry == null) return null;
    if (entry.isExpired) {
      _entries.remove(key);
      _scheduleSave();
      return null;
    }
    return entry.body;
  }

  /// Bewaart de body van een event.
  void store(String key, String body) {
    if (body.isEmpty) return;
    _ensureLoaded();
    if (_entries.containsKey(key)) return;
    _entries[key] = _CacheEntry(body, DateTime.now());
    if (_entries.length > _maxEntries) {
      // Oudste eerst weg (LinkedHashMap bewaart de invoervolgorde).
      _entries.remove(_entries.keys.first);
    }
    _scheduleSave();
  }

  /// Haalt de cache op uit SharedPreferences (eenmalig, lui).
  void _ensureLoaded() {
    if (_loaded) return;
    _loaded = true;
    _prefs = null;
    unawaited(_loadFromPrefs());
  }

  Future<void> _loadFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _prefs = prefs;
      final raw = prefs.getString(_prefsKey);
      if (raw == null || raw.isEmpty) return;
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return;
      final now = DateTime.now();
      decoded.forEach((key, value) {
        if (value is! Map) return;
        final body = value['body'];
        final ts = value['ts'];
        if (body is! String || ts is! int) return;
        final saved = DateTime.fromMillisecondsSinceEpoch(ts);
        if (now.difference(saved).inDays > _maxAgeDays) return;
        _entries[key] = _CacheEntry(body, saved);
      });
    } catch (_) {
      // Cache is een extraatje: als het niet lukt, gaat de app gewoon door.
    }
  }

  void _scheduleSave() {
    _dirty = true;
    _saveTimer?.cancel();
    _saveTimer = Timer(const Duration(seconds: 5), _save);
  }

  Future<void> _save() async {
    if (!_dirty) return;
    _dirty = false;
    try {
      final prefs = _prefs ?? await SharedPreferences.getInstance();
      _prefs = prefs;
      final now = DateTime.now();
      final payload = <String, dynamic>{};
      _entries.forEach((key, entry) {
        if (now.difference(entry.savedAt).inDays <= _maxAgeDays) {
          payload[key] = {
            'body': entry.body,
            'ts': entry.savedAt.millisecondsSinceEpoch,
          };
        }
      });
      await prefs.setString(_prefsKey, jsonEncode(payload));
    } catch (_) {
      // Opslagfout mag de app niet laten crashen.
    }
  }

  /// Maakt de cache direct schrijfbaar (bij app-achtergrond).
  Future<void> flush() async {
    _saveTimer?.cancel();
    await _save();
  }
}

class _CacheEntry {
  final String body;
  final DateTime savedAt;
  const _CacheEntry(this.body, this.savedAt);

  bool get isExpired =>
      DateTime.now().difference(savedAt).inDays > RedactedBodyCache._maxAgeDays;
}

/// Samenstelt de cache-sleutel voor een bericht.
///
/// Event-id's zijn uniek, maar niet over verschillende accounts heen. Daarom
/// nemen we de ruimte-id mee.
String redactedCacheKey(String roomId, String eventId) => '$roomId:$eventId';
