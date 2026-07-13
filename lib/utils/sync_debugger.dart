import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:matrix/matrix.dart';

import 'package:Pulsly/config/app_config.dart';

class SyncDebugger {
  static final SyncDebugger _instance = SyncDebugger._internal();
  factory SyncDebugger() => _instance;
  SyncDebugger._internal();

  final List<Map<String, dynamic>> _syncLogs = [];
  StreamSubscription? _syncSub;
  bool _isMonitoring = false;

  List<Map<String, dynamic>> get syncLogs => List.unmodifiable(_syncLogs);

  void startMonitoring(Client client) {
    if (_isMonitoring) return;
    _isMonitoring = true;

    Logs().i('[SyncDebugger] Starting sync monitoring for ${client.userID}');

    // Monitor sync status
    _syncSub = client.onSyncStatus.stream.listen((status) {
      final log = {
        'timestamp': DateTime.now().toIso8601String(),
        'type': 'sync_status',
        'status': status.toString(),
        'userId': client.userID,
      };
      _syncLogs.add(log);
      Logs().i('[SyncDebugger] Sync status: $status');

      // Keep only last 100 logs
      if (_syncLogs.length > 100) {
        _syncLogs.removeAt(0);
      }
    });

    // Monitor sync errors
    client.onSync.stream.listen(
      (syncUpdate) {
        final log = {
          'timestamp': DateTime.now().toIso8601String(),
          'type': 'sync_update',
          'nextBatch': syncUpdate.nextBatch,
          'rooms': syncUpdate.rooms != null
              ? [
                  ...?syncUpdate.rooms!.join?.keys,
                  ...?syncUpdate.rooms!.invite?.keys,
                  ...?syncUpdate.rooms!.leave?.keys,
                  ...?syncUpdate.rooms!.knock?.keys,
                ].join(', ')
              : 'none',
          'userId': client.userID,
        };
        _syncLogs.add(log);
        Logs().i('[SyncDebugger] Sync update received, nextBatch: ${syncUpdate.nextBatch}');
      },
      onError: (error, stackTrace) {
        final log = {
          'timestamp': DateTime.now().toIso8601String(),
          'type': 'sync_error',
          'error': error.toString(),
          'stackTrace': stackTrace.toString(),
          'userId': client.userID,
        };
        _syncLogs.add(log);
        Logs().e('[SyncDebugger] Sync error!', error, stackTrace);
      },
    );

    // Monitor connection state
    Timer.periodic(const Duration(seconds: 30), (timer) {
      if (!_isMonitoring) {
        timer.cancel();
        return;
      }

      final log = {
        'timestamp': DateTime.now().toIso8601String(),
        'type': 'connection_check',
        'isLoggedIn': client.isLogged(),
        'backgroundSync': 'N/A', // backgroundSync not available in this SDK version
        'syncPresence': client.syncPresence.toString(),
        'userId': client.userID,
      };
      _syncLogs.add(log);
      Logs().i('[SyncDebugger] Connection check - loggedIn: ${client.isLogged()}');
    });
  }

  void stopMonitoring() {
    _isMonitoring = false;
    _syncSub?.cancel();
    _syncSub = null;
    Logs().i('[SyncDebugger] Stopped sync monitoring');
  }

  void clearLogs() {
    _syncLogs.clear();
  }

  String getLogsAsText() {
    return _syncLogs.map((log) => 
      '[${log['timestamp']}] ${log['type']}: ${log.entries.where((e) => e.key != 'timestamp' && e.key != 'type').map((e) => '${e.key}=${e.value}').join(', ')}'
    ).join('\n');
  }
}

class SyncDebugScreen extends StatefulWidget {
  final Client client;

  const SyncDebugScreen({super.key, required this.client});

  @override
  State<SyncDebugScreen> createState() => _SyncDebugScreenState();
}

class _SyncDebugScreenState extends State<SyncDebugScreen> {
  final SyncDebugger _debugger = SyncDebugger();
  bool _isMonitoring = false;

  @override
  void initState() {
    super.initState();
    _isMonitoring = true;
    _debugger.startMonitoring(widget.client);
  }

  @override
  void dispose() {
    _debugger.stopMonitoring();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sync Debug'),
        actions: [
          IconButton(
            icon: const Icon(Icons.copy),
            onPressed: () {
              final logs = _debugger.getLogsAsText();
              Clipboard.setData(ClipboardData(text: logs));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Logs copied to clipboard')),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              _debugger.clearLogs();
              setState(() {});
            },
          ),
        ],
      ),
      body: StreamBuilder(
        stream: Stream.periodic(const Duration(seconds: 1)),
        builder: (context, snapshot) {
          final logs = _debugger.syncLogs;
          if (logs.isEmpty) {
            return const Center(child: Text('No sync logs yet...'));
          }

          return ListView.builder(
            reverse: true,
            itemCount: logs.length,
            itemBuilder: (context, index) {
              final log = logs[logs.length - 1 - index];
              final color = _getLogColor(log['type'] as String);

              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: color.withValues(alpha: 0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            log['type'] as String,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          log['timestamp']?.toString().substring(11, 19) ?? '',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ...log.entries.where((e) => 
                      e.key != 'timestamp' && e.key != 'type'
                    ).map((e) => Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        '${e.key}: ${e.value}',
                        style: const TextStyle(fontSize: 12),
                      ),
                    )),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Color _getLogColor(String type) {
    switch (type) {
      case 'sync_error':
        return Colors.red;
      case 'sync_status':
        return Colors.blue;
      case 'sync_update':
        return Colors.green;
      case 'connection_check':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}