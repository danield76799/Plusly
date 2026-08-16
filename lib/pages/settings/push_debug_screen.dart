import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unifiedpush/unifiedpush.dart';

import 'package:Pulsly/generated/l10n/l10n.dart';
import 'package:Pulsly/utils/platform_infos.dart';
import 'package:Pulsly/widgets/matrix.dart';

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
    } catch (e, s) {
      logs.add('Distributor error: $e');
    }

    // Read endpoint + registered flags for all logged-in clients
    final matrix = Matrix.of(context);
    final store = matrix.store;
    for (final client in matrix.clients.where((c) => c.isLogged())) {
      final prefix = client.clientName;
      final endpoint = store.getString(prefix + 'unifiedPushEndpoint');
      final registered = store.getBool(prefix + 'unifiedPushRegistered');
      final saved = endpoint != null && endpoint.isNotEmpty;
      logs.add('Client=$prefix endpoint=${saved ? "saved" : "missing"} registered=$registered');
      if (saved && _endpoint == null) {
        _endpoint = endpoint;
      }
    }

    // Read persisted last-push timestamp if any
    try {
      final prefs = await SharedPreferences.getInstance();
      final t = prefs.getString('plusly_push_last_received_ts');
      if (t != null) _lastPushTime = t;
      logs.add('Last push timestamp: ${_lastPushTime ?? 'none'}');
    } catch (_) {}

    setState(() {
      _logs = logs;
      _loading = false;
    });
  }

  Future<void> _copyLogs() async {
    await Clipboard.setData(ClipboardData(text: _logs.join('\n')));
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
        title: Text(l10n.settingsNotificationsTitle ?? 'Push diagnose'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _load),
          IconButton(icon: const Icon(Icons.copy), onPressed: _copyLogs),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                SwitchListTile(
                  title: Text(l10n.pushNotificationsEnabled ?? 'Pushnotificaties'),
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
                Text('Diagnostiek:', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                ..._logs.map((l) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Text(l),
                    )),
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
