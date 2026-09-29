// Copyright (C) 2025 Daan – Samenvattingsmelding moet leesbaar zijn.
//
// ANDROID TOONT DE SAMENVATTING, NIET DE LOSSE MELDINGEN.
//
// Zodra twee of meer notificaties dezelfde groupKey delen en er een
// notificatie met setAsGroupSummary:true tussen zit, klapt Android de groep
// in en toont het de SAMENVATTING. Was die samenvatting leeg, dan verving
// Android leesbare meldingen door een onzichtbaar vak — de melding leek niet
// aangekomen terwijl getActiveNotifications() hem wel teruggaf.
//
// Deze test legt vast dat de samenvatting (a) een titel krijgt, (b) per
// actieve melding een regel met inhoud meestuurt, en (c) stil is, zodat hij
// de individuele meldingen niet opnieuw laat klinken.
//
// Daarnaast: de samenvatting mag zichzelf niet meetellen in de actieve lijst.
// Zonder die uitsluiting blijft de lengte >= 2 zolang de samenvatting bestaat,
// waardoor de opruimtak (length <= 1 → cancel) nooit meer draait.

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  String code(String pad) {
    final c = File(pad).readAsStringSync();
    final zonderBlok = c.replaceAll(RegExp(r'/\*[\s\S]*?\*/'), '');
    return zonderBlok
        .split('\n')
        .map((r) {
          final idx = r.indexOf('//');
          return idx == -1 ? r : r.substring(0, idx);
        })
        .join('\n');
  }

  /// De body van `updateSummaryNotification`.
  ///
  /// De signatuur eindigt op `}) async {`; het eerste `\n}` daarna is dus nog
  /// de parameterlijst. We zoeken daarom eerst het EINDE van de signatuur en
  /// pas daarna de afsluitende accolade van de functie op kolom 0.
  String samenvattingBody() {
    final bron = code('lib/utils/push_helper.dart');
    final start = bron.indexOf('updateSummaryNotification({');
    expect(start, isNonNegative,
        reason: 'updateSummaryNotification moet bestaan');
    final naSignatuur = bron.indexOf('}) async {', start);
    expect(naSignatuur, isNonNegative,
        reason: 'de functie moet een async-signatuur hebben');
    final einde = bron.indexOf('\n}', naSignatuur);
    expect(einde, isNonNegative,
        reason: 'de functie moet een afsluitende accolade hebben');
    return bron.substring(naSignatuur, einde);
  }

  group('samenvattingsmelding is leesbaar (23460)', () {
    test('de samenvatting krijgt een titel mee', () {
      final body = samenvattingBody();
      // De show()-aanroep van de samenvatting moet een titel-argument hebben.
      final showIdx = body.lastIndexOf('flutterLocalNotificationsPlugin.show(');
      expect(showIdx, isNonNegative, reason: 'de summary-show moet bestaan');
      final aanroep = body.substring(showIdx);
      expect(
        aanroep.contains('title:'),
        isTrue,
        reason:
            '23460: zonder titel toont Android een lege samenvatting zodra '
            'de groep inklapt — dat is precies het gemelde "opeens geen '
            'notificatie meer"',
      );
    });

    test('de samenvatting vult de regels uit de actieve meldingen', () {
      final body = samenvattingBody();
      expect(
        body.contains('InboxStyleInformation'),
        isTrue,
        reason: 'de samenvatting hoort de losse meldingen als regels te tonen',
      );
      // De regelinhoud moet uit de actieve meldingen komen, niet een lege
      // lijst of een constante string.
      expect(
        body.contains('activeNotifications.map'),
        isTrue,
        reason:
            'de regels moeten per actieve melding gevuld worden, anders is '
            'de samenvatting inhoudelijk leeg',
      );
      // En niet uitsluitend op `body` leunen: op Android is body null.
      expect(
        body.contains('n.title'),
        isTrue,
        reason:
            'op Android is `body` bewust null (MessagingStyle draagt de '
            'inhoud); de samenvatting moet dus `title` als bron nemen',
      );
    });

    test('de samenvatting is stil', () {
      final body = samenvattingBody();
      expect(
        body.contains('silent: true'),
        isTrue,
        reason:
            'de samenvatting is een ordeningslaag; hij hoort niet nog eens '
            'geluid of trilling te geven bovenop de individuele melding',
      );
    });

    test('de samenvatting telt zichzelf niet mee', () {
      final body = samenvattingBody();
      expect(
        body.contains('n.id != clientName.hashCode'),
        isTrue,
        reason:
            'zonder deze uitsluiting blijft de actieve lijst >= 2 zolang de '
            'samenvatting bestaat, en draait de opruimtak (length <= 1) nooit',
      );
    });
  });
}
