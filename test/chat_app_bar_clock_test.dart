// Borgt de klok in de kop van een gesprek vast.
//
// HET GAT. De tweede regel onder de contactnaam toonde de presencedata
// ("Laatst gezien om 20:01"), en alleen terwijl er gesynchroniseerd werd.
// In een brugkamer is er meestal geen presencedata, dus die regel was daar
// vrijwel altijd leeg — de gebruiker meldde "tijdstip in de chat is
// verdwenen" en wilde daar een klok met de huidige tijd, net als op de
// home (chatlijst).

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

String _code(String pad) {
  final c = File(pad).readAsStringSync();
  final zonderBlok = c.replaceAll(RegExp(r'/\*[\s\S]*?\*/'), '');
  return zonderBlok
      .split('\n')
      .map((r) => r.replaceAll(RegExp(r'//.*$', multiLine: true), ''))
      .join('\n');
}

void main() {
  group('klok in de kop van een gesprek', () {
    final code = _code('lib/pages/chat/chat_app_bar_title.dart');

    test('de kop toont een klok met de huidige tijd', () {
      expect(
        code.contains('ClockText('),
        isTrue,
        reason: 'de kop van een gesprek toont een klok, net als de home',
      );
    });

    test('beide titeltakken gebruiken dezelfde regel', () {
      // De gecentreerde en de niet-gecentreerde titel moeten hetzelfde
      // gedrag hebben; anders hangt het af van de instelling.
      expect(
        code.contains('_buildStatusLine(context, compact: true)'),
        isTrue,
        reason: 'de gecentreerde titel gebruikt de gedeelde statusregel',
      );
      expect(
        code.contains('_buildStatusLine(context, compact: false)'),
        isTrue,
        reason: 'de linker uitgelichte titel gebruikt dezelfde statusregel',
      );
    });

    test('de presencedata is weg, de klok staat er', () {
      expect(
        code.contains('PresenceBuilder'),
        isFalse,
        reason: 'de presencedata verscheen alleen tijdens het synchroniseren '
            'en stond daarom zelden te zien; de klok staat nu altijd',
      );
    });

    test('een syncfout blijft zichtbaar', () {
      // De klok vervangt de syncstatus, maar een echte fout mag niet
      // stilletjes verdwijnen.
      expect(
        code.contains('status.status == SyncStatus.error'),
        isTrue,
        reason: 'bij een syncfout moet de fout in de kop blijven staan',
      );
      expect(
        code.contains('status.calcLocalizedString(context)'),
        isTrue,
        reason: 'de fouttekst blijft zichtbaar',
      );
    });

    test('de home gebruikt dezelfde klokwidget', () {
      final header = _code('lib/pages/chat_list/chat_list_header.dart');
      expect(
        header.contains('ClockText('),
        isTrue,
        reason: 'de home gebruikt dezelfde widget, zodat de klok er overal '
            'hetzelfde uitziet',
      );
      expect(
        header.contains('class _ClockText'),
        isFalse,
        reason: 'de privaten kopie is vervangen door de gedeelde widget',
      );
    });
  });
}
