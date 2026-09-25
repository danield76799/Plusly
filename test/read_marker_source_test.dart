// Regressietest voor de "nieuwe berichten"-marker.
//
// AANLEIDING: de marker verscheen onder een bericht zodra dat bericht gelezen
// werd — inclusief je EIGEN verzonden bericht. Daaronder stond dan de avatar
// van degene die het gelezen had. Dat is een categorie-fout: de marker hoort bij
// de LEESPOSITIE VAN DE GEBRUIKER (room.fullyRead), niet bij de gelezen-status
// van een bericht.
//
// De oorzaak was een TWEEDE implementatie naast de bestaande: de codebase had al
// `displayReadMarker` (gevoed door `controller.readMarkerEventId`, dus door
// `room.fullyRead`) en daar was een tweede, receipt-afgeleide marker bovenop
// gelegd die `room.getLatestReadMessage()` gebruikte. Die functie leest
// `event.receipts` en laat de afzender er niet uit — dus in een DM, waar de
// ander vrijwel elk bericht leest, vuurde hij constant.
//
// WAT DEZE TEST MEET: de broncode en de gatestructuur. Een rendertest zou hier
// niets kunnen aantonen zonder een volledige room met receipts en fullyRead, en
// dat is precies de laag waar de fout niet zit — de fout is de KEUZE van bron.

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

String _bron(String pad) {
  final f = File(pad);
  expect(f.existsSync(), isTrue, reason: '$pad moet bestaan');
  return f.readAsStringSync();
}

void main() {
  group('de marker komt uit de LEZER se eigen positie', () {
    test('de leespositie is room.fullyRead, niet de receipts', () {
      final chat = _bron('lib/pages/chat/chat.dart');
      expect(
        chat.contains('room.hasNewMessages ? room.fullyRead'),
        isTrue,
        reason: 'de leespositie van de gebruiker hoort uit room.fullyRead te '
            'komen; receipts vertellen waar ANDEREN zijn',
      );
    });

    test('geen tweede marker op basis van receipts in de lijst', () {
      final lijst = _bron('lib/pages/chat/chat_event_list.dart');
      // `getLatestReadMessage` MAG blijven voor de vinkjes: "heeft de ander mijn
      // bericht gelezen" is een echte receipts-vraag, en de vinkjes staan op het
      // bericht zelf (hasBeenRead). Wat niet mag is dat dezelfde bron de MARKER
      // voedt — dat was de tweede implementatie.
      expect(
        lijst.contains('isLastReadEvent'),
        isFalse,
        reason: 'dit was de tweede, receipt-afgeleide marker. Die laat de '
            'afzender er niet uit, waardoor in een DM bijna elk bericht als '
            '"gelezen door iemand anders" geldt en de marker constant vuurt — '
            'ook onder je EIGEN bericht, met de avatar van de lezer eronder.',
      );
      expect(
        lijst.contains('if (isLastReadEvent)'),
        isFalse,
        reason: 'de losse separator-widget hoort weg; er is al een marker',
      );
    });

    test('de marker staat niet op het NIEUWSTE bericht', () {
      final lijst = _bron('lib/pages/chat/chat_event_list.dart');
      expect(
        lijst.contains('i > 0 && controller.readMarkerEventId == event.eventId'),
        isTrue,
        reason: 'in een omgekeerde lijst staat de onderrand naast de invoerbalk '
            'en de SeenByRow; een marker op het nieuwste bericht leest als deel '
            'van die avatarrij',
      );
    });

    test('de marker-widget is aanwezig (de fix haalt niets weg)', () {
      final lijst = _bron('lib/pages/chat/chat_event_list.dart');
      expect(lijst.contains('displayReadMarker:'), isTrue);
      final bubble = _bron('lib/pages/chat/events/message_modern.dart');
      expect(bubble.contains('widget.displayReadMarker'), isTrue);
      expect(bubble.contains('newMessages'), isTrue,
          reason: 'de "nieuwe berichten"-tekst hoort nog gerenderd te worden');
    });
  });

  group('de vinkjes blijven op de gelezen-status van het BERICHT', () {
    test('hasBeenRead leest de leespositie, niet de receipts', () {
      final lijst = _bron('lib/pages/chat/chat_event_list.dart');
      // De vinkjes mogen wél van de leespositie-index afgeleid worden: een
      // bericht is "gelezen" als het op of vóór de leespositie van de gebruiker
      // ligt. Dat is een andere vraag dan "wie heeft dit gelezen".
      expect(lijst.contains('hasBeenRead:'), isTrue);
      expect(lijst.contains('latestReadEventIndex'), isTrue,
          reason: 'de vinkjes gebruiken de index van de leespositie');
    });
  });
}
