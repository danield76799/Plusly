// Zoeken binnen een chat: de zoekterm moet gemarkeerd staan in de
// resultaten, en een tik op een resultaat moet naar dat bericht gaan.
//
// HET PROBLEEM (code-audit 01-11-2026, Plusly v1.4.17+23551):
//   De zoekpagina (/rooms/<id>/search) bestond al, met tabbladen Berichten,
//   Galerij en Bestanden. Twee dingen ontbraken aan het berichtentabblad:
//
//   1. De zoekterm werd NIET gemarkeerd. Het veld `searchQuery` werd zelfs
//      aan de resultaattegel doorgegeven maar nergens gebruikt — je moest
//      per regel zelf lezen waar de match stond.
//   2. Tikken op een resultaat deed niets. Alleen het pijltje rechtsop
//      navigeerde, terwijl het resultaat zelf de reden is dat je zoekt.
//
// Nu: BodyWithHighlight tekent de treffers met een achtergrondkleur en
// houdt URLs aanklikbaar (die gingen via Linkify verloren als je die zou
// vervangen zonder ze zelf te herkennen).

import 'dart:io';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:Pulsly/pages/chat_search/chat_search_message_tab.dart';

Widget _app({required String text, required String query}) {
  return MaterialApp(
    home: Scaffold(
      body: BodyWithHighlight(text: text, query: query, maxLines: 7),
    ),
  );
}

TextSpan _spans(WidgetTester tester) {
  for (final text in tester.widgetList<Text>(find.byType(Text))) {
    if (text.textSpan != null) return text.textSpan as TextSpan;
  }
  fail('geen Text met tekstspans gevonden — de body wordt niet als span '
      'getekend en kan de zoekterm dus niet markeren');
}

List<String> _metAchtergrond(TextSpan root) {
  final result = <String>[];
  void walk(InlineSpan span) {
    if (span is TextSpan) {
      if (span.style?.backgroundColor != null &&
          span.toPlainText().isNotEmpty) {
        result.add(span.toPlainText());
      }
      span.children?.forEach(walk);
    }
  }

  walk(root);
  return result;
}

List<String> _onderstreept(TextSpan root) {
  final result = <String>[];
  void walk(InlineSpan span) {
    if (span is TextSpan) {
      if (span.style?.decoration == TextDecoration.underline) {
        result.add(span.toPlainText());
      }
      span.children?.forEach(walk);
    }
  }

  walk(root);
  return result;
}

/// De tekst zonder enige opmaak, zoals het oog die leest.
String _plat(TextSpan root) => root.toPlainText();

void main() {
  group('zoekterm markeren', () {
    testWidgets('markeert de zoekterm in het resultaat', (tester) async {
      await tester.pumpWidget(
        _app(
          query: 'Madelief',
          text: 'Formeel wordt zij nu als verdachte gezien. Maandag zit ik met '
              'Madelief bij een advocaat.',
        ),
      );

      expect(_metAchtergrond(_spans(tester)), ['Madelief']);
    });

    testWidgets('markeert ongeacht hoofdletters', (tester) async {
      await tester.pumpWidget(
        _app(query: 'madelief', text: 'Met MADELIEF naar de arts.'),
      );

      expect(_metAchtergrond(_spans(tester)).first, 'MADELIEF');
    });

    testWidgets('markeert elke treffer, niet alleen de eerste', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(query: 'ja', text: 'Ja vertelde je, ja, en dat was ja.'),
      );

      // In "Ja vertelde je, ja, en dat was ja." staat "ja" drie keer.
      expect(_metAchtergrond(_spans(tester)).length, 3);
      expect(
        _metAchtergrond(_spans(tester)).map((v) => v.toLowerCase()).toList(),
        ['ja', 'ja', 'ja'],
      );
    });

    testWidgets('de tekst blijft verder ongemoeid', (tester) async {
      await tester.pumpWidget(
        _app(query: 'advocaat', text: 'Advocaat gebeld, daarna thee.'),
      );

      expect(_plat(_spans(tester)), 'Advocaat gebeld, daarna thee.');
    });

    testWidgets('een treffer aan het einde van de tekst', (tester) async {
      await tester.pumpWidget(_app(query: 'thee', text: 'koffie en thee'));

      expect(_metAchtergrond(_spans(tester)), ['thee']);
    });
  });

  group('links blijven leesbaar en aanklikbaar', () {
    testWidgets('houdt URLs onderstreept naast de markering', (tester) async {
      await tester.pumpWidget(
        _app(
          query: 'advocaat',
          text: 'Advocaat: https://example.org/plan.pdf komt later',
        ),
      );

      expect(_onderstreept(_spans(tester)), ['https://example.org/plan.pdf']);
      expect(_metAchtergrond(_spans(tester)), ['Advocaat']);
    });

    testWidgets('de URL is tikbaar', (tester) async {
      await tester.pumpWidget(
        _app(query: 'x', text: 'Zie https://example.org/x'),
      );

      final tikbaar = <String>[];
      void walk(InlineSpan span) {
        if (span is TextSpan) {
          if (span.recognizer is TapGestureRecognizer) {
            tikbaar.add(span.toPlainText());
          }
          span.children?.forEach(walk);
        }
      }

      walk(_spans(tester));
      expect(tikbaar, ['https://example.org/x']);
    });

    testWidgets('zonder zoekterm verdwijnt alleen de markering', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(query: '   ', text: 'Zie https://example.org/x voor meer.'),
      );

      expect(_metAchtergrond(_spans(tester)), isEmpty);
      expect(_onderstreept(_spans(tester)), ['https://example.org/x']);
      expect(_plat(_spans(tester)), 'Zie https://example.org/x voor meer.');
    });
  });

  group('broncode', () {
    test('een tik op het resultaat gaat naar dat bericht', () {
      final inhoud = File(
        'lib/pages/chat_search/chat_search_message_tab.dart',
      ).readAsStringSync();
      expect(
        inhoud.contains('onTap: () => context.go'),
        isTrue,
        reason: 'zonder onTap is alleen het pijltje rechtsop tikbaar',
      );
      expect(
        inhoud.contains('query: searchQuery'),
        isTrue,
        reason: 'de zoekterm moet bij het resultaat aankomen om te markeren',
      );
    });
  });
}
