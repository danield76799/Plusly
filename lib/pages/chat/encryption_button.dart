import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';
import 'package:matrix/matrix.dart';

import 'package:Pulsly/generated/l10n/l10n.dart';
import '../../widgets/matrix.dart';

class EncryptionButton extends StatelessWidget {
  final Room room;
  const EncryptionButton(this.room, {super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<SyncUpdate>(
      stream: Matrix.of(
        context,
      ).client.onSync.stream.where((s) => s.deviceLists != null),
      builder: (context, snapshot) {
        return FutureBuilder<EncryptionHealthState>(
          future: room.encrypted
              ? room.calcEncryptionHealthState()
              : Future.value(EncryptionHealthState.allVerified),
          builder: (BuildContext context, snapshot) => IconButton(
            tooltip: room.encrypted
                ? L10n.of(context).encrypted
                : L10n.of(context).encryptionNotEnabled,
            icon: Icon(
              room.encrypted ? Icons.lock_outlined : Icons.lock_open_outlined,
              size: 20,
              // Red is reserved for destructive actions (block/delete). For the
              // E2EE indicator we use a subtle green when encrypted, and amber
              // as a non-destructive warning when unencrypted / unverified.
              color: !room.encrypted
                  ? Colors.orange
                  : snapshot.data == EncryptionHealthState.unverifiedDevices
                      ? Colors.orange
                      : Colors.green,
            ),
            onPressed: () => context.go('/rooms/${room.id}/encryption'),
          ),
        );
      },
    );
  }
}
