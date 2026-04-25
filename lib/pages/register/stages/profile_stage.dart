import 'dart:io';

import 'package:extera_next/generated/l10n/l10n.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:extera_next/pages/register/register.dart';

class ProfileStage extends StatelessWidget {
  final RegisterController controller;

  const ProfileStage({required this.controller, super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.all(24.0),
      children: [
        const SizedBox(height: 16),
        Icon(
          Icons.celebration_outlined,
          size: 48,
          color: theme.colorScheme.primary,
        ),
        const SizedBox(height: 16),
        Text(
          L10n.of(context).welcome,
          style: theme.textTheme.headlineSmall,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          L10n.of(context).yourAccountWasCreated,
          style: theme.textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        Center(
          child: Stack(
            children: [
              CircleAvatar(
                radius: 56,
                backgroundColor: theme.colorScheme.secondaryContainer,
                backgroundImage: controller.avatarFile != null
                    ? _getAvatarImage(controller)
                    : null,
                child: controller.avatarFile == null
                    ? Icon(
                        Icons.person_outlined,
                        size: 48,
                        color: theme.colorScheme.onSecondaryContainer,
                      )
                    : null,
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: CircleAvatar(
                  radius: 18,
                  backgroundColor: theme.colorScheme.primary,
                  child: IconButton(
                    iconSize: 18,
                    padding: EdgeInsets.zero,
                    icon: Icon(
                      Icons.camera_alt_outlined,
                      color: theme.colorScheme.onPrimary,
                    ),
                    onPressed: controller.loading
                        ? null
                        : controller.pickAvatar,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        TextField(
          readOnly: controller.loading,
          controller: controller.displayNameController,
          textInputAction: TextInputAction.done,
          textCapitalization: TextCapitalization.words,
          onSubmitted: (_) => controller.completeProfile(),
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.badge_outlined),
            labelText: L10n.of(context).displayname,
            hintText: L10n.of(context).displaynameHint,
          ),
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: theme.colorScheme.onPrimary,
          ),
          onPressed: controller.loading ? null : controller.completeProfile,
          child: controller.loading
              ? const LinearProgressIndicator()
              : Text(L10n.of(context).completeSetup),
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: controller.loading ? null : controller.skipProfile,
          child: Text(L10n.of(context).skip),
        ),
      ],
    );
  }

  ImageProvider? _getAvatarImage(RegisterController controller) {
    if (controller.avatarFile == null) return null;
    if (kIsWeb) {
      return NetworkImage(controller.avatarFile!.path);
    }
    return FileImage(File(controller.avatarFile!.path));
  }
}
