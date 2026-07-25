import 'dart:io';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:app_settings/app_settings.dart' as app_settings;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:matrix/matrix.dart';
import 'package:Pulsly/generated/l10n/l10n.dart';

/// Key om te onthouden of het first-launch setup-scherm al getoond is.
const String _firstLaunchSetupDoneKey = 'plusly_first_launch_setup_done';

/// Toont bij de allereerste app-start een scherm dat de gebruiker helpt
/// meldingen toe te staan en batterijoptimalisatie uit te zetten. Beide zijn
/// nodig voor betrouwbare push-ontvangst op Android.
///
/// Android blokkeert het vragen van notificatie-toestemming bij installatie,
/// dus dit moet bij eerste gebruik. Batterijoptimalisatie is geen permission
/// die bij installatie gevraagd kan worden; we leiden de gebruiker er met
/// één tap naartoe.
Future<void> maybeShowFirstLaunchSetup(BuildContext context) async {
  // Alleen op Android en alleen bij de allereerste start.
  if (!Platform.isAndroid) return;
  if (!context.mounted) return;

  final prefs = await SharedPreferences.getInstance();
  final alreadyDone = prefs.getBool(_firstLaunchSetupDoneKey) ?? false;
  if (alreadyDone) return;

  // Markeer meteen zodat we niet per ongeluk dubbel tonen bij snelle rebuilds.
  await prefs.setBool(_firstLaunchSetupDoneKey, true);

  if (!context.mounted) return;
  await _runSetupFlow(context);
}

/// Toont het push-instellingen scherm op aanvraag (bijv. vanuit
/// Instellingen → Meldingen). In tegenstelling tot [maybeShowFirstLaunchSetup]
/// wordt dit altijd getoond, ongeacht of het al eerder is gezien.
Future<void> showFirstLaunchSetup(BuildContext context) async {
  if (!Platform.isAndroid) return;
  if (!context.mounted) return;
  await _runSetupFlow(context);
}

/// De daadwerkelijke flow: dialog + permission requests.
Future<void> _runSetupFlow(BuildContext context) async {
  final l10n = L10n.of(context);
  final scaffoldMessenger = ScaffoldMessenger.of(context);

  await showAdaptiveDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => AlertDialog(
      title: Text(l10n.pushSetupDialogTitle),
      content: Text(l10n.pushSetupDialogBody),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(false),
          child: Text(l10n.skip),
        ),
        FilledButton(
          onPressed: () => Navigator.of(ctx).pop(true),
          child: Text(l10n.setup),
        ),
      ],
    ),
  );

  if (!context.mounted) return;

  // 1. Meldingen
  try {
    final status = await Permission.notification.status;
    if (!status.isGranted) {
      final result = await Permission.notification.request();
      if (!result.isGranted && context.mounted) {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text(l10n.pushNotificationsDenied),
            action: SnackBarAction(
              label: l10n.settings,
              onPressed: () => app_settings.AppSettings.openAppSettings(),
            ),
          ),
        );
      }
    }
  } on Object catch (e) {
    Logs().w('Notification permission request failed', e);
  }

  // 2. Batterijoptimalisatie uitzetten
  try {
    final batteryStatus = await Permission.ignoreBatteryOptimizations.status;
    if (!batteryStatus.isGranted) {
      final result = await Permission.ignoreBatteryOptimizations.request();
      if (!result.isGranted && context.mounted) {
        // Sommige fabrikanten (Samsung, Xiaomi, Huawei) negeren de request.
        // Leid de gebruiker dan naar de instellingen.
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text(l10n.pushBatteryOptimizationHint),
            action: SnackBarAction(
              label: l10n.settings,
              onPressed: () => app_settings.AppSettings.openAppSettings(
                type: app_settings.AppSettingsType.batteryOptimization,
              ),
            ),
          ),
        );
      }
    }
  } on Object catch (e) {
    Logs().w('Battery optimization request failed', e);
  }
}
