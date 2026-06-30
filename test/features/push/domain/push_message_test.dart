import 'package:flutter_test/flutter_test.dart';
import 'package:Pulsly/features/push/domain/push_provider.dart';

void main() {
  group('PushMessage', () {
    test('fromJson parseert volledige payload correct', () {
      final json = {
        'room_id': '!abc:server',
        'event_id': '\$event123',
        'sender': '@alice:server',
        'body': 'Hallo wereld',
        'source': 'unifiedPush',
        'received_at': '2024-06-15T10:30:00.000Z',
        'unread_count': 5,
        'client_name': 'Plusly',
      };

      final msg = PushMessage.fromJson(json);

      expect(msg.roomId, '!abc:server');
      expect(msg.eventId, '\$event123');
      expect(msg.sender, '@alice:server');
      expect(msg.body, 'Hallo wereld');
      expect(msg.source, PushProviderType.unifiedPush);
      expect(msg.receivedAt, DateTime.parse('2024-06-15T10:30:00.000Z'));
      expect(msg.unreadCount, 5);
      expect(msg.clientName, 'Plusly');
    });

    test('fromJson handelt null velden met defaults', () {
      final msg = PushMessage.fromJson({});

      expect(msg.roomId, '');
      expect(msg.eventId, '');
      expect(msg.sender, '');
      expect(msg.body, '');
      expect(msg.source, PushProviderType.unifiedPush);
      expect(msg.receivedAt, isA<DateTime>());
      expect(msg.unreadCount, isNull);
      expect(msg.clientName, isNull);
    });

    test('fromJson onbekende source valt terug naar unifiedPush', () {
      final msg = PushMessage.fromJson({'source': 'onbekend_provider'});
      expect(msg.source, PushProviderType.unifiedPush);
    });

    test('toJson serialiseert correct', () {
      final msg = PushMessage(
        roomId: '!abc:server',
        eventId: '\$event123',
        sender: '@alice:server',
        body: 'Test',
        source: PushProviderType.unifiedPush,
        receivedAt: DateTime.parse('2024-06-15T10:30:00.000Z'),
        unreadCount: 3,
        clientName: 'Plusly',
      );

      final json = msg.toJson();

      expect(json['room_id'], '!abc:server');
      expect(json['event_id'], '\$event123');
      expect(json['source'], 'unifiedPush');
      expect(json['unread_count'], 3);
      expect(json['client_name'], 'Plusly');
    });

    test('toPayload genereert correct format', () {
      final msg = PushMessage(
        roomId: '!abc:server',
        eventId: '\$event123',
        sender: '@alice:server',
        body: 'Test',
        source: PushProviderType.unifiedPush,
        receivedAt: DateTime.now(),
        clientName: 'Plusly',
      );

      expect(msg.toPayload(), 'Plusly|!abc:server|\$event123');
    });

    test('toPayload zonder clientName is leeg prefix', () {
      final msg = PushMessage(
        roomId: '!abc:server',
        eventId: '\$event123',
        sender: '@alice:server',
        body: 'Test',
        source: PushProviderType.unifiedPush,
        receivedAt: DateTime.now(),
      );

      expect(msg.toPayload(), '|!abc:server|\$event123');
    });

    test('toString bevat sender en body', () {
      final msg = PushMessage(
        roomId: '!abc:server',
        eventId: '\$event123',
        sender: '@alice:server',
        body: 'Hallo',
        source: PushProviderType.unifiedPush,
        receivedAt: DateTime.now(),
      );

      expect(msg.toString(), contains('@alice:server'));
      expect(msg.toString(), contains('Hallo'));
      expect(msg.toString(), contains('!abc:server'));
    });

    test('roundtrip: toJson -> fromJson behoudt alle data', () {
      final original = PushMessage(
        roomId: '!test:server',
        eventId: '\$evt456',
        sender: '@bob:server',
        body: 'Bericht',
        source: PushProviderType.unifiedPush,
        receivedAt: DateTime(2024, 6, 15, 12, 0, 0),
        unreadCount: 7,
        clientName: 'TestClient',
      );

      final json = original.toJson();
      final restored = PushMessage.fromJson(json);

      expect(restored.roomId, original.roomId);
      expect(restored.eventId, original.eventId);
      expect(restored.sender, original.sender);
      expect(restored.body, original.body);
      expect(restored.source, original.source);
      expect(restored.unreadCount, original.unreadCount);
      expect(restored.clientName, original.clientName);
    });
  });

  group('PushProviderType', () {
    test('enum bevat expected values', () {
      expect(PushProviderType.values, contains(PushProviderType.unifiedPush));
      expect(PushProviderType.values, contains(PushProviderType.none));
    });

    test('enum name property werkt', () {
      expect(PushProviderType.unifiedPush.name, 'unifiedPush');
      expect(PushProviderType.none.name, 'none');
    });
  });
}
