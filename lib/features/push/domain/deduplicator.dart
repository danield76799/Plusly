import 'dart:collection';

/// Deduplicatie service voor push notificaties.
/// 
/// Voorkomt dubbele notificaties door recente event IDs te tracken.
/// Gebruikt een LRU (Least Recently Used) cache met tijdsbeperking.
class PushDeduplicator {
  /// Hoe lang een event ID wordt onthouden (voorkomt herhaalde notificaties)
  static const Duration _window = Duration(minutes: 5);
  
  /// Maximale cache grootte
  static const int _maxSize = 100;
  
  /// Cache van recente event IDs → timestamp
  final _cache = <String, DateTime>{};
  
  /// Check of dit event al is verwerkt
  bool isDuplicate(String eventId) {
    _cleanup();
    
    if (_cache.containsKey(eventId)) {
      return true;
    }
    
    // Voeg toe aan cache
    _cache[eventId] = DateTime.now();
    
    // Beperk cache grootte
    while (_cache.length > _maxSize) {
      _cache.remove(_cache.keys.first);
    }
    
    return false;
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
  
  /// Reset cache (bijv. bij app restart)
  void clear() {
    _cache.clear();
  }
  
  /// Aantal entries in cache (voor debugging)
  int get size => _cache.length;
}
