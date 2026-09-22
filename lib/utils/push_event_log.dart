import 'dart:isolate';

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
///
/// WAAROM MERGEN EN NIET OVERSCHRIJVEN: de UnifiedPush-plugin start zijn eigen
/// FlutterEngine (zie unifiedpush_android, `UnifiedPushService.getEngine` →
/// `DartExecutor.DartEntrypoint.createDefault()`), dus er kan een TWEEDE
/// isolate zijn dat dezelfde prefs-sleutel schrijft. Toen `_persist()` nog
/// simpelweg de eigen in-memory lijst wegschreef, wiste het ene isolate de
/// regels van het andere. Gevolg: pushes die het tweede isolate wél
/// registreerde, verdwenen zodra het eerste isolate een lifecycle-event
/// schreef — en de diagnosepagina toonde een gat dat niet bestond.
/// `_persist()` voegt nu samen met wat er al staat, in plaats van te
/// vervangen, zodat geen enkele schrijver bewijs van een andere kan wissen.
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

  bool _loaded = false;

  /// Leest de bewaarde geschiedenis — precies één keer per isolate.
  ///
  /// Idempotent, zodat het veilig bij het opstarten aan te roepen is. Zonder
  /// deze aanroep begint een verse sessie met een lege in-memory lijst en
  /// schreef de eerste `add()` die lege lijst over de bewaarde geschiedenis
  /// heen: elke app-start wiste dan de geschiedenis van de vorige.
  Future<void> ensureLoaded() async {
    if (_loaded) return;
    _loaded = true;
    await load();
  }

  /// Naam van dit isolate, zodat een dump laat zien WELKE schrijver een regel
  /// achterliet. Isolate zonder naam (het hoofdproces in de praktijk) krijgt
  /// 'main'. Dit maakt twee schrijvers op één sleutel zichtbaar in plaats van
  /// onzichtbaar.
  static String get _isolateTag =>
      Isolate.current.debugName ?? 'main';

  void add(String kind, Map<String, String> extra) {
    final isLifecycle = kind == _lifecycleKind;
    final target = isLifecycle ? _lifecycleEvents : _pushEvents;
    final cap = isLifecycle ? maxLifecycleEvents : maxPushEvents;

    if (isLifecycle) {
      // Opeenvolgende identieke toestanden zijn ruis: elke koude start
      // schrijft inactive/hidden/paused/detached, en bij het openen van de
      // app nog een keer. Alleen een ECHTE overgang is interessant als
      // context bij een push. Dit houdt de lifecycle-ring informatief in
      // plaats van gevuld met herhalingen.
      final vorige = _lifecycleEvents.isEmpty
          ? null
          : _lifecycleEvents.last['state'];
      if (vorige == extra['state']) return;
    }

    target.add({
      'ts': DateTime.now().toIso8601String(),
      'kind': kind,
      'iso': _isolateTag,
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

  /// Schrijft de eigen regels, SAMENGEVOEGD met wat er al stond.
  ///
  /// De merge is de kern: er kan een tweede isolate (de UnifiedPush-engine)
  /// op dezelfde sleutel schrijven, en zonder merge wiste dit de regels van
  /// die ander. Regels worden gededupliceerd op hun encoded vorm, zodat
  /// herhaald persisten van dezelfde regel geen duplicaten geeft.
  Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // EERST verversen: getStringList leest een PER-ISOLATE cache, niet de
      // schijf. Het tweede isolate (de UnifiedPush-engine) schrijft naar
      // dezelfde sleutel, dus zonder reload zouden we onze eigen, stale
      // cache mergen en daarmee de regels van dat andere isolate alsnog
      // wissen — precies het defect dat deze merge moet voorkomen.
      await prefs.reload();
      final bestaand = prefs.getStringList(_key) ?? const <String>[];

      final gezien = <String>{};
      final push = <Map<String, String>>[];
      final life = <Map<String, String>>[];

      void voegToe(String ring, Map<String, String> e) {
        if (!gezien.add(_encode(e, ring))) return;
        (ring == 'l' ? life : push).add(e);
      }

      for (final line in bestaand) {
        final d = _decode(line);
        if (d == null) continue;
        voegToe(d.ring, d.map);
      }
      for (final e in _pushEvents) {
        voegToe('p', e);
      }
      for (final e in _lifecycleEvents) {
        voegToe('l', e);
      }

      _bewaarNieuwste(push, _pushEvents, maxPushEvents);
      _bewaarNieuwste(life, _lifecycleEvents, maxLifecycleEvents);

      await prefs.setStringList(_key, [
        ..._pushEvents.map((e) => _encode(e, 'p')),
        ..._lifecycleEvents.map((e) => _encode(e, 'l')),
      ]);
    } catch (_) {}
  }

  /// Sorteert op tijdstip, houdt de nieuwste [cap] over en zet die in [doel].
  static void _bewaarNieuwste(
    List<Map<String, String>> bron,
    List<Map<String, String>> doel,
    int cap,
  ) {
    bron.sort((a, b) => (a['ts'] ?? '').compareTo(b['ts'] ?? ''));
    final start = bron.length > cap ? bron.length - cap : 0;
    doel
      ..clear()
      ..addAll(bron.sublist(start));
  }

  static String _encode(Map<String, String> e, String ring) {
    final body = e.entries
        .where((x) => x.key != 'ts' && x.key != 'kind')
        .map((x) => '${x.key}=${x.value}')
        .join('&');
    return '$ring|${e['ts']}|${e['kind']}|$body';
  }

  /// Leest één bewaarde regel.
  ///
  /// Nieuw formaat: `<ring>|<ts>|<kind>|<kv>` → 4 delen. Oud formaat:
  /// `<ts>|<kind>|<kv>` → 3 delen. (ts en kind bevatten zelf geen '|', dus
  /// het aantal delen is betrouwbaar. Zonder deze splitsing zou bij een oude
  /// regel de timestamp als ring gelezen worden en verdween de geschiedenis.)
  /// Geeft null bij een onbruikbare regel.
  static _Decoded? _decode(String line) {
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
      ts = parts[0];
      kind = parts[1];
      extraStr = parts.sublist(2).join('|');
      ring = kind == _lifecycleKind ? 'l' : 'p';
    } else {
      return null;
    }

    final map = <String, String>{'ts': ts, 'kind': kind};
    if (extraStr.isNotEmpty) {
      for (final kv in extraStr.split('&')) {
        final idx = kv.indexOf('=');
        if (idx <= 0) continue;
        map[kv.substring(0, idx)] = kv.substring(idx + 1);
      }
    }
    return _Decoded(ring, map);
  }

  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // Zelfde reden als bij _persist: de cache is per-isolate. Een verse
      // start moet de SCHIJF lezen, niet wat dit isolate ooit zag.
      await prefs.reload();
      final raw = prefs.getStringList(_key);
      if (raw == null) return;
      _pushEvents.clear();
      _lifecycleEvents.clear();
      for (final line in raw) {
        final d = _decode(line);
        if (d == null) continue;
        (d.ring == 'l' ? _lifecycleEvents : _pushEvents).add(d.map);
      }
    } catch (_) {}
  }
}

class _Decoded {
  final String ring;
  final Map<String, String> map;
  const _Decoded(this.ring, this.map);
}
