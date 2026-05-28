import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher_string.dart';

import 'package:matrix/matrix.dart';

import 'package:Pulsly/config/app_config.dart';
import 'package:Pulsly/generated/l10n/l10n.dart';
import 'package:Pulsly/utils/adaptive_bottom_sheet.dart';
import 'package:Pulsly/utils/platform_infos.dart';

/// GitHub Releases API response for a release.
class GitHubRelease {
  final String tagName;
  final String downloadUrl;
  final String browserDownloadUrl;
  final bool hasApk;

  GitHubRelease({
    required this.tagName,
    required this.downloadUrl,
    required this.browserDownloadUrl,
    this.hasApk = false,
  });

  factory GitHubRelease.fromJson(Map<String, dynamic> json) {
    var downloadUrl = '';
    var browserUrl = '';
    var apkUrl = '';
    var aabUrl = '';

    // Find the first APK or AAB asset
    final assets = json['assets'] as List<dynamic>? ?? [];
    for (final asset in assets) {
      final name = (asset['name'] as String? ?? '').toLowerCase();
      final url = asset['browser_download_url'] as String? ?? '';
      if (name.endsWith('.apk')) {
        apkUrl = url;
      } else if (name.endsWith('.aab')) {
        aabUrl = url;
      }
    }

    // Prefer APK over AAB for direct download
    downloadUrl = apkUrl.isNotEmpty ? apkUrl : aabUrl;

    // Use release page URL as fallback
    browserUrl = json['html_url'] as String? ?? '';

    return GitHubRelease(
      tagName: json['tag_name'] as String? ?? '',
      downloadUrl: downloadUrl,
      browserDownloadUrl: browserUrl,
      hasApk: apkUrl.isNotEmpty,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tag_name': tagName,
      'download_url': downloadUrl,
      'browser_download_url': browserDownloadUrl,
      'has_apk': hasApk,
    };
  }
}

Future<GitHubRelease?> getLatestRelease({bool forceRefresh = false}) async {
  const repo = 'danield76799/Plusly';
  const url = 'https://api.github.com/repos/$repo/releases';
  const cacheKey = 'cached_github_release';
  const cacheTimeKey = 'cached_github_release_time';
  const cacheDuration = Duration(hours: 24);

  // Try to get from cache first (if not forcing refresh)
  if (!forceRefresh) {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedData = prefs.getString(cacheKey);
      final cachedTime = prefs.getInt(cacheTimeKey);

      if (cachedData != null && cachedTime != null) {
        final cacheAge = DateTime.now().millisecondsSinceEpoch - cachedTime;
        if (cacheAge < cacheDuration.inMilliseconds) {
          Logs().v('Using cached GitHub release info');
          final json = jsonDecode(cachedData) as Map<String, dynamic>;
          return GitHubRelease.fromJson(json);
        }
      }
    } catch (e) {
      Logs().v('Cache read failed: $e, fetching from GitHub');
    }
  }

  try {
    // Fetch all releases and find the latest semver release with APK
    final response = await Dio().get(
      url,
      options: Options(
        headers: {
          'Accept': 'application/vnd.github+json',
          'User-Agent': 'PluslyApp',
        },
        sendTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      ),
    );

    if (response.statusCode == 200 && response.data is List) {
      final releases = response.data as List<dynamic>;
      
      // Find the latest semver release (not playstore-vNNN tags)
      // Prefer releases with APK assets
      GitHubRelease? latestSemverRelease;
      
      for (final releaseData in releases) {
        if (releaseData is! Map<String, dynamic>) continue;
        
        final release = GitHubRelease.fromJson(releaseData);
        final tagName = release.tagName;
        
        // Skip playstore-vNNN tags - these are Play Store only, not for APK updates
        if (tagName.startsWith('playstore-') || tagName.startsWith('playstore-v')) {
          continue;
        }
        
        // Only accept releases with APK - skip AAB-only releases
        if (release.hasApk) {
          latestSemverRelease = release;
          break; // First semver release with APK is the latest
        }
      }

      // If no release with APK found, return null (no update available)
      if (latestSemverRelease == null) {
        Logs().v('No semver release with APK found');
        return null;
      }

      // Cache the result
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(cacheKey, jsonEncode(latestSemverRelease.toJson()));
        await prefs.setInt(cacheTimeKey, DateTime.now().millisecondsSinceEpoch);
      } catch (e) {
        Logs().v('Cache write failed: $e');
      }

      return latestSemverRelease;
    } else {
      Logs().w('GitHub API returned status ${response.statusCode}');
    }
  } on DioException catch (e) {
    Logs().e(
      'Failed to fetch GitHub release',
      'DioError: ${e.type} - ${e.message}',
    );
  } catch (e) {
    Logs().e('Failed to fetch GitHub release', e);
  }
  return null;
}

/// Compare two version strings (e.g. "1.2.3" vs "1.2.4").
/// Returns true if latest is newer than current.
bool isNewerVersion(String latest, String current) {
  // Strip 'v' prefix if present
  latest = latest.startsWith('v') ? latest.substring(1) : latest;
  current = current.startsWith('v') ? current.substring(1) : current;

  // Strip build metadata (+NNN) from both versions for comparison
  final latestPlusIndex = latest.indexOf('+');
  if (latestPlusIndex != -1) {
    latest = latest.substring(0, latestPlusIndex);
  }
  final currentPlusIndex = current.indexOf('+');
  if (currentPlusIndex != -1) {
    current = current.substring(0, currentPlusIndex);
  }

  // Check if versions look like Plusly build tags (e.g., "0.9.9-build421", "1.1.3+863", "playstore-240")
  final latestIsBuildTag = latest.contains('+') || latest.contains('build') || latest.startsWith('playstore-') || latest.startsWith('playstore-v');
  final currentIsBuildTag = current.contains('+') || current.contains('build');

  // Special case: playstore- tags are only newer if current is also a playstore tag
  // and the build number is higher. Otherwise, compare semver normally.
  if (latest.startsWith('playstore-') || latest.startsWith('playstore-v')) {
    // If current is also a playstore tag, compare build numbers
    if (current.startsWith('playstore-') || current.startsWith('playstore-v')) {
      final latestMatch = RegExp(r'playstore-v?(\d+)').firstMatch(latest);
      final currentMatch = RegExp(r'playstore-v?(\d+)').firstMatch(current);
      if (latestMatch != null && currentMatch != null) {
        final latestBuild = int.tryParse(latestMatch.group(1) ?? '0') ?? 0;
        final currentBuild = int.tryParse(currentMatch.group(1) ?? '0') ?? 0;
        return latestBuild > currentBuild;
      }
    }
    // If current is semver, playstore tag is NOT newer (we only use semver for updates)
    return false;
  }

  // If BOTH are build tags, compare build numbers
  if (latestIsBuildTag && currentIsBuildTag) {
    // Extract build number: handles "playstore-240", "0.9.9-build421", "1.4.0+928"
    int? latestBuild;
    int? currentBuild;
    
    // Try playstore- format first (handles both playstore-240 and playstore-v240)
    final playstoreMatch = RegExp(r'playstore-v?(\d+)');
    final latestPlaystoreMatch = playstoreMatch.firstMatch(latest);
    final currentPlaystoreMatch = playstoreMatch.firstMatch(current);
    
    if (latestPlaystoreMatch != null) {
      latestBuild = int.tryParse(latestPlaystoreMatch.group(1) ?? '0');
    } else {
      final latestBuildMatch = RegExp(r'(\d+)$').firstMatch(latest);
      latestBuild = latestBuildMatch != null ? int.tryParse(latestBuildMatch.group(1) ?? '0') : null;
    }
    
    if (currentPlaystoreMatch != null) {
      currentBuild = int.tryParse(currentPlaystoreMatch.group(1) ?? '0');
    } else {
      final currentBuildMatch = RegExp(r'(\d+)$').firstMatch(current);
      currentBuild = currentBuildMatch != null ? int.tryParse(currentBuildMatch.group(1) ?? '0') : null;
    }
    
    if (latestBuild != null && currentBuild != null) {
      return latestBuild > currentBuild;
    }
  }

  // If latest is NOT a build tag (i.e., proper semantic like "1.5.1"), always compare semantically
  // This handles cases like current="1.4.0+928" vs latest="1.5.1"
  if (!latestIsBuildTag) {
    final latestParts = latest
        .split('.')
        .map((e) => int.tryParse(e) ?? 0)
        .toList();
    final currentParts = current
        .split('.')
        .map((e) => int.tryParse(e) ?? 0)
        .toList();

    // Pad with zeros
    while (latestParts.length < currentParts.length) {
      latestParts.add(0);
    }
    while (currentParts.length < latestParts.length) {
      currentParts.add(0);
    }

    for (var i = 0; i < latestParts.length; i++) {
      if (latestParts[i] > currentParts[i]) return true;
      if (latestParts[i] < currentParts[i]) return false;
    }
    return false;
  }

  // Fallback: semantic version comparison for mixed cases
  final latestParts = latest
      .split('.')
      .map((e) => int.tryParse(e) ?? 0)
      .toList();
  final currentParts = current
      .split('.')
      .map((e) => int.tryParse(e) ?? 0)
      .toList();

  while (latestParts.length < currentParts.length) {
    latestParts.add(0);
  }
  while (currentParts.length < latestParts.length) {
    currentParts.add(0);
  }

  for (var i = 0; i < latestParts.length; i++) {
    if (latestParts[i] > currentParts[i]) return true;
    if (latestParts[i] < currentParts[i]) return false;
  }
  return false;
}

Future<void> downloadAndInstallApk(BuildContext context, String url) async {
  final l10n = L10n.of(context);
  final scaffold = ScaffoldMessenger.of(context);

  // Progress state
  var progress = 0.0;
  var statusText = 'Downloaden...';

  try {
    // Show downloading indicator with progress
    if (context.mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(l10n.downloadUpdateButton),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(
                    value: progress > 0 ? progress : null,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    statusText,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  if (progress > 0)
                    Text(
                      '${(progress * 100).toStringAsFixed(0)}%',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                ],
              ),
            );
          },
        ),
      );
    }

    final tempDir = await getTemporaryDirectory();
    final fileName = url.split('/').last;
    if (fileName.isEmpty) {
      throw Exception('Ongeldige download URL');
    }
    final filePath = '${tempDir.path}/$fileName';

    Logs().v('Starting download from: $url');
    Logs().v('Saving to: $filePath');

    await Dio().download(
      url,
      filePath,
      options: Options(
        headers: {
          'Accept': 'application/vnd.android.package-archive, application/octet-stream, */*',
          'User-Agent': 'PluslyApp',
        },
        // 30 seconden timeout voor connect + receive
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 10),
      ),
      onReceiveProgress: (received, total) {
        if (total > 0) {
          progress = received / total;
          statusText = 'Downloaden... ${(progress * 100).toStringAsFixed(0)}%';
        } else {
          statusText =
              'Downloaden... ${(received / 1024 / 1024).toStringAsFixed(1)} MB';
        }
        // Force dialog rebuild safely
        if (context.mounted) {
          try {
            (context as Element).markNeedsBuild();
          } catch (_) {
            // Ignore if context is no longer valid
          }
        }
      },
    );

    // Verify file exists and has content
    final file = File(filePath);
    if (!await file.exists()) {
      throw Exception('Bestand niet gevonden na download');
    }
    final fileSize = await file.length();
    if (fileSize == 0) {
      throw Exception('Gedownload bestand is leeg');
    }

    Logs().v('Download complete: $fileSize bytes');

    // Check if it's an AAB file - redirect to browser for manual install
    if (fileName.endsWith('.aab')) {
      if (context.mounted) {
        Navigator.of(context).pop();
        scaffold.showSnackBar(
          SnackBar(
            content: Text('AAB bestand vereist Play Store of bundletool. Open de release pagina voor installatie instructies.'),
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'Open Pagina',
              onPressed: () => launchUrlString(url),
            ),
          ),
        );
      }
      return;
    }

    if (context.mounted) {
      // Close downloading dialog
      Navigator.of(context).pop();
    }

    // Show success message
    if (context.mounted) {
      scaffold.showSnackBar(
        SnackBar(
          content: Text('Download compleet! Installeren...'),
          duration: const Duration(seconds: 3),
        ),
      );
    }

    // Check and request install packages permission on Android
    if (PlatformInfos.isAndroid) {
      final status = await Permission.requestInstallPackages.status;
      if (!status.isGranted) {
        final result = await Permission.requestInstallPackages.request();
        if (!result.isGranted) {
          throw Exception('Permission denied: android.permission.REQUEST_INSTALL_PACKAGES');
        }
      }
    }

    // Open the APK — Android will show the install prompt
    final result = await OpenFile.open(filePath);
    if (result.type != ResultType.done) {
      throw Exception('Kon APK niet openen: ${result.message}');
    }
  } on DioException catch (e) {
    // Handle Dio specific errors
    try {
      if (context.mounted && Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
    } catch (_) {
      // Ignore navigation errors
    }

    String errorMsg;
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        errorMsg = 'Download timeout - check je internetverbinding';
        break;
      case DioExceptionType.badResponse:
        if (e.response?.statusCode == 404) {
          errorMsg = 'Download link niet gevonden (404). Probeer de browser optie.';
        } else {
          errorMsg = 'Server fout: ${e.response?.statusCode ?? 'onbekend'}';
        }
        break;
      case DioExceptionType.cancel:
        errorMsg = 'Download geannuleerd';
        break;
      default:
        errorMsg = 'Download mislukt: ${e.message}';
    }

    Logs().e('Download failed: $errorMsg', e);

    if (context.mounted) {
      scaffold.showSnackBar(
        SnackBar(
          content: Text(errorMsg),
          duration: const Duration(seconds: 5),
          action: SnackBarAction(
            label: 'Open Pagina',
            onPressed: () => launchUrlString('https://github.com/danield76799/Plusly/releases'),
          ),
        ),
      );
    }
  } catch (e) {
    try {
      if (context.mounted && Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
    } catch (_) {
      // Ignore navigation errors
    }
    Logs().e('Download failed: $e');
    if (context.mounted) {
      scaffold.showSnackBar(
        SnackBar(
          content: Text('Download mislukt: $e'),
          duration: const Duration(seconds: 5),
          action: SnackBarAction(
            label: 'Open Pagina',
            onPressed: () => launchUrlString('https://github.com/danield76799/Plusly/releases'),
          ),
        ),
      );
    }
  }
}

void checkForUpdates(BuildContext context) async {
  // Reset the check flag so we can check again
  AppConfig.alreadyCheckedUpdates = false;
  
  // Always check for updates regardless of setting (for testing)
  // if (!AppSettings.checkForUpdates.value) {
  //   return;
  // }

  Logs().v('Checking updates via GitHub Releases...');

  try {
    final currentVersion = await PlatformInfos.getVersion();
    // Force refresh to bypass cache - ensures we always get latest
    final release = await getLatestRelease(forceRefresh: true);

    if (release == null) {
      Logs().v('No release found or failed to fetch');
      return;
    }

    final latestVersion = release.tagName;
    Logs().v(
      'Latest version: $latestVersion | Current version: $currentVersion',
    );

    if (!isNewerVersion(latestVersion, currentVersion)) return;

    AppConfig.alreadyCheckedUpdates = true;

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
                child: Text(l10n.updateAvailable(latestVersion)),
              ),
              const Divider(),
              if (release.downloadUrl.isNotEmpty)
                ListTile(
                  leading: Icon(release.hasApk ? Icons.android : Icons.warning),
                  title: Text(release.hasApk ? 'Download & installeer APK' : 'Download beschikbaar (geen APK)'),
                  subtitle: Text(release.hasApk ? 'Directe installatie' : 'Alleen AAB beschikbaar - gebruik browser'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    if (release.hasApk) {
                      Navigator.of(ctx).pop();
                      downloadAndInstallApk(context, release.downloadUrl);
                    } else {
                      // No APK available, show message
                      Navigator.of(ctx).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Geen APK beschikbaar voor directe download. Gebruik de browser optie.'),
                          duration: Duration(seconds: 5),
                        ),
                      );
                    }
                  },
                ),
              ListTile(
                leading: const Icon(Icons.open_in_browser),
                title: const Text('Open GitHub releasepagina'),
                subtitle: const Text('Direct downloaden via browser'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.of(ctx).pop();
                  launchUrlString(
                    'https://github.com/danield76799/Plusly/releases',
                  );
                },
              ),
              if (release.browserDownloadUrl.isNotEmpty)
                ListTile(
                  leading: const Icon(Icons.source),
                  title: const Text('Download source code'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    launchUrlString(release.browserDownloadUrl);
                  },
                ),
            ],
          ),
        );
      },
    );
  } catch (e) {
    Logs().e('Failed to check for updates', e);
  }
}