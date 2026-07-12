
import 'package:flutter_test/flutter_test.dart';
import 'package:matrix/matrix.dart' show Event, PushRuleState, Room;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:Pulsly/services/chat_list_cache_service.dart';

void main() {
  group('ChatListCacheService', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
    });

    tearDown(() async {
      await ChatListCacheService.clear();
    });

    test('loadRooms retourneert null bij eerste start', () async {
      final rooms = await ChatListCacheService.loadRooms();
      expect(rooms, isNull);
    });

    test('saveRooms en loadRooms roundtrip', () async {
      final mockRooms = _createMockRooms(3);

      await ChatListCacheService.saveRooms(mockRooms);
      final loaded = await ChatListCacheService.loadRooms();

      expect(loaded, isNotNull);
      expect(loaded!.length, 3);
      expect(loaded[0]['id'], '!room1:server');
      expect(loaded[0]['name'], 'Room 1');
      // lastMessage is leeg omdat lastEvent null is in de mock
      expect(loaded[0]['lastMessage'], '');
    });

    test('saveRooms slaat maximaal 20 rooms op', () async {
      final mockRooms = _createMockRooms(25);

      await ChatListCacheService.saveRooms(mockRooms);
      final loaded = await ChatListCacheService.loadRooms();

      expect(loaded, isNotNull);
      expect(loaded!.length, 20);
    });

    test('saveRooms filtert spaces uit', () async {
      final rooms = [
        _MockRoom(id: '!direct:server', name: 'Alice', isDirect: true),
        _MockRoom(id: '!space:server', name: 'Space', isSpace: true),
        _MockRoom(id: '!group:server', name: 'Group'),
      ];

      await ChatListCacheService.saveRooms(rooms);
      final loaded = await ChatListCacheService.loadRooms();

      expect(loaded!.length, 2);
      expect(loaded.any((r) => r['id'] == '!space:server'), isFalse);
    });

    test('clear verwijdert opgeslagen data', () async {
      await ChatListCacheService.saveRooms(_createMockRooms(2));
      await ChatListCacheService.clear();

      final loaded = await ChatListCacheService.loadRooms();
      expect(loaded, isNull);
    });

    test('loadRooms retourneert null bij corrupte data', () async {
      SharedPreferences.setMockInitialValues({
        'chat_list_cache_v1': 'invalid-json{{',
      });

      final loaded = await ChatListCacheService.loadRooms();
      expect(loaded, isNull);
    });

    test('saveRooms bevat alle verwachte velden', () async {
      final rooms = [
        _MockRoom(
          id: '!test:server',
          name: 'Test Room',
          isDirect: true,
          unread: true,
          notifCount: 3,
          isFav: true,
          isMuted: true,
        ),
      ];

      await ChatListCacheService.saveRooms(rooms);
      final loaded = (await ChatListCacheService.loadRooms())!.first;

      expect(loaded['id'], '!test:server');
      expect(loaded['name'], 'Test Room');
      expect(loaded['unread'], isTrue);
      expect(loaded['notificationCount'], 3);
      expect(loaded['isDirectChat'], isTrue);
      expect(loaded['isFavourite'], isTrue);
      expect(loaded['isMuted'], isTrue);
    });
  });
}

// === MOCK HELPERS ===

List<_MockRoom> _createMockRooms(int count) {
  return List.generate(count, (i) => _MockRoom(
    id: '!room${i + 1}:server',
    name: 'Room ${i + 1}',
    isDirect: i % 2 == 0,
  ));
}

/// Minimale Room mock die alleen de velden exposeert die
/// ChatListCacheService.saveRooms() nodig heeft.
class _MockRoom implements Room {
  final String id;
  final String name;
  final bool isDirect;
  final bool _isSpace;
  final bool unread;
  final int notifCount;
  final bool isFav;
  final bool isMuted;

  _MockRoom({
    required this.id,
    required this.name,
    this.isDirect = false,
    bool isSpace = false,
    this.unread = false,
    this.notifCount = 0,
    this.isFav = false,
    this.isMuted = false,
  }) : _isSpace = isSpace;

  @override
  String get displayname => name;

  @override
  bool get isDirectChat => isDirect;

  @override
  bool get isSpace => _isSpace;

  @override
  bool get isUnread => unread;

  @override
  int get notificationCount => notifCount;

  @override
  bool get isFavourite => isFav;

  @override
  PushRuleState get pushRuleState => isMuted ? PushRuleState.dontNotify : PushRuleState.notify;

  // lastEvent / avatar mock — null is OK voor de test
  @override
  Event? get lastEvent => null;

  @override
  Uri? get avatar => null;

  // Delegate everything else to noSuchMethod
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
