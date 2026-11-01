// Uitloggen moet de database van het account sluiten.
//
// HET PROBLEEM (pushuitval 31-10-2026):
//   ClientManager.forgetClient haalde de client alleen uit de cache, maar
//   sloot de database nooit. Na het uitloggen bleef de SQLite-verbinding van
//   dat account open. De push-isolate opende hetzelfde bestand daarna opnieuw
//   en kreeg SQLITE_MISUSE (code 21) op BEGIN IMMEDIATE — dat was de
//   oorzaak van het uitvallen van alle pushnotificaties.
//
// Nu sluit forgetClient de database (dispose met closeDatabase: true).
//
// Dit is een broncode-assertie: een echte Client vereist een echte database
// (met encryptie), die je in een unittest niet zomaar opzet. De bewering
// borgt het wezenlijke gedrag — dat dispose mét closeDatabase wordt
// aangeroepen — zodat iemand die de regel verwijdert meteen een rode test
// krijgt.

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('forgetClient sluit de database', () {
    test('roept dispose met closeDatabase: true aan', () {
      final inhoud = File(
        'lib/utils/client_manager.dart',
      ).readAsStringSync();

      expect(
        inhoud.contains('dispose(closeDatabase: true)'),
        isTrue,
        reason:
            'zonder closeDatabase blijft de verbinding open en krijgt een '
            'volgende push SQLITE_MISUSE op datzelfde bestand',
      );
    });

    test('forgetClient is async en geeft het sluiten de tijd', () {
      final inhoud = File(
        'lib/utils/client_manager.dart',
      ).readAsStringSync();

      expect(
        inhoud.contains('static Future<void> forgetClient('),
        isTrue,
        reason: 'dispose is async; forgetClient moet het kunnen awaiten',
      );
    });

    test('een mislukt sluiten blokkeert het uitloggen niet', () {
      final inhoud = File(
        'lib/utils/client_manager.dart',
      ).readAsStringSync();

      expect(
        inhoud.contains('await client.dispose(closeDatabase: true);'),
        isTrue,
      );
      expect(
        inhoud.contains('kon niet worden gesloten'),
        isTrue,
        reason: 'een uitzondering bij het sluiten mag het uitloggen niet '
            'laten hangen',
      );
    });

    test('het uitlogpad roept forgetClient aan', () {
      final inhoud = File('lib/widgets/matrix.dart').readAsStringSync();

      expect(
        inhoud.contains('unawaited(ClientManager.forgetClient('),
        isTrue,
        reason: 'uitloggen moet de gecachte client weggooien én diens '
            'database sluiten',
      );
    });
  });
}
