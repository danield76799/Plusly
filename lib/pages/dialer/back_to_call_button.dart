import 'package:extera_next/generated/l10n/l10n.dart';
import 'package:extera_next/widgets/matrix.dart';
import 'package:flutter/material.dart';

class BackToCallButton extends StatefulWidget {
  const BackToCallButton({super.key});

  @override
  BackToCallButtonState createState() => BackToCallButtonState();
}

class BackToCallButtonState extends State<BackToCallButton> {
  @override
  Widget build(BuildContext context) {
    final voipPlugin = Matrix.of(context).voipPlugin;

    if (voipPlugin == null || voipPlugin.currentCallSession == null) {
      return const SizedBox.shrink();
    }

    return FilledButton.tonal(
      onPressed: () {
        setState(() {
          voipPlugin.overlayMinimised = false;
          voipPlugin.overlayEntry?.markNeedsBuild();
        });
      },
      style: FilledButton.styleFrom(
        shape: const RoundedRectangleBorder(),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.call),
          const SizedBox(width: 18),
          Text(L10n.of(context).backToCall),
        ],
      ),
    );
  }
}
