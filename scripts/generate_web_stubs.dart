/// Script to generate web stubs for mobile-only packages
/// Run this before building for web
///
/// Usage:
/// ```bash
/// dart run scripts/generate_web_stubs.dart
/// ```
library;

import 'dart:async';
import 'dart:io';

final packagesToStub = [
  'camera',
  'flutter_foreground_task',
  'flutter_local_notifications',
  'flutter_secure_storage',
  'geolocator',
  'permission_handler',
  'video_compress',
  'firebase_core',
  'firebase_messaging',
  'unifiedpush',
  'unifiedpush_ui',
  'local_auth',
  'flutter_new_badger',
  'flutter_ringtone_player',
  'receive_sharing_intent',
  'qr_code_scanner_plus',
  'audioplayers_linux',
  'record_linux',
  'desktop_drop',
  'desktop_notifications',
  'desktop_webview_window',
  'hotkey_manager',
  'handy_window',
];

void main() async {
  final libDir = Directory('lib');
  if (!libDir.existsSync()) {
    _log('Error: lib directory not found');
    exit(1);
  }

  // Generate stubs
  await _generateStubs();

  // Replace imports in all dart files
  await _replaceImports(libDir);

  _log('Done! Web stubs generated and imports replaced.');
}

void _log(String message) {
  // ignore: avoid_print
  print(message);
}

Future<void> _generateStubs() async {
  final stubDir = Directory('lib/web_stubs');
  if (!stubDir.existsSync()) {
    stubDir.createSync(recursive: true);
  }

  for (final package in packagesToStub) {
    final stubFile = File('lib/web_stubs/${package}_stub.dart');

    // Generate stub content based on package name
    final stubContent = _generateStubContent(package);

    await stubFile.writeAsString(stubContent);
    _log('Generated stub for $package');
  }
}

String _generateStubContent(String package) {
  // Generate a generic stub that exports empty implementations
  return '''
// Auto-generated web stub for $package
// This file provides empty implementations for web builds

class ${package.split('_').map((s) => s[0].toUpperCase() + s.substring(1)).join('')}Stub {
  static Future<void> initialize() async {}
  static Future<bool> requestPermission() async => false;
  static Future<void> show() async {}
  static Future<void> cancel() async {}
}

// Export stub as default
export '${package}_stub.dart' if (dart.library.io) 'package:$package/$package.dart';
''';
}

Future<void> _replaceImports(Directory dir) async {
  await for (final entity in dir.list(recursive: true)) {
    if (entity is File && entity.path.endsWith('.dart')) {
      var content = await entity.readAsString();
      var modified = false;

      for (final package in packagesToStub) {
        // Replace direct imports with conditional imports
        final directImport = "import 'package:$package/";
        if (content.contains(directImport)) {
          // Replace with conditional import
          content = content.replaceAll(
            RegExp("import 'package:$package/[^']*';"),
            "import 'package:$package/${package.replaceAll('_', '_')}.dart' if (dart.library.html) 'web_stubs/${package}_stub.dart';",
          );
          modified = true;
        }
      }

      if (modified) {
        await entity.writeAsString(content);
        _log('Modified: ${entity.path}');
      }
    }
  }
}
