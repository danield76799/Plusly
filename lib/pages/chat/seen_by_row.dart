import 'package:flutter/material.dart';
import 'package:matrix/matrix.dart';

import 'package:Pulsly/config/app_config.dart';
import 'package:Pulsly/config/themes.dart';
import 'package:Pulsly/generated/l10n/l10n.dart';
import 'package:Pulsly/utils/adaptive_bottom_sheet.dart';
import 'package:Pulsly/utils/date_time_extension.dart';
import 'package:Pulsly/widgets/avatar.dart';
import 'package:Pulsly/widgets/list_divider.dart';
import 'package:Pulsly/widgets/matrix.dart';

class SeenByRow extends StatelessWidget {
  final Event event;
  const SeenByRow({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    const maxAvatars = 7;
    return StreamBuilder(
      stream: event.room.client.onSync.stream.where(
        (syncUpdate) =>
            syncUpdate.rooms?.join?[event.room.id]?.ephemeral?.any(
              (ephemeral) => ephemeral.type == 'm.receipt',
            ) ??
            false,
      ),
      builder: (context, asyncSnapshot) {
        final seenByUsers = event.receipts
            .map((r) => r.user)
            .where(
              (user) =>
                  user.id != event.room.client.userID &&
                  user.id != event.senderId,
            )
            .toList();
        return Container(
          width: double.infinity,
          alignment: Alignment.center,
          child: AnimatedContainer(
            constraints: const BoxConstraints(
              maxWidth: FluffyThemes.columnWidth * 2.5,
            ),
            height: seenByUsers.isEmpty ? 0 : 24,
            duration: seenByUsers.isEmpty
                ? Duration.zero
                : FluffyThemes.animationDuration,
            curve: FluffyThemes.animationCurve,
            alignment: event.senderId == Matrix.of(context).client.userID
                ? Alignment.topRight
                : Alignment.topLeft,
            padding: const EdgeInsets.only(
              bottom: 4,
              top: 1,
              left: 8,
              right: 8,
            ),
            child: Wrap(
              spacing: 4,
              children: [
                ...(seenByUsers.length > maxAvatars
                        ? seenByUsers.sublist(0, maxAvatars)
                        : seenByUsers)
                    .map(
                      (user) => Avatar(
                        mxContent: user.avatarUrl,
                        name: user.calcDisplayname(),
                        size: 16,
                      ),
                    ),
                if (seenByUsers.length > maxAvatars)
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: Material(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(32),
                      child: Center(
                        child: Text(
                          '+${seenByUsers.length - maxAvatars}',
                          style: const TextStyle(fontSize: 9),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class SeenByDialog extends StatelessWidget {
  final List<Receipt> receipts;

  const SeenByDialog(this.receipts, {super.key});

  Future<bool?> show(BuildContext context) =>
      showAdaptiveBottomSheet(context: context, builder: (context) => this);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(L10n.of(context).readReceipts)),
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: Material(
          clipBehavior: Clip.hardEdge,
          color: theme.colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(AppConfig.borderRadius),
          child: ListView.builder(
            itemCount: receipts.length,
            itemBuilder: (context, i) {
              final receipt = receipts[i];
              return Column(
                children: [
                  ListTile(
                    leading: Avatar(
                      mxContent: receipt.user.avatarUrl,
                      name: receipt.user.displayName,
                      size: 24,
                    ),
                    title: Text(receipt.user.calcDisplayname()),
                    subtitle: Text(receipt.time.localizedTime(context)),
                  ),
                  const ListDivider(),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
