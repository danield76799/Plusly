// SPDX-FileCopyrightText: 2019-Present Christian Kußowski
// SPDX-FileCopyrightText: 2019-Present Contributors to FluffyChat
//
// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';

import 'package:Pulsly/generated/l10n/l10n.dart';
import 'package:Pulsly/pages/bootstrap/view_model/bootstrap_view_model.dart';
import 'package:Pulsly/pages/bootstrap/widgets/new_passphrase_view.dart';
import 'package:Pulsly/pages/bootstrap/widgets/restore_bootstrap_view.dart';
import 'package:Pulsly/pages/bootstrap/widgets/store_recovery_key_view.dart';
import 'package:Pulsly/widgets/adaptive_dialogs/show_ok_cancel_alert_dialog.dart';
import 'package:Pulsly/widgets/layouts/login_scaffold.dart';
import 'package:Pulsly/widgets/matrix.dart';
import 'package:Pulsly/widgets/view_model_builder.dart';

class BootstrapPage extends StatelessWidget {
  const BootstrapPage({super.key});

  @override
  Widget build(BuildContext context) {
    // final theme = Theme.of(context);
    return ViewModelBuilder(
      create: () => BootstrapViewModel(client: Matrix.of(context).client),
      builder: (context, viewModel, _) {
        final cryptoIdentityState = viewModel.value.cryptoIdentityState;
        if (cryptoIdentityState?.connected == true) {
          WidgetsBinding.instance.addPostFrameCallback(
            (_) => viewModel.goToRoomsPageAfterSuccess(context),
          );
        }

        final title = cryptoIdentityState == null
            ? L10n.of(context).loadingPleaseWait
            : cryptoIdentityState.initialized && !viewModel.value.reset
            ? L10n.of(context).restoreCryptoIdentity
            : viewModel.value.reset
            ? viewModel.value.recoveryKey != null
                  ? L10n.of(context).youAreReadyToStart
                  : L10n.of(context).resetCryptoIdentity
            : L10n.of(context).setUpCryptoIdentity;

        return LoginScaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            leading: viewModel.value.recoveryKey != null
                ? null
                : CloseButton(
                    onPressed: () async {
                      final consent = await showOkCancelAlertDialog(
                        context: context,
                        title: L10n.of(context).skipChatBackup,
                        message: L10n.of(context).skipChatBackupWarning,
                        okLabel: L10n.of(context).skip,
                        isDestructive: true,
                      );
                      if (consent != OkCancelResult.ok) return;
                      if (!context.mounted) return;
                      context.go('/rooms');
                    },
                  ),
            title: Text(title),
          ),

          body: cryptoIdentityState == null
              ? Center(child: CircularProgressIndicator.adaptive())
              : !cryptoIdentityState.initialized || viewModel.value.reset
              ? viewModel.value.recoveryKey == null
                    ? NewPassphraseView(viewModel)
                    : StoreRecoveryKeyView(viewModel)
              : RestoreBootstrapView(viewModel),
        );
      },
    );
  }
}
