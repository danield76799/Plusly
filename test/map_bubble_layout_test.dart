// Regressietest: MapBubble moet een echte breedte krijgen binnen de
// IntrinsicWidth van de message bubble (MessageLayout.bubbles).
//
// Achtergrond: commit e57573841 verving BoxConstraints.loose door
// ConstrainedBox(maxWidth) + AspectRatio, in de veronderstelling dat dit
// "ImageBubble spiegelt". Dat klopt niet: ImageBubble's kind (MxcImage) heeft
// een intrinsieke breedte, FlutterMap niet. AspectRatio valt bij een kind
// zonder intrinsics terug op breedte 0, waardoor de kaart ineenklapt tot een
// smalle strook. Deze test legt dat vast: de kaart moet de volledige
// beschikbare bubbelbreedte vullen.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:Pulsly/pages/chat/events/map_bubble.dart';

/// Bootst de bubbles-layout na: een bubbel met maxWidth 0.75 * schermbreedte
/// die zijn inhoud via IntrinsicWidth meet (message_bubble.dart:583).
Widget bubbleHarness(Widget child, {double screenWidth = 411}) => MaterialApp(
  home: MediaQuery(
    data: MediaQueryData(size: Size(screenWidth, 800)),
    child: Scaffold(
      body: Align(
        alignment: Alignment.centerRight,
        child: Container(
          constraints: BoxConstraints(maxWidth: screenWidth * 0.75),
          decoration: BoxDecoration(
            color: const Color(0xFF0D4A52),
            borderRadius: BorderRadius.circular(12),
          ),
          child: IntrinsicWidth(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [child],
            ),
          ),
        ),
      ),
    ),
  ),
);

void main() {
  testWidgets('MapBubble vult de bubbelbreedte (niet ineenklappen)', (
    tester,
  ) async {
    await tester.pumpWidget(
      bubbleHarness(
        const MapBubble(latitude: 52.3712, longitude: 5.2145),
      ),
    );
    await tester.pump();

    final size = tester.getSize(find.byType(MapBubble));
    debugPrint('MapBubble size = $size');

    // Een kaartbubbel hoort breed te zijn (2:1), niet een smalle strook.
    expect(
      size.width,
      greaterThan(200),
      reason: 'Kaartbubbel klapt ineen: breedte $size.width is te klein',
    );
    expect(
      size.height,
      greaterThan(100),
      reason: 'Kaartbubbel klapt ineen: hoogte $size.height is te klein',
    );
    // 2:1 verhouding uit MapBubble(width: 400, height: 200).
    expect(size.width / size.height, closeTo(2.0, 0.05));
  });

  testWidgets('MapBubble krimpt op smalle schermen zonder te overlopen', (
    tester,
  ) async {
    await tester.pumpWidget(
      bubbleHarness(
        const MapBubble(latitude: 52.3712, longitude: 5.2145),
        screenWidth: 320,
      ),
    );
    await tester.pump();

    final size = tester.getSize(find.byType(MapBubble));
    debugPrint('MapBubble size op 320px scherm = $size');

    expect(size.width, lessThanOrEqualTo(240.0 + 0.5));
    expect(size.width / size.height, closeTo(2.0, 0.05));
  });
}
