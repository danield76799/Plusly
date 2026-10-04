
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unifiedpush/unifiedpush.dart';

import 'package:Pulsly/generated/l10n/l10n.dart';
import 'package:Pulsly/config/app_config.dart';
import 'package:Pulsly/utils/platform_infos.dart';
import 'package:Pulsly/utils/push_event_log.dart';
import 'package:Pulsly/utils/room_unread_extension.dart';
import 'package:Pulsly/utils/share_event_log.dart';
import 'package:Pulsly/widgets/matrix.dart';

import 'package:Pulsly/config/setting_keys.dart';
import 'package:matrix/matrix.dart';

class PushDebugScreen extends StatefulWidget {
  const PushDebugScreen({super.key});

  @override
  State<PushDebugScreen> createState() => _PushDebugScreenState();
}

class _PushDebugScreenState extends State<PushDebugScreen> {
  bool _loading = true;
  String? _distributor;
  String? _endpoint;
  List<String> _logs = const [];
  List<Map<String, String>> _events = const [];
  String? _lastPushTime;
  DateTime? _lastPushDateTime;
  String _lastPushAge = '—';
  bool _pushStale = false;
  bool _unifiedPushAvailable = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final logs = <String>[];
    try {
      final distributors = await UnifiedPush.getDistributors();
      _unifiedPushAvailable = distributors.isNotEmpty;
      logs.add('Distributors available: $_unifiedPushAvailable');
      if (_unifiedPushAvailable) {
        _distributor = await UnifiedPush.getDistributor();
        logs.add('Distributor: ${_distributor ?? 'none'}');
      }
    } catch (e) {
      logs.add('Distributor error: $e');
    }

    final matrix = Matrix.of(context);

    for (final client in matrix.widget.clients.where((c) => c.isLogged())) {
      final prefix = client.clientName;
      final endpoint = AppSettings.unifiedPushEndpoint.value;
      final registered = AppSettings.unifiedPushRegistered.value;
      final saved = endpoint.isNotEmpty;
      logs.add('Client=$prefix endpoint=${saved ? "saved" : "missing"} registered=$registered');
      if (saved && _endpoint == null) {
        _endpoint = endpoint;
      }
    }

    // KANAALMETING. Android staat niet toe dat een app de importance van een
    // bestaand notificatiekanaal wijzigt; createNotificationChannel() stuurt
    // altijd 'createIfNotExists' en is dus een no-op voor een kanaal dat al
    // bestaat. Zonder deze uitlezing is niet te zien of een melding stil
    // blijft omdat het kanaal laag staat, of omdat iets anders speelt.
    if (PlatformInfos.isAndroid) {
      try {
        final android = FlutterLocalNotificationsPlugin()
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();
        final enabled = await android?.areNotificationsEnabled();
        logs.add('Meldingen toegestaan: ${enabled ?? "?"}');

        final channels = await android?.getNotificationChannels();
        if (channels == null || channels.isEmpty) {
          logs.add('Kanalen: geen');
        } else {
          for (final c in channels) {
            if (c.id == AppConfig.pushNotificationsChannelId) {
              logs.add(
                'Kanaal ${c.id}: importance=${c.importance.name} '
                'geluid=${c.playSound} trillen=${c.enableVibration} '
                'bypassDnd=${c.bypassDnd} badge=${c.showBadge}',
              );
            }
          }
        }
      } catch (e) {
        logs.add('Kanaalmeting mislukt: $e');
      }
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      // FC-pariteit: per-client laatst-ontvangen-tijdstempel (geschreven door
      // PushHelperInstrumentation.markeerLaatstePush). De oude
      // 'plusly_push_last_received_ts'-key blijft gelezen voor historie.
      final t = prefs.getString('plusly_push_last_received_ts');
      if (t != null) _lastPushTime = t;
      for (final client in matrix.widget.clients.where((c) => c.isLogged())) {
        final ms = prefs.getInt('push_last_received_ts_${client.clientName}');
        if (ms != null) {
          final dt = DateTime.fromMillisecondsSinceEpoch(ms);
          _lastPushTime ??= dt.toIso8601String();
          _lastPushDateTime ??= dt;
          logs.add('Last push [${client.clientName}]: ${dt.toIso8601String()}');
        }
      }
      logs.add('Last push timestamp: ${_lastPushTime ?? 'none'}');

      // Endpoint-frisheid: toont hoe lang geleden de laatste push was. Een
      // stil kanaal (Sunup/ntfy op Android 17 bèta dooft na verloop van tijd
      // uit) is hieraan te herkennen: de laatste push is dan opeens oud,
      // terwijl er wél nieuwe berichten verwacht werden. Dit is een HEURISTIEK
      // (stilte is geen hard bewijs), dus de tekst vraagt om bevestiging via
      // een testbericht in plaats van met zekerheid te claimen dat het kapot is.
      final lastPush = _lastPushDateTime;
      if (lastPush == null) {
        _lastPushAge = 'nog nooit een push ontvangen';
        // Geregistreerd maar nóg nooit een push: op de Android-17-bèta dooft
        // het kanaal soms al vóór de eerste push. Zonder waarschuwing leek
        // dit scherm gezond terwijl er niets binnenkwam — precies de valkuil
        // van de dump van 2026-10-01 (registered=true, Last push: none, en
        // desondanks geen enkele push sinds de (her)login).
        if (AppSettings.unifiedPushRegistered.value) {
          _pushStale = true;
          logs.add(
            '⚠ Geregistreerd, maar nóg nooit een push ontvangen. Stuur één '
            'testbericht; komt er niets, tik dan op '
            '"Registreer push notifications".',
          );
        } else {
          _pushStale = false;
        }
      } else {
        final age = DateTime.now().difference(lastPush);
        _lastPushAge = _humanAge(age);
        // Drempel ruim boven de normale chatfrequentie; pas dan noemen we
        // het "verdacht stil" en raden we een test + eventuele herregistratie aan.
        _pushStale = age > const Duration(minutes: 30);
        if (_pushStale) {
          logs.add(
            '⚠ Push-kanaal lijkt stil: laatste push $_lastPushAge geleden. '
            'Stuur een testbericht; komt er niets, tik dan op '
            '"Registreer push notifications".',
          );
        }
      }

      // FC-pariteit: push-helper crash-rapport tonen indien aanwezig.
      final crash = prefs.getStringList(AppConfig.pushHelperCrashReportKey);
      if (crash != null && crash.isNotEmpty) {
        logs.add('⚠ Push-helper crash-rapport:');
        for (final regel in crash.take(8)) {
          for (var i = 0; i < regel.length; i += 160) {
            logs.add('  ${regel.substring(i, (i + 160).clamp(0, regel.length))}');
          }
        }
      }
    } catch (_) {}

    final eventLog = PushEventLog();
    await eventLog.load();
    final events = eventLog.events;

    // BADGE-AUDIT (2026-10-02): de klacht "gelezen chats worden weer
    // ongelezen" kan drie oorzaken hebben: (1) server notification_count >
    // 0 (leesmarker niet aangekomen), (2) m.marked_unread-vlag staat aan
    // (openen wist de vlag, maar als een sync hem terugzet...), (3)
    // hasNewMessages — timestamp-vergelijking: het laatste event is nieuwer
    // dan de leesmarker. Deze tabel toont per ongelezen kamer welke bron
    // de badge omhoog houdt, zodat één dump de oorzaak bewijst in plaats
    // van giswerk.
    try {
      final ongelezen = <Room>[];
      for (final c in matrix.widget.clients.where((cl) => cl.isLogged())) {
        ongelezen.addAll(
          c.rooms.where(
            (r) => r.membership == Membership.join && r.isUnread,
          ),
        );
      }
      if (ongelezen.isEmpty) {
        logs.add('[badges] geen ongelezen kamers');
      } else {
        logs.add('[badges] ${ongelezen.length} ongelezen kamers (bron):');
        final nu = DateTime.now();
        for (final room in ongelezen) {
          final teller = room.notificationCount;
          final vlag = room.markedUnread;
          final nieuw = room.hasNewMessages;
          final last = room.lastEvent;
          final leeftijd = last == null
              ? '?'
              : _humanAge(nu.difference(last.originServerTs));
          // Lokaal lees-moment meesturen: zonder dit is niet te zien of de
          // override gehydrateerd is (na een herstart) en of een kamer dus
          // terecht of onterecht ongelezen staat.
          final lokaal = RoomUnreadX.leesTijdSync(room.id);
          final lokaalTxt = lokaal == null
              ? 'geen'
              : _humanAge(nu.difference(lokaal));
          String bron;
          if (teller > 0 && !vlag) {
            bron = 'TELLER (server kent de leesmarker niet?)';
          } else if (vlag && teller == 0) {
            bron = 'MARKED_UNREAD-vlag';
          } else if (nieuw) {
            bron = 'HAS_NEW_MESSAGES (timestamp-verschil)';
          } else {
            bron = 'combinatie';
          }
          logs.add(
            '[badges] "${room.getLocalizedDisplayname()}": teller=$teller vlag=$vlag '
            'nieuw=$nieuw lastAge=$leeftijd lokaalGelezen=$lokaalTxt → $bron',
          );
        }
      }
    } catch (e) {
      logs.add('[badges] mislukt: $e');
    }

    // Share-diagnose: losse log, want delen is een ander onderwerp dan push.
    // Zonder deze regels is een mislukte share volledig spoorloos.
    try {
      final shareLog = ShareEventLog();
      await shareLog.ensureLoaded();
      final regels = shareLog.regels;
      if (regels.isNotEmpty) {
        logs.add('── Share-flow (nieuwste eerst) ──');
        for (final r in regels.take(15)) {
          logs.add(r);
        }
      } else {
        logs.add('Share-flow: nog geen share geprobeerd in deze sessie');
      }
    } catch (e) {
      logs.add('Share-flow uitlezen mislukt: $e');
    }

    // Samenvattingsregel: maakt een dump zelf-verklarend. Zonder dit moet je
    // elke kopie met de hand tellen om te zien of de buffer vol zat en of er
    // een koude start in het venster viel. `met room=` scheidt de pushes die
    // een notificatie KUNNEN tonen van de teller-pushes die per definitie
    // alleen opruimen, en `branch=background` verraadt een koude start.
    try {
      final ontvangen = events.where((e) => e['kind'] == 'push_received').toList();
      final metRoom = ontvangen.where((e) => (e['room'] ?? '').isNotEmpty).length;
      final getoond = events.where((e) => e['kind'] == 'push_shown').length;
      final onderdrukt = events.where((e) => e['kind'] == 'push_suppressed').length;
      final opgeruimd = events.where((e) => e['kind'] == 'push_clearing').length;
      final events2 = events.where((e) => e['kind'] == 'push_event').length;
      final afgerond = events.where((e) => e['kind'] == 'push').length;
      final isolaten = <String, int>{};
      for (final e in events) {
        final iso = e['iso'] ?? 'main';
        isolaten[iso] = (isolaten[iso] ?? 0) + 1;
      }
      final achtergrond = events
          .where((e) => e['kind'] == 'init' && e['branch'] == 'background')
          .length;
      logs.add(
        '[samenvatting] ontvangen=${ontvangen.length} (met room=$metRoom, '
        'tellers=${ontvangen.length - metRoom}) getoond=$getoond '
        'onderdrukt=$onderdrukt opgeruimd=$opgeruimd push_event=$events2 '
        'afgerond=$afgerond | koude starts=$achtergrond | '
        'isolates: ${isolaten.entries.map((x) => '${x.key}=${x.value}').join(', ')} | '
        'totaal ${events.length} events (cap: push=500, lifecycle=25)',
      );

      // Na-meting: bleef de melding staan, of ruimde de app hem zelf op?
      //
      // Dit is de enige regel die "Android toont hem niet" scheidt van "wij
      // hebben hem weggehaald". Een push_active_later met actief=nee terwijl
      // de directe check actief=ja was, betekent dat de melding na show()
      // is opgeruimd — dan zit de oorzaak in de app, niet in de weergave.
      final later = events.where((e) => e['kind'] == 'push_active_later').toList();
      if (later.isNotEmpty) {
        final nogJa = later.where((e) => e['actief'] == 'ja').length;
        final weg = later.length - nogJa;
        logs.add(
          '[na-meting] ${later.length} gecontroleerd na 3s: '
          'nog-aanwezig=$nogJa zelf-opgeruimd=$weg',
        );
        for (final e in later.reversed.take(5)) {
          logs.add('[push_active_later] ${e['ts']} id=${e['id']} '
              'actief=${e['actief']} totaal=${e['totaal']}');
        }
      } else {
        logs.add('[na-meting] nog geen na-metingen (verschijnt 3s na een push)');
      }
    } catch (_) {}

    setState(() {
      _logs = logs;
      _events = events;
      _loading = false;
    });
  }

  /// Korte, menselijke weergave van een tijdsverschil.
  String _humanAge(Duration d) {
    if (d.inSeconds < 60) return '${d.inSeconds}s';
    if (d.inMinutes < 60) return '${d.inMinutes}m';
    if (d.inHours < 24) return '${d.inHours}u';
    return '${d.inDays}d';
  }

  Future<void> _copyLogs() async {
    final buffer = StringBuffer();
    for (final l in _logs) {
      buffer.writeln('[status] $l');
    }
    for (final e in _events) {
      final ts = e['ts'] ?? '';
      final kind = e['kind'] ?? '';
      final extra = e.entries
          .where((x) => x.key != 'ts' && x.key != 'kind')
          .map((x) => '${x.key}=${x.value}')
          .join(' ');
      buffer.writeln('[$kind] $ts $extra');
    }
    await Clipboard.setData(ClipboardData(text: buffer.toString()));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(L10n.of(context).copiedToClipboard)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.notifications),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _load),
          IconButton(icon: const Icon(Icons.copy), onPressed: _copyLogs),
          IconButton(icon: const Icon(Icons.delete_outline), onPressed: () async {
            await PushEventLog().clear();
            if (!mounted) return;
            setState(() { _events = const []; });
          }),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                SwitchListTile(
                  title: Text('Pushnotificaties'),
                  subtitle: Text(_unifiedPushAvailable ? 'UnifiedPush beschikbaar' : 'Geen UP-distributor'),
                  value: _unifiedPushAvailable,
                  onChanged: null,
                ),
                const SizedBox(height: 12),
                ListTile(
                  title: Text('Distributor'),
                  subtitle: Text(_distributor ?? '—'),
                ),
                ListTile(
                  title: Text('Endpoint'),
                  subtitle: Text(_endpoint ?? '—'),
                ),
                ListTile(
                  title: Text('Laatste push'),
                  subtitle: Text(_lastPushTime ?? 'nog geen push ontvangen in deze sessie'),
                ),
                ListTile(
                  title: Text('Push-kanaal'),
                  subtitle: Text(_pushStale
                      ? '⚠ $_lastPushAge geleden — mogelijk stil'
                      : 'actief ($_lastPushAge geleden)'),
                  leading: Icon(
                    _pushStale ? Icons.warning_amber_rounded : Icons.check_circle_outline,
                    color: _pushStale ? Colors.orange : Colors.green,
                  ),
                ),
                const SizedBox(height: 12),
                Text('Status:', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                ..._logs.map((l) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Text(l),
                    )),
                const SizedBox(height: 16),
                Text('Eventlog:', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                if (_events.isEmpty)
                  const Text('Nog geen events gelogd in deze sessie.')
                else
                  ..._events.take(40).map((e) {
                    final ts = (e['ts'] ?? '').substring(11, 19);
                    final kind = e['kind'] ?? '';
                    final extra = e.entries.where((x) => x.key != 'ts' && x.key != 'kind').map((x) => '${x.key}=${x.value}').join(' ');
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Text('[$kind] $ts $extra'),
                    );
                  }),
                const SizedBox(height: 16),
                if (!PlatformInfos.isAndroid)
                  const Text('Pushdiagnose is vooral nuttig op Android.')
                else
                  const Text(
                    'Tip: als push in standby stopt, controleer dan ook '
                    'Instellingen → Apps → Plusly → Batterij → Onbeperkt.',
                  ),
              ],
            ),
    );
  }
}
