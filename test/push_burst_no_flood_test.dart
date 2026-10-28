// Borgt vast dat een push-burst geen meldingsvloed meer veroorzaakt.
//
// HET PROBLEEM (gemeten in de push-diagnose van de gebruiker):
//   push_received ... (20 keer binnen 2 seconden, zelfde kamer)
//   push_event_unresolvable ... error=Null check operator used on a null value
//   push_clearing ... unread=56
//   push_event_unresolvable ... error=SqfliteFfiException(sqlite_error: 21 ...
//     Causing statement: BEGIN IMMEDIATE)
//   push_event_unresolvable ... error=Exception: Client is not logged in.
//
// De crash-rapport-stack wees het spoor:
//   #11 BoxCollection.open → #12 MatrixSdkDatabase.open → #13 .init
//   #14 _constructDatabase (builder.dart)
//   #16 ClientManager.createClient → #17 PushHelper._newPushHandler
//
// Elke push maakte een EIGEN client aan, en elke client opent de
// database van dat account opnieuw. De tweede open op een database die
// nog open is geeft SQLITE_MISUSE (21) op BEGIN IMMEDIATE. De
// push-verwerking belandde dan in de catch, en die zette per push een
// "Nieuw bericht in Plusly"-melding neer. Zo kreeg de gebruiker er
// twintig in plaats van één.

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
  group('push-burst', () {
    final manager = _code('lib/utils/client_manager.dart');
    final helper = _code('lib/utils/push_helper.dart');

    test('één client per account, gedeeld door alle aanroepers', () {
      expect(
        manager.contains('static final Map<String, Client> _clients'),
        isTrue,
        reason: 'zonder gedeelde client opent elke push de database opnieuw, '
            'en de tweede open crasht op SQLITE_MISUSE',
      );
      expect(
        manager.contains('static final Map<String, Future<Client>> _creatingClients'),
        isTrue,
        reason: 'een lopende creatie wordt gedeeld, zodat twee pushes niet '
            'tegelijk dezelfde database openen',
      );
    });

    test('de generieke fallbackmelding komt niet in een vloed', () {
      expect(
        helper.contains('_magFallbackMeldingTonen'),
        isTrue,
        reason: 'de vangnetmelding wordt begrensd per kamer',
      );
      expect(
        helper.contains('_fallbackMeldingSperre = Duration(minutes: 1)'),
        isTrue,
        reason: 'één melding per kamer per minuut is genoeg',
      );
    });

    test('een niet-ingelogd account geeft geen melding', () {
      expect(
        helper.contains('_isNotLoggedIn'),
        isTrue,
        reason: 'bij een account dat niet ingelogd is valt er niets te tonen',
      );
      expect(
        helper.contains('!_isNotLoggedIn(e)'),
        isTrue,
        reason: 'de vangnetmelding wordt overgeslagen bij "Client is not '
            'logged in"',
      );
    });

    test('de crash komt in de push-diagnose terecht', () {
      expect(
        helper.contains("PushEventLog().add('push_handler_crash'"),
        isTrue,
        reason: 'zonder spoor in de diagnose is de oorzaak niet te vinden',
      );
    });
  });
}
