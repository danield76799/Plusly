// Regressietests voor de "Nieuwe berichten"-divider in de tijdlijn.
//
// AANLEIDING. Op 19-09-2026 kwam er een tweede divider-implementatie bij, op
// basis van `getLatestReadMessage(timeline)`. Die functie zoekt het nieuwste
// bericht waarop IEMAND ANDERS een leesbevestiging heeft — niet waar de
// gebruiker zelf gebleven is. Gevolg: de divider verscheen ook als er niets
// ongelezen was (hij filtert de afzender-receipt niet weg, dus in een DM wijst
// hij vrijwel altijd naar het nieuwste bericht), en belandde onderaan de
// tijdlijn direct boven de SeenByRow. Visueel leek het dan of de
// leesbevestigings-avatars zelf "nieuwe berichten" waren.
//
// REGEL. Er is één divider-bron: `readMarkerEventId` (= hasNewMessages ?
// fullyRead : ''), zoals FluffyChat. En de divider mag nooit op het nieuwste
// bericht zelf staan (de `i > 0`-guard).

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Broncode zonder commentaar: de uitleg bij een fix citeert bewust de oude
/// code, en daar mag een structuurtest niet op stuklopen.
String _code(String pad) {
  final zonderBlok =
      File(pad).readAsStringSync().replaceAll(RegExp(r'/\*[\s\S]*?\*/'), '');
  return zonderBlok
      .split('\n')
      .map((regel) => regel.replaceAll(RegExp(r'//.*$'), ''))
      .join('\n');
}

void main() {
  final code = _code('lib/pages/chat/chat_event_list.dart');

  group('één bron voor de divider', () {
    test('de tijdlijn bouwt geen receipt-divider meer', () {
      expect(
        RegExp(r'isLastReadEvent').hasMatch(code),
        isFalse,
        reason: 'tweede divider-implementatie hoort niet terug te komen',
      );
      expect(
        RegExp(r'isLastReadEvent[\s\S]{0,400}L10n\.of\(context\)\.newMessages')
            .hasMatch(code),
        isFalse,
        reason: 'de receipt-divider toonde "newMessages" onderaan de tijdlijn',
      );
      // De divider-op-het-laatst-gelezen-bericht is weg; er is nu precies
      // één plek in dit bestand die newMessages noemt — de oude kwam erbij.
      expect(
        RegExp(r'newMessages').allMatches(code).length,
        0,
        reason: 'de tijdlijn rendert zelf geen divider meer',
      );
    });

    test('de divider komt uit readMarkerEventId (hasNewMessages + fullyRead)',
        () {
      expect(
        code.contains('controller.readMarkerEventId == event.eventId'),
        isTrue,
        reason: 'dit is de FluffyChat-bron voor de divider',
      );
    });
  });

  group('divider staat nooit op het nieuwste bericht', () {
    test('displayReadMarker heeft de i > 0-guard', () {
      expect(
        RegExp(r'displayReadMarker:\s*\n?\s*i > 0 &&').hasMatch(code),
        isTrue,
        reason: 'zonder deze guard kan de divider op het laatste bericht '
            'staan en onderaan de tijdlijn plakken',
      );
    });
  });

  group('leesbevestigings-vinkjes blijven intact', () {
    test('hasBeenRead voedt nog steeds de blauwe vinkjes', () {
      // De divider is weg, maar de blauwe-vinkjesketen moet blijven werken.
      expect(code.contains('hasBeenRead'), isTrue);
      expect(code.contains('latestReadEvent'), isTrue,
          reason: 'hasBeenRead rekent op de laatst-gelezen-index');
    });
  });
}
