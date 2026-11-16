import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:Pulsly/config/setting_keys.dart';
import 'package:Pulsly/widgets/chat_background.dart';

void main() {
  group('ChatBackground per chat', () {
    setUpAll(() async {
      SharedPreferences.setMockInitialValues({});
      await AppSettings.init();
    });

    test('standaard: geen achtergrond, geen hasChatBackground', () {
      expect(chatBackgroundMode('!a:x'), 'none');
      expect(hasChatBackground('!a:x'), isFalse);
      expect(chatBackgroundMode(), 'none');
    });

    test('globale achtergrond geldt voor alle chats', () async {
      await AppSettings.chatBackground.setItem('forest');
      expect(chatBackgroundMode('!a:x'), 'forest');
      expect(hasChatBackground('!a:x'), isTrue);
    });

    test('per-chat override wint van de globale instelling', () async {
      await setChatBackgroundForRoom('!a:x', 'ocean');
      expect(chatBackgroundMode('!a:x'), 'ocean');
      expect(chatBackgroundMode('!b:x'), 'forest');
      expect(perRoomChatBackground('!a:x'), 'ocean');
      expect(perRoomChatBackground('!b:x'), 'default');
    });

    test('per-chat none wint ook van een eigen foto (wallpaper)', () async {
      await AppSettings.wallpaperPath.setItem('/tmp/foto.jpg');
      expect(chatBackgroundMode('!c:x'), 'wallpaper');
      await setChatBackgroundForRoom('!c:x', 'none');
      expect(chatBackgroundMode('!c:x'), 'none');
      expect(hasChatBackground('!c:x'), isFalse);
      await setChatBackgroundForRoom('!c:x', 'default');
      expect(chatBackgroundMode('!c:x'), 'wallpaper');
      await AppSettings.wallpaperPath.setItem('');
    });

    test('default wist de override en volgt weer de globale instelling',
        () async {
      await setChatBackgroundForRoom('!a:x', 'default');
      expect(perRoomChatBackground('!a:x'), 'default');
      expect(chatBackgroundMode('!a:x'), 'forest');
    });

    test('kapotte JSON valt terug op de globale instelling', () async {
      await AppSettings.chatBackgroundPerRoom.setItem('dit-is-geen-json{{{');
      expect(chatBackgroundMode('!a:x'), 'forest');
      expect(hasChatBackground('!a:x'), isTrue);
      // opruimen voor de volgende tests
      await AppSettings.chatBackgroundPerRoom.setItem('{}');
      expect(chatBackgroundMode('!a:x'), 'forest');
    });

    test("per-chat 'wallpaper' valt terug op globale modus als er geen eigen foto is", () async {
      await AppSettings.wallpaperPath.setItem('/tmp/globalfoto.jpg');
      await setChatBackgroundForRoom('!wp:test', 'wallpaper');
      // globale foto staat aan -> wallpaper
      expect(chatBackgroundMode('!wp:test'), 'wallpaper');
      // globale foto weg -> terugval op globale ingebouwde instelling ('forest')
      await AppSettings.wallpaperPath.setItem('');
      expect(chatBackgroundMode('!wp:test'), 'forest');
      await setChatBackgroundForRoom('!wp:test', 'default');
    });

    test('override via directe JSON-injectie wordt gelezen', () async {
      await AppSettings.chatBackgroundPerRoom
          .setItem(jsonEncode({'!z:y': 'lattice'}));
      expect(chatBackgroundMode('!z:y'), 'lattice');
      expect(chatBackgroundMode('!a:x'), 'forest');
      await AppSettings.chatBackgroundPerRoom.setItem('{}');
    });
  });
}
