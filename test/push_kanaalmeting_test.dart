// Copyright (C) 2025 Daan – Kanaalmeting in de pushdiagnose.
//
// ACHTERGROND:
// Android staat niet toe dat een app de importance van een BESTAAND
// notificatiekanaal wijzigt. `createNotificationChannel()` in
// flutter_local_notifications stuurt altijd
// `AndroidNotificationChannelAction.createIfNotExists`, en aan de
// Java-kant betekent dat: alleen aanmaken als het kanaal nog niet
// bestaat. Voor een bestaand kanaal is die aanroep dus een no-op —
// importance, geluid en trillen blijven zoals ze ooit zijn vastgezet.
//
// Daardoor was niet te zien of een melding stil blijft door een laag
// kanaal of door iets anders. Deze uitlezing maakt dat meetbaar:
//   * staan meldingen überhaupt toe?
//   * welk importance-niveau heeft het kanaal ECHT?
//   * staan geluid, trillen en badge aan?
//
// De test bewaakt dat die meting blijft bestaan en dat de plugin de
// uitlees-API's blijft aanbieden waarop ze leunt.

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  String code(String pad) {
    final c = File(pad).readAsStringSync();
    final zonderBlok = c.replaceAll(RegExp(r'/\*[\s\S]*?\*/'), '');
    return zonderBlok
        .split('\n')
        .map((r) {
          final idx = r.indexOf('//');
          return idx == -1 ? r : r.substring(0, idx);
        })
        .join('\n');
  }

  group('kanaalmeting in pushdiagnose', () {
    final scherm = 'lib/pages/settings/push_debug_screen.dart';

    test('het scherm leest de echte kanaalinstellingen uit', () {
      final bron = code(scherm);
      expect(
        bron.contains('getNotificationChannels'),
        isTrue,
        reason:
            'zonder uitlezing is niet te zien of het kanaal stil staat; '
            'createNotificationChannel kan een bestaand kanaal niet wijzigen',
      );
    });

    test('het scherm toont of meldingen toegestaan zijn', () {
      final bron = code(scherm);
      expect(
        bron.contains('areNotificationsEnabled'),
        isTrue,
        reason: 'een uitgezette meldingsinstelling ziet er hetzelfde uit',
      );
    });

    test('de meting toont importance, geluid, trillen en DND', () {
      final bron = code(scherm);
      for (final veld in [
        'importance',
        'playSound',
        'enableVibration',
        'bypassDnd',
      ]) {
        expect(
          bron.contains(veld),
          isTrue,
          reason: 'kanaalveld $veld hoort in de meting te staan',
        );
      }
    });

    test('de meting filtert op het eigen kanaal-id', () {
      final bron = code(scherm);
      expect(
        bron.contains('AppConfig.pushNotificationsChannelId'),
        isTrue,
        reason: 'anders verdrinkt de meting in kanalen van andere plugins',
      );
    });

    test('een mislukte meting laat het scherm niet klappen', () {
      final bron = code(scherm);
      // Anker op de code, niet op de toelichting: de commentaar-stripper
      // hierboven haalt juist het commentaar weg.
      final start = bron.indexOf('getNotificationChannels');
      expect(start, isNonNegative, reason: 'de meting moet bestaan');
      final blok = bron.substring(start, start + 1200);
      expect(
        blok.contains('catch'),
        isTrue,
        reason: 'de diagnose moet ook zonder plugin-permissie bruikbaar zijn',
      );
    });

    test('de client-regel met endpoint en registered blijft aanwezig', () {
      // Regressie op het per ongeluk verwijderen van deze regel.
      final bron = code(scherm);
      expect(
        bron.contains('endpoint='),
        isTrue,
        reason: 'de endpoint/registered-regel hoort in de statuskop te staan',
      );
      expect(
        bron.contains('registered='),
        isTrue,
        reason: 'registered= is het eerste where signaal dat iets mis is',
      );
    });
  });
}
