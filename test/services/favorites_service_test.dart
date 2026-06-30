import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:Pulsly/services/favorites_service.dart';

void main() {
  group('FavoritesService', () {
    setUp(() async {
      // Mock SharedPreferences — vereist voor tests
      SharedPreferences.setMockInitialValues({});
      // Reset interne state
      await FavoritesService.reset();
    });

    test('getFavorites retourneert lege lijst bij start', () async {
      final favorites = await FavoritesService.getFavorites();
      expect(favorites, isEmpty);
    });

    test('saveMessage voegt bericht toe', () async {
      final msg = SavedMessage(
        id: 'msg-1',
        roomId: '!abc:server',
        sender: '@alice:server',
        content: 'Hallo wereld',
        savedAt: DateTime(2024, 6, 15, 10, 30),
      );

      await FavoritesService.saveMessage(msg);
      final favorites = await FavoritesService.getFavorites();

      expect(favorites.length, 1);
      expect(favorites.first.id, 'msg-1');
      expect(favorites.first.content, 'Hallo wereld');
      expect(favorites.first.sender, '@alice:server');
    });

    test('removeMessage verwijdert juiste bericht', () async {
      await FavoritesService.saveMessage(SavedMessage(
        id: 'msg-1', roomId: '!abc:server',
        sender: '@a:server', content: 'Eerste', savedAt: DateTime.now(),
      ));
      await FavoritesService.saveMessage(SavedMessage(
        id: 'msg-2', roomId: '!abc:server',
        sender: '@b:server', content: 'Tweede', savedAt: DateTime.now(),
      ));

      await FavoritesService.removeMessage('msg-1');
      final favorites = await FavoritesService.getFavorites();

      expect(favorites.length, 1);
      expect(favorites.first.id, 'msg-2');
    });

    test('searchFavorites zoekt in content en sender', () async {
      await FavoritesService.saveMessage(SavedMessage(
        id: '1', roomId: '!a:server',
        sender: '@alice:server', content: 'Welkom bij de meeting',
        savedAt: DateTime.now(),
      ));
      await FavoritesService.saveMessage(SavedMessage(
        id: '2', roomId: '!a:server',
        sender: '@bob:server', content: 'Bedankt voor het helpen',
        savedAt: DateTime.now(),
      ));
      await FavoritesService.saveMessage(SavedMessage(
        id: '3', roomId: '!a:server',
        sender: '@charlie:server', content: 'Tot ziens',
        savedAt: DateTime.now(),
      ));

      final result = await FavoritesService.searchFavorites('helpen');
      expect(result.length, 1);
      expect(result.first.id, '2');

      final result2 = await FavoritesService.searchFavorites('ALICE');
      expect(result2.length, 1);
      expect(result2.first.sender, '@alice:server');
    });

    test('searchFavorites met lege query retourneert alles', () async {
      await FavoritesService.saveMessage(SavedMessage(
        id: '1', roomId: '!a:server',
        sender: '@a:server', content: 'Test', savedAt: DateTime.now(),
      ));

      final result = await FavoritesService.searchFavorites('');
      expect(result.length, 1);
    });

    test('getFavoritesByPerson groepeert op sender', () async {
      await FavoritesService.saveMessage(SavedMessage(
        id: '1', roomId: '!a:server',
        sender: '@alice:server', content: 'Hallo', savedAt: DateTime.now(),
      ));
      await FavoritesService.saveMessage(SavedMessage(
        id: '2', roomId: '!a:server',
        sender: '@alice:server', content: 'Dag', savedAt: DateTime.now(),
      ));
      await FavoritesService.saveMessage(SavedMessage(
        id: '3', roomId: '!a:server',
        sender: '@bob:server', content: 'Hey', savedAt: DateTime.now(),
      ));

      final byPerson = await FavoritesService.getFavoritesByPerson();
      expect(byPerson.length, 2);
      expect(byPerson['@alice:server']?.length, 2);
      expect(byPerson['@bob:server']?.length, 1);
    });

    test('SavedMessage JSON roundtrip werkt correct', () {
      final original = SavedMessage(
        id: 'msg-42',
        roomId: '!test:server',
        sender: '@user:server',
        content: 'Test bericht',
        savedAt: DateTime(2024, 1, 15, 14, 30, 0),
      );

      final json = original.toJson();
      final restored = SavedMessage.fromJson(json);

      expect(restored.id, original.id);
      expect(restored.roomId, original.roomId);
      expect(restored.sender, original.sender);
      expect(restored.content, original.content);
      expect(restored.savedAt, original.savedAt);
    });

    test('SavedMessage fromJson handelt null gracefully', () {
      final restored = SavedMessage.fromJson({});

      expect(restored.id, '');
      expect(restored.roomId, '');
      expect(restored.sender, 'Unknown');
      expect(restored.content, '');
      expect(restored.savedAt, isA<DateTime>());
    });
  });
}
