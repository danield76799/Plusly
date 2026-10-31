// Borgt vast dat één kapot account de push niet meer doodt.
//
// HET PROBLEEM (uit de push-diagnose van de gebruiker, 31-10-2026):
//   [status] Push-helper crash-rapport:
//   SqfliteFfiException(sqlite_error: 21, ... bad parameter or other API misuse)
//   Causing statement: BEGIN IMMEDIATE
//   #11 BoxCollection.open → #12 MatrixSdkDatabase.open → #13 .init
//   #14 _constructDatabase → #16 ClientManager.createClient
//   #17 PushHelper._newPushHandler → #19 PushHelper.pushHelper
//   #20 BackgroundPush._onUpMessage
//   database: /data/user/0/com.danield.plusly.app/files/Plusly-1792390469026.sqlite
//
// ClientManager.getClients deed `Future.wait` over ALLE accounts. Future.wait
// faalt op de eerste fout, dus één account waarvan de database niet opent
// (SQLITE_MISUSE op BEGIN IMMEDIATE — de push-isolate opent dezelfde file als
// de hoofd-isolate) sloopte de hele lijst, inclusief het gezonde, actieve
// account.
//
// Gevolg: bij elke start crashte het ophalen van de clients. Daardoor
// werden de pushers bij de homeserver nooit hersteld (setupPusher wordt pas
// na het ophalen van de clients aangeroepen) en kwam er geen enkele push
// meer binnen.
//
// DE REGELS DIE HIER BEVAKT WORDEN
// 1. Een account dat niet opent, mag de andere accounts niet meenemen.
// 2. Een account wordt NOOIT stilzwijgend uit de store verwijderd: een
//    database die even op slot staat zou de gebruiker dan uit een werkend
//    account loggen.
// 3. De push-verwerking mag niet crashen als er geen client beschikbaar
//    is: dan wordt de push overgeslagen, niet de hele pijp.

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:Pulsly/utils/client_manager.dart';

void main() {
  group('kapot account', () {
    test(
      'één account dat niet opent neemt de andere accounts niet mee',
      () async {
        final geprobeerd = <String>[];
        final resultaat = await ClientManager.openAccounts<String>([
          'goed-1',
          'kapot',
          'goed-2',
        ], (naam) async {
          geprobeerd.add(naam);
          if (naam == 'kapot') {
            throw StateError(
              'SqfliteFfiException(sqlite_error: 21): BEGIN IMMEDIATE',
            );
          }
          return naam;
        });

        expect(
          resultaat.clients.length,
          2,
          reason: 'de twee gezonde accounts moeten overblijven',
        );
        expect(resultaat.clients, ['goed-1', 'goed-2']);
        expect(resultaat.kapot, ['kapot']);
        expect(
          geprobeerd.where((n) => n == 'kapot').length,
          1,
          reason: 'zonder herhaalpoging wordt een account één keer geprobeerd',
        );
      },
    );

    test(
      'met herhaalpoging opent een account dat even blokkeerde alsnog',
      () async {
        var pogingen = 0;
        final resultaat = await ClientManager.openAccounts<String>(
          ['eerste-keer-mislukt'],
          (naam) async {
            pogingen++;
            if (pogingen == 1) {
              throw StateError('database op slot');
            }
            return naam;
          },
          herhaalPoging: const Duration(milliseconds: 50),
        );

        expect(pogingen, 2);
        expect(resultaat.clients.length, 1);
        expect(resultaat.kapot, isEmpty);
      },
    );

    test('blijft een account blokkeren, dan is het kapot', () async {
      final resultaat = await ClientManager.openAccounts<String>(
        ['blijft-kapot'],
        (naam) async => throw StateError('database op slot'),
        herhaalPoging: const Duration(milliseconds: 50),
      );

      expect(resultaat.clients, isEmpty);
      expect(resultaat.kapot, ['blijft-kapot']);
    });
  });

  group('broncode', () {
    final manager = File(
      'lib/utils/client_manager.dart',
    ).readAsStringSync();
    final helper = File('lib/utils/push_helper.dart').readAsStringSync();

    test('getClients faalt niet meer op de eerste fout', () {
      expect(
        manager.contains(
          'Future.wait(\n      clientNames.map((name) => createClient(name, store)),',
        ),
        isFalse,
        reason:
            'Future.wait faalt op de eerste fout; één kapot account sloopte '
            'daarmee alle accounts',
      );
      expect(manager.contains('openAccounts('), isTrue);
    });

    test('een kapot account wordt niet uit de store verwijderd', () {
      expect(
        manager.contains('clientNames.remove(name)'),
        isFalse,
        reason:
            'een database die even op slot staat mag de gebruiker niet uit een '
            'werkend account loggen',
      );
    });

    test('de push-verwerking vangt een mislukte client-resolutie op', () {
      expect(
        helper.contains('push_client_failed'),
        isTrue,
        reason: 'een push zonder client moet worden overgeslagen, niet crashen',
      );
      expect(
        helper.contains('probeer het nogmaals'),
        isTrue,
        reason: 'een tijdelijk blokkeerde database krijgt een tweede kans',
      );
    });
  });
}
