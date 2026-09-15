// Borgt de twee upstream-pariteiten (09-2026):
// 1. Foreground-service rond uploads: wegdrukken killt de upload niet meer.
// 2. Archief hergebruikt zijn timeline i.p.v. opnieuw laden.

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Broncode zonder commentaar: uitleg citeert bewust oude code.
// Let op: //.*$ stript per regel ALLEEN met multiLine:true — zonder vlag
// matcht $ uitsluitend het bestandeinde en blijft elk regelcommentaar staan.
String _code(String pad) {
  final c = File(pad).readAsStringSync();
  final zonderBlok = c.replaceAll(RegExp(r'/\*[\s\S]*?\*/'), '');
  return zonderBlok
      .split('\n')
      .map((r) => r.replaceAll(RegExp(r'//.*$', multiLine: true), ''))
      .join('\n');
}

void main() {
  group('Foreground-service rond uploads (structuur)', () {
    test('manifest dekt shortService af', () {
      final manifest = File(
        'android/app/src/main/AndroidManifest.xml',
      ).readAsStringSync();
      expect(
        manifest.contains('FOREGROUND_SERVICE_SHORT_SERVICE'),
        isTrue,
        reason: 'Android 14+ eist de permissie per type',
      );
      expect(manifest.contains('mediaProjection|shortService'), isTrue,
          reason: 'service-declaratie moet het type kennen');
    });

    test('helper deelt één service en killt geen gesprek', () {
      final code = _code('lib/utils/foreground_services.dart');
      expect(code.contains('_runningServices'), isTrue,
          reason: 'refcount: meerdere sends delen één service');
      expect(code.contains('_externGestart'), isTrue,
          reason: 'lopende service (gesprek) bij stop met rust laten');
      expect(code.contains('ForegroundServiceTypes.shortService'), isTrue);
      expect(code.contains('PlatformInfos.isMobile'), isTrue,
          reason: 'alleen mobiel');
    });

    test('alle vier verstuur-paden starten en stoppen', () {
      final dialoog = _code('lib/pages/chat/send_file_dialog.dart');
      expect(dialoog.contains("startService('send_files')"), isTrue);
      expect(dialoog.contains("stopService('send_files')"), isTrue);
      expect(dialoog.contains('finally'), isTrue,
          reason: 'ook stoppen bij falen');

      final chat = _code('lib/pages/chat/chat.dart');
      expect(
        RegExp(r"startService\('send_files'\)").allMatches(chat).length,
        2,
        reason: 'voice + video-note',
      );
      expect(
        RegExp(r"stopService\('send_files'\)").allMatches(chat).length,
        2,
      );

      final input = _code('lib/pages/chat/input_bar.dart');
      expect(input.contains("startService('send_files')"), isTrue,
          reason: 'plakken is fire-and-forget maar telt wel mee');
    });
  });

  group('Archief hergebruikt timeline (structuur)', () {
    test('archief laadt met timelines en geeft ze mee', () {
      final archief = _code('lib/pages/archive/archive.dart');
      expect(archief.contains('loadArchiveWithTimeline'), isTrue);
      expect(archief.contains('ArchivedRoom'), isTrue);
      expect(archief.contains('.room.forget()'), isTrue);

      final view = _code('lib/pages/archive/archive_view.dart');
      expect(view.contains('extra: controller.archive[i].timeline'), isTrue);
    });

    test('route geeft alleen een Timeline door, geen shareItems-conflict', () {
      final routes = _code('lib/config/routes.dart');
      expect(routes.contains('state.extra is Timeline'), isTrue,
          reason: 'type-check, geen cast: extra draagt elders shareItems');
    });

    test('chat hergebruikt archive-timeline zonder cache', () {
      final chat = _code('lib/pages/chat/chat.dart');
      expect(chat.contains('widget.timeline != null'), isTrue,
          reason: 'archive-timeline hergebruiken');
      expect(chat.contains('timeline = widget.timeline;'), isTrue);
      // SDK 6.2.0: .room bestaat alleen op RoomTimeline.
      expect(chat.contains('timeline is RoomTimeline'), isTrue);
      expect(chat.contains('TimelineCache.setTimeline'), isFalse,
          reason: 'dode regel: nooit een UI-timeline registreren');
    });
  });
}
