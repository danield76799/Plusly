import 'dart:async';

import 'package:matrix/matrix.dart';

import 'package:Pulsly/utils/push_event_log.dart';

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

  final Map<String, DateTime> _gelezenOp = {};
  StreamSubscription? _sub;

  /// Camerazone: hoe lang een "gelezen-observatie" geldig blijft.
  static const _observatieTtl = Duration(hours: 24);

  /// Max aantal correcties per sync (tegen run-away loops).
  static const _maxFixPerSync = 50;

  int fixAantal = 0;

  /// Start de watcher voor een client.
  void bewaarLezing(String roomId) {
    _gelezenOp[roomId] = DateTime.now();
  }

  void observeClient(Client client) {
    if (_sub != null) return;
    _sub = client.onSync.stream.listen((_) => _checkSync(client));
  }

  /// OBSERVE: meerdere clients — maar in dit profiel is er 1 actieve.
  final Map<String, StreamSubscription> _subs = {};

  void observeClientNamed(String name, Client client) {
    _subs[name] ??= client.onSync.stream.listen((_) => _checkSync(client));
  }

  void stopAlles() {
    for (final s in _subs.values) {
      s.cancel();
    }
    _subs.clear();
  }

  void _checkSync(Client client) {
    final nu = DateTime.now();
    var fixes = 0;
    for (final room in client.rooms.where((r) => r.membership == Membership.join)) {
      final gelezen = _gelezenOp[room.id];
      if (gelezen == null) continue;
      if (nu.difference(gelezen) > _observatieTtl) {
        _gelezenOp.remove(room.id);
        continue;
      }
      // Kamer ongelezen zonder nieuw event sinds de lezing = bridge-overschrijving.
      if (room.isUnread && room.notificationCount > 0) {
        final last = room.lastEvent;
        final laatsTs = last?.originServerTs; // DateTime in deze SDK
        // Nieuw event sinds lezing = echte nieuwe berichten (badge terecht);
        // geen nieuw event = bridge heeft de teller teruggezet.
        final geenNieuwEvent =
            laatsTs == null || !laatsTs.isAfter(gelezen);
        if (geenNieuwEvent && fixes < _maxFixPerSync) {
          room.notificationCount = 0;
          fixes++;
          PushEventLog().add('badge_fixer', {
            'room': room.id,
            'teller_was': 'positief',
            'laats_leeftijd_s': laatsTs == null
                ? '?'
                : (nu.difference(laatsTs).inSeconds).toString(),
          });
        }
      }
    }
    if (fixes > 0) {
      fixAantal += fixes;
      PushEventLog().add('badge_fixer', {
        'sync-fixes': '$fixes',
        'totaal': '$fixAantal',
      });
    }
  }

  Future<void> dispose() async {
    stopAlles();
  }
}