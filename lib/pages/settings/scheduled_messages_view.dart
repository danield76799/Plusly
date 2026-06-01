import 'package:flutter/material.dart';

import 'package:Pulsly/generated/l10n/l10n.dart';
import 'package:Pulsly/utils/scheduled_messages_service.dart';
import 'package:Pulsly/widgets/matrix.dart';

class ScheduledMessagesView extends StatefulWidget {
  const ScheduledMessagesView({super.key});

  @override
  State<ScheduledMessagesView> createState() => _ScheduledMessagesViewState();
}

class _ScheduledMessagesViewState extends State<ScheduledMessagesView> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(L10n.of(context).chatBackup),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Gepland', icon: Icon(Icons.schedule)),
            Tab(text: 'Gemist', icon: Icon(Icons.error_outline)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _PendingMessagesTab(),
          _MissedMessagesTab(),
        ],
      ),
    );
  }
}

class _PendingMessagesTab extends StatefulWidget {
  const _PendingMessagesTab();

  @override
  State<_PendingMessagesTab> createState() => _PendingMessagesTabState();
}

class _PendingMessagesTabState extends State<_PendingMessagesTab> {
  Future<List<ScheduledMessage>> _loadMessages() async {
    return await ScheduledMessagesService.loadScheduledMessages();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<ScheduledMessage>>(
      future: _loadMessages(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator.adaptive());
        }

        final messages = snapshot.data ?? [];
        final pendingMessages = messages.where((m) => !m.isSent && !m.isMissed).toList();

        if (pendingMessages.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.schedule_outlined,
                  size: 64,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(height: 16),
                Text(
                  'No scheduled messages',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'Messages you schedule will appear here',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: pendingMessages.length,
          itemBuilder: (context, index) {
            final message = pendingMessages[index];
            return _ScheduledMessageTile(
              message: message,
              onCancel: () => setState(() {}),  // ← Ververs de lijst!
            );
          },
        );
      },
    );
  }
}

class _MissedMessagesTab extends StatelessWidget {
  const _MissedMessagesTab();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<ScheduledMessage>>(
      future: ScheduledMessagesService.loadScheduledMessages(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator.adaptive());
        }

        final messages = snapshot.data ?? [];
        final missedMessages = messages.where((m) => m.isMissed && !m.isSent).toList();

        if (missedMessages.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.check_circle_outline,
                  size: 64,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(height: 16),
                Text(
                  'Geen gemiste berichten',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'Alle geplande berichten zijn verstuurd',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: missedMessages.length,
          itemBuilder: (context, index) {
            final message = missedMessages[index];
            return _MissedMessageTile(message: message);
          },
        );
      },
    );
  }
}

class _MissedMessageTile extends StatelessWidget {
  final ScheduledMessage message;

  const _MissedMessageTile({required this.message});

  String _formatMissedTime(BuildContext context) {
    final missed = message.missedAt ?? message.scheduledAt;
    return '${missed.day}/${missed.month}/${missed.year} at ${missed.hour}:${missed.minute.toString().padLeft(2, '0')}';
  }

  String _getRoomName(BuildContext context) {
    final client = Matrix.of(context).client;
    final room = client.getRoomById(message.roomId);
    return room?.displayname ?? 'Unknown room';
  }

  String _getMessagePreview() {
    final body = message.content['body'] as String? ?? '';
    if (body.length > 50) {
      return '${body.substring(0, 50)}...';
    }
    return body;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: theme.colorScheme.errorContainer,
        child: Icon(
          Icons.error_outline,
          color: theme.colorScheme.onErrorContainer,
        ),
      ),
      title: Text(
        _getRoomName(context),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _getMessagePreview(),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(
                Icons.access_time,
                size: 14,
                color: theme.colorScheme.error,
              ),
              const SizedBox(width: 4),
              Text(
                'Gemist: ${_formatMissedTime(context)}',
                style: TextStyle(
                  fontSize: 12,
                  color: theme.colorScheme.error,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ElevatedButton.icon(
            onPressed: () async {
              try {
                final client = Matrix.of(context).client;
                final success = await ScheduledMessagesService.sendMissedMessage(client, message.id);
                if (success && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Bericht handmatig verstuurd!')),
                  );
                  // Force rebuild
                  (context as Element).markNeedsBuild();
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Fout bij versturen: $e')),
                  );
                }
              }
            },
            icon: const Icon(Icons.send, size: 16),
            label: const Text('Verstuur'),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: Icon(Icons.delete_outline, color: theme.colorScheme.error),
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Gemist bericht verwijderen?'),
                  content: const Text('Dit bericht wordt niet verstuurd.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('Annuleren'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: Text(
                        'Verwijderen',
                        style: TextStyle(color: theme.colorScheme.error),
                      ),
                    ),
                  ],
                ),
              );

              if (confirm == true) {
                await ScheduledMessagesService.removeScheduledMessage(message.id);
                if (context.mounted) {
                  (context as Element).markNeedsBuild();
                }
              }
            },
          ),
        ],
      ),
      isThreeLine: true,
    );
  }
}

class _ScheduledMessageTile extends StatelessWidget {
  final ScheduledMessage message;
  final VoidCallback? onCancel;

  const _ScheduledMessageTile({required this.message, this.onCancel});

  String _formatScheduledTime(BuildContext context) {
    final scheduled = message.scheduledAt;
    final now = DateTime.now();
    final diff = scheduled.difference(now);

    if (diff.isNegative) {
      return 'Due now';
    }

    if (diff.inMinutes < 60) {
      return 'In ${diff.inMinutes} minutes';
    }

    if (diff.inHours < 24) {
      return 'In ${diff.inHours} hours';
    }

    if (diff.inDays < 7) {
      return 'In ${diff.inDays} days';
    }

    // Format as date
    return '${scheduled.day}/${scheduled.month}/${scheduled.year} at ${scheduled.hour}:${scheduled.minute.toString().padLeft(2, '0')}';
  }

  String _getRoomName(BuildContext context) {
    final client = Matrix.of(context).client;
    final room = client.getRoomById(message.roomId);
    return room?.displayname ?? 'Unknown room';
  }

  String _getMessagePreview() {
    final body = message.content['body'] as String? ?? '';
    if (body.length > 50) {
      return '${body.substring(0, 50)}...';
    }
    return body;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: theme.colorScheme.primaryContainer,
        child: Icon(
          Icons.schedule,
          color: theme.colorScheme.onPrimaryContainer,
        ),
      ),
      title: Text(
        _getRoomName(context),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _getMessagePreview(),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(
                Icons.access_time,
                size: 14,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 4),
              Text(
                _formatScheduledTime(context),
                style: TextStyle(
                  fontSize: 12,
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
      trailing: IconButton(
        icon: Icon(Icons.delete_outline, color: theme.colorScheme.error),
        onPressed: () async {
          final isServerScheduled = message.delayId != null;
          
          final confirm = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Cancel scheduled message?'),
              content: Text(
                isServerScheduled
                    ? 'This will cancel the message on the server so it will not be sent.'
                    : 'This message is scheduled locally. It will only be removed from this device.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Keep'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Text(
                    'Cancel',
                    style: TextStyle(color: theme.colorScheme.error),
                  ),
                ),
              ],
            ),
          );

          if (confirm == true) {
            final client = Matrix.of(context).client;
            if (isServerScheduled) {
              // Try server-side cancel first
              final success = await ScheduledMessagesService.cancelScheduledMessage(client, message.id);
              if (!success && context.mounted) {
                // Server doesn't support cancel — message will still be sent
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Server does not support cancellation. Message will still be sent.'),
                    duration: Duration(seconds: 5),
                  ),
                );
                return;
              }
            } else {
              await ScheduledMessagesService.removeScheduledMessage(message.id);
            }
            onCancel?.call();
          }
        },
      ),
      isThreeLine: true,
    );
  }
}
