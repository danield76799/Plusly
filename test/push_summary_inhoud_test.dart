// Copyright (C) 2025 Daan – Samenvattingsmelding: pariteit met FluffyChat.
//
// WAAROM PARITEIT EN NIET EEN EIGEN IDEE.
//
// Bij het zoeken naar "melding komt aan maar is niet zichtbaar" is de
// samenvatting een verdachte: Android klapt een groep in zodra er een
// notificatie met setAsGroupSummary:true in zit, en toont dan de SAMENVATTING.
// Wie daar een eigen titel/tekst aan toevoegt, wijkt af van upstream zonder
// dat bewezen is dat die afwijking het probleem oplost — en verliest het
// ijkpunt: zolang Plusly identiek is aan FluffyChat kan een waargenomen
// gedragsverschil niet aan onze code liggen.
//
// Deze test legt daarom de pariteit vast, niet een theorie. Vier ankerpunten:
//   * geen title/body meegegeven aan show() — upstream doet dat ook niet;
//   * InboxStyleInformation gevuld uit `n.body`, dezelfde bron als upstream;
//   * de samenvatting sluit zichzelf uit van de actieve lijst, anders blijft
//     length >= 2 en draait de opruimtak (length <= 1 -> cancel) nooit meer;
//   * `silent: true`, zoals upstream: de samenvatting is ordening, niet een
//     tweede geluidssignaal bovenop de losse melding.

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

  group('samenvatting: pariteit met FluffyChat', () {
    test('de samenvatting geeft geen eigen titel of tekst mee', () {
      final body = samenvattingBody();
      final showIdx = body.lastIndexOf('flutterLocalNotificationsPlugin.show(');
      expect(showIdx, isNonNegative, reason: 'de summary-show moet bestaan');
      final aanroep = body.substring(showIdx);
      // Alleen `id:` en `notificationDetails:` — net als upstream. Een extra
      // title/body is een afwijking die bewezen moet worden, niet aangenomen.
      expect(
        aanroep.contains('title:'),
        isFalse,
        reason:
            'upstream geeft geen title mee aan de samenvatting; een eigen '
            'titel is een onbewezen afwijking van FluffyChat',
      );
      expect(
        aanroep.contains('body:'),
        isFalse,
        reason:
            'upstream geeft geen body mee aan de samenvatting; de inhoud '
            'komt uit de InboxStyle-regels',
      );
    });

    test('de InboxStyle-regels komen uit n.body, zoals upstream', () {
      final body = samenvattingBody();
      expect(
        body.contains('InboxStyleInformation'),
        isTrue,
        reason: 'de samenvatting hoort de losse meldingen als regels te tonen',
      );
      expect(
        body.contains('activeNotifications.map((n) => n.body ?? '),
        isTrue,
        reason:
            'upstream vult de regels uit n.body; een andere bron (n.title) '
            'is een afwijking zonder bewijs',
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

    test('de samenvatting is stil, zoals upstream', () {
      final body = samenvattingBody();
      expect(
        body.contains('silent: true'),
        isTrue,
        reason:
            'de samenvatting is een ordeningslaag; hij hoort niet nog eens '
            'geluid of trilling te geven bovenop de individuele melding',
      );
    });
  });
}
