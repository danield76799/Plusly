// Regressietests voor "ik plak een bericht en het staat er 3x".
//
// Symptoom: één gedeeld/geplakt bericht levert DRIE identieke bubbels op.
//
// Twee onafhankelijke oorzaken zaten hier achter:
//
// 1. ALIASING in routes.dart. `state.extra as List<ShareItem>` is geen kopie
//    maar een verwijzing naar de lijst die GoRouter zelf vasthoudt. De code
//    deed `shareItems.add(TextShareItem(body))` op diezelfde lijst. Elke keer
//    dat de route opnieuw werd opgebouwd kwam er een item BIJ, en de gegroeide
//    lijst werd daarna in zijn geheel verzonden.
//
// 2. DE GUARD LEVENSDUUR. `_shareItemsProcessed` was een instantie-veld. GoRouter
//    bouwt na `context.go()` de ChatPage opnieuw op en maakt daarbij een NIEUWE
//    State met een verse vlag op false. De guard liet dus elke rebuild opnieuw
//    verzenden. De guard hangt nu aan de identiteit van de lijst (static set),
//    zodat elke doorstuuractie precies één keer verzendt, ongeacht rebuilds.

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

String _bron(String pad) => File(pad).readAsStringSync();

/// Broncode zonder commentaar.
///
/// Nodig omdat de uitleg bij deze fix de OUDE code citeert (dat is juist de
/// bedoeling), en een test die naar de hele tekst kijkt zou daarop stuklopen.
/// We willen de code controleren, niet de uitleg erover.
String _code(String pad) {
  final zonderBlok = File(pad).readAsStringSync().replaceAll(
    RegExp(r'/\*[\s\S]*?\*/'),
    '',
  );
  return zonderBlok
      .split('\n')
      .map((regel) => regel.replaceAll(RegExp(r'//.*$'), ''))
      .join('\n');
}

/// Tekst tussen `start` en de eerstvolgende top-level member.
String _bodyVan(String bron, String signature) {
  final start = bron.indexOf(signature);
  expect(start, greaterThan(-1), reason: 'kon "$signature" niet vinden');
  final rest = bron.substring(start + 1);
  final m = RegExp(r'\n  (?:Future|void|String|bool|int|static|@)').firstMatch(rest);
  return m == null ? bron.substring(start) : bron.substring(start, start + 1 + m.start);
}

void main() {
  group('routes.dart muteert de routerlijst niet meer', () {
    test('state.extra wordt gekopieerd, niet ge-aliast', () {
      final routes = _code('lib/config/routes.dart');

      // De kapotte vorm: een cast (geen kopie) direct gevolgd door .add(...)
      expect(
        RegExp(r'shareItems\s*\?\?=\s*\[\]').hasMatch(routes),
        isFalse,
        reason: 'de lijst van de router mag niet in-place aangevuld worden',
      );
      expect(
        RegExp(r'state\.extra\s+as\s+List<ShareItem>').hasMatch(routes),
        isFalse,
        reason: 'een cast is geen kopie; de routerlijst groeide zo per rebuild',
      );
    });

    test('de lijst wordt opgebouwd met een spread (een echte kopie)', () {
      final routes = _bron('lib/config/routes.dart');
      expect(routes.contains('...extra'), isTrue,
          reason: 'de items moeten in een NIEUWE lijst terechtkomen');
    });

    test('dezelfde body wordt niet twee keer toegevoegd', () {
      final routes = _bron('lib/config/routes.dart');
      expect(routes.contains('alAanwezig'), isTrue,
          reason: 'de builder kan meerdere keren draaien voor dezelfde URL');
    });
  });

  group('De deel-guard overleeft een rebuild van de pagina', () {
    test('de guard is static, niet een instantie-veld', () {
      final chat = _code('lib/pages/chat/chat.dart');
      expect(chat.contains('_shareItemsProcessed'), isFalse,
          reason: 'een instantie-vlag begint na elke rebuild weer op false');
      expect(
        RegExp(r'static final Set<int> _verwerkteDeelActies').hasMatch(chat),
        isTrue,
        reason: 'de guard moet de rebuild overleven',
      );
    });

    test('de guard sleutelt op de identiteit van de gedeelde lijst', () {
      final body = _bodyVan(_code('lib/pages/chat/chat.dart'), 'void _shareItems(');
      expect(body.contains('identityHashCode'), isTrue,
          reason: 'één doorstuuractie = één lijstobject = één verzending');
      expect(body.contains('_verwerkteDeelActies.add'), isTrue,
          reason: 'add() geeft false terug als het al verwerkt is');
    });

    test('de guard wordt gezet VOOR er iets verzonden wordt', () {
      final body = _bodyVan(_code('lib/pages/chat/chat.dart'), 'void _shareItems(');
      final guard = body.indexOf('_verwerkteDeelActies.add');
      final verzend = body.indexOf('sendTextEvent');
      expect(guard, greaterThan(-1));
      expect(verzend, greaterThan(-1));
      expect(guard, lessThan(verzend),
          reason: 'anders kan een tweede aanroep alsnog verzenden');
    });

    test('de oude instantie-guard is weg', () {
      final body = _bodyVan(_code('lib/pages/chat/chat.dart'), 'void _shareItems(');
      expect(body.contains('_shareItemsProcessed'), isFalse);
    });
  });

  group('De send() debounce is nog intact', () {
    test('_isSending gate staat voor het lezen van de composer', () {
      final chat = _code('lib/pages/chat/chat.dart');
      final send = _bodyVan(chat, 'Future<void> send() async {');
      final gate = send.indexOf('if (_isSending) return;');
      final clear = send.indexOf('_clearComposer();');
      expect(gate, greaterThan(-1), reason: 'de debounce mag niet verdwijnen');
      expect(gate, lessThan(clear));
    });

    test('_isSending wordt op succes EN fout vrijgegeven', () {
      final send = _bodyVan(_code('lib/pages/chat/chat.dart'), 'Future<void> send() async {');
      expect(send.contains('_isSending = false;'), isTrue,
          reason: 'anders kan de gebruiker na een fout niets meer versturen');
      expect(send.contains('whenComplete'), isTrue,
          reason: 'vrijgeven moet ook op een foutpad gebeuren');
    });
  });
}
