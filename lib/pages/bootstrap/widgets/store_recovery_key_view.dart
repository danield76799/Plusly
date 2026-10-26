// SPDX-FileCopyrightText: 2019-Present Christian Kußowski
// SPDX-FileCopyrightText: 2019-Present Contributors to FluffyChat
//
// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';

import 'package:Pulsly/generated/l10n/l10n.dart';
import 'package:Pulsly/pages/bootstrap/view_model/bootstrap_view_model.dart';
import 'package:Pulsly/utils/fluffy_share.dart';
import 'package:Pulsly/utils/platform_infos.dart';

class StoreRecoveryKeyView extends StatelessWidget {
  final BootstrapViewModel viewModel;
  const StoreRecoveryKeyView(this.viewModel, {super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: .stretch,
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              Text(L10n.of(context).storeRecoveryKeyDescription),
              const SizedBox(height: 16),
              TextField(
                controller: TextEditingController(
                  text: viewModel.value.recoveryKey,
                ),
                readOnly: true,
                minLines: 2,
                maxLines: 4,
                style: const TextStyle(fontFamily: 'RobotoMono'),
                decoration: InputDecoration(
                  suffixIcon: IconButton(
                    icon: Icon(Icons.copy_outlined),
                    onPressed: () => FluffyShare.share(
                      viewModel.value.recoveryKey!,
                      context,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              CheckboxListTile.adaptive(
                value: viewModel.value.recoveryKeyDownloaded,
                onChanged: (copied) =>
                    viewModel.toggleRecoveryKeyDownloaded(copied, context),
                title: Text(L10n.of(context).saveAsFile),
              ),
              if (viewModel.supportsSecureStorage)
                CheckboxListTile.adaptive(
                  value: viewModel.value.recoveryKeyStoredInSecureStorage,
                  onChanged: viewModel.toggleRecoveryKeyStoredInSecureStorage,
                  title: Text(_getSecureStorageLocalizedName(context)),
                ),
            ],
          ),
        ),
        Padding(
          padding: const .all(24),
          child: ElevatedButton(
            onPressed: () {
              context.go('/rooms');
            },
            child: Text(L10n.of(context).continueText),
          ),
        ),
      ],
    );
  }

  String _getSecureStorageLocalizedName(BuildContext context) {
    if (PlatformInfos.isAndroid) {
      return L10n.of(context).storeInAndroidKeystore;
    }
    if (PlatformInfos.isIOS || PlatformInfos.isMacOS) {
      return L10n.of(context).storeInAppleKeyChain;
    }
    return L10n.of(context).storeSecurlyOnThisDevice;
  }
}
