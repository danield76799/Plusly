import 'package:flutter_test/flutter_test.dart';
import 'package:Pulsly/features/push/domain/push_provider.dart';

void main() {
  group('PushMessage', () {
    test('should create valid PushMessage from JSON', () {
      // Arrange
      final json = {
        'room_id': '!test:matrix.org',
        'event_id': '\$123456',
        'sender': '@alice:matrix.org',
        'body': 'Hello world',
        'source': 'unifiedPush',
        'received_at': '2026-05-25T12:00:00.000Z',
        'unread_count': 5,
      };

      // Act
      final message = PushMessage.fromJson(json);

      // Assert
      expect(message.roomId, '!test:matrix.org');
      expect(message.eventId, '\$123456');
      expect(message.sender, '@alice:matrix.org');
      expect(message.body, 'Hello world');
      expect(message.source, PushProviderType.unifiedPush);
      expect(message.unreadCount, 5);
    });

    test('should serialize to payload string', () {
      // Arrange
      final message = PushMessage(
        roomId: '!test:matrix.org',
        eventId: '\$123456',
        sender: '@alice:matrix.org',
        body: 'Hello world',
        source: PushProviderType.unifiedPush,
        receivedAt: DateTime(2026, 5, 25, 12, 0),
        clientName: 'test_client',
      );

      // Act
      final payload = message.toPayload();

      // Assert
      expect(payload, 'test_client|!test:matrix.org|\$123456');
    });

    test('should handle missing optional fields', () {
      // Arrange
      final json = {
        'room_id': '!test:matrix.org',
        'event_id': '\$123456',
        'sender': '@alice:matrix.org',
        'body': 'Hello',
        'source': 'firebase',
        'received_at': '2026-05-25T12:00:00.000Z',
      };

      // Act
      final message = PushMessage.fromJson(json);

      // Assert
      expect(message.unreadCount, isNull);
      expect(message.clientName, isNull);
      expect(message.source, PushProviderType.firebase);
    });

    test('should use default values for missing source and received_at', () {
      // Arrange
      final json = {
        'room_id': '!test:matrix.org',
        'event_id': '\$123456',
        'sender': '@alice:matrix.org',
        'body': 'Hello',
      };

      // Act
      final message = PushMessage.fromJson(json);

      // Assert
      expect(message.source, PushProviderType.unifiedPush);
      expect(message.receivedAt, isA<DateTime>());
    });

    test('should round-trip through JSON', () {
      // Arrange
      final original = PushMessage(
        roomId: '!test:matrix.org',
        eventId: '\$123456',
        sender: '@alice:matrix.org',
        body: 'Hello world',
        source: PushProviderType.unifiedPush,
        receivedAt: DateTime(2026, 5, 25, 12, 0),
        unreadCount: 3,
        clientName: 'my_client',
      );

      // Act
      final json = original.toJson();
      final restored = PushMessage.fromJson(json);

      // Assert
      expect(restored.roomId, original.roomId);
      expect(restored.eventId, original.eventId);
      expect(restored.sender, original.sender);
      expect(restored.body, original.body);
      expect(restored.source, original.source);
      expect(restored.unreadCount, original.unreadCount);
      expect(restored.clientName, original.clientName);
    });
  });
}
