// Copyright (C) 2025 Daan – Meting: neemt Android de melding over?
//
// ACHTERGROND:
// `flutterLocalNotificationsPlugin.show()` geeft op Android geen
// terugkoppeling. De plugin roept NotificationManager.notify() aan en
// meldt alleen of de *aanroep* lukte, niet wat Android ermee doet.
// Daardoor was niet te onderscheiden:
//   a) Android verwerpt de melding meteen, of
//   b) Android neemt 'm aan maar toont 'm niet (systeemlaag blokkeert).
//
// De meting leest direct na show() de actieve notificaties uit en legt
// vast of het zojuist gezette id er tussen zit. Dat maakt het verschil
// tussen (a) en (b) meetbaar in plaats van giswerk.
//
// Deze test bewaakt dat de meting blijft bestaan en na de show()-aanroep
// blijft staan.

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  String code(String pad) {
    final c = File(pad).readAsStringSync();
    final zonderBlok = c.replaceAll(RegExp(r'/\*[\s\S]*?\*/'), '');
    return zonderBlok
        .split('\n')
        .map((r) {
          // Let op: '//' in een URL of string mag niet als commentaar gelden.
          var idx = r.indexOf('//');
          while (idx > 0 && r[idx - 1] == ':') {
            idx = r.indexOf('//', idx + 2);
          }
          return idx == -1 ? r : r.substring(0, idx);
        })
        .join('\n');
  }

  group('push active-check meting', () {
    final helper = 'lib/utils/push_helper.dart';

    test('er wordt na show() een push_active_check gelogd', () {
      final bron = code(helper);
      expect(
        bron.contains("'push_active_check'"),
        isTrue,
        reason:
            'zonder deze meting is niet te zien of Android de melding '
            'verwerpt of alleen niet toont',
      );
    });

    test('de meting leest de actieve notificaties uit', () {
      final bron = code(helper);
      expect(
        bron.contains('getActiveNotifications'),
        isTrue,
        reason: 'de meting moet bij Android navragen wat er actief is',
      );
    });

    test('de meting staat NA de show()-aanroep', () {
      final bron = code(helper);
      final showIdx = bron.indexOf("PushEventLog().add('push_show_result'");
      final checkIdx = bron.indexOf("PushEventLog().add('push_active_check'");
      expect(showIdx, isNonNegative, reason: 'show_result moet bestaan');
      expect(checkIdx, isNonNegative, reason: 'active_check moet bestaan');
      expect(
        checkIdx > showIdx,
        isTrue,
        reason:
            'de meting heeft alleen zin direct na de show(); ervoor zou hij '
            'het vorige beeld lezen',
      );
    });

    test('de meting meldt expliciet ja of nee', () {
      final bron = code(helper);
      expect(
        bron.contains("'actief': actief ? 'ja' : 'nee'"),
        isTrue,
        reason: 'een meting zonder uitslag is geen meting',
      );
    });

    test('een mislukte meting wordt apart gemarkeerd, niet stil', () {
      final bron = code(helper);
      expect(
        bron.contains("'actief': 'fout'"),
        isTrue,
        reason:
            'als de uitlezing zelf faalt moet dat zichtbaar zijn, anders '
            'lijkt het op een lege uitslag',
      );
    });
  });
}
