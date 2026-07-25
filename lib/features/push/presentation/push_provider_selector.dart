import 'dart:io';

import 'package:flutter/material.dart';

import 'package:Pulsly/generated/l10n/l10n.dart';
import '../domain/push_provider.dart';
import '../domain/push_state.dart';
import 'push_controller.dart';

/// Widget voor het selecteren van de push provider in settings.
///
/// Toont de huidige status en laat de gebruiker UnifiedPush configureren.
/// Alleen UnifiedPush — geen Firebase.
class PushProviderSelector extends StatelessWidget {
  final PushController controller;

  const PushProviderSelector({required this.controller, super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final state = controller.state;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatusTile(context, state, l10n),
            if (state.isActive) ...[
              const Divider(),
              _buildProviderTile(
                context,
                l10n: l10n,
                title: 'UnifiedPush',
                subtitle: l10n.unifiedPushPrivacy,
                icon: Icons.security,
                isSelected:
                    state.activeProvider == PushProviderType.unifiedPush,
                onTap: () =>
                    controller.switchProvider(PushProviderType.unifiedPush),
                isAvailable: Platform.isAndroid,
              ),
            ],
            if (state.isFailed)
              ListTile(
                leading: const Icon(Icons.error, color: Colors.red),
                title: Text(l10n.pushError),
                subtitle:
                    Text(state.errorMessage ?? l10n.pushUnknownError),
              ),
          ],
        );
      },
    );
  }

  Widget _buildStatusTile(
    BuildContext context,
    PushState state,
    L10n l10n,
  ) {
    final theme = Theme.of(context);

    IconData icon;
    Color color;
    String status;

    switch (state.status) {
      case PushStatus.active:
        icon = Icons.notifications_active;
        color = Colors.green;
        status = l10n.pushStatusActive(
          state.activeProvider?.name ?? l10n.pushUnknownProvider,
        );
      case PushStatus.initializing:
        icon = Icons.sync;
        color = Colors.orange;
        status = l10n.pushStatusInitializing;
      case PushStatus.failed:
        icon = Icons.error;
        color = Colors.red;
        status = l10n.pushStatusFailed;
      case PushStatus.disabled:
        icon = Icons.notifications_off;
        color = Colors.grey;
        status = l10n.pushStatusDisabled;
      case PushStatus.initial:
        icon = Icons.notifications;
        color = theme.colorScheme.primary;
        status = l10n.pushStatusInitial;
    }

    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(l10n.pushNotificationsLabel),
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
    required L10n l10n,
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
              : Text(l10n.notApplicable),
      onTap: isAvailable ? onTap : null,
    );
  }
}
