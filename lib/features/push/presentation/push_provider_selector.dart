import 'dart:io';

import 'package:flutter/material.dart';

import '../domain/push_provider.dart';
import '../domain/push_state.dart';
import 'push_controller.dart';

/// Widget voor het selecteren van de push provider in settings.
///
/// Toont de huidige status en laat de gebruiker switchen tussen
/// UnifiedPush (Android) en Firebase Cloud Messaging.
class PushProviderSelector extends StatelessWidget {
  final PushController controller;

  const PushProviderSelector({required this.controller, super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final state = controller.state;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatusTile(context, state),
            if (state.isActive) ...[
              const Divider(),
              _buildProviderTile(
                context,
                title: 'UnifiedPush',
                subtitle: 'Privacy-vriendelijk, geen Google',
                icon: Icons.security,
                isSelected: state.activeProvider == PushProviderType.unifiedPush,
                onTap: () => controller.switchProvider(PushProviderType.unifiedPush),
                isAvailable: Platform.isAndroid,
              ),
              _buildProviderTile(
                context,
                title: 'Firebase Cloud Messaging',
                subtitle: 'Google push dienst',
                icon: Icons.cloud,
                isSelected: state.activeProvider == PushProviderType.firebase,
                onTap: () => controller.switchProvider(PushProviderType.firebase),
                isAvailable: true,
              ),
            ],
            if (state.isFailed)
              ListTile(
                leading: const Icon(Icons.error, color: Colors.red),
                title: const Text('Push fout'),
                subtitle: Text(state.errorMessage ?? 'Onbekende fout'),
              ),
          ],
        );
      },
    );
  }

  Widget _buildStatusTile(BuildContext context, PushState state) {
    final theme = Theme.of(context);
    
    IconData icon;
    Color color;
    String status;
    
    switch (state.status) {
      case PushStatus.active:
        icon = Icons.notifications_active;
        color = Colors.green;
        status = 'Actief: ${state.activeProvider?.name ?? 'onbekend'}';
      case PushStatus.initializing:
        icon = Icons.sync;
        color = Colors.orange;
        status = 'Initialiseren...';
      case PushStatus.failed:
        icon = Icons.error;
        color = Colors.red;
        status = 'Mislukt';
      case PushStatus.disabled:
        icon = Icons.notifications_off;
        color = Colors.grey;
        status = 'Uitgeschakeld';
      case PushStatus.initial:
        icon = Icons.notifications;
        color = theme.colorScheme.primary;
        status = 'Nog niet gestart';
    }

    return ListTile(
      leading: Icon(icon, color: color),
      title: const Text('Push notificaties'),
      subtitle: Text(status),
      trailing: state.isInitializing
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : null,
    );
  }

  Widget _buildProviderTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
    required bool isAvailable,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      enabled: isAvailable,
      trailing: isSelected
          ? const Icon(Icons.check_circle, color: Colors.green)
          : isAvailable
              ? const Icon(Icons.circle_outlined)
              : const Text('N/A'),
      onTap: isAvailable ? onTap : null,
    );
  }
}
