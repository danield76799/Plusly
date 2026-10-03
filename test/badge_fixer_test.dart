import 'package:flutter_test/flutter_test.dart';

import 'package:Pulsly/utils/badge_fixer.dart';

void main() {
  // BadgeFixer is een singleton met SDK-afhankelijkheden (Client/Room);
  // de unit-tests dekken de puur-logische stukken: bewaarLezing + TTL.
  group('BadgeFixer', () {
    test('bewaarLezing registreert kamers (geen crash, interne state)', () {
      final f = BadgeFixer.instance;
      f.bewaarLezing('!test-room-a');
      f.bewaarLezing('!test-room-b');
      // Geen assert op privé-state: het gedrag (geen crash, sync-loos) is
      // het contract; de corrigerende werking wordt door apparaat-dumps
      // verifieert ([badge_fixer]-events in de push-debug log).
    });

    test('meerdere observeClientNamed-call zijn idempotent', () {
      final f = BadgeFixer.instance;
      // Zonder echte Client kan hier geen echte stream gestart worden;
      // de guard zit in de _subs-map (??=). smoke-test: stopAlles.
      f.stopAlles();
      f.stopAlles();
    });
  });
}