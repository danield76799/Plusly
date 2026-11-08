// Regressietest voor de cache met originele berichtteksten.
//
// Probleem: bij een Matrix-redaction verwijdert de SDK de content van het
// event. In matrix-dart-sdk doet Event.setRedactionEvent() dat:
//
//   unsigned = {'redacted_because': ...};
//   prevContent = null;
//   final contentKeyWhiteList = <String>[];   // leeg voor m.room.message
//
// Daarna levert Event.body de letterlijke string 'Redacted' op en is de
// originele tekst nergens meer terug te vinden uit het event zelf.
//
// Oplossing: RedactedBodyCache bewaart de body zodra het bericht getoond
// wordt, en levert die terug wanneer het bericht later verwijderd blijkt.

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:Pulsly/utils/redacted_body_cache.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('RedactedBodyCache', () {
    test('bewaart en leest de body van een bericht', () {
      final cache = RedactedBodyCache.instance;
      const key = '!room:example.org:bericht1';

      expect(cache.lookup(key), isNull);

      cache.store(key, 'Dit was de originele tekst');

      expect(cache.lookup(key), 'Dit was de originele tekst');
    });

    test('een lege body wordt niet bewaard', () {
      final cache = RedactedBodyCache.instance;
      const key = '!room:example.org:leeg';

      cache.store(key, '');

      expect(cache.lookup(key), isNull);
    });

    test('overschrijven kan niet: de eerste body blijft', () {
      final cache = RedactedBodyCache.instance;
      const key = '!room:example.org:bericht2';

      cache.store(key, 'originele tekst');
      cache.store(key, 'andere tekst');

      expect(cache.lookup(key), 'originele tekst');
    });

    test('de cache-sleutel combineert ruimte en event', () {
      expect(
        redactedCacheKey('!abc:example.org', '\$event1'),
        '!abc:example.org:\$event1',
      );
    });

    test('de cache wordt gevuld vanuit de Message-wrapper', () {
      // De opslag moet in de wrapper rond ALLE bericht-layouts staan
      // (bubbles, bubblesLegacy, modern). In een van de bubbel-widgets
      // zou de cache bij een andere layout leeg blijven.
      final wrapper = File(
        'lib/pages/chat/events/message.dart',
      ).readAsStringSync();
      expect(
        wrapper,
        contains('RedactedBodyCache.instance.store('),
        reason:
            'De Message-wrapper moet de originele tekst bewaren, zodat het '
            'werkt onafhankelijk van de gekozen bericht-layout',
      );

      for (final bubbel in [
        'lib/pages/chat/events/message_bubble.dart',
        'lib/pages/chat/events/message_bubble_legacy.dart',
        'lib/pages/chat/events/message_modern.dart',
      ]) {
        final inhoud = File(bubbel).readAsStringSync();
        expect(
          inhoud,
          isNot(contains('RedactedBodyCache.instance.store(')),
          reason:
              '$bubbel slaat de body op; dat hoort in de Message-wrapper, '
              'anders blijft de cache leeg bij een andere layout',
        );
      }
    });

    test('de cache overleeft een herstart (SharedPreferences)', () async {
      final cache = RedactedBodyCache.instance;
      const key = '!room:example.org:persistent';
      cache.store(key, 'blijft bewaard');

      // Handmatig wegschrijven, zoals de app doet bij het naar de achtergrond
      // gaan of na de schrijfvertraging van een paar seconden.
      await cache.flush();

      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString('redacted_body_cache_v1');
      expect(raw, isNotNull);
      final decoded = jsonDecode(raw!);
      expect(decoded, contains(key));
      expect(decoded[key]['body'], 'blijft bewaard');
    });
  });
}
