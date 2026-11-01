// De Links-tab in het per-chat media-overzicht.
//
// WhatsApp heeft naast Media en Documenten ook een tab met gedeelde
// webadressen: "waar stond die link ook alweer?" is een van de meest
// gestelde vragen in een gesprek. Plusly had Berichten/Galerij/Bestanden
// maar miste die tab.
//
// Wat hier vastligt:
// 1. Alleen echte webadressen horen in de tab — niet elk woord met een
//    dubbele punt, en niet een mailadres.
// 2. De tab staat er echt (broncodecontrole op het aantal tabs en op de
//    filter die de zoekpagina gebruikt).

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:Pulsly/pages/chat_search/chat_search_links_tab.dart';

void main() {
  group('bevatLink', () {
    test('vindt een https-adres', () {
      expect(bevatLink('Zie https://example.org/plan.pdf'), isTrue);
    });

    test('vindt een http-adres', () {
      expect(bevatLink('http://example.org'), isTrue);
    });

    test('vindt een adres midden in de tekst', () {
      expect(bevatLink('De afspraak staat op https://x.y/z om 9 uur.'), isTrue);
    });

    test('vindt een adres aan het einde', () {
      expect(bevatLink('kijk maar https://example.org'), isTrue);
    });

    test('negeert gewone tekst', () {
      expect(bevatLink('Maandag zit ik met Madelief bij een advocaat.'), isFalse);
    });

    test('negeert een mailadres', () {
      expect(bevatLink('Mail naar fenna@example.org'), isFalse);
    });

    test('negeert een matrix-id', () {
      expect(bevatLink('Groet van @fenna:example.org'), isFalse);
    });

    test('leeg is geen link', () {
      expect(bevatLink(''), isFalse);
      expect(bevatLink('   '), isFalse);
    });
  });

  group('broncode', () {
    test('de zoekpagina heeft vier tabs', () {
      final view = File(
        'lib/pages/chat_search/chat_search_view.dart',
      ).readAsStringSync();
      expect(view.contains('L10n.of(context).links'), isTrue);
      expect(
        view.contains('ChatSearchLinksTab('),
        isTrue,
        reason: 'de tab moet ook echt zijn aangesloten',
      );
    });

    test('de zoekpagina filtert op webadressen', () {
      final page = File(
        'lib/pages/chat_search/chat_search_page.dart',
      ).readAsStringSync();
      expect(
        page.contains('bevatLink(event.body)'),
        isTrue,
        reason: 'de tab hoort alleen berichten met een webadres te krijgen',
      );
    });

    test('de links staan na de galerij, vóór de bestanden', () {
      final view = File(
        'lib/pages/chat_search/chat_search_view.dart',
      ).readAsStringSync();
      final galerij = view.indexOf('ChatSearchImagesTab(');
      final links = view.indexOf('ChatSearchLinksTab(');
      final bestanden = view.indexOf('ChatSearchFilesTab(');
      expect(galerij, greaterThan(0));
      expect(links, greaterThan(galerij));
      expect(bestanden, greaterThan(links));
    });
  });
}
