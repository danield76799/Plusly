import 'dart:convert';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:app_settings/app_settings.dart';
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
  final Map<String, String> apkUrlsByAbi;

  GitHubRelease({
    required this.tagName,
    required this.downloadUrl,
    required this.browserDownloadUrl,
    this.hasApk = false,
    this.apkUrlsByAbi = const {},
  });

  factory GitHubRelease.fromJson(Map<String, dynamic> json) {
    var downloadUrl = '';
    var browserUrl = '';
    var apkUrl = '';
    var aabUrl = '';
    final apkUrlsByAbi = <String, String>{};

    // Find APK or AAB assets, grouped by ABI when possible.
    final assets = json['assets'] as List<dynamic>? ?? [];
    for (final asset in assets) {
      final name = (asset['name'] as String? ?? '').toLowerCase();
      final url = asset['browser_download_url'] as String? ?? '';
      if (name.endsWith('.apk')) {
        apkUrl = apkUrl.isEmpty ? url : apkUrl;
        if (name.contains('arm64-v8a')) {
          apkUrlsByAbi['arm64-v8a'] = url;
        } else if (name.contains('armeabi-v7a')) {
          apkUrlsByAbi['armeabi-v7a'] = url;
        } else if (name.contains('x86_64')) {
          apkUrlsByAbi['x86_64'] = url;
        } else if (name.contains('x86')) {
          apkUrlsByAbi['x86'] = url;
        }
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
      apkUrlsByAbi: apkUrlsByAbi,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tag_name': tagName,
      'download_url': downloadUrl,
      'browser_download_url': browserDownloadUrl,
      'has_apk': hasApk,
      'apk_urls_by_abi': apkUrlsByAbi,
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
    // GitHub's /releases/latest endpoint lags behind: it can keep pointing at
    // an older release even after newer tags have been published. We therefore
    // fetch the last page of releases, filter out non-APK / playstore-only
    // releases, and pick the one with the highest version/build number ourselves.
    final response = await Dio().get(
      url,
      queryParameters: {'per_page': '20'},
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
      final releases = (response.data as List)
          .whereType<Map<String, dynamic>>()
          .map(GitHubRelease.fromJson)
          .where((r) {
        final tag = r.tagName;
        if (tag.startsWith('playstore-') || tag.startsWith('playstore-v')) {
          return false;
        }
        return r.hasApk;
      })
          .toList();

      if (releases.isEmpty) {
        Logs().v('No suitable releases with APK found');
        return null;
      }

      // Pick the newest release according to our own version comparison.
      var newest = releases.first;
      for (final candidate in releases.skip(1)) {
        if (isNewerVersion(candidate.tagName, newest.tagName)) {
          newest = candidate;
        }
      }

      // Cache the result
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(cacheKey, jsonEncode(newest.toJson()));
        await prefs.setInt(cacheTimeKey, DateTime.now().millisecondsSinceEpoch);
      } catch (e) {
        Logs().v('Cache write failed: $e');
      }

      return newest;
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

  // Extract build metadata (+NNN) from both versions
  final latestPlusIndex = latest.indexOf('+');
  final latestBuildNumber = latestPlusIndex != -1 ? latest.substring(latestPlusIndex + 1) : '';
  if (latestPlusIndex != -1) {
    latest = latest.substring(0, latestPlusIndex);
  }
  final currentPlusIndex = current.indexOf('+');
  final currentBuildNumber = currentPlusIndex != -1 ? current.substring(currentPlusIndex + 1) : '';
  if (currentPlusIndex != -1) {
    current = current.substring(0, currentPlusIndex);
  }

  // If both versions share the same semver core, compare build numbers if present.
  if (latest == current) {
    if (latestBuildNumber.isNotEmpty && currentBuildNumber.isNotEmpty) {
      final latestBuild = int.tryParse(latestBuildNumber) ?? 0;
      final currentBuild = int.tryParse(currentBuildNumber) ?? 0;
      return latestBuild > currentBuild;
    }
    // A tagged CI build (e.g. +2350) is newer than a local/package build that
    // only reports the semver core (no build number).
    if (latestBuildNumber.isNotEmpty && currentBuildNumber.isEmpty) {
      return true;
    }
    return false;
  }

  // Check if versions look like Plusly build tags (e.g., "0.9.9-build421", "1.1.3+863", "playstore-240")
  final latestIsBuildTag = latestBuildNumber.isNotEmpty || latest.contains('build') || latest.startsWith('playstore-') || latest.startsWith('playstore-v');
  final currentIsBuildTag = currentBuildNumber.isNotEmpty || current.contains('build');

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
    } else if (latestBuildNumber.isNotEmpty) {
      latestBuild = int.tryParse(latestBuildNumber);
    } else {
      final latestBuildMatch = RegExp(r'(\d+)$').firstMatch(latest);
      latestBuild = latestBuildMatch != null ? int.tryParse(latestBuildMatch.group(1) ?? '0') : null;
    }
    
    if (currentPlaystoreMatch != null) {
      currentBuild = int.tryParse(currentPlaystoreMatch.group(1) ?? '0');
    } else if (currentBuildNumber.isNotEmpty) {
      currentBuild = int.tryParse(currentBuildNumber);
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

  final progressNotifier = ValueNotifier<double?>(null);
  final statusNotifier = ValueNotifier<String>('Downloaden...');
  BuildContext? dialogContext;

  void closeDialog() {
    final ctx = dialogContext;
    if (ctx != null && ctx.mounted && Navigator.of(ctx).canPop()) {
      Navigator.of(ctx).pop();
    }
    dialogContext = null;
  }

  if (context.mounted) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        dialogContext = ctx;
        return AlertDialog(
          title: Text(l10n.downloadUpdateButton),
          content: ValueListenableBuilder<double?>(
            valueListenable: progressNotifier,
            builder: (_, progress, __) {
              return ValueListenableBuilder<String>(
                valueListenable: statusNotifier,
                builder: (_, status, __) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(
                        value: progress != null && progress > 0 ? progress : null,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        status,
                        style: Theme.of(ctx).textTheme.bodyMedium,
                      ),
                      if (progress != null)
                        Text(
                          '${(progress * 100).toStringAsFixed(0)}%',
                          style: Theme.of(ctx).textTheme.bodySmall,
                        ),
                    ],
                  );
                },
              );
            },
          ),
        );
      },
    );
  }

  String? filePath;
  try {
    final tempDir = await getTemporaryDirectory();
    final fileName = url.split('/').last;
    if (fileName.isEmpty || !fileName.toLowerCase().endsWith('.apk')) {
      throw Exception('Ongeldige APK download URL');
    }
    filePath = '${tempDir.path}/$fileName';

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
        receiveTimeout: const Duration(minutes: 5),
        sendTimeout: const Duration(seconds: 10),
      ),
      onReceiveProgress: (received, total) {
        if (total > 0) {
          progressNotifier.value = received / total;
          statusNotifier.value =
              'Downloaden... ${(progressNotifier.value! * 100).toStringAsFixed(0)}%';
        } else {
          progressNotifier.value = null;
          statusNotifier.value =
              'Downloaden... ${(received / 1024 / 1024).toStringAsFixed(1)} MB';
        }
      },
    );

    final file = File(filePath);
    if (!await file.exists()) {
      throw Exception('Bestand niet gevonden na download');
    }
    final fileSize = await file.length();
    if (fileSize == 0) {
      throw Exception('Gedownload bestand is leeg');
    }

    Logs().v('Download complete: $fileSize bytes');

    closeDialog();

    if (context.mounted) {
      scaffold.showSnackBar(
        SnackBar(
          content: Text('Download compleet! Installeren...'),
          duration: const Duration(seconds: 3),
        ),
      );
    }

    if (PlatformInfos.isAndroid) {
      try {
        final status = await Permission.requestInstallPackages.status;
        if (!status.isGranted) {
          final result = await Permission.requestInstallPackages.request();
          if (result.isDenied || result.isPermanentlyDenied) {
            if (context.mounted) {
              scaffold.showSnackBar(
                SnackBar(
                  content: const Text(
                    "Plusly mag geen APK's installeren. Zet dit aan in de "
                    'instellingen en probeer het opnieuw.',
                  ),
                  duration: const Duration(seconds: 6),
                  action: SnackBarAction(
                    label: 'Instellingen',
                    onPressed: () => AppSettings.openAppSettings(
                      asAnotherTask: true,
                    ),
                  ),
                ),
              );
            }
            return;
          }
        }
      } on Exception catch (e) {
        Logs().w('requestInstallPackages failed', e);
      }
    }

    final openResult = await OpenFile.open(filePath);
    if (openResult.type != ResultType.done) {
      throw Exception('Kon APK niet openen: ${openResult.message}');
    }
  } on DioException catch (e) {
    closeDialog();

    String errorMsg;
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        errorMsg = 'Download timeout - check je internetverbinding';
      case DioExceptionType.badResponse:
        if (e.response?.statusCode == 404) {
          errorMsg = 'Download link niet gevonden (404). Probeer de browser optie.';
        } else {
          errorMsg = 'Server fout: ${e.response?.statusCode ?? 'onbekend'}';
        }
      case DioExceptionType.cancel:
        errorMsg = 'Download geannuleerd';
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
            onPressed: () => launchUrlString(AppConfig.downloadUpdateUrl),
          ),
        ),
      );
    }
  } catch (e) {
    closeDialog();
    Logs().e('Download failed: $e');
    if (context.mounted) {
      scaffold.showSnackBar(
        SnackBar(
          content: Text('Download mislukt: $e'),
          duration: const Duration(seconds: 5),
          action: SnackBarAction(
            label: 'Open Pagina',
            onPressed: () => launchUrlString(AppConfig.downloadUpdateUrl),
          ),
        ),
      );
    }
  } finally {
    progressNotifier.dispose();
    statusNotifier.dispose();
  }
}

Future<String> _pickBestApkUrl(GitHubRelease release) async {
  if (release.apkUrlsByAbi.isEmpty) return release.downloadUrl;

  // Kies de beste APK op basis van de ondersteunde ABI's van dit toestel.
  // Dit voorkomt dat we een 32-bit APK proberen te installeren op een
  // 64-bit toestel (of andersom), wat stilzwijgend mislukt.
  if (Platform.isAndroid) {
    final androidInfo = await DeviceInfoPlugin().androidInfo;
    final supported = [
      ...androidInfo.supported64BitAbis,
      ...androidInfo.supported32BitAbis,
    ];
    for (final abi in supported) {
      final url = release.apkUrlsByAbi[abi];
      if (url != null && url.isNotEmpty) return url;
    }
  }

  // Fallback: arm64-v8a is de meest voorkomende moderne architectuur.
  return release.apkUrlsByAbi['arm64-v8a'] ??
      release.apkUrlsByAbi['armeabi-v7a'] ??
      release.apkUrlsByAbi['x86_64'] ??
      release.apkUrlsByAbi['x86'] ??
      release.downloadUrl;
}

Future<void> checkForUpdates(BuildContext context) async {
  // Reset the check flag so we can check again
  AppConfig.alreadyCheckedUpdates = false;
  
  // Always check for updates regardless of setting (for testing)
  // if (!AppSettings.checkForUpdates.value) {
  //   return;
  // }

  Logs().v('Checking updates via GitHub Releases...');

  try {
    final currentVersion = await PlatformInfos.getVersion();

    // Primary: the version file on the repo (no API rate-limit, always in
    // sync because the deploy workflow rewrites it on every release).
    // NOTE: we MUST set responseType to plain. Without it Dio tries to
    // JSON-parse the txt body, which silently fails on Android, leaving
    // `response.data` as null and breaking the whole update check.
    GitHubRelease? release;
    try {
      final response = await Dio().get(
        AppConfig.updateCheckUrl,
        options: Options(
          headers: {
            'User-Agent': 'PluslyApp',
            'Accept': 'text/plain',
          },
          responseType: ResponseType.plain,
          sendTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        ),
      );
      Logs().v('plusly-version.txt response: ${response.statusCode}');
      if (response.statusCode == 200 && response.data is String) {
        final tag = (response.data as String).trim();
        if (tag.isNotEmpty) {
          release = GitHubRelease(
            tagName: tag,
            downloadUrl: AppConfig.downloadUpdateUrl,
            browserDownloadUrl: AppConfig.downloadUpdateUrl,
          );
          Logs().v('Using version.txt: $tag');
        } else {
          Logs().w('plusly-version.txt was empty');
        }
      } else {
        Logs().w(
          'plusly-version.txt unexpected response: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      Logs().w('Version.txt fetch failed, trying GitHub API', e.message);
    } catch (e) {
      Logs().w('Version.txt fetch failed, trying GitHub API', e);
    }

    // Secondary: GitHub Releases API (can be rate-limited on shared mobile IPs).
    // If the version file already gave us a version, only use the API to
    // enrich it with a real APK download URL; otherwise use it as the source.
    if (release == null) {
      try {
        release = await getLatestRelease(forceRefresh: true);
      } catch (e) {
        Logs().w('GitHub release fetch failed', e);
      }
    } else {
      // We have a version from the txt file — try to upgrade it with a real
      // APK URL from the latest GitHub release so "Download & install" works.
      var gotApkUrls = false;
      try {
        final apiRelease = await getLatestRelease(forceRefresh: true);
        if (apiRelease != null && apiRelease.hasApk) {
          release = GitHubRelease(
            tagName: release.tagName,
            downloadUrl: apiRelease.downloadUrl,
            browserDownloadUrl: apiRelease.browserDownloadUrl,
            hasApk: true,
            apkUrlsByAbi: apiRelease.apkUrlsByAbi,
          );
          gotApkUrls = true;
        }
      } catch (e) {
        Logs().w('GitHub APK URL fetch failed, falling back to predictable URLs', e);
      }
      // Fallback: if the API couldn't enrich the release (rate-limited /
      // no auth / etc.) but the GHA always names assets the same way
      // (plusly-<abi>-release.apk), we can build the APK URLs ourselves
      // from the tag. This keeps "Download & install" working even when
      // the GitHub API is unreachable from a mobile IP.
      if (!gotApkUrls) {
        final previousRelease = release!;
        final rawTag = previousRelease.tagName.startsWith('v')
            ? previousRelease.tagName.substring(1)
            : previousRelease.tagName;
        final encodedTag = Uri.encodeComponent(rawTag);
        final base =
            'https://github.com/danield76799/Plusly/releases/download/$encodedTag';
        final fallbackApkUrls = <String, String>{
          'arm64-v8a': '$base/plusly-arm64-v8a-release.apk',
          'armeabi-v7a': '$base/plusly-armeabi-v7a-release.apk',
          'x86_64': '$base/plusly-x86_64-release.apk',
          'x86': '$base/plusly-x86-release.apk',
        };
        // GitHub's "/releases/latest/download/<asset>" redirects to the
        // latest tag's matching asset, so we can use it as a catch-all
        // when the per-ABI map doesn't cover the device.
        final latestAssetRedirect =
            'https://github.com/danield76799/Plusly/releases/latest/download/'
            'plusly-arm64-v8a-release.apk';
        final tagName = previousRelease.tagName;
        release = GitHubRelease(
          tagName: tagName,
          downloadUrl: latestAssetRedirect,
          browserDownloadUrl: previousRelease.browserDownloadUrl,
          hasApk: true,
          apkUrlsByAbi: fallbackApkUrls,
        );
        Logs().v(
          'Using predictable APK URLs from tag $tagName',
        );
      }
    }

    if (release == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Kon updates niet controleren. Probeer het later opnieuw.',
            ),
            duration: Duration(seconds: 5),
          ),
        );
      }
      return;
    }

    final latestVersion = release.tagName;
    Logs().v(
      'Latest version: $latestVersion | Current version: $currentVersion | '
      'isNewer: ${isNewerVersion(latestVersion, currentVersion)}',
    );

    if (!isNewerVersion(latestVersion, currentVersion)) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Je hebt al de nieuwste versie ($currentVersion).',
            ),
            duration: const Duration(seconds: 3),
          ),
        );
      }
      return;
    }

    final safeRelease = release;

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
                child: Text(l10n.updateAvailable(safeRelease.tagName)),
              ),
              const Divider(),
              if (safeRelease.downloadUrl.isNotEmpty)
                ListTile(
                  leading: Icon(safeRelease.hasApk ? Icons.android : Icons.warning),
                  title: Text(safeRelease.hasApk ? 'Download & installeer APK' : 'Download beschikbaar (geen APK)'),
                  subtitle: Text(safeRelease.hasApk ? 'Directe installatie' : 'Alleen AAB beschikbaar - gebruik browser'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () async {
                    if (safeRelease.hasApk) {
                      Navigator.of(ctx).pop();
                      try {
                        final apkUrl = await _pickBestApkUrl(safeRelease);
                        if (context.mounted) {
                          // downloadAndInstallApk has its own try/catch and
                          // shows a snackbar on any failure — no fatal crash.
                          await downloadAndInstallApk(context, apkUrl);
                        }
                      } catch (e) {
                        Logs().e('APK URL pick failed', e);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Kon download niet starten: $e'),
                              duration: const Duration(seconds: 5),
                              action: SnackBarAction(
                                label: 'Open Pagina',
                                onPressed: () => launchUrlString(
                                  'https://github.com/danield76799/Plusly/releases',
                                ),
                              ),
                            ),
                          );
                        }
                      }
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
              if (safeRelease.browserDownloadUrl.isNotEmpty)
                ListTile(
                  leading: const Icon(Icons.source),
                  title: const Text('Download source code'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    launchUrlString(safeRelease.browserDownloadUrl);
                  },
                ),
            ],
          ),
        );
      },
    );
  } catch (e) {
    Logs().e('Failed to check for updates', e);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Updatecontrole mislukt: $e'),
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }
}