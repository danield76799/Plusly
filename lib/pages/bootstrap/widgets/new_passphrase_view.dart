// SPDX-FileCopyrightText: 2019-Present Christian Kußowski
// SPDX-FileCopyrightText: 2019-Present Contributors to FluffyChat
//
// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter/material.dart';

import 'package:Pulsly/generated/l10n/l10n.dart';
import 'package:Pulsly/pages/bootstrap/view_model/bootstrap_view_model.dart';

class NewPassphraseView extends StatelessWidget {
  final BootstrapViewModel viewModel;

  const NewPassphraseView(this.viewModel, {super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final canCreatePassphrase =
        viewModel.value.newPassphraseEqualsRepeatPassphrase &&
        viewModel.value.newPassphraseNumbers &&
        viewModel.value.newPassphraseSpecialCharacters &&
        viewModel.value.newPassphraseUpperAndLowerCase &&
        viewModel.value.newPassphraseLongEnough;

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: constraints.maxHeight - 32.0,
            ),
            child: IntrinsicHeight(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    L10n.of(context).newPassphraseDescription,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    obscureText: viewModel.value.obscureText,
                    readOnly: viewModel.value.isLoading,
                    controller: viewModel.newPassphraseController,
                    decoration: InputDecoration(
                      suffixIcon: IconButton(
                        icon: Icon(
                          viewModel.value.obscureText
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                        ),
                        onPressed: viewModel.toggleObscureText,
                      ),
                      hintText: L10n.of(context).newPassphrase,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    obscureText: viewModel.value.obscureText,
                    readOnly: viewModel.value.isLoading,
                    controller: viewModel.repeatPassphraseController,
                    decoration: InputDecoration(
                      hintText: L10n.of(context).repeatPassphrase,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Column(
                      spacing: 12,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _PassphraseCheckListTile(
                          checked: viewModel
                              .value
                              .newPassphraseEqualsRepeatPassphrase,
                          label: L10n.of(context).passphrasesMatch,
                        ),
                        _PassphraseCheckListTile(
                          checked: viewModel.value.newPassphraseLongEnough,
                          label: L10n.of(context).passphraseLengthRequirement,
                        ),
                        _PassphraseCheckListTile(
                          checked:
                              viewModel.value.newPassphraseUpperAndLowerCase,
                          label: L10n.of(
                            context,
                          ).passphraseUpperAndLowerCaseRequirement,
                        ),
                        _PassphraseCheckListTile(
                          checked:
                              viewModel.value.newPassphraseSpecialCharacters,
                          label: L10n.of(
                            context,
                          ).passphraseSpecialCharactersRequirement,
                        ),
                        _PassphraseCheckListTile(
                          checked: viewModel.value.newPassphraseNumbers,
                          label: L10n.of(context).passphraseNumberRequirement,
                        ),
                      ],
                    ),
                  ),

                  const Spacer(),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: canCreatePassphrase && !viewModel.value.isLoading
                        ? () => viewModel.setOrSkipPassphrase(
                            viewModel.newPassphraseController.text,
                            context,
                          )
                        : null,
                    child: viewModel.value.isLoading
                        ? LinearProgressIndicator()
                        : Text(L10n.of(context).continueText),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: viewModel.value.isLoading
                        ? null
                        : () => viewModel.setOrSkipPassphrase(null, context),
                    style: TextButton.styleFrom(
                      foregroundColor: theme.colorScheme.error,
                    ),
                    child: Text(L10n.of(context).skip),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _PassphraseCheckListTile extends StatelessWidget {
  final String label;
  final bool checked;
  const _PassphraseCheckListTile({required this.label, required this.checked});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      spacing: 8.0,
      children: [
        Icon(
          checked ? Icons.circle : Icons.circle_outlined,
          color: checked
              ? theme.brightness == Brightness.light
                    ? Colors.green.shade800
                    : Colors.green.shade300
              : theme.colorScheme.onSurfaceVariant,
          size: 10,
        ),
        Text(label, style: theme.textTheme.bodySmall),
      ],
    );
  }
}
