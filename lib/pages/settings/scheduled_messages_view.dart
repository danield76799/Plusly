import 'package:flutter/material.dart';

import 'package:Pulsly/generated/l10n/l10n.dart';
import 'package:Pulsly/utils/scheduled_messages_service.dart';
import 'package:Pulsly/widgets/matrix.dart';

class ScheduledMessagesView extends StatefulWidget {
  const ScheduledMessagesView({super.key});

  @override
  State<ScheduledMessagesView> createState() => _ScheduledMessagesViewState();
}

class _ScheduledMessagesViewState extends State<ScheduledMessagesView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late Future<List<ScheduledMessage>> _messagesFuture;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _messagesFuture = ScheduledMessagesService.loadScheduledMessages();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _refresh() {
    setState(() {
      _messagesFuture = ScheduledMessagesService.loadScheduledMessages();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = L10n.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.scheduledMessages),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: l10n.scheduledTab),
            Tab(text: l10n.missedTab),
          ],
        ),
      ),
      body: FutureBuilder<List<ScheduledMessage>>(
        future: _messagesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator.adaptive(),
            );
          }

          final messages = snapshot.data ?? [];
          final pending =
              messages.where((m) => !m.isSent && !m.isMissed).toList();
          final missed =
              messages.where((m) => m.isMissed && !m.isSent).toList();

          return TabBarView(
            controller: _tabController,
            children: [
              _PendingTab(
                messages: pending,
                onRefresh: _refresh,
              ),
              _MissedTab(
                messages: missed,
                onRefresh: _refresh,
              ),
            ],
          );
        },
      ),
    );
  }
}

// ─── Pending Tab ────────────────────────────────────────────────────

class _PendingTab extends StatelessWidget {
  final List<ScheduledMessage> messages;
  final VoidCallback onRefresh;

  const _PendingTab({required this.messages, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = L10n.of(context);

    if (messages.isEmpty) {
      return _EmptyState(
        icon: Icons.schedule_rounded,
        title: l10n.noScheduledMessages,
        subtitle: l10n.noScheduledMessagesDescription,
      );
    }

    return RefreshIndicator.adaptive(
      onRefresh: () async => onRefresh(),
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        itemCount: messages.length,
        separatorBuilder: (_, __) => const SizedBox(height: 4),
        itemBuilder: (context, index) {
          return _PendingCard(
            message: messages[index],
            onChanged: onRefresh,
          );
        },
      ),
    );
  }
}

class _PendingCard extends StatelessWidget {
  final ScheduledMessage message;
  final VoidCallback onChanged;

  const _PendingCard({required this.message, required this.onChanged});

  String _relativeTime(BuildContext context) {
    final l10n = L10n.of(context);
    final diff = message.scheduledAt.difference(DateTime.now());

    if (diff.isNegative) return l10n.scheduledDueNow;
    if (diff.inMinutes < 60) return l10n.scheduledInMinutes(diff.inMinutes);
    if (diff.inHours < 24) return l10n.scheduledInHours(diff.inHours);
    if (diff.inDays < 7) return l10n.scheduledInDays(diff.inDays);

    final d = message.scheduledAt;
    return '${d.day}/${d.month}/${d.year} ${d.hour}:${d.minute.toString().padLeft(2, '0')}';
  }

  String _roomName(BuildContext context) {
    final client = Matrix.of(context).client;
    final room = client.getRoomById(message.roomId);
    return room?.displayname ?? message.roomId;
  }

  String _preview() {
    final body = message.content['body'] as String? ?? '';
    return body.length > 80 ? '${body.substring(0, 80)}…' : body;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = L10n.of(context);
    final isServer = message.delayId != null;

    return Dismissible(
      key: ValueKey(message.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.symmetric(vertical: 2),
        decoration: BoxDecoration(
          color: theme.colorScheme.errorContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          Icons.cancel_rounded,
          color: theme.colorScheme.onErrorContainer,
        ),
      ),
      confirmDismiss: (_) => _confirmCancel(context),
      onDismissed: (_) => _doCancel(context),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row: room name + source chip
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _roomName(context),
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  _SourceChip(isServer: isServer),
                ],
              ),
              const SizedBox(height: 6),

              // Message preview
              Text(
                _preview(),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 10),

              // Footer: time + cancel button
              Row(
                children: [
                  Icon(
                    Icons.access_time_rounded,
                    size: 14,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _relativeTime(context),
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: () => _confirmCancel(context).then((yes) {
                      if (yes == true) _doCancel(context);
                    }),
                    icon: const Icon(Icons.cancel_outlined, size: 16),
                    label: Text(l10n.cancelMessage),
                    style: TextButton.styleFrom(
                      foregroundColor: theme.colorScheme.error,
                      visualDensity: VisualDensity.compact,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool?> _confirmCancel(BuildContext context) {
    final l10n = L10n.of(context);
    final isServer = message.delayId != null;

    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.cancelScheduledMessage),
        content: Text(
          isServer
              ? l10n.cancelServerScheduledDescription
              : l10n.cancelLocalScheduledDescription,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.keep),
          ),
          FilledButton.tonal(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n.cancelMessage),
          ),
        ],
      ),
    );
  }

  Future<void> _doCancel(BuildContext context) async {
    final l10n = L10n.of(context);
    final isServer = message.delayId != null;

    if (isServer) {
      final client = Matrix.of(context).client;
      final success =
          await ScheduledMessagesService.cancelScheduledMessage(client, message.id);
      if (!success && context.mounted) {
        await ScheduledMessagesService.removeScheduledMessage(message.id);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.serverCancelNotSupported),
              duration: const Duration(seconds: 4),
            ),
          );
        }
      }
    } else {
      await ScheduledMessagesService.removeScheduledMessage(message.id);
    }
    onChanged();
  }
}

// ─── Missed Tab ─────────────────────────────────────────────────────

class _MissedTab extends StatelessWidget {
  final List<ScheduledMessage> messages;
  final VoidCallback onRefresh;

  const _MissedTab({required this.messages, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);

    if (messages.isEmpty) {
      return _EmptyState(
        icon: Icons.check_circle_rounded,
        title: l10n.noMissedMessages,
        subtitle: l10n.noMissedMessagesDescription,
      );
    }

    return RefreshIndicator.adaptive(
      onRefresh: () async => onRefresh(),
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        itemCount: messages.length,
        separatorBuilder: (_, __) => const SizedBox(height: 4),
        itemBuilder: (context, index) {
          return _MissedCard(
            message: messages[index],
            onChanged: onRefresh,
          );
        },
      ),
    );
  }
}

class _MissedCard extends StatelessWidget {
  final ScheduledMessage message;
  final VoidCallback onChanged;

  const _MissedCard({required this.message, required this.onChanged});

  String _missedTime() {
    final d = message.missedAt ?? message.scheduledAt;
    return '${d.day}/${d.month}/${d.year} ${d.hour}:${d.minute.toString().padLeft(2, '0')}';
  }

  String _roomName(BuildContext context) {
    final client = Matrix.of(context).client;
    final room = client.getRoomById(message.roomId);
    return room?.displayname ?? message.roomId;
  }

  String _preview() {
    final body = message.content['body'] as String? ?? '';
    return body.length > 80 ? '${body.substring(0, 80)}…' : body;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = L10n.of(context);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: theme.colorScheme.errorContainer.withValues(alpha: 0.5),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              children: [
                Icon(
                  Icons.error_outline_rounded,
                  size: 18,
                  color: theme.colorScheme.error,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    _roomName(context),
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),

            // Message preview
            Text(
              _preview(),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 10),

            // Footer: missed time + action buttons
            Row(
              children: [
                Icon(
                  Icons.access_time_rounded,
                  size: 14,
                  color: theme.colorScheme.error,
                ),
                const SizedBox(width: 4),
                Text(
                  l10n.scheduledMissedAt(_missedTime()),
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.error,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: () => _sendNow(context),
                  icon: const Icon(Icons.send_rounded, size: 16),
                  label: Text(l10n.sendNow),
                  style: TextButton.styleFrom(
                    foregroundColor: theme.colorScheme.primary,
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                ),
                TextButton.icon(
                  onPressed: () => _confirmDelete(context),
                  icon: const Icon(Icons.delete_outline_rounded, size: 16),
                  label: Text(l10n.deleteScheduled),
                  style: TextButton.styleFrom(
                    foregroundColor: theme.colorScheme.error,
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _sendNow(BuildContext context) async {
    final l10n = L10n.of(context);
    try {
      final client = Matrix.of(context).client;
      final success =
          await ScheduledMessagesService.sendMissedMessage(client, message.id);
      if (success && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.messageSentManually)),
        );
        onChanged();
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.errorSendingMessage)),
        );
      }
    }
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final l10n = L10n.of(context);

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.deleteMissedMessage),
        content: Text(l10n.deleteMissedMessageDescription),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton.tonal(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n.deleteScheduled),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await ScheduledMessagesService.removeScheduledMessage(message.id);
      onChanged();
    }
  }
}

// ─── Shared Widgets ─────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _EmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 56,
              color: theme.colorScheme.primary.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _SourceChip extends StatelessWidget {
  final bool isServer;

  const _SourceChip({required this.isServer});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = L10n.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isServer
            ? theme.colorScheme.primaryContainer
            : theme.colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isServer ? Icons.cloud_outlined : Icons.phone_android_rounded,
            size: 12,
            color: isServer
                ? theme.colorScheme.onPrimaryContainer
                : theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 4),
          Text(
            isServer ? l10n.serverScheduled : l10n.localScheduled,
            style: theme.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w500,
              color: isServer
                  ? theme.colorScheme.onPrimaryContainer
                  : theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
