// Copyright (C) 2025 Daan – Eén vaste UnifiedPush-instantie.
//
// HET GEMETEN GEVAL.
//
// Op het toestel stonden vier losse UnifiedPush-topics naast elkaar, alle vier
// voor Plusly:
//   upNmYpWHrFCZ6D, upFU6GBOizOvmt, upfR9OXqdZ2KSO, upXWn3MBVngb0T
//
// Oorzaak: Plusly gaf `clients.map((c) => c.clientName)` door als
// UP-instantie, en clientName is 'Plusly-<millisecondsSinceEpoch>' — die wordt
// bij elke login opnieuw gegenereerd. Elke login werd daarmee een nieuwe
// instantie met een nieuw topic. FluffyChat gebruikt `['default']`.
//
// Deze test legt dat vast, plus het feit dat de instantienaam NIET uit de
// clientlijst mag komen. Een `instances: [...]` die clients aanraakt is per
// definitie fout: de waarde moet constant zijn over herstarts en logins heen.

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

  /// De `registerAppWithDialog()`-aanroep met zijn argumentenlijst.
  String upAanroep() {
    final bron = code('lib/utils/background_push.dart');
    final start = bron.indexOf('UnifiedPushUi(');
    expect(start, isNonNegative,
        reason: 'de UnifiedPushUi-registratie moet bestaan');
    final einde = bron.indexOf('registerAppWithDialog()', start);
    expect(einde, isNonNegative,
        reason: 'de registratie moet op registerAppWithDialog() eindigen');
    return bron.substring(start, einde);
  }

  group('één vaste UnifiedPush-instantie (geen clientnaam)', () {
    test('instances is een vaste lijst, niet afgeleid van clients', () {
      final aanroep = upAanroep();
      expect(
        aanroep.contains("instances: const ['default']"),
        isTrue,
        reason:
            'FluffyChat gebruikt één vaste instantienaam. Een waarde die uit '
            'de clientlijst komt verandert bij elke login en maakt daarmee '
            'elke keer een nieuw ntfy-topic aan',
      );
    });

    test('de instantienaam komt niet uit de clientlijst', () {
      final aanroep = upAanroep();
      // Dit is de kernfout: `clients.map(...)` of `c.clientName` in de
      // instances-lijst. Beide betekent een wisselende naam per login.
      expect(
        aanroep.contains('clientName'),
        isFalse,
        reason:
            'clientName is Plusly-<tijdstempel> en verandert per login; hij '
            'mag daarom nooit de UP-instantie zijn — dat was de oorzaak van '
            'de vier losse topics op het toestel',
      );
      expect(
        aanroep.contains('clients'),
        isFalse,
        reason:
            'de instantienaam moet constant zijn over logins heen, dus niet '
            'afgeleid van de ingelogde clients',
      );
    });

    test('de comment legt vast waarom dit fout was', () {
      // Onbewerkt bestand: de ankerzin staat in een comment.
      final raw = File('lib/utils/background_push.dart').readAsStringSync();
      expect(
        raw.contains('ÉÉN VASTE INSTANTIE'),
        isTrue,
        reason:
            'zonder deze uitleg wordt de clientnaam er bij een volgende '
            'refactor zo weer in gezet, met dezelfde vier topics tot gevolg',
      );
    });
  });
}
