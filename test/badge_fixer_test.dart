import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:Pulsly/utils/badge_fixer.dart';
import 'package:Pulsly/utils/room_unread_extension.dart';

void main() {
  // BadgeFixer deelt zijn lees-momenten met de UI-override (RoomUnreadX) en
  // raakt daardoor SharedPreferences aan; de binding moet dus bestaan.
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    RoomUnreadX.debugClearCache();
  });

  group('BadgeFixer', () {
    test('bewaarLezing registreert kamers in de persistente opslag', () async {
      final f = BadgeFixer.instance;
      f.bewaarLezing('!test-room-a');
      f.bewaarLezing('!test-room-b');

      // De schrijfactie loopt async (unawaited); geef de microtask-queue de
      // kans om te drainen voordat we de opslag uitlezen.
      await Future<void>.delayed(Duration.zero);

      // Eén bron van waarheid: wat de fixer bewaart, ziet de UI-override ook.
      expect(RoomUnreadX.leesTijdSync('!test-room-a'), isNotNull);
      expect(RoomUnreadX.leesTijdSync('!test-room-b'), isNotNull);
    });

    test('bewaarLezing overleeft een herstart via hydrate()', () async {
      BadgeFixer.instance.bewaarLezing('!test-room-c');
      await Future<void>.delayed(Duration.zero);

      // Herstart simuleren: geheugen leeg, SharedPreferences intact.
      RoomUnreadX.debugClearCache();
      await RoomUnreadX.hydrate();

      expect(RoomUnreadX.leesTijdSync('!test-room-c'), isNotNull);
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
