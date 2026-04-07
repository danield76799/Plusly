import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Utility class for storing wallpaper information locally.
///
/// The wallpaper image is saved to the application's documents directory.
/// The file path, opacity and blur values are persisted using
/// [SharedPreferences] so they survive app restarts.
class LocalWallpaperConfig {
  // Preference keys – keep them consistent with SettingKeys.
  static const _pathKey = 'xyz.extera.wallpaper_path';
  static const _opacityKey = 'xyz.extera.wallpaper_opacity';
  static const _blurKey = 'xyz.extera.wallpaper_blur';

  /// Returns the absolute file path of the stored wallpaper, or null if none.
  static Future<String?> getWallpaperPath() async {
    final prefs = await SharedPreferences.getInstance();
    final relative = prefs.getString(_pathKey);
    if (relative == null || relative.isEmpty) return null;
    final dir = await getApplicationDocumentsDirectory();
    return '${dir.path}/$relative';
  }

  /// Saves the wallpaper file to the app's documents directory and stores the
  /// relative file name in shared preferences.
  static Future<void> setWallpaperFile(File file) async {
    final dir = await getApplicationDocumentsDirectory();
    final fileName = file.uri.pathSegments.last;
    final targetPath = '${dir.path}/$fileName';
    await file.copy(targetPath);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_pathKey, fileName);
  }

  /// Clears the saved wallpaper path (does NOT delete the file).
  static Future<void> clearWallpaperPath() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_pathKey);
  }

  static Future<double> getOpacity() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_opacityKey) ?? 0.5;
  }

  static Future<void> setOpacity(double value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_opacityKey, value);
  }

  static Future<double> getBlur() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_blurKey) ?? 0.0;
  }

  static Future<void> setBlur(double value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_blurKey, value);
  }

  /// Deletes the wallpaper file (if it exists) and clears all related prefs.
  static Future<void> deleteWallpaper() async {
    final path = await getWallpaperPath();
    if (path != null) {
      try {
        final file = File(path);
        if (await file.exists()) await file.delete();
      } catch (_) {
        // ignore failures – we still want to clear prefs.
      }
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_pathKey);
    await prefs.remove(_opacityKey);
    await prefs.remove(_blurKey);
  }
}
