import 'dart:io';

import 'package:flutter/material.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:url_launcher/url_launcher_string.dart';

import 'package:Pulsly/generated/l10n/l10n.dart';
import 'package:Pulsly/utils/adaptive_bottom_sheet.dart';
import 'package:Pulsly/utils/platform_infos.dart';

/// Uses the Google Play In-App Updates API on Android when the app was
/// installed through Play Store. Falls back to the GitHub releases page on
/// non-Play builds or other platforms.
Future<void> showPlayStoreUpdateIfAvailable(
  BuildContext context, {
  required String latestTag,
  String? releaseUrl,
}) async {
  if (!PlatformInfos.isAndroid || !Platform.isAndroid) {
    _openBrowserFallback(context, releaseUrl);
    return;
  }

  try {
    final info = await InAppUpdate.checkForUpdate().timeout(
      const Duration(seconds: 10),
      onTimeout: () => throw Exception('Play Store update check timeout'),
    );

    if (info.updateAvailability != UpdateAvailability.updateAvailable) {
      _openBrowserFallback(context, releaseUrl);
      return;
    }

    if (!context.mounted) return;

    final l10n = L10n.of(context);
    await showAdaptiveBottomSheet(
      context: context,
      useRootNavigator: false,
      builder: (ctx) {
        return Scaffold(
          appBar: AppBar(title: Text(l10n.updateAvailableTitle)),
          body: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text('Plusly $latestTag is beschikbaar via Google Play.'),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.system_update),
                title: const Text('Nu updaten'),
                subtitle: const Text('Direct via Google Play'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () async {
                  Navigator.of(ctx).pop();
                  try {
                    await InAppUpdate.performImmediateUpdate();
                  } catch (e) {
                    _openBrowserFallback(context, releaseUrl);
                  }
                },
              ),
              if (info.flexibleUpdateAllowed)
                ListTile(
                  leading: const Icon(Icons.download_for_offline),
                  title: const Text('Op de achtergrond downloaden'),
                  subtitle: const Text('Installeer later zelf'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () async {
                    Navigator.of(ctx).pop();
                    try {
                      await InAppUpdate.startFlexibleUpdate();
                    } catch (e) {
                      _openBrowserFallback(context, releaseUrl);
                    }
                  },
                ),
              ListTile(
                leading: const Icon(Icons.open_in_browser),
                title: const Text('GitHub release bekijken'),
                subtitle: const Text('Download APK via browser'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.of(ctx).pop();
                  _openBrowserFallback(context, releaseUrl);
                },
              ),
            ],
          ),
        );
      },
    );
  } catch (e) {
    // Play Store API not available (side-load, non-Play build, etc.)
    _openBrowserFallback(context, releaseUrl);
  }
}

void _openBrowserFallback(BuildContext context, String? releaseUrl) {
  final url = releaseUrl ?? 'https://github.com/danield76799/Plusly/releases';
  launchUrlString(url, mode: LaunchMode.externalApplication);
}
