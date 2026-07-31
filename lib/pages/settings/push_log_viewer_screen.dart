import 'package:flutter/material.dart';
import '../../utils/push_log_buffer.dart';
import '../../widgets/matrix.dart';

class PushLogViewerScreen extends StatefulWidget {
  const PushLogViewerScreen({super.key});

  @override
  State<PushLogViewerScreen> createState() => _PushLogViewerScreenState();
}

class _PushLogViewerScreenState extends State<PushLogViewerScreen> {
  bool _reRegistering = false;

  Future<void> _reRegisterPush() async {
    setState(() => _reRegistering = true);
    PushLogBuffer.instance.i('Manual re-registration requested');

    try {
      final matrix = Matrix.of(context);
      final push = matrix.backgroundPush;
      if (push == null) {
        PushLogBuffer.instance.e('backgroundPush is null — cannot re-register');
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Push systeem niet beschikbaar')),
        );
        return;
      }

      // Clear saved distributor to force fresh picker
      final store = matrix.store;
      await store.setString('unifiedpush distributor', '');
      PushLogBuffer.instance.i('Cleared saved distributor');

      // Clear endpoint for each client
      for (final client in matrix.widget.clients) {
        final endpointKey = client.clientName + 'unifiedpush_endpoint';
        final registeredKey = client.clientName + 'unifiedpush_registered';
        await store.setString(endpointKey, '');
        await store.setBool(registeredKey, false);
        PushLogBuffer.instance.i('Cleared endpoint for ${client.clientName}');
      }

      // Reset UP action flag
      push.upAction = false;

      // Re-setup push — this will show distributor picker
      await push.setupPush(matrix.widget.clients);
      PushLogBuffer.instance.i('Push re-registration complete');

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Push opnieuw geregistreerd')),
      );
    } catch (e) {
      PushLogBuffer.instance.e('Re-registration failed: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Herregistratie mislukt: $e')),
      );
    } finally {
      if (mounted) setState(() => _reRegistering = false);
    }
  }
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final entries = PushLogBuffer.instance.entries;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Push logs'),
        actions: [
          IconButton(
            icon: _reRegistering
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.restart_alt),
            tooltip: 'Herregistreer push',
            onPressed: _reRegistering ? null : _reRegisterPush,
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Wis logs',
            onPressed: () {
              PushLogBuffer.instance.clear();
              setState(() {});
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Ververs',
            onPressed: () => setState(() {}),
          ),
        ],
      ),
      body: entries.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.inbox_outlined,
                    size: 64,
                    color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Geen push logs',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Logs verschijnen hier wanneer er een push\nbinnenkomt of de test-knop wordt gebruikt.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(8),
              itemCount: entries.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final entry = entries[index];
                final color = switch (entry.level) {
                  'E' => theme.colorScheme.error,
                  'W' => theme.colorScheme.tertiary,
                  _ => theme.colorScheme.onSurface,
                };
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.formatted.substring(0, 8), // timestamp
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 11,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '[${entry.level}]',
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          entry.message,
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 11,
                            color: color,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
