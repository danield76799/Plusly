// Copyright (C) 2025 Daan – Share-intent opnieuw lezen bij resume.
//
// HET GEMETEN GEVAL.
//
// Een share vanuit Google Foto's leverde in de diagnoselog:
//   share_initialmedia aantal=0
//   share_ontvangen    aantal=0 paden= types=
//   share_afgebroken   reden=geen-bestanden
// en de media-stream zweeg volledig. De app wérd op dat moment gestart, dus
// het intent had de activity bereikt; de eenmalige uitlezing bij het opzetten
// leverde alleen niets op.
//
// De plugin biedt twee routes (getInitialMedia eenmalig, getMediaStream
// doorlopend) en er is geen reset die het intent opnieuw aanbiedt. Wat wel
// werkt is opnieuw vragen zodra de app naar de voorgrond komt: op dat moment
// staat het intent alsnog op de activity.
//
// Deze test legt die route vast, plus de voorwaarde die hem veilig maakt:
// de dedupe op genormaliseerd pad, zodat een bestand dat via beide routes
// binnenkomt niet twee keer verstuurd wordt.

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

  group('share-intent herlezen bij resume', () {
    test('de resume-tak vraagt het intent opnieuw op', () {
      final bron = code('lib/pages/chat_list/chat_list.dart');
      final resume = bron.indexOf('void didChangeAppLifecycleState');
      expect(resume, isNonNegative,
          reason: 'de lifecycle-hook moet bestaan');
      final body = bron.substring(resume);
      final eind = body.indexOf('\n  }');
      final blok = body.substring(0, eind);

      expect(
        blok.contains('getInitialMedia'),
        isTrue,
        reason:
            'de resume-tak moet het share-intent opnieuw ophalen; zonder dat '
            'blijft een share die bij het opzetten niets opleverde voorgoed '
            'liggen (gemeten: aantal=0 → share_afgebroken)',
      );
    });

    test('herlezen wordt gelogd zodat het meetbaar is', () {
      final bron = code('lib/pages/chat_list/chat_list.dart');
      expect(
        bron.contains('share_herlezen'),
        isTrue,
        reason:
            'zonder logregel is niet te zien of de herlezing iets oplevert '
            'of opnieuw leeg terugkomt; dan is de volgende dump niet te lezen',
      );
      expect(
        bron.contains('share_herlezen-fout'),
        isTrue,
        reason:
            'een fout in de plugin moet ook zichtbaar zijn, anders verdwijnt '
            'hij stil — precies het patroon dat dit onderzoek al weken kost',
      );
    });

    test('een lege herlezing doet niets', () {
      final bron = code('lib/pages/chat_list/chat_list.dart');
      final idx = bron.indexOf('share_herlezen');
      expect(idx, isNonNegative);
      // Vóór de logregel moet een leeg-resultaat-guard staan, anders
      // schrijft elke resume een nutteloze regel en loopt de log vol.
      final venster = bron.substring(idx > 400 ? idx - 400 : 0, idx);
      expect(
        venster.contains('files.isEmpty'),
        isTrue,
        reason:
            'getInitialMedia wordt bij ELKE resume aangeroepen; zonder guard '
            'schrijft dat een regel per voorgrondwissel en verdringt het de '
            'echte metingen uit de ring',
      );
    });

    test('de dedupe is een TIJDVENSTER, niet sessielang', () {
      final bron = code('lib/pages/chat_list/chat_list.dart');
      expect(
        bron.contains('_processedSharedPathsTijd'),
        isTrue,
        reason:
            'de herlezing kan hetzelfde bestand leveren als de stream; zonder '
            'dedupe zou dat bestand twee keer verstuurd worden',
      );
      // GEMETEN GEVAL 2026-10-01: vijf keer `share_afgebroken
      // reden=alles-al-gezien` achtereen. Het oude intent bleef op de
      // activity staan; de sessie-dedupe blokkeerde dezelfde foto bij elke
      // heropening — delen deed minutenlang NIETS meer.
      expect(
        bron.contains('shareDedupeVenster'),
        isTrue,
        reason:
            'de dedupe moet een tijdsvenster hebben. Een sessielange set '
            'blokkeert hetzelfde bestand bij latere shares: het oude intent '
            'blijft op de activity staan en elke heropening leverde '
            'alles-al-gezien (gemeten 5x achtereen)',
      );
      // Het venster moet expliciet een Duration zijn — geen magisch getal.
      expect(
        bron.contains('Duration(seconds:'),
        isTrue,
        reason: 'het venster moet leesbaar en aanpasbaar zijn als constante',
      );
      // De verloog-logica moet de set écht afsnijden: removeWhere op de
      // tijd-map, met het venster als drempel. Alleen een constante
      // declareren is niet genoeg.
      expect(
        bron.contains('removeWhere') &&
            bron.contains('nu.difference(gezien) > shareDedupeVenster'),
        isTrue,
        reason:
            'de verlooplogica moet aanwezig zijn; zonder removeWhere blijft '
            'de set sessielang en keert de blokkade terug',
      );
      // De oude, sessielange set mag niet meer bestaan.
      expect(
        bron.contains('_processedSharedPaths ='),
        isFalse,
        reason:
            'oude sessielange set moet weg zijn; anders blijft de blokkade '
            'bestaan naast het nieuwe venster',
      );
    });
  });
}
