import 'dart:async';

import 'package:Pulsly/features/push/domain/push_provider.dart';

class FakePushProvider implements PushProvider {
  @override
  String get id => 'fake';

  @override
  String get displayName => 'Fake';

  @override
  bool get isAvailable => true;

  @override
  bool get isActive => false;

  @override
  Future<bool> initialize() async => true;

  @override
  Future<String?> register() async => null;

  @override
  Future<void> unregister() async {}

  @override
  Stream<PushMessage> get messageStream => const Stream.empty();

  @override
  void dispose() {}
}

class FakePushMessage implements PushMessage {
  @override
  final String roomId;
  @override
  final String eventId;
  @override
  final String sender;
  @override
  final String body;
  @override
  final PushProviderType source;
  @override
  final DateTime receivedAt;
  @override
  final int? unreadCount;
  @override
  final String? clientName;

  FakePushMessage({
    this.roomId = '',
    this.eventId = '',
    this.sender = '',
    this.body = '',
    this.source = PushProviderType.none,
    DateTime? receivedAt,
    this.unreadCount,
    this.clientName,
  }) : receivedAt = receivedAt ?? DateTime.now();

  @override
  Map<String, dynamic> toJson() => {
    'room_id': roomId,
    'event_id': eventId,
    'sender': sender,
    'body': body,
    'source': source.name,
    'received_at': receivedAt.toIso8601String(),
    'unread_count': unreadCount,
    'client_name': clientName,
  };

  @override
  String toPayload() => '${clientName ?? ''}|$roomId|$eventId';

  @override
  String toString() => 'FakePushMessage($sender: $body @ $roomId)';
}

void registerPushFakes() {
  // No-op: kept for compatibility with old test bootstrap.
}
