
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

    try {
      final prefs = await SharedPreferences.getInstance();
      final t = prefs.getString('plusly_push_last_received_ts');
      if (t != null) _lastPushTime = t;
      logs.add('Last push timestamp: ${_lastPushTime ?? 'none'}');
    } catch (_) {}

    final eventLog = PushEventLog();
    await eventLog.load();
    final events = eventLog.events;

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
    } catch (_) {}

    setState(() {
      _logs = logs;
      _events = events;
      _loading = false;
    });
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
