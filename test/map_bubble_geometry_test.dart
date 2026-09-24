// Borgt de kaartgeometrie van de locatie-bubble.
//
// Aanleiding: "Locatie delen zorgt voor een kleine map ipv een normale map."
// Commit d73690fcc ("kaartweergave verbeterd — compact, tappable") zette
// height 400 -> 200, zoom 14 -> 15 EN haalde de AspectRatio-wrapper weg.
// Zonder AspectRatio rekt de kaart op tot de volledige dialoogbreedte terwijl
// de hoogte 200 blijft: een platte strook. Upstream (FluffyChat
// map_bubble.dart r39-40) heeft de wrapper wel, met 400x400 (aspect 1:1).
//
// Deze tests lezen de bron: een widget-test zou een netwerk-tile-load vergen.

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

String _code(String pad) => File(pad)
    .readAsStringSync()
    .replaceAll(RegExp(r'/\*[\s\S]*?\*/'), '')
    .split('\n')
    .map((r) => r.replaceAll(RegExp(r'//.*$', multiLine: true), ''))
    .join('\n');

void main() {
  final bron = _code('lib/pages/chat/events/map_bubble.dart');

  num _default(String naam) {
    final m = RegExp('this\\.$naam\\s*=\\s*([0-9.]+)').firstMatch(bron);
    expect(m, isNotNull, reason: 'default $naam niet gevonden');
    return num.parse(m!.group(1)!);
  }

  group('MapBubble-geometrie', () {
    test('de kaart is vierkant, niet een platte strook', () {
      // Dit is de kern van het symptoom. 400x200 zonder AspectRatio gaf een
      // strook; 400x400 mét geeft de normale kaart.
      expect(
        _default('width'),
        _default('height'),
        reason: 'width en height moeten gelijk zijn (upstream: 400x400) — '
            'een ongelijke verhouding zonder AspectRatio geeft een strook',
      );
    });

    test('heeft de AspectRatio-wrapper die de kaart vierkant houdt', () {
      expect(
        bron.contains('AspectRatio('),
        isTrue,
        reason: 'zonder AspectRatio bepaalt de ouder de breedte en blijft de '
            'hoogte op `height` staan — precies de platte strook',
      );
      expect(
        RegExp(r'aspectRatio:\s*width\s*/\s*height').hasMatch(bron),
        isTrue,
        reason: 'de verhouding moet uit de eigen velden komen, niet hardcoded',
      );
    });

    test('zoom staat op het upstream-niveau (14.0, niet 15.0)', () {
      expect(
        _default('zoom'),
        14.0,
        reason: 'd73690fcc verhoogde dit naar 15.0; upstream gebruikt 14.0',
      );
    });

    test('de bubble begrenst zichzelf nog steeds', () {
      // Niet de fix stukmaken: de Container-constraint moet blijven, anders
      // groeit de kaart voorbij de chatbubble.
      expect(
        bron.contains('BoxConstraints.loose(Size(width, height))'),
        isTrue,
        reason: 'zonder losse constraint groeit de kaart voorbij de bubble',
      );
    });

    test('de Plusly-eigen afwijkingen van upstream blijven intact', () {
      // Bewust behouden: de "Openen"-knop, de gradient-overlay, de
      // coördinatenregel en de niet-interactieve kaart. Een revert naar
      // upstream zou deze weggooien.
      expect(bron.contains('InteractiveFlag.none'), isTrue,
          reason: 'de kaart is bewust niet panbaar/zoombaar in de chat');
      expect(bron.contains('geoUri'), isTrue,
          reason: 'de Plusly-eigen tik-naar-kaarten-ingang');
      expect(bron.contains('UrlLauncher'), isTrue);
    });
  });
}
