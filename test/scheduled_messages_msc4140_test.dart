// Borgt de oorzaak van "geplande berichten gaan direct de deur uit".
//
// DE BUG: `send_later_dialog` probeerde MSC4140 ALTIJD. Een homeserver die
// MSC4140 niet kent negeert de onbekende `delay`-queryparameter en antwoordt
// met 200 OK op de gewone send — het bericht is dan al verzonden, terwijl de
// app het als "ingepland" opslaat. De oude code accepteerde die response ook
// (`?? txid`-fallback), dus er was niets dat het verkeerde gedrag opmerkte.
//
// Bewezen servercapaciteit (read-only, /_matrix/client/versions):
//   matrix.org -> org.matrix.msc4140: false  (bug treedt hier op)
//   mtux.nl    -> org.matrix.msc4140: true   (correcte route)
//
// Deze tests toetsen STRUCTUUR: het verzend-pad loopt via een netwerk-call en
// is niet in een widgettest te bereiken. Elke assertie is rood te krijgen op
// de oude code (zie de commit-message voor het bewijs).

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

int _codeLineIndex(String bron, String fragment) {
  final regels = bron.split('\n');
  for (var i = 0; i < regels.length; i++) {
    final t = regels[i].trim();
    if (t.isEmpty || t.startsWith('//')) continue;
    if (regels[i].contains(fragment)) return i;
  }
  return -1;
}

void main() {
  group('Geplande berichten (MSC4140-capaciteit)', () {
    test('de capaciteit wordt getoetst VÓÓR het verzenden', () {
      final dialoog = _code('lib/pages/chat/send_later_dialog.dart');
      final capIdx = _codeLineIndex(dialoog, 'supportsMsc4140()');
      final sendIdx = _codeLineIndex(dialoog, 'scheduleDelayedEvent(');

      expect(capIdx, greaterThan(-1),
          reason: 'zonder capaciteit-check gaat ?delay= naar elke server');
      expect(sendIdx, greaterThan(-1));
      expect(
        capIdx,
        lessThan(sendIdx),
        reason: 'de check moet VÓÓR de verzendpoging staan — anders is het '
            'bericht al weg voordat we weten dat de server het niet kan',
      );
    });

    test('bij ontbrekende capaciteit wordt lokaal ingepland', () {
      final dialoog = _code('lib/pages/chat/send_later_dialog.dart');
      expect(
        dialoog.contains('if (!supportsDelayedSend)'),
        isTrue,
        reason: 'de onderscheiden tak: geen MSC4140 -> lokaal, niet server-side',
      );
      expect(dialoog.contains('_scheduleLocally(txid, messageContent)'), isTrue);

      // De lokale tak moet vóór de server-poging afronden (return), niet
      // doorvallen naar de server-poging.
      final guardIdx = _codeLineIndex(dialoog, 'if (!supportsDelayedSend)');
      final sendIdx = _codeLineIndex(dialoog, 'scheduleDelayedEvent(');
      expect(guardIdx, lessThan(sendIdx));
    });

    test('de capaciteit komt uit /versions en faalt veilig', () {
      final ext = _code('lib/utils/matrix_sdk_extensions/msc4140_extension.dart');
      expect(
        ext.contains("unstableFeatures?['org.matrix.msc4140']"),
        isTrue,
        reason: 'de feature-vlag uit /versions is het enige betrouwbare '
            'signaal; de endpoint-statuscode is dat niet, want een server '
            'zonder MSC4140 antwoordt 200 OK op de gewone send',
      );
      expect(ext.contains('Future<bool> supportsMsc4140()'), isTrue);

      // Twee aparte caches: verzenden en annuleren zijn verschillende
      // capabilities. Delen laat de een het antwoord van de ander geven.
      expect(ext.contains('_delayedSendSupportCache'), isTrue);
      expect(ext.contains('_cancelSupportCache'), isTrue);
    });

    test('een 200 zonder delay_id geldt NIET als ingepland', () {
      final ext = _code('lib/utils/matrix_sdk_extensions/msc4140_extension.dart');
      expect(
        ext.contains('return (responseBody[\'delay_id\'] as String?) ?? txid'),
        isFalse,
        reason: 'die fallback verstopte de bug: een 200 met alleen een '
            'event_id is een AL VERZONDEN bericht, geen ingepland bericht',
      );
      expect(
        ext.contains("if (delayId == null || delayId.isEmpty)"),
        isTrue,
        reason: 'zonder delay_id een exception, zodat de aanroeper lokaal '
            'inplant in plaats van "ingepland" te tonen voor een verzonden '
            'bericht',
      );
    });

    test('de delay-parameter draagt de MSC4140-prefix', () {
      final ext = _code('lib/utils/matrix_sdk_extensions/msc4140_extension.dart');

      // Dit is DE bug die het symptoom "stuurt weer meteen" veroorzaakte:
      // Synapse leest letterlijk `parse_integer(request, "org.matrix.msc4140.delay")`.
      // Een kale `delay` bestaat daar niet, wordt genegeerd, en de PUT valt
      // door naar de gewone send. Bevestigd in element-hq/synapse
      // (synapse/rest/client/room.py r529) en in matrix-js-sdk's
      // getUnstableDelayQueryOpts().
      expect(
        ext.contains("'org.matrix.msc4140.delay': delay.toString()"),
        isTrue,
        reason: 'zonder de prefix negeert de server de parameter stil en '
            'verzendt het bericht direct',
      );
      expect(
        ext.contains("queryParameters: {'delay': delay.toString()}"),
        isFalse,
        reason: 'de kale variant is precies wat Synapse niet leest',
      );
    });

    test('elke httpClient-call krijgt een absolute Uri', () {
      final ext = _code('lib/utils/matrix_sdk_extensions/msc4140_extension.dart');

      // client.httpClient is een kale http.Client zonder baseUrl. De SDK geeft
      // hem overal een absolute Uri. Een relatieve Uri laat HttpClient.openUrl
      // gooien ("No host specified"), waarna de catch `false` teruggeeft — de
      // cancel-probe meldde daardoor op elke server "geen support", en dat is
      // waarom een eerdere versie besloot de guard te laten varen.
      final aantalCalls = RegExp(r'client\.httpClient\.(post|put|get)\(')
          .allMatches(ext)
          .length;
      final aantalResolved =
          RegExp(r'client\.baseUri!\.resolveUri\(').allMatches(ext).length;

      expect(aantalCalls, greaterThan(0));
      expect(
        aantalResolved,
        aantalCalls,
        reason: 'elke aanroep moet resolveUri gebruiken, anders faalt hij op '
            'een relatieve Uri',
      );
    });

    test('een 404 op de cancel-probe wordt op errcode beoordeeld', () {
      final ext = _code('lib/utils/matrix_sdk_extensions/msc4140_extension.dart');
      expect(
        ext.contains("errcode != 'M_UNRECOGNIZED'"),
        isTrue,
        reason: 'M_NOT_FOUND betekent "route bestaat, delay_id niet" en is dus '
            'wél support; M_UNRECOGNIZED betekent "route bestaat niet"',
      );
      expect(
        ext.contains('final supported = response.statusCode != 404;'),
        isFalse,
        reason: 'die toets zag beide 404-varianten als "geen support"',
      );
    });

    test('lokaal inplan-bericht liegt niet over annuleren', () {
      final dialoog = _code('lib/pages/chat/send_later_dialog.dart');
      expect(
        dialoog.contains('canCancel'),
        isTrue,
        reason: 'de cancel-capaciteit is een aparte vraag en hoort in de '
            'bevestiging aan de gebruiker',
      );
      expect(dialoog.contains("cancelling not supported by this server"), isTrue);
    });
  });
}
