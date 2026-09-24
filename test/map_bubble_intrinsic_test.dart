// Borgt dat de locatie-kaart niet degenereert naar 1x1 in de chatbubble.
//
// SYMPTOOM (gemeld): "Map is nu enorm klein. 1x1 pixel."
//
// OORZAAK, uit de Flutter-bron geverifieerd: FlutterMap gebruikt intern een
// LayoutBuilder, en die kan geen intrinsieke dimensies berekenen. Flutter gooit
// dan letterlijk:
//     LayoutBuilder does not support returning intrinsic dimensions.
// Plusly's chatbubble wikkelt de berichtinhoud in een IntrinsicWidth
// (message_bubble.dart r583). Die vraag bereikt dus de kaart, de layout breekt
// af, en de kaart wordt 0x0 — wat op het scherm als één pixel verschijnt.
//
// WAAROM DIT NIET AAN DE ASPECTRATIO LAG: gemeten met drie varianten in
// dezelfde keten — de oude compact-versie (height 200, geen AspectRatio), de
// nieuwe versie (height 400 + AspectRatio) en FluffyChat's eigen structuur —
// alle drie faalden identiek. De kaart in de chatbubble was dus altijd al
// stuk; de eerdere "compact"-commit maakte het alleen zichtbaar.
//
// FluffyChat ontloopt dit doordat het daar geen IntrinsicWidth heeft: grep op
// `IntrinsicWidth` in FC's pages/chat geeft nul treffers. De fix is daarom
// Plusly-specifiek en staat in map_bubble.dart.

import 'package:Pulsly/pages/chat/events/map_bubble.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Zet het testoppervlak op een doorsnee Android-toestel (360x800 logical).
/// Nodig omdat de dialoogbreedte — en dus de kaartmaat — daarvan afhangt.
void _phone(WidgetTester t) {
  t.view.physicalSize = const Size(1080, 2400);
  t.view.devicePixelRatio = 3.0;
  addTearDown(t.view.reset);
}

Widget _chatbubble(Widget kind, {double maxWidth = 270}) => Container(
  constraints: BoxConstraints(maxWidth: maxWidth),
  child: IntrinsicWidth(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [kind],
    ),
  ),
);

void main() {
  const bubble = MapBubble(latitude: 52.0, longitude: 5.0);

  testWidgets('kaart overleeft de IntrinsicWidth van de chatbubble', (
    tester,
  ) async {
    _phone(tester);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Align(
            alignment: Alignment.topLeft,
            child: _chatbubble(bubble),
          ),
        ),
      ),
    );
    await tester.pump();

    // 1. De keten mag geen intrinsieke-dimensies-assert meer gooien.
    expect(
      tester.takeException(),
      isNull,
      reason: 'FlutterMap kan geen intrinsieke maten geven; zonder de '
          '_MapIntrinsicBox-wrapper breekt de layout hier af',
    );

    // 2. En de kaart moet een echte maat hebben, geen 1x1.
    final size = tester.getSize(find.byType(MapBubble));
    expect(size.width, greaterThan(50.0), reason: 'dit was de 1x1-pixel');
    expect(size.height, greaterThan(50.0), reason: 'dit was de 1x1-pixel');
    expect(
      size.width,
      size.height,
      reason: 'de kaart hoort vierkant te zijn',
    );
  });

  testWidgets('kaart blijft vierkant met tekst onder zich in de bubble', (
    tester,
  ) async {
    _phone(tester);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Align(
            alignment: Alignment.topLeft,
            child: _chatbubble(
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [bubble, const Text('ok')],
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    expect(tester.takeException(), isNull);
    final size = tester.getSize(find.byType(MapBubble));
    expect(size.width, size.height);
    expect(size.width, greaterThan(50.0));
  });

  testWidgets('het deel-dialoog toont een echte kaart', (tester) async {
    _phone(tester);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AlertDialog.adaptive(
            title: const Text('Locatie delen'),
            content: bubble,
            actions: [
              TextButton(onPressed: () {}, child: const Text('Send')),
            ],
          ),
        ),
      ),
    );
    await tester.pump();
    expect(tester.takeException(), isNull);
    final size = tester.getSize(find.byType(MapBubble));
    expect(size.width, greaterThan(100.0));
    expect(size.width, size.height);
  });

  testWidgets('de intrinsieke maat wordt zelf beantwoord, niet doorgegeven', (
    tester,
  ) async {
    // Dit is de kern van de fix. Als de wrapper de vraag doorgeeft aan de
    // kaart eronder, komt de assert terug.
    _phone(tester);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(child: IntrinsicWidth(child: bubble)),
        ),
      ),
    );
    await tester.pump();
    expect(tester.takeException(), isNull);
    final size = tester.getSize(find.byType(MapBubble));
    expect(size.width, greaterThan(50.0));
    expect(size.width, size.height);
  });
}
