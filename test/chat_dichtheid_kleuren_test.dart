// Regressietests voor dichtheid, leesbaarheid en kleuren in de chat.
//
// Drie dingen die vastliggen:
//
// 1. Dichtheid: de berichttekst had 16dp marge BINNEN de bubbel, terwijl de
//    bubbel er zelf al 10dp bij deed: 26dp per kant. Korte berichten zaten
//    er "lost" in. Zonder extra marge (10dp totaal) stond de tekst
//    echter te krap tegen de rand. De marge is nu per bubbelvariant:
//    overal 16dp tussen tekst en rand.
//
// 2. Leesbaarheid: een bericht MET opmaak (HTML) erfde de thema-
//    regelafstand (1.5), terwijl een plat bericht expliciet 1.2 had.
//    Hetzelfde bericht oogde dus luchtiger met dan zonder opmaak. Nu
//    hebben beide 1.2 (WhatsApp-stijl).
//
// 3. Kleuren: de donkere uitgaande bubbel was een hardcoded teal
//    (#005C53). Bij een andere seed-kleur (bijvoorbeeld paars) bleef de
//    bubbel dan teal, terwijl de rest van de app meebeweegt. Nu volgt de
//    bubbel de seed. De tekst erop moet leesbaar blijven (WCAG AA).
import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:Pulsly/config/themes.dart';

/// Relatieve luminantie volgens WCAG 2.1.
double _kanaal(int v) {
  final s = v / 255.0;
  return s <= 0.03928 ? s / 12.92 : math.pow((s + 0.055) / 1.055, 2.4).toDouble();
}

double _luminantie(Color c) {
  final argb = c.toARGB32();
  return 0.2126 * _kanaal((argb >> 16) & 0xff) +
      0.7152 * _kanaal((argb >> 8) & 0xff) +
      0.0722 * _kanaal(argb & 0xff);
}

double contrast(Color a, Color b) {
  final l1 = _luminantie(a);
  final l2 = _luminantie(b);
  final hi = l1 > l2 ? l1 : l2;
  final lo = l1 > l2 ? l2 : l1;
  return (hi + 0.05) / (lo + 0.05);
}

/// Kleur met een alpha over een achtergrond, zoals Flutter dat doet.
Color _metAlpha(Color voorgrond, double alpha, Color achtergrond) =>
    Color.alphaBlend(voorgrond.withValues(alpha: alpha), achtergrond);

/// De bron van een bestand, zonder commentaarregels.
String _bronZonderCommentaar(String pad) {
  return File(pad)
      .readAsStringSync()
      .split('\n')
      .where((l) => !l.trimLeft().startsWith('//'))
      .join('\n');
}

void main() {
  group('dichtheid', () {
    test('de berichttekst heeft geen eigen horizontale marge meer', () {
      final code = _bronZonderCommentaar(
        'lib/pages/chat/events/message_content.dart',
      );
      // De marge is nu per bubbelvariant: de standaardvariant heeft zelf
      // 10dp en vraagt 6dp extra (16 totaal); de legacy- en moderne
      // variant hebben geen eigen marge en houden 16dp.
      expect(
        code.contains('final double textPadding;'),
        isTrue,
        reason: 'de marge moet per bubbelvariant kunnen verschillen',
      );
      expect(
        code.contains('this.textPadding = 16'),
        isTrue,
        reason: 'de legacy- en moderne variant houden 16dp',
      );
      expect(
        code.contains('padding: const .symmetric(horizontal: 16'),
        isFalse,
        reason: 'de bubbel geeft al 10dp; 16dp erbij was 26dp per kant',
      );

      // De som: bubbelmarge + tekstmarge = 16dp. Bij 26dp voelde een kort
      // bericht "lost"; bij 10dp stond de tekst te krap tegen de rand.
      final bubbel = _bronZonderCommentaar(
        'lib/pages/chat/events/message_bubble.dart',
      );
      expect(
        bubbel.contains('vertical: 6.0,'),
        isTrue,
        reason: 'de standaardbubbel houdt 10dp marge',
      );
      expect(
        bubbel.contains('horizontal: 10.0,'),
        isTrue,
        reason: 'de standaardbubbel houdt 10dp marge',
      );
      expect(
        bubbel.contains('textPadding: 6'),
        isTrue,
        reason: '10dp van de bubbel plus 6dp van de tekst is 16dp',
      );
    });
  });

  group('leesbaarheid', () {
    test('HTML-berichten hebben dezelfde regelafstand als platte', () {
      final html = _bronZonderCommentaar(
        'lib/pages/chat/events/html_message.dart',
      );
      expect(
        html.contains('height: 1.2'),
        isTrue,
        reason: 'zonder dit oogt een bericht met opmaak luchtiger dan '
            'hetzelfde bericht zonder opmaak',
      );
    });

    test('de platte tak houdt 1.2', () {
      final code = _bronZonderCommentaar(
        'lib/pages/chat/events/message_content.dart',
      );
      expect(code.contains('height: 1.2'), isTrue);
    });
  });

  group('kleuren', () {
    /// Bouwt een thema met de gegeven seed en leest de bubbelkleuren uit.
    Future<({Color bubble, Color incoming, Color onBubble})> kleurenMetSeed(
      WidgetTester tester,
      Color seed,
    ) async {
      late ThemeData theme;
      await tester.pumpWidget(
        Builder(
          builder: (context) {
            theme = FluffyThemes.buildTheme(context, Brightness.dark, seed);
            return const SizedBox.shrink();
          },
        ),
      );
      late Color bubble;
      late Color incoming;
      late Color onBubble;
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Builder(
            builder: (context) {
              bubble = Theme.of(context).bubbleColor;
              incoming = Theme.of(context).incomingBubbleColor;
              onBubble = Theme.of(context).onBubbleColor;
              return const SizedBox.shrink();
            },
          ),
        ),
      );
      return (bubble: bubble, incoming: incoming, onBubble: onBubble);
    }

    testWidgets('de donkere eigen bubbel volgt de seed-kleur', (tester) async {
      final thee = await kleurenMetSeed(tester, const Color(0xFF49AFC2));
      final paars = await kleurenMetSeed(tester, const Color(0xFF9B7BD4));

      expect(
        thee.bubble != paars.bubble,
        isTrue,
        reason: 'de bubbel volgt de seed niet meer',
      );
      // De paarse bubbel moet paarsTint hebben, niet teal.
      expect(
        paars.bubble.b - paars.bubble.r,
        greaterThan(0),
        reason: 'de bubbel moet de tint van de seed dragen',
      );
    });

    testWidgets('witte tekst op de donkere bubbel blijft leesbaar',
        (tester) async {
      final thee = await kleurenMetSeed(tester, const Color(0xFF49AFC2));
      expect(
        contrast(Colors.white, thee.bubble),
        greaterThanOrEqualTo(4.5),
        reason: 'de tekst op de eigen bubbel moet leesbaar blijven',
      );
    });

    testWidgets('de voettekst (tijd) op de bubbel blijft leesbaar',
        (tester) async {
      // De voettekst is 12px, dus kleine tekst: AA vraagt 4.5:1.
      final licht = await kleurenMetSeed(tester, const Color(0xFF49AFC2));
      expect(
        contrast(
          _metAlpha(licht.onBubble, 0.85, licht.bubble),
          licht.bubble,
        ),
        greaterThanOrEqualTo(4.5),
        reason: 'de tijd op de eigen bubbel moet leesbaar zijn',
      );
    });

    test('de voettekst gebruikt geen hardcoded wit meer', () {
      final code = _bronZonderCommentaar(
        'lib/pages/chat/events/message_bubble.dart',
      );
      expect(
        code.contains('Colors.white.withValues(alpha: 0.75)'),
        isFalse,
        reason: 'wit is onzichtbaar op de bleke lichte bubbel',
      );
      expect(
        code.contains('theme.onBubbleColor.withValues(alpha: 0.85)'),
        isTrue,
      );
    });

    testWidgets('de inkomende bubbel blijft neutraal', (tester) async {
      final thee = await kleurenMetSeed(tester, const Color(0xFF49AFC2));
      // Neutraal: grijs, niet sterk getint.
      final spreiding =
          (thee.incoming.r - thee.incoming.g).abs() +
          (thee.incoming.g - thee.incoming.b).abs();
      expect(
        spreiding,
        lessThan(40),
        reason: 'de inkomende bubbel moet neutraal blijven, zodat de eigen '
            'bubbel de kleur draagt',
      );
    });
  });
}
