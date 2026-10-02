// Copyright (C) 2025 Daan — share-intent wordt na verwerking opgeruimd.
//
// HET GEMETEN GEVAL (2026-10-01, ~20:00).
//
// De gebruiker: "Als ik naar de Plusly app ga, staat er vaak Deel of Delen
// met. Terwijl ik alleen maar de app wil openen."
//
// OORZAAK. Het share-intent bleef óp de activity staan. Elke heropening van
// de app bood het opnieuw aan:
//   share_initialmedia aantal=1 … share_dialoog aantal=1   ( steeds opnieuw)
// De eerdere sessielange dedupe dempte het toevallig; de venster-fix hield
// de blokkade 10s vol, waarna de dialoog terugkwam. De echte oorzaak is dat
// het intent nooit geconsumeerd werd.
//
// FIX. De plugin heeftReceiveSharingIntent.instance.reset() — consumeert
// het opgeslagen intent. Na verwerking aanroepen, vóór de dialoog.
//
// Deze test legt vast: (1) reset() wordt aangeroepen in de verwerkingsroute,
// (2) vóór de dialog (post-frame), (3) gelogd zodat een dump het bewijst.

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

  group('share-intent opschonen na verwerking', () {
    test('reset() wordt aangeroepen in de verwerkingsroute', () {
      final bron = code('lib/pages/chat_list/chat_list.dart');
      final idx = bron.indexOf('void _processIncomingSharedMedia');
      expect(idx, isNonNegative,
          reason: 'de verwerkingsfunctie moet bestaan');
      final body = bron.substring(idx);
      final einde = body.indexOf('\n  void _processIncomingUris');
      final blok = body.substring(0, einde);

      expect(
        blok.contains('ReceiveSharingIntent.instance.reset()'),
        isTrue,
        reason:
            'zonder reset() blijft het intent op de activity staan en wordt '
            'het bij elke heropening opnieuw aangeboden — de gebruiker kreeg '
            'de deeldialoog terwijl hij de app alleen wilde openen',
      );
    });

    test('reset gebeurt vóór de deeldialoog, niet erna', () {
      final bron = code('lib/pages/chat_list/chat_list.dart');
      final idx = bron.indexOf('void _processIncomingSharedMedia');
      final blok = bron.substring(idx);
      final resetIdx = blok.indexOf('ReceiveSharingIntent.instance.reset()');
      final dialoogIdx = blok.indexOf('showScaffoldDialog');
      expect(resetIdx, isNonNegative);
      expect(dialoogIdx, isNonNegative);
      expect(
        resetIdx < dialoogIdx,
        isTrue,
        reason:
            'een crash in de dialog-route mag het intent niet achterlaten; '
            'eerst opschonen, dan de dialoog openen',
      );
    });

    test('reset wordt gelogd zodat een dump het bewijst', () {
      final bron = code('lib/pages/chat_list/chat_list.dart');
      expect(
        bron.contains('share_reset'),
        isTrue,
        reason:
            'zonder logregel is niet te zien óf het opschonen liep; als de '
            'dialoog desondanks terugkomt moet de dump dat kunnen aantonen',
      );
      expect(
        bron.contains('share_reset-fout'),
        isTrue,
        reason: 'een falende reset moet eveneens zichtbaar zijn',
      );
    });
  });
}