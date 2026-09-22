import 'package:shared_preferences/shared_preferences.dart';

/// Diagnoselog voor push-afhandeling.
///
/// WAAROM TWEE RINGEN: lifecycle-events komen tientallen keren per push
/// (elke koude start schrijft inactive/hidden/paused/resumed), terwijl een
/// push zelf maar 4 regels kost. Één gedeelde buffer van 80 raakte daardoor
/// binnen ongeveer anderhalve minuut app-gebruik vol, waarna de pushes er
/// uitgerold werden — precies de informatie die je nodig hebt om te zien of
/// een afgeleverde push ook getoond is.
///
/// Nu: push-events krijgen een grote eigen ring, lifecycle een kleine. Ze
/// kunnen elkaar niet meer verdringen. Lifecycle wordt NIET weggegooid, want
/// het is het enige bewijs dat de headless engine überhaupt wakker werd.
class PushEventLog {
  static final PushEventLog _instance = PushEventLog._internal();
  factory PushEventLog() => _instance;
  PushEventLog._internal();

  static const _key = 'plusly_push_event_log';

  /// Push-events. Een werkdag met enkele honderden pushes past hierin.
  static const int maxPushEvents = 500;

  /// Lifecycle-events. Klein gehouden: ze zijn nuttig als context bij een
  /// push, niet als zelfstandige geschiedenis.
  static const int maxLifecycleEvents = 25;

  static const String _lifecycleKind = 'lifecycle';

  final List<Map<String, String>> _pushEvents = [];
  final List<Map<String, String>> _lifecycleEvents = [];

  void add(String kind, Map<String, String> extra) {
    final isLifecycle = kind == _lifecycleKind;
    final target = isLifecycle ? _lifecycleEvents : _pushEvents;
    final cap = isLifecycle ? maxLifecycleEvents : maxPushEvents;

    target.add({
      'ts': DateTime.now().toIso8601String(),
      'kind': kind,
      ...extra,
    });
    if (target.length > cap) {
      target.removeRange(0, target.length - cap);
    }
    _persist();
  }

  /// Push-events en lifecycle-events samen, chronologisch. Dit is wat het
  /// diagnosescherm toont: je ziet een push in context van de lifecycle.
  List<Map<String, String>> get events {
    final all = [..._pushEvents, ..._lifecycleEvents];
    all.sort((a, b) => (a['ts'] ?? '').compareTo(b['ts'] ?? ''));
    return List.unmodifiable(all);
  }

  /// Alleen de push-events, zonder lifecycle-ruis.
  List<Map<String, String>> get pushEvents => List.unmodifiable(_pushEvents);

  Future<void> clear() async {
    _pushEvents.clear();
    _lifecycleEvents.clear();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }

  Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_key, [
        ..._pushEvents.map((e) => _encode(e, 'p')),
        ..._lifecycleEvents.map((e) => _encode(e, 'l')),
      ]);
    } catch (_) {}
  }

  static String _encode(Map<String, String> e, String ring) {
    final body = e.entries
        .where((x) => x.key != 'ts' && x.key != 'kind')
        .map((x) => '${x.key}=${x.value}')
        .join('&');
    return '$ring|${e['ts']}|${e['kind']}|$body';
  }

  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getStringList(_key);
      if (raw == null) return;
      _pushEvents.clear();
      _lifecycleEvents.clear();
      for (final line in raw) {
        // Nieuw formaat: <ring>|<ts>|<kind>|<key=value&...>  → 4 delen.
        // Oud formaat:  <ts>|<kind>|<key=value&...>          → 3 delen.
        // (ts en kind bevatten zelf geen '|', dus het aantal delen is
        // betrouwbaar. Zonder deze splitsing zou bij een oude regel de
        // timestamp als ring gelezen worden en verdween de geschiedenis.)
        final parts = line.split('|').toList();
        final isNewFormat =
            parts.length >= 4 && (parts[0] == 'p' || parts[0] == 'l');
        final String ring;
        final String ts;
        final String kind;
        final String extraStr;
        if (isNewFormat) {
          ring = parts[0];
          ts = parts[1];
          kind = parts[2];
          extraStr = parts.sublist(3).join('|');
        } else if (parts.length >= 3) {
          ring = 'l';
          ts = parts[0];
          kind = parts[1];
          extraStr = parts.sublist(2).join('|');
        } else {
          continue;
        }
        // Bij oud formaat bepaalt het soort naar welke ring het gaat.
        final effectiveRing = isNewFormat
            ? ring
            : (kind == _lifecycleKind ? 'l' : 'p');

        final map = <String, String>{'ts': ts, 'kind': kind};
        if (extraStr.isNotEmpty) {
          for (final kv in extraStr.split('&')) {
            final idx = kv.indexOf('=');
            if (idx <= 0) continue;
            map[kv.substring(0, idx)] = kv.substring(idx + 1);
          }
        }
        (effectiveRing == 'l' ? _lifecycleEvents : _pushEvents).add(map);
      }
    } catch (_) {}
  }
}
