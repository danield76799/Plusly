import 'package:flutter/material.dart';

extension LoadingSnackbarExtension on ScaffoldMessengerState {
  ScaffoldFeatureController<SnackBar, SnackBarClosedReason> showLoadingSnackBar(
    String title, {
    VoidCallback? onCancel,
  }) {
    clearSnackBars();
    return showSnackBar(
      SnackBar(
        duration: const Duration(minutes: 5),
        dismissDirection: DismissDirection.none,
        showCloseIcon: true,
        action: onCancel != null
            ? SnackBarAction(
                label: 'Stop',
                onPressed: onCancel,
              )
            : null,
        content: Row(
          children: [
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator.adaptive(strokeWidth: 2),
            ),
            const SizedBox(width: 16),
            Expanded(child: Text(title)),
          ],
        ),
      ),
    );
  }
}
