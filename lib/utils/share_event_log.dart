// Diagnoselog voor de share-flow (delen van buiten de app).
//
// WAAROM: als delen vanuit Google Foto's mislukt, is er geen foutmelding,
// geen dialog en geen logregel — de share verdwijnt geruisloos. Daardoor was
// niet te zien WAAR het misging: bij het binnenkomen van de intent, bij het
// lezen van het bestand, of pas bij het versturen.
//
// Deze log legt elke stap vast, zodat één dump na een mislukte share laat
// zien welke schakel faalt. Bewaard in prefs (niet in het push-eventlog) om
// de ringen daar niet te vervuilen: dit is een ander onderwerp.

import 'package:shared_preferences/shared_preferences.dart';

class ShareEventLog {
  static final ShareEventLog _instance = ShareEventLog._internal();
  factory ShareEventLog() => _instance;
  ShareEventLog._internal();

  static const _key = 'plusly_share_event_log';
  static const int _cap = 120;

  final List<String> _regels = [];
  bool _loaded = false;

  static String get _nu => DateTime.now().toIso8601String();

  /// Legt één stap vast. Vorm: `HH:mm:ss <stap> <details>`.
  void add(String stap, [Map<String, Object?>? details]) {
    final extra = details == null || details.isEmpty
        ? ''
        : ' ${details.entries.map((e) => '${e.key}=${e.value}').join(' ')}';
    _regels.add('$_nu $stap$extra');
    if (_regels.length > _cap) {
      _regels.removeRange(0, _regels.length - _cap);
    }
    _persist();
  }

  /// Regels van nieuwste naar oudste, zodat een dump direct bovenaan de
  /// laatste poging toont.
  List<String> get regels => List.unmodifiable(_regels.reversed.toList());

  Future<void> clear() async {
    _regels.clear();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_key);
    } catch (_) {}
  }

  Future<void> ensureLoaded() async {
    if (_loaded) return;
    _loaded = true;
    await load();
  }

  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.reload();
      final raw = prefs.getStringList(_key);
      if (raw == null) return;
      _regels
        ..clear()
        ..addAll(raw);
    } catch (_) {}
  }

  Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.reload();
      final bestaand = prefs.getStringList(_key) ?? const <String>[];
      // Samenvoegen met wat er al staat: er kan een tweede isolate schrijven
      // (de UnifiedPush-engine start zijn eigen FlutterEngine).
      final samen = <String>{...bestaand, ..._regels}.toList()..sort();
      final bewaard = samen.length > _cap
          ? samen.sublist(samen.length - _cap)
          : samen;
      await prefs.setStringList(_key, bewaard);
    } catch (_) {}
  }
}
