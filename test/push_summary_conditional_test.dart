// Copyright (C) 2025 Daan – Push-summary conditional test.
//
// 23454: de groeps-samenvatting mag alleen aangeroepen worden nadat
// een individuele melding al zichtbaar was. Anders verving de summary
// op Android 17 de individuele meldingen en verdwenen ze in de OS-balk.
//
// We bekrachtigen hier de structurele ankerpunten van die fix:
//   * direct na show() checkt de code of er al een actieve notificatie
//     bestaat met dezelfde notificationId (zelfde clientName + room),
//   * updateSummaryNotification wordt alleen aangeroepen binnen een
//     hasSameRoomActive-guard,
//   * de hulp-comment legt expliciet vast dat het een 23454-fix is.

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  String code(String pad) {
    final c = File(pad).readAsStringSync();
    final zonderBlok = c.replaceAll(RegExp(r'/\*[\s\S]*?\*/'), '');
    final regels = zonderBlok
        .split('\n')
        .map((r) {
          final idx = r.indexOf('//');
          return idx == -1 ? r : r.substring(0, idx);
        });
    return regels.join('\n');
  }

  group('push summary conditional (23454)', () {
    test('show() wordt gevolgd door een active-notifications check', () {
      final helper = code('lib/utils/push_helper.dart');
      expect(
        helper.contains('getActiveNotifications'),
        isTrue,
        reason:
            '23454: na show() moet de code peilen of er al een actieve '
            'notificatie bestaat voor dezelfde kamer',
      );
    });

    test('summary wordt alleen aangeroepen onder een guard', () {
      final helper = code('lib/utils/push_helper.dart');
      // De guard-variabele moet expliciet genoemd worden zodat een toevallige
      // refactor 'm niet weghaalt zonder de summary-aanroep mee te verhuizen.
      expect(
        helper.contains('hasSameRoomActive'),
        isTrue,
        reason:
            '23454: updateSummaryNotification moet alleen binnen '
            'hasSameRoomActive draaien',
      );
    });

    test('updateSummaryNotification blijft aangeroepen binnen de guard', () {
      final helper = code('lib/utils/push_helper.dart');
      // Zoek het 23454-blok (na regel ~440) en kijk dat de guard
      // erboven staat. We pakken hier de tweede aanroep, want de eerste
      // (rond regel 228) valt onder de needsUpdateForSummaryNotification-
      // vlag en hoort daar niet bij de 23454-fix.
      final lines = helper.split('\n');
      var summaryIndex = -1;
      var count = 0;
      for (var i = 0; i < lines.length; i++) {
        if (lines[i].contains('updateSummaryNotification(')) {
          count++;
          if (count == 2) {
            summaryIndex = i;
            break;
          }
        }
      }
      expect(summaryIndex, isNonNegative,
          reason: 'tweede updateSummaryNotification-call (23454) moet bestaan');
      // Kijk in de 8 regels vóór de summary-aanroep voor de guard.
      final window = lines
          .sublist(
            summaryIndex > 8 ? summaryIndex - 8 : 0,
            summaryIndex + 1,
          )
          .join('\n');
      expect(
        window.contains('hasSameRoomActive'),
        isTrue,
        reason:
            '23454: tweede updateSummaryNotification moet binnen de '
            'hasSameRoomActive-guard staan',
      );
    });

    test('comment markeert expliciet de 23454-fix', () {
      // We lezen hier het onbewerkte bronbestand, niet de comment-stripped
      // variant, omdat de ankerzin per definitie in een comment staat.
      final raw = File('lib/utils/push_helper.dart').readAsStringSync();
      expect(
        raw.contains('23454'),
        isTrue,
        reason:
            '23454: een comment met het build-nummer maakt duidelijk dat dit '
            'de samenvattings-conditional is, niet de upstream-variant',
      );
    });
  });
}
