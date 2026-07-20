import 'dart:convert';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher_string.dart';

import 'package:matrix/matrix.dart';

import 'package:Pulsly/config/app_config.dart';
import 'package:Pulsly/generated/l10n/l10n.dart';
import 'package:Pulsly/utils/adaptive_bottom_sheet.dart';
import 'package:Pulsly/utils/platform_infos.dart';
import 'package:Pulsly/utils/play_store_update.dart';

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

  // When the user explicitly asks for a refresh (e.g. pull-to-refresh in
  // settings), skip the in-memory cache too.
  final prefs = await SharedPreferences.getInstance();

  // Try to get from cache first (if not forcing refresh)
  if (!forceRefresh) {
    try {
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
  } else {
    // Force refresh: clear the stale cache so the new result is always saved.
    try {
      await prefs.remove(cacheKey);
      await prefs.remove(cacheTimeKey);
      Logs().v('Cleared GitHub release cache for forced refresh');
    } catch (e) {
      Logs().v('Failed to clear release cache: $e');
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

Future<String?> _bestReleasePageUrl(GitHubRelease release) async {
  // Prefer a direct per-ABI APK URL so the browser can immediately download
  // the right architecture. If none is available, fall back to the release page.
  if (release.apkUrlsByAbi.isNotEmpty && Platform.isAndroid) {
    final androidInfo = await DeviceInfoPlugin().androidInfo;
    final supported = [
      ...androidInfo.supported64BitAbis,
      ...androidInfo.supported32BitAbis,
    ];

    const preferredAbiOrder = [
      'arm64-v8a',
      'x86_64',
      'armeabi-v7a',
      'x86',
    ];

    final ordered = supported.toSet().toList()
      ..sort(
        (a, b) => preferredAbiOrder.indexOf(a).compareTo(
              preferredAbiOrder.indexOf(b),
            ),
      );
    for (final abi in ordered) {
      final url = release.apkUrlsByAbi[abi];
      if (url != null && url.startsWith('https://')) return url;
    }
  }

  return release.browserDownloadUrl.isNotEmpty
      ? release.browserDownloadUrl
      : AppConfig.downloadUpdateUrl;
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

    // Android apps distributed via Google Play can use the official
    // In-App Updates API. This does not require REQUEST_INSTALL_PACKAGES
    // and is the Play-Store-compliant way to update. Side-loaded APKs fall
    // back to the browser/GitHub page automatically.
    if (PlatformInfos.isAndroid) {
      await showPlayStoreUpdateIfAvailable(
        context,
        latestTag: safeRelease.tagName,
        releaseUrl: safeRelease.browserDownloadUrl.isNotEmpty
            ? safeRelease.browserDownloadUrl
            : 'https://github.com/danield76799/Plusly/releases',
      );
      return;
    }

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
              ListTile(
                leading: const Icon(Icons.open_in_browser),
                title: const Text('Open releasepagina'),
                subtitle: const Text('Download de laatste versie via je browser'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () async {
                  Navigator.of(ctx).pop();
                  final url = await _bestReleasePageUrl(safeRelease);
                  if (context.mounted) {
                    await launchUrlString(
                      url ?? 'https://github.com/danield76799/Plusly/releases',
                      mode: LaunchMode.externalApplication,
                    );
                  }
                },
              ),
              if (safeRelease.browserDownloadUrl.isNotEmpty)
                ListTile(
                  leading: const Icon(Icons.source),
                  title: const Text('Bekijk release op GitHub'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.of(ctx).pop();
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