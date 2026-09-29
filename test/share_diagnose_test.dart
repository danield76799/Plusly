// Copyright (C) 2025 Daan – Share-diagnose.
//
// ACHTERGROND:
// Als delen vanuit Google Foto's mislukt, was dat volledig spoorloos: geen
// foutmelding in een log, geen dialog, geen regel. Daardoor was niet te zien
// WAAR het misging — bij het binnenkomen van de intent, bij het lezen van het
// bestand, of pas bij het versturen.
//
// Deze tests bewaken dat elke stap in de share-flow zijn eigen regel schrijft,
// zodat één dump na een mislukte share de falende schakel aanwijst.

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  String code(String pad) {
    final c = File(pad).readAsStringSync();
    final zonderBlok = c.replaceAll(RegExp(r'/\*[\s\S]*?\*/'), '');
    return zonderBlok
        .split('\n')
        .map((r) {
          var idx = r.indexOf('//');
          while (idx > 0 && r[idx - 1] == ':') {
            idx = r.indexOf('//', idx + 2);
          }
          return idx == -1 ? r : r.substring(0, idx);
        })
        .join('\n');
  }

  group('share-diagnose', () {
    test('de share-log bestaat en bewaart in prefs', () {
      final bron = code('lib/utils/share_event_log.dart');
      expect(
        bron.contains('plusly_share_event_log'),
        isTrue,
        reason: 'de regels moeten een app-herstart overleven',
      );
    });

    test('de log voegt samen en overschrijft niet', () {
      final bron = code('lib/utils/share_event_log.dart');
      expect(
        bron.contains('reload()'),
        isTrue,
        reason:
            'SharedPreferences is per isolate gecached; zonder reload lees je '
            'een verouderd beeld en wis je andermans regels',
      );
    });

    test('chat_list logt ontvangst met paden en types', () {
      final bron = code('lib/pages/chat_list/chat_list.dart');
      expect(
        bron.contains("'share_ontvangen'"),
        isTrue,
        reason: 'zonder dit is niet te zien of de intent uberhaupt aankwam',
      );
      expect(
        bron.contains("'paden'"),
        isTrue,
        reason:
            'het pad onderscheidt content-URI van bestandspad; dat is precies '
            'het verschil tussen Google Foto en Standaard Foto',
      );
    });

    test('elke afbreekreden wordt apart gelogd', () {
      final bron = code('lib/pages/chat_list/chat_list.dart');
      for (final reden in [
        'geen-bestanden',
        'alles-al-gezien',
        'alleen-deeplink',
        'leeg-pad',
        'niet-gemonteerd',
      ]) {
        expect(
          bron.contains("'$reden'"),
          isTrue,
          reason: 'afbreekreden $reden moet meetbaar zijn',
        );
      }
    });

    test('stream- en initialmedia-fouten worden gelogd', () {
      final bron = code('lib/pages/chat_list/chat_list.dart');
      expect(
        bron.contains("'share_stream-fout'"),
        isTrue,
        reason: 'een plugin-fout op de stream verdween eerder in de console',
      );
      expect(
        bron.contains("'share_initialmedia'"),
        isTrue,
        reason: 'delen terwijl de app dicht was gaat via initialMedia',
      );
    });

    test('de verzendfout wordt gelogd met het fouttype', () {
      final bron = code('lib/pages/chat/send_file_dialog.dart');
      expect(
        bron.contains("'share_verzend-fout'"),
        isTrue,
        reason:
            'de snackbar is vluchtig; de oorzaak moet blijven staan',
      );
      expect(
        bron.contains('runtimeType'),
        isTrue,
        reason:
            'het exceptietype onderscheidt een leesfout van een uploadfout',
      );
    });

    test('de diagnose toont de share-regels', () {
      final bron = code('lib/pages/settings/push_debug_screen.dart');
      expect(
        bron.contains('ShareEventLog'),
        isTrue,
        reason: 'de regels moeten ook daadwerkelijk zichtbaar zijn',
      );
    });
  });
}
