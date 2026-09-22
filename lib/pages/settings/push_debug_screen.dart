
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unifiedpush/unifiedpush.dart';

import 'package:Pulsly/generated/l10n/l10n.dart';
import 'package:Pulsly/utils/platform_infos.dart';
import 'package:Pulsly/utils/push_event_log.dart';
import 'package:Pulsly/widgets/matrix.dart';

import 'package:Pulsly/config/setting_keys.dart';

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
  List<Map<String, String>> _pushEvents = const [];
  String? _lastPushTime;
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
    final store = matrix.store;
    for (final client in Matrix.of(context).widget.clients.where((c) => c.isLogged())) {
      final prefix = client.clientName;
      final endpoint = store.getString(prefix + AppSettings.unifiedPushEndpoint.key);
      final registered = store.getBool(prefix + AppSettings.unifiedPushRegistered.key);
      final saved = endpoint != null && endpoint.isNotEmpty;
      logs.add('Client=$prefix endpoint=${saved ? "saved" : "missing"} registered=$registered');
      if (saved && _endpoint == null) {
        _endpoint = endpoint;
      }
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final t = prefs.getString('plusly_push_last_received_ts');
      if (t != null) _lastPushTime = t;
      logs.add('Last push timestamp: ${_lastPushTime ?? 'none'}');
    } catch (_) {}

    final eventLog = PushEventLog();
    await eventLog.load();
    final events = eventLog.events;
    final pushEvents = eventLog.pushEvents;

    setState(() {
      _logs = logs;
      _events = events;
      _pushEvents = pushEvents;
      _loading = false;
    });
  }

  /// Het getal dat de vraag "komt elke push ook aan?" in één blik beantwoordt.
  String get _pushStats {
    if (_pushEvents.isEmpty) return 'nog geen push-events';
    int count(String kind) =>
        _pushEvents.where((e) => e['kind'] == kind).length;

    final received = count('push_received');
    final shown = count('push_shown');
    final suppressed = count('push_suppressed');
    final clearing = count('push_clearing');
    final events = count('push_event');
    final afgerond = count('push');
    final fouten = count('push_error');

    // Alleen pushes MET een room_id kunnen ooit getoond worden. Een teller
    // zonder room_id heeft niets te tonen en hoort in push_clearing.
    final metRoom = _pushEvents
        .where((e) => e['kind'] == 'push_received' && (e['room'] ?? '').isNotEmpty)
        .length;
    final zonderRoom = received - metRoom;

    final b = StringBuffer();
    b.write('ontvangen=$received (met room=$metRoom, tellers=$zonderRoom) ');
    b.write('getoond=$shown onderdrukt=$suppressed opgeruimd=$clearing ');
    b.write('push_event=$events afgerond=$afgerond');
    if (fouten > 0) b.write(' FOUTEN=$fouten');
    b.write(' | totaal ${_pushEvents.length} events');
    return b.toString();
  }

  Future<void> _copyLogs() async {
    final buffer = StringBuffer();
    for (final l in _logs) buffer.writeln('[status] $l');
    if (_pushEvents.isNotEmpty) buffer.writeln('[samenvatting] $_pushStats');
    // Oplopend, zodat je bij het lezen ziet hoe een push zich ontwikkelt.
    for (final e in _events) {
      final ts = e['ts'] ?? '';
      final kind = e['kind'] ?? '';
      final extra = e.entries.where((x) => x.key != 'ts' && x.key != 'kind').map((x) => '${x.key}=${x.value}').join(' ');
      buffer.writeln('[$kind] $ts $extra');
    }
    await Clipboard.setData(ClipboardData(text: buffer.toString()));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(L10n.of(context).copiedToClipboard ?? 'Copied')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.notifications ?? 'Push diagnose'),
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
                  title: Text('Pushes in log'),
                  subtitle: Text(_pushStats),
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
                const SizedBox(height: 4),
                if (_events.isNotEmpty)
                  Text(
                    'Nieuwste eerst. Lifecycle-regels zijn context bij een '
                    'push; ze hebben een eigen kleine buffer en kunnen '
                    'push-events niet meer verdringen.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                const SizedBox(height: 8),
                if (_events.isEmpty)
                  const Text('Nog geen events gelogd in deze sessie.')
                else
                  // Nieuwste eerst: je wilt zien wat er zojuist gebeurde, niet
                  // het begin van de geschiedenis.
                  ..._events.reversed.take(150).map((e) {
                    final rawTs = e['ts'] ?? '';
                    final ts = rawTs.length >= 19
                        ? rawTs.substring(11, 19)
                        : rawTs;
                    final kind = e['kind'] ?? '';
                    final extra = e.entries
                        .where((x) => x.key != 'ts' && x.key != 'kind')
                        .map((x) => '${x.key}=${x.value}')
                        .join(' ');
                    final isPush = kind.startsWith('push');
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Text(
                        '[$kind] $ts $extra',
                        style: isPush
                            ? const TextStyle(fontWeight: FontWeight.w600)
                            : Theme.of(context).textTheme.bodySmall,
                      ),
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
