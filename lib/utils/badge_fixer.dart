import 'dart:async';

import 'package:matrix/matrix.dart';

import 'package:Pulsly/utils/room_unread_extension.dart';

/// VOORTDURENDE-BADGE-FIX (2026-10-03):
///
/// Klacht: chats die gelezen zijn worden na verloop van tijd wéér ongelezen.
/// Meetrapport (23472-23476 dumps): de leesmarker slaagt wél (poging=1
/// result=ok), maar de badge komt terug. Alle terugkerende kamers zijn
/// WhatsApp-bridge-kamers ((WA)-kamers). Drie bronnen zijn gemeten:
///
/// 1. **Server-teller**: de bridge houdt zijn eigen lees-state bij op de
///    homeserver; zodra de bridge opnieuw sync't (bv. na WhatsApp-reconnect)
///    zet hij `notificationCount` in de sync-oplossing terug > 0 — óók als
///    de gebruiker in Plusly alles gelezen had.
/// 2. **m.fully_read-overschrijving**: de bridge (of een ander apparaat)
///    schrijft de account-data leesmarkeer terug op een oude event-ID; de
///    volgende sync zet `room.fullyRead` terug, de badge-berekening ziet een
///    verschil tussen `fullyRead` en het laatste event... en markeert opnieuw.
/// 3. **marked_unread-vlag**: idem, wordt door de bridge opnieuw gezet.
///
/// Deze service luistert op `client.onSync` en telt per sync hoe vaak een
/// kamer die eerder als gelezen gemarkeerd was (lokaal) terugkomt als
/// ongelezen. De fix:
///
/// - kamers waarvan wij lokaal hebben gezien dat de gebruiker ze gelezen
///   heeft (lees-marker `result=ok`, of room open ging met teller=0) worden
///   op de watchlist gezet (TTL 24 uur);
/// - komt zo'n kamer na een sync terüg met teller > 0 en Geen nieuw event
///   sinds de lees-tijdstip, dan corrigeren we dat lokaal (teller = 0) en
///   loggen we [badge-fixer] zodat het meetbaar is in de debug-dump;
/// - er is GEEN actie richting server: de bridge mag zijn eigen state
///   houden; wij tonen alleen wat de gebruiker zélf heeft gelezen.
class BadgeFixer {
  static final BadgeFixer instance = BadgeFixer._();
  BadgeFixer._();

  StreamSubscription? _sub;

  int fixAantal = 0;

  /// Moment waarop deze kamer voor het laatst als gelezen is geregistreerd.
  ///
  /// Leest de PERSISTENTE bron (SharedPreferences, via [RoomUnreadX]) en niet
  /// een eigen in-memory map. Een eigen map was dezelfde bug als in de UI-
  /// override: hij was leeg na elke herstart, waardoor de fixer precies de
  /// kamers niet corrigeerde die de gebruiker vóór de herstart had gelezen.
  DateTime? leesTijd(String roomId) => RoomUnreadX.leesTijdSync(roomId);

  /// Registreert dat de gebruiker deze kamer nu gelezen heeft.
  ///
  /// Schrijft naar dezelfde persistente opslag als de UI-override, zodat er
  /// één bron van waarheid is in plaats van twee die uit elkaar kunnen lopen.
  void bewaarLezing(String roomId) {
    unawaited(RoomUnreadX.markeerLokaalGelezenVoor(roomId));
  }

  void observeClient(Client client) {
    if (_sub != null) return;
    _sub = client.onSync.stream.listen((_) => _checkSync(client));
  }

  /// OBSERVE: meerdere clients — maar in dit profiel is er 1 actieve.
  final Map<String, StreamSubscription> _subs = {};

  void observeClientNamed(String name, Client client) {
    // No-op sinds 2026-10-06: de sync-correctie is gestopt (zie _checkSync).
    // Er wordt bewust geen onSync-listener meer geregistreerd — de UI-override
    // doet het werk op de display-laag, zonder mutatie en zonder eventlog-ruis.
  }

  void stopAlles() {
    for (final s in _subs.values) {
      s.cancel();
    }
    _subs.clear();
  }

  void _checkSync(Client client) {
    // GESTOPT (2026-10-06): de mutatie hieronder is een regressie.
    //
    // Oorspronkelijk corrigeerde deze watcher de bridge-terugzettingen door
    // `room.notificationCount = 0` te zetten. Maar dat is een eindeloos
    // gevecht: de bridge zet de teller bij ELKE sync terug (gemeten: 28
    // correcties in ~4 minuten op één kamer, teller_was=201 → 0 → 201 → 0),
    // en de mutatie is bovendien schadelijk — `isUnread` wordt er vals false
    // door, wat de push-clearing-logica verwart, en het eventlog raakt
    // overspoeld waardoor echte push-historie uit de buffer wordt geduwd.
    //
    // De UI-override (RoomUnreadX.isEffectivelyUnreadSync) doet dit werk al
    // correct en zonder te muteren: hij vergelijkt de event-tijdstempel met
    // het lokale leesmoment en beslist puur op de display-laag of een kamer
    // ongelezen is. De bridge mag zijn eigen teller houden; wij tonen wat de
    // gebruiker zélf heeft gelezen. Deze sync-watcher is daarmee overbodig en
    // wordt bewust niet meer aangeroepen (observeClientNamed is een no-op).
  }

  Future<void> dispose() async {
    stopAlles();
  }
}