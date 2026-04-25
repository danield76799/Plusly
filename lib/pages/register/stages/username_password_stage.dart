import 'package:extera_next/generated/l10n/l10n.dart';
import 'package:flutter/material.dart';

import 'package:extera_next/pages/register/register.dart';

class UsernamePasswordStage extends StatelessWidget {
  final RegisterController controller;

  const UsernamePasswordStage({required this.controller, super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final homeserver = controller.widget.client.homeserver
        ?.toString()
        .replaceFirst('https://', '');

    return AutofillGroup(
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        children: [
          const SizedBox(height: 16),
          Hero(
            tag: 'info-logo',
            child: Image.asset('assets/banner_transparent.png'),
          ),
          const SizedBox(height: 16),
          if (homeserver != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Text(
                L10n.of(context).registerOn(homeserver),
                style: theme.textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
            ),
          TextField(
            readOnly: controller.loading,
            autocorrect: false,
            autofocus: true,
            controller: controller.usernameController,
            onChanged: controller.checkUsernameWithCoolDown,
            textInputAction: TextInputAction.next,
            keyboardType: TextInputType.text,
            autofillHints: controller.loading
                ? null
                : [AutofillHints.newUsername],
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.person_outlined),
              labelText: L10n.of(context).username,
              errorText: controller.usernameError,
              errorStyle: TextStyle(color: theme.colorScheme.error),
              suffixIcon: controller.checkingUsername
                  ? const Padding(
                      padding: EdgeInsets.all(12.0),
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : controller.usernameAvailable &&
                        controller.usernameController.text.isNotEmpty
                  ? const Icon(Icons.check_circle, color: Colors.green)
                  : null,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            readOnly: controller.loading,
            autocorrect: false,
            controller: controller.passwordController,
            textInputAction: TextInputAction.next,
            obscureText: !controller.showPassword,
            autofillHints: controller.loading
                ? null
                : [AutofillHints.newPassword],
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.lock_outlined),
              labelText: L10n.of(context).password,
              errorText: controller.passwordError,
              errorStyle: TextStyle(color: theme.colorScheme.error),
              suffixIcon: IconButton(
                onPressed: controller.toggleShowPassword,
                icon: Icon(
                  controller.showPassword
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            readOnly: controller.loading,
            autocorrect: false,
            controller: controller.confirmPasswordController,
            textInputAction: TextInputAction.go,
            obscureText: !controller.showPassword,
            onSubmitted: (_) => controller.startRegistration(),
            autofillHints: controller.loading
                ? null
                : [AutofillHints.newPassword],
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.lock_outlined),
              labelText: L10n.of(context).repeatPassword,
              errorText: controller.confirmPasswordError,
              errorStyle: TextStyle(color: theme.colorScheme.error),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
            ),
            onPressed: controller.loading ? null : controller.startRegistration,
            child: controller.loading
                ? const LinearProgressIndicator()
                : Text(L10n.of(context).next),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
