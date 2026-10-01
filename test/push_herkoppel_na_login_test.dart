// Copyright (C) 2025 Daan – login-tijdens-registratie-fix.
//
// HET GEMETEN GEVAL (2026-10-01, dump ~10:00).
//
// Na een re-login/herinstallatie ontstond een nieuwe client
// (Plusly-1790841511153). De debugdump toonde daarna:
//   Distributor: org.unifiedpush.distributor.sunup
//   endpoint=saved registered=true
//   Last push timestamp: none
// ...en geen enkele push meer. De pusher-ensure op de homeserver liep wél
// (de code deed zijn werk), maar de distributeur hield zn kant van de
// koppeling naar de oude sessie vast. registerApp() op de bestaande
// instantie forceert een verse NEW_ENDPOINT — precies de ontbrekende stap.
//
// Deze test legt drie dingen vast:
//   1. herkopelNaLogin bestaat en doet UnifiedPush.register op 'default'.
//   2. De login-listener roept hem aan ná setupPush.
//   3. De pusher-ensure is een gedeelde helper (geen dubbele code).

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

  group('login-tijdens-registratie-fix', () {
    test('herkopelNaLogin herregistreert de default-instantie', () {
      final bron = code('lib/utils/background_push.dart');
      expect(bron.contains('Future<void> herkopelNaLogin'), isTrue,
          reason: 'de herkoppelstap moet bestaan');
      final start = bron.indexOf('Future<void> herkopelNaLogin');
      final body = bron.substring(start);
      final einde = body.indexOf('\n  }');
      final blok = body.substring(0, einde);

      expect(
        blok.contains("register(instance: 'default')"),
        isTrue,
        reason:
            'de fix moet een verse registratie afdwingen; zonder register() '
            'blijft de distributeur-kant op de oude sessie staan (gemeten: '
            'registered=true maar Last push none)',
      );
      // Bewust GEEN unregister/removeDistributor hier: het keuzemenu hoort
      // niet automatisch te verschijnen bij elke login.
      expect(
        blok.contains('removeDistributor'),
        isFalse,
        reason:
            'een login mag nooit het keuzemenu triggeren; unregister is voor '
            'de handmatige knop, niet voor deze automatische stap',
      );
    });

    test('de login-listener roept de herkoppeling aan', () {
      final bron = code('lib/widgets/matrix.dart');
      // De listener die setupPush doet (r~276), niet de .where()-filter op
      // r~157 of de loggedOut-check r~300 — pak het blok rond de setup-aanroep.
      final anker = bron.indexOf('Login complete, setting up push');
      expect(anker, isNonNegative,
          reason: 'de login-listener moet bestaan');
      final venster = bron.substring(
        anker > 200 ? anker - 200 : 0,
        (anker + 800).clamp(0, bron.length),
      );
      expect(
        venster.contains('herkopelNaLogin'),
        isTrue,
        reason:
            'zonder de aanroep in de login-listener gebeurt er niets bij een '
            'nieuwe login — precies het gemeten gat',
      );
    });

    test('pusher-ensure is een gedeelde helper zonder duplicatie', () {
      final bron = code('lib/utils/background_push.dart');
      expect(
        bron.contains('_herstelPushers'),
        isTrue,
        reason: 'de gedeelde helper moet bestaan',
      );
      // Slechts één aanroepsite met de inline loop; de rest gaat via de helper.
      final inlineLoops = 'gatewayUrl: gatewayUrl'.allMatches(bron).length;
      expect(
        inlineLoops,
        lessThan(3),
        reason:
            'de pusher-loop moet gedeeld zijn; dubbele loops divergeren bij '
            'de volgende fix (les van de default-instantie-bug)',
      );
    });
  });
}