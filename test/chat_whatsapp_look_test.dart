// Regressietests voor de WhatsApp-look van de chat.
//
// 1. Datum-scheiding: tussen twee dagen in een gesprek staat een pil met
//    "Vandaag"/"Gisteren"/datum. Zonder die pil leest een gesprek over
//    meerdere dagen als een enkele muur.
// 2. Bubbel-staart: WhatsApp tekent een klein hoekje onder de buitenste
//    hoek van een bubbel. Plusly had alleen afgeronde hoeken.

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:Pulsly/generated/l10n/l10n.dart';
import 'package:Pulsly/pages/chat/events/bubble_tail.dart';
import 'package:Pulsly/pages/chat/events/date_separator.dart';

Widget _metTaal(Widget child, Locale locale) {
  return MaterialApp(
    localizationsDelegates: L10n.localizationsDelegates,
    supportedLocales: L10n.supportedLocales,
    locale: locale,
    home: Scaffold(body: child),
  );
}

void main() {
  group('Datum-scheiding', () {
    testWidgets('toont "Vandaag" voor een bericht van vandaag', (tester) async {
      await tester.pumpWidget(
        _metTaal(
          DateSeparator(timestamp: DateTime.now()),
          const Locale('nl'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Vandaag'), findsOneWidget);
    });

    testWidgets('toont "Gisteren" voor een bericht van gisteren', (tester) async {
      await tester.pumpWidget(
        _metTaal(
          DateSeparator(
            timestamp: DateTime.now().subtract(const Duration(days: 1)),
          ),
          const Locale('nl'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Gisteren'), findsOneWidget);
    });

    test('de scheiding gebruikt de l10n-teksten van de app', () {
      // De scheiding leest zijn label via de l10n-sleutels, dus hij volgt
      // automatisch de taalinstelling van de app (niet een eigen
      // NL/EN-keuze zoals het help-scherm vroeger deed).
      final bron = File(
        'lib/pages/chat/events/date_separator.dart',
      ).readAsStringSync();

      expect(
        bron,
        contains('localizedMonthDay(context)'),
        reason:
            'Het label moet uit de l10n-sleutels komen, zodat de '
            'datum-scheiding de taal van de app volgt',
      );
      expect(bron, isNot(contains('isDutch')),
          reason: 'geen eigen taalschakelaar in het chatscherm');
    });

    test('de chat zet een scheiding zodra de dag verandert', () {
      final bron = File(
        'lib/pages/chat/chat_event_list.dart',
      ).readAsStringSync();

      expect(
        bron,
        contains('DateSeparator(timestamp: event.originServerTs)'),
        reason:
            'De chat moet een datum-scheiding plaatsen zodra de dag '
            'verandert (WhatsApp-look)',
      );
      expect(
        bron,
        contains('isSameDay(current.originServerTs)'),
        reason:
            'De scheiding wordt bepaald door de dagvergelijking, niet door '
            'een tijdsverschil (zomertijd-drift)',
      );
    });
  });

  group('Bubbel-staart', () {
    testWidgets('tekent een staartje bij een eigen bericht', (tester) async {
      await tester.pumpWidget(
        _metTaal(
          const BubbleTail(color: Colors.green, ownMessage: true),
          const Locale('nl'),
        ),
      );
      await tester.pumpAndSettle();

      final painter = tester
          .widget<CustomPaint>(find.byType(CustomPaint).last)
          .painter;
      expect(painter, isNotNull);
    });

    test('de staart zit achter de bubbel, niet ervoor', () {
      // De staart moet het eerste kind van de Stack zijn: de bubbel tekent
      // dan zijn hoekradius erover heen, zodat er geen gat ontstaat.
      final bron = File(
        'lib/pages/chat/events/message_bubble.dart',
      ).readAsStringSync();

      final staartIndex = bron.indexOf('BubbleTail(color: bubbleColor');
      final bubbelIndex = bron.indexOf('final bubble = ClipRRect(');
      expect(staartIndex, greaterThan(-1), reason: 'de staart ontbreekt');
      expect(bubbelIndex, greaterThan(-1), reason: 'de bubbel ontbreekt');
      expect(
        staartIndex,
        greaterThan(bubbelIndex),
        reason:
            'De BubbleTail moet in de bron ná de ClipRRect staan, zodat hij '
            'écht als kind aan de Stack wordt toegevoegd',
      );
    });
  });
}
