// Copyright (C) 2025 Daan – Pusher-registratie bij app-start.
//
// ACHTERGROND (bug die dit bewaakt):
// `setupPusher()` — de functie die de pusher bij de homeserver registreert —
// werd alleen aangeroepen vanuit `_newUpEndpoint`, de callback van
// `UnifiedPush.initialize(onNewEndpoint: ...)`. Die callback gaat alleen af
// als de distributeur een NIEUW endpoint uitgeeft.
//
// ntfy geeft bij her-registratie van hetzelfde toestel hetzelfde endpoint
// terug. Gevolg: bij een nieuwe login (nieuwe clientnaam) of een
// accountwissel bleef `onNewEndpoint` uit, werd er nooit een pusher gezet,
// en ontving het toestel berichten via sync maar nooit een push. De
// diagnose toonde `endpoint=saved registered=true` (stale uit de oude
// sessie) met `Last push timestamp: none`.
//
// De fix: `setupPush()` controleert bij elke start zelf de pusher voor elke
// ingelogde client. `setupPusher()` is idempotent — staat er al een
// kloppende pusher, dan stopt hij direct.
//
// Deze test bewaakt de structurele ankerpunten daarvan.

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  /// Verwijdert een regelcommentaar, maar laat `//` binnen een string met
  /// rust. Zonder deze uitzondering wordt `https://…` afgekapt tot `https:`
  /// en verdwijnen URL's uit de te controleren body.
  String stripLineComment(String regel) {
    var vanaf = 0;
    while (true) {
      final idx = regel.indexOf('//', vanaf);
      if (idx < 0) return regel;
      if (idx > 0 && regel[idx - 1] == ':') {
        // `://` hoort bij een URL, niet bij commentaar.
        vanaf = idx + 2;
        continue;
      }
      return regel.substring(0, idx);
    }
  }

  String code(String pad) {
    final c = File(pad).readAsStringSync();
    final zonderBlok = c.replaceAll(RegExp(r'/\*[\s\S]*?\*/'), '');
    return zonderBlok.split('\n').map(stripLineComment).join('\n');
  }

  /// Geeft de body van een lidfunctie: vanaf de signature tot de volgende
  /// lidfunctie-signatuur op hetzelfde inspringingsniveau (twee spaties in
  /// deze class). We ankeren op `\n  Future<` / `\n  void ` zodat een
  /// toevallige variabele-declaratie de body niet afknipt.
  String bodyOf(String bron, String signature) {
    final start = bron.indexOf(signature);
    if (start < 0) return '';
    final na = bron.substring(start + signature.length);
    final match = RegExp(
      r'\n  (?:@\w+\n  )?(?:Future<[^>]*>|void|String|bool|int|double|List<[^>]*>|Map<[^>]*>) \w+\(',
    ).firstMatch(na);
    return match == null ? na : na.substring(0, match.start);
  }

  group('pusher-registratie bij app-start', () {
    final bestand = 'lib/utils/background_push.dart';

    // 2026-10-01: de pusher-ensure is een GEDEELDE helper (_herstelPushers)
    // geworden, opgeroepen uit setupPush én herkopelNaLogin. De ankers
    // controleren daarom de helper zelf plus de aanroep in setupPush — niet
    // meer de inline-code in de setupPush-body.
    String herstelBody(String bron) =>
        bodyOf(bron, 'Future<void> _herstelPushers(');

    test('setupPush zet zelf een pusher, niet alleen via onNewEndpoint', () {
      final bron = code(bestand);
      final body = herstelBody(bron);
      expect(body, isNotEmpty, reason: '_herstelPushers moet bestaan');
      expect(
        body.contains('setupPusher('),
        isTrue,
        reason:
            'zonder directe aanroep blijft de pusher ontbreken '
            'wanneer het UnifiedPush-endpoint niet verandert',
      );
      // En setupPush moet de helper aanroepen.
      final setupPush = bodyOf(bron, 'Future<void> setupPush(');
      expect(
        setupPush.contains('_herstelPushers('),
        isTrue,
        reason:
            'setupPush moet de gedeelde helper aanroepen; zonder aanroep '
            'gebeurt er bij de start niets meer',
      );
    });

    test('setupPush gebruikt het opgeslagen endpoint als token', () {
      final body = herstelBody(code(bestand));
      expect(
        body.contains('AppSettings.unifiedPushEndpoint.value'),
        isTrue,
        reason: 'de pusher moet met het bewaarde endpoint geregistreerd worden',
      );
      expect(
        body.contains('token: savedEndpoint'),
        isTrue,
        reason: 'zonder token weigert setupPusher te registreren',
      );
    });

    test('lege endpoint wordt overgeslagen, niet als leeg token verstuurd', () {
      final body = herstelBody(code(bestand));
      expect(
        body.contains('savedEndpoint.isNotEmpty'),
        isTrue,
        reason:
            'zonder deze guard zou een verse installatie een pusher met een '
            'leeg endpoint proberen te zetten',
      );
    });

    test('alleen voor ingelogde clients registreren', () {
      final body = herstelBody(code(bestand));
      expect(
        body.contains('isLogged()'),
        isTrue,
        reason: 'uitgelogde clients hebben geen geldige sessie voor een pusher',
      );
    });

    test('fouten blokkeren het opstarten niet', () {
      final body = herstelBody(code(bestand));
      expect(
        body.contains('catch'),
        isTrue,
        reason:
            'een mislukte pusher-registratie mag het opstarten van de app '
            'niet laten klappen',
      );
    });

    test('gateway-resolutie zit in één hulpfunctie', () {
      final bron = code(bestand);
      expect(
        bron.contains('Future<String> _resolveGatewayUrl('),
        isTrue,
        reason: 'de gateway-URL-logica hoort op één plek te staan',
      );

      final nieuwEndpoint = bodyOf(bron, 'Future<void> _newUpEndpoint(');
      expect(
        nieuwEndpoint.contains('_resolveGatewayUrl('),
        isTrue,
        reason: '_newUpEndpoint moet dezelfde hulpfunctie gebruiken',
      );

      // De oude inline-logica mag niet zijn blijven staan.
      expect(
        nieuwEndpoint.contains('matrix.gateway.unifiedpush.org'),
        isFalse,
        reason: 'de publieke gateway-URL hoort alleen in _resolveGatewayUrl',
      );
    });

    test('_resolveGatewayUrl valt terug op de publieke UP-gateway', () {
      final body = bodyOf(code(bestand), 'Future<String> _resolveGatewayUrl(');
      expect(
        body.contains('matrix.gateway.unifiedpush.org'),
        isTrue,
        reason: 'zonder zelf-gehoste gateway moet de publieke gateway gebruikt',
      );
      expect(
        body.contains('catch'),
        isTrue,
        reason: 'een onbereikbare discovery-pagina mag niet doorwerken',
      );
    });
  });
}
