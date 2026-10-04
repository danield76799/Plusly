import 'dart:async';

import 'package:matrix/matrix.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Lokale override van de ongelezen-status per kamer.
///
/// Probleem: WhatsApp-bridgekamers komen steeds terug als ongelezen omdat de
/// bridge zijn eigen notification_count op de homeserver herberekenend en bij
/// elke reconnect terugzet. De SDK-read-marker slaagt wel (`result=ok`), maar
/// een volgende sync van de bridge overschrijft de teller weer.
///
/// Oplossing: wij onthouden lokaal (persistent in SharedPreferences) op welk
/// moment de gebruiker een kamer voor het laatst opende of een read-marker
/// succesvol verstuurde. De UI toont een kamer alleen als ongelezen als er een
/// event is dat nieuwer is dan dat lokale lees-moment. Alles daarvoor wordt
/// genegeerd, ongeacht wat de server/bridge beweert.
///
/// Deze extension is puur UI: hij verandert niets aan de SDK-state en doet
/// geen server-calls. De echte `Room.isUnread` blijft onaangeroerd zodat
/// push-logica en badges voor nieuwe berichten blijven werken.
extension RoomUnreadX on Room {
  static const _prefsPrefix = 'plusly_last_read_v1_';
  static final Map<String, DateTime> _cache = {};

  static String _key(String roomId) => '$_prefsPrefix$roomId';

  /// Geeft het laatste moment terug waarop deze kamer lokaal als gelezen is
  /// gemarkeerd, of null als dat nooit is gebeurd.
  static Future<DateTime?> _laadTijd(String roomId) async {
    final cached = _cache[roomId];
    if (cached != null) return cached;
    final prefs = await SharedPreferences.getInstance();
    final iso = prefs.getString(_key(roomId));
    if (iso == null || iso.isEmpty) return null;
    try {
      final dt = DateTime.parse(iso);
      _cache[roomId] = dt;
      return dt;
    } catch (_) {
      return null;
    }
  }

  /// Marker deze kamer als lokaal gelezen op dit moment.
  ///
  /// Moet worden aangeroepen zodra de gebruiker de kamer opent én nadat de
  /// server read-marker succesvol is verstuurd.
  Future<void> markeerLokaalGelezen() => markeerLokaalGelezenVoor(id);

  /// Zelfde als [markeerLokaalGelezen], maar op room-id.
  ///
  /// Nodig omdat [BadgeFixer] alleen een id heeft en geen `Room`-instantie.
  /// Eén implementatie voor beide houdt de opslag en de cache consistent.
  static Future<void> markeerLokaalGelezenVoor(String roomId) async {
    final now = DateTime.now();
    _cache[roomId] = now;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key(roomId), now.toIso8601String());
  }

  /// Synchrone toegang tot het bewaarde lees-moment van een kamer.
  ///
  /// Leest de in-memory cache. Die moet gevuld zijn door [hydrate] (bij
  /// app-start) of door [markeerLokaalGelezen] (bij openen van een kamer).
  static DateTime? leesTijdSync(String roomId) => _cache[roomId];

  /// Laadt ALLE bewaarde lees-momenten uit SharedPreferences in het geheugen.
  ///
  /// ZONDER DEZE STAP IS DE HELE OVERRIDE NUTTELOOS NA EEN HERSTART. De UI
  /// gebruikt `isEffectivelyUnreadSync`, en die leest uitsluitend de
  /// in-memory `_cache`. Die is leeg bij een koude start, dus viel de UI
  /// terug op de SDK-status — en precies daar zet de bridge zijn teller
  /// terug. Gevolg: alle kamers kwamen na elke herstart terug als ongelezen,
  /// ook al stond het lees-moment wél correct in SharedPreferences. Er was
  /// alleen nooit iets dat die waarden inlas: de async getters die
  /// `_laadTijd` gebruiken hebben nul call sites in de UI.
  ///
  /// Moet één keer bij het opstarten worden aangeroepen, vóór de chatlijst
  /// voor het eerst bouwt.
  static Future<void> hydrate() async {
    final prefs = await SharedPreferences.getInstance();
    for (final key in prefs.getKeys()) {
      if (!key.startsWith(_prefsPrefix)) continue;
      final iso = prefs.getString(key);
      if (iso == null || iso.isEmpty) continue;
      try {
        _cache[key.substring(_prefsPrefix.length)] = DateTime.parse(iso);
      } catch (_) {
        // Corrupte waarde: negeren. Eén slechte regel mag de start niet
        // blokkeren en mag de rest van de kamers niet meeslepen.
      }
    }
  }

  /// Leegt de in-memory cache. Alleen voor tests die een herstart simuleren.
  static void debugClearCache() => _cache.clear();

  /// Verwijder het lokale lees-moment (bij uitzonderen / debug).
  Future<void> verwijderLokaalGelezen() async {
    _cache.remove(id);
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key(id));
  }

  /// True als de UI deze kamer als ongelezen moet tonen.
  ///
  /// Een kamer is effectief ongelezen als:
  /// - de SDK zegt dat er iets ongelezen is (`isUnread` of `hasNewMessages`),
  ///   EN
  /// - er een laatste event bestaat dat nieuwer is dan het lokale lees-moment
  ///   (of er helemaal geen lokaal lees-moment is, dan valt hij terug op de
  ///   SDK-status).
  ///
  /// Als de kamer lokaal gelezen is maar het laatste event is ouder dan dat
  /// moment, forceren we gelezen — de bridge-terugzetting wordt onderdrukt.
  Future<bool> get isEffectivelyUnread async {
    final sdkUnread = isUnread || hasNewMessages;
    if (!sdkUnread) return false;

    final last = lastEvent;
    if (last == null) return false;

    final gelezen = await _laadTijd(id);
    if (gelezen == null) return sdkUnread;

    return last.originServerTs.isAfter(gelezen);
  }

  /// Hulp voor sync-context: zelfde logica maar dan synchronous op basis van
  /// het in-memory cache. Gebruik dit alleen in listeners die niet async willen.
  bool get isEffectivelyUnreadSync {
    final sdkUnread = isUnread || hasNewMessages;
    if (!sdkUnread) return false;

    final last = lastEvent;
    if (last == null) return false;

    final gelezen = _cache[id];
    if (gelezen == null) return sdkUnread;

    return last.originServerTs.isAfter(gelezen);
  }

  /// Effectieve notification count voor de UI-badge.
  ///
  /// Geeft 0 terug als de kamer lokaal als gelezen is en geen nieuw event
  /// heeft sindsdien. Anders de echte `notificationCount`.
  Future<int> get effectiveNotificationCount async {
    final last = lastEvent;
    if (last == null) return 0;

    final gelezen = await _laadTijd(id);
    if (gelezen == null) return notificationCount;

    if (!last.originServerTs.isAfter(gelezen)) return 0;
    return notificationCount;
  }

  /// Synchrone variant voor plaatsen waar async niet praktisch is.
  int get effectiveNotificationCountSync {
    final last = lastEvent;
    if (last == null) return 0;

    final gelezen = _cache[id];
    if (gelezen == null) return notificationCount;

    if (!last.originServerTs.isAfter(gelezen)) return 0;
    return notificationCount;
  }
}
