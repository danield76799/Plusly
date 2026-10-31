// Regressietests voor blauwe vinkjes (WhatsApp-stijl leesbevestiging).
//
// De keten bestond al: chat_event_list berekent hasBeenRead (latestReadEvent),
// message.dart reikt hem aan alle 3 layouts aan, en die tonen done_all vs
// check. Wat ontbrak was alleen de blauwe kleur — het vinkje bleef grijs.
// Nu: gelezen = blauw (#53BDEB), de rest volgt de statuskleur.
//
// Contrast: een 13px icoon is non-tekst → WCAG ≥3.0 tegen de echte
// bubbelkleur (thema wordt in een Builder gebouwd, dus met echte
// ColorScheme-waardes, niet nagemaakt).

import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:Pulsly/config/themes.dart';

double _luminance(Color c) {
  double channel(double v) =>
      v <= 0.03928 ? v / 12.92 : math.pow((v + 0.055) / 1.055, 2.4).toDouble();
  return 0.2126 * channel(c.r) + 0.7152 * channel(c.g) + 0.0722 * channel(c.b);
}

double _contrast(Color a, Color b) {
  final la = _luminance(a), lb = _luminance(b);
  final hi = math.max(la, lb), lo = math.min(la, lb);
  return (hi + 0.05) / (lo + 0.05);
}

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
  group('Blauwe vinkjes', () {
    test('blauw is WhatsApp-blauw (dark) en de donkere tint daarvan (light)', () {
      final light = ThemeData.light().copyWith();
      final dark = ThemeData.dark().copyWith();
      expect(dark.readReceiptBlue, const Color(0xFF53BDEB));
      // Het lichte ijsblauw haalde 1.0:1 op de bleke lichte bubbel; nu is
      // het dezelfde blauw in de donkere tint.
      expect(light.readReceiptBlue, const Color(0xFF1F6FEB));
    });

    testWidgets('blauw haalt ≥3.0 op de echte bubbelkleur (light + dark)',
        (tester) async {
      late ThemeData lightTheme;
      late ThemeData darkTheme;
      await tester.pumpWidget(
        Builder(builder: (context) {
          lightTheme = FluffyThemes.buildTheme(
              context, Brightness.light, const Color(0x0049AFC2));
          darkTheme = FluffyThemes.buildTheme(
              context, Brightness.dark, const Color(0x0049AFC2));
          return const SizedBox.shrink();
        }),
      );
      final blauwLicht = lightTheme.readReceiptBlue;
      final blauwDonker = darkTheme.readReceiptBlue;
      expect(
        _contrast(blauwLicht, lightTheme.bubbleColor),
        greaterThanOrEqualTo(3.0),
        reason: 'blauw vinkje onleesbaar op lichte bubbel',
      );
      expect(
        _contrast(blauwDonker, darkTheme.bubbleColor),
        greaterThanOrEqualTo(3.0),
        reason: 'blauw vinkje onleesbaar op donkere bubbel',
      );
    });

    test('alle 3 layouts kleuren het vinkje blauw bij gelezen', () {
      for (final pad in [
        'lib/pages/chat/events/message_bubble.dart',
        'lib/pages/chat/events/message_modern.dart',
        'lib/pages/chat/events/message_bubble_legacy.dart',
      ]) {
        final code = _code(pad);
        expect(code.contains('hasBeenRead'), isTrue, reason: pad);
        // De Plusly-bubbel deelt zijn voettekst met MessageStatusRow; daar
        // staat de blauwe kleur.
        expect(
          code.contains('readReceiptBlue') || code.contains('MessageStatusRow'),
          isTrue,
          reason: pad,
        );
      }
      // Het gedeelde stuk haalt de blauwe kleur uit het thema.
      final gedeeld = _code('lib/pages/chat/events/message_status_row.dart');
      expect(gedeeld.contains('readReceiptBlue'), isTrue);
    });

    test('versturen en fout blijven hun eigen icoon houden', () {
      // Blauw mag nooit een klokje of fout-icoon overschilderen.
      for (final pad in [
        'lib/pages/chat/events/message_modern.dart',
        'lib/pages/chat/events/message_bubble_legacy.dart',
        'lib/pages/chat/events/message_status_row.dart',
      ]) {
        final code = _code(pad);
        expect(code.contains('EventStatus.sending'), isTrue, reason: pad);
        expect(code.contains('EventStatus.error'), isTrue, reason: pad);
      }
      // De Plusly-bubbel regelt dat via de gedeelde voettekst.
      final plusly = _code('lib/pages/chat/events/message_bubble.dart');
      expect(plusly.contains('MessageStatusRow'), isTrue);
      expect(plusly.contains('status: event.status'), isTrue);
    });
  });
}
