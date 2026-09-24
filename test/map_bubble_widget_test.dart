// Gedragstest voor de kaartgeometrie van MapBubble.
//
// Aanleiding: "Locatie delen zorgt voor een kleine map ipv een normale map."
// d73690fcc zette height 400 -> 200 en haalde de AspectRatio-wrapper weg,
// waardoor de kaart een platte strook werd.
//
// WAAROM EEN OUDER MET ALLEEN EEN VASTE BREEDTE: in de praktijk krijgt de
// kaart een begrensde breedte (dialoogbreedte, chatbubble) en een vrije
// hoogte. Dat is precies de situatie waarin het misging: de breedte volgde de
// ouder, de hoogte bleef op de vaste default staan. Een SizedBox met BEIDE
// maten vast legt de widget op, en dan meet je de ouder in plaats van de
// widget zelf.
//
// Let ook op het testoppervlak: flutter_test is 800x600. Vraag nooit een maat
// boven die grens op, want dan klemt het framework de ouder en lijkt de widget
// fout terwijl de testopzet fout is.

import 'package:Pulsly/pages/chat/events/map_bubble.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Bouwt de kaart in een ouder met vaste BREEDTE en vrije hoogte.
Future<void> _pumpInWidth(WidgetTester tester, double width) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Align(
          alignment: Alignment.topLeft,
          child: SizedBox(
            width: width,
            child: const MapBubble(latitude: 52.0, longitude: 5.0),
          ),
        ),
      ),
    ),
  );
  await tester.pump();
}

void main() {
  testWidgets('de hoogte volgt de breedte, niet een vaste default', (
    tester,
  ) async {
    // Dit is het symptoom zelf. Oud: breedte = ouder, hoogte = 200 -> strook.
    // Nieuw (upstream): AspectRatio maakt de hoogte gelijk aan de breedte.
    // Boven de 400 kapt BoxConstraints.loose de hoogte af (zie de laatste
    // test), dus hier blijven we binnen de normale dialoogbreedtes.
    for (final width in <double>[280, 340, 400]) {
      await _pumpInWidth(tester, width);
      final size = tester.getSize(find.byType(MapBubble));
      expect(
        size.width,
        size.height,
        reason:
            'bij breedte $width moet de kaart vierkant zijn; een hoogte die '
            'daarvan afwijkt is de platte strook',
      );
    }
  });

  testWidgets('boven 400 kapt de hoogte af op de eigen maximummaat', (
    tester,
  ) async {
    // Bestaand upstream-gedrag (FC identiek): BoxConstraints.loose(400, 400)
    // begrenst de hoogte, terwijl een bredere ouder de breedte opdringt. Dit
    // vastleggen voorkomt dat iemand het later als bug "fixt" en de
    // bovengrens sloopt.
    await _pumpInWidth(tester, 480);
    final size = tester.getSize(find.byType(MapBubble));
    expect(size.height, 400.0, reason: 'de hoogte is afgekapt op het maximum');
    expect(size.width, 480.0, reason: 'de breedte volgt de ouder');
  });

  testWidgets('de kaart negeert de oude vaste hoogte van 200', (tester) async {
    await _pumpInWidth(tester, 340);
    final size = tester.getSize(find.byType(MapBubble));
    expect(
      size.height,
      isNot(200.0),
      reason: '200 was de "compact"-waarde die het symptoom veroorzaakte',
    );
    expect(
      size.height,
      greaterThan(250.0),
      reason: 'de kaart moet echt kaartoppervlak krijgen, niet een strook',
    );
  });

  testWidgets('een krappe ouder geeft een krappe maar vierkante kaart', (
    tester,
  ) async {
    await _pumpInWidth(tester, 200);
    final size = tester.getSize(find.byType(MapBubble));
    expect(size.width, size.height);
    expect(size.width, 200.0);
  });
}
