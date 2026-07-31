import 'package:flutter/material.dart';
import '../../utils/push_log_buffer.dart';

class PushLogViewerScreen extends StatefulWidget {
  const PushLogViewerScreen({super.key});

  @override
  State<PushLogViewerScreen> createState() => _PushLogViewerScreenState();
}

class _PushLogViewerScreenState extends State<PushLogViewerScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final entries = PushLogBuffer.instance.entries;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Push logs'),
        actions: [
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
