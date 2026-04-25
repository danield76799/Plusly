import 'package:extera_next/generated/l10n/l10n.dart';
import 'package:flutter/material.dart';

import 'package:extera_next/pages/register/register.dart';

class EmailStage extends StatefulWidget {
  final RegisterController controller;

  const EmailStage({required this.controller, super.key});

  @override
  State<EmailStage> createState() => _EmailStageState();
}

class _EmailStageState extends State<EmailStage> {
  bool _emailSent = false;

  Future<void> _sendVerification() async {
    final email = widget.controller.emailController.text.trim();
    if (email.isEmpty) {
      widget.controller.updateState(() {
        widget.controller.emailError = L10n.of(context).pleaseEnterEmailAddress;
      });
      return;
    }
    final emailPattern = RegExp(
      r"""(?:[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*|"(?:[\x01-\x08\x0b\x0c\x0e-\x1f\x21\x23-\x5b\x5d-\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])*")@(?:(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\[(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?|[a-z0-9-]*[a-z0-9]:(?:[\x01-\x08\x0b\x0c\x0e-\x1f\x21-\x5a\x53-\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])+)\])""",
    );
    if (!emailPattern.hasMatch(email)) {
      widget.controller.updateState(() {
        widget.controller.emailError = L10n.of(context).invalidEmail;
      });
      return;
    }
    await widget.controller.requestEmailToken(email);
    if (widget.controller.emailError == null) {
      setState(() => _emailSent = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: ListView(
              children: [
                Icon(
                  _emailSent
                      ? Icons.mark_email_read_outlined
                      : Icons.email_outlined,
                  size: 48,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(height: 16),
                Text(
                  L10n.of(context).emailVerification,
                  style: theme.textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  _emailSent
                      ? L10n.of(context).verificationEmailSent
                      : L10n.of(context).serverRequiresEmail,
                  style: theme.textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                if (!_emailSent)
                  TextField(
                    readOnly: widget.controller.loading,
                    controller: widget.controller.emailController,
                    keyboardType: TextInputType.emailAddress,
                    autocorrect: false,
                    autofillHints: widget.controller.loading
                        ? null
                        : [AutofillHints.email],
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.email_outlined),
                      labelText: L10n.of(context).emailAddress,
                      hintText: 'user@example.com',
                      errorText: widget.controller.emailError,
                      errorStyle: TextStyle(color: theme.colorScheme.error),
                    ),
                  ),
              ],
            ),
          ),
          if (!_emailSent)
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
              ),
              onPressed: widget.controller.loading ? null : _sendVerification,
              child: widget.controller.loading
                  ? const LinearProgressIndicator()
                  : Text(L10n.of(context).sendVerificationEmail),
            )
          else ...[
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
              ),
              onPressed: widget.controller.loading
                  ? null
                  : widget.controller.completeEmailStage,
              child: widget.controller.loading
                  ? const LinearProgressIndicator()
                  : Text(L10n.of(context).iHaveVerifiedMyEmail),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: widget.controller.loading
                  ? null
                  : () {
                      setState(() => _emailSent = false);
                    },
              child: Text(L10n.of(context).useDifferentEmail),
            ),
          ],
        ],
      ),
    );
  }
}
