// Regressietest: de invoerbalk moet genoeg ruimte overlaten voor de
// tekst.
//
// De hinttekst ("Schrijf een bericht...") werd afgeknipt: de invoerbalk
// bevatte drie vaste knoppen (paperclip 44dp, geplande berichten 56dp en
// emoji 56dp) plus de verzendknop. De klokknop voor geplande berichten
// is verplaatst naar het bijlage-menu en de overige knoppen zijn kleiner
// geworden.

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('invoerbalk', () {
    final code = File('lib/pages/chat/chat_input_row.dart').readAsStringSync();

    test('de knop "Geplande berichten" staat niet meer in de balk', () {
      expect(
        code.contains("tooltip: 'Geplande berichten'"),
        isFalse,
        reason: 'die knop kostte 56dp en kapte de hinttekst af; hij staat nu '
            'in het bijlage-menu',
      );
      expect(
        code.contains("value: 'scheduled'"),
        isTrue,
        reason: 'de lijst met geplande berichten moet via het menu '
            'bereikbaar blijven',
      );
    });

    test('de emoji-knop is kleiner dan de vorige 56dp', () {
      expect(
        code.contains('height: 44,'),
        isTrue,
        reason: 'de emoji-knop was 56dp breed',
      );
    });

    test('de marges rond de balk zijn smaller', () {
      expect(
        code.contains('horizontal: 6.0,'),
        isTrue,
        reason: 'de marge was 10dp per kant',
      );
      expect(
        code.contains('minWidth: 38,'),
        isTrue,
        reason: 'de paperclip nam 44dp',
      );
    });
  });

  test('de menu-keuze "scheduled" is afgehandeld', () {
    final chat = File('lib/pages/chat/chat.dart').readAsStringSync();
    expect(
      chat.contains("if (choice == 'scheduled') {"),
      isTrue,
      reason: 'anders doet de knop niets',
    );
    expect(
      chat.contains('await openScheduledMessages();'),
      isTrue,
    );
  });
}
