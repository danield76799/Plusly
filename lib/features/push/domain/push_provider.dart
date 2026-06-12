import 'dart:async';

/// Abstract interface voor alle push providers.
/// 
/// Implementaties:
/// - [UnifiedPushProvider] — privacy-first, geen Google
abstract class PushProvider {
  /// Unieke identifier voor deze provider
  String get id;

  /// Display name voor UI
  String get displayName;

  /// Of deze provider beschikbaar is op dit platform
  bool get isAvailable;

  /// Of deze provider momenteel actief is (succesvol geregistreerd)
  bool get isActive;

  /// Initialiseer de provider (eenmalig bij app start)
  /// Returnt true als init succesvol was
  Future<bool> initialize();

  /// Registreer voor push notifications
  /// Returnt het push token/endpoint, of null bij falen
  Future<String?> register();

  /// De-registreer en cleanup
  Future<void> unregister();

  /// Stream van inkomende push messages
  Stream<PushMessage> get messageStream;

  /// Cleanup resources
  void dispose();
}

/// Unified push message model — één format voor ALLE providers
class PushMessage {
  final String roomId;
  final String eventId;
  final String sender;
  final String body;
  final PushProviderType source;
  final DateTime receivedAt;
  final int? unreadCount;
  final String? clientName;

  const PushMessage({
    required this.roomId,
    required this.eventId,
    required this.sender,
    required this.body,
    required this.source,
    required this.receivedAt,
    this.unreadCount,
    this.clientName,
  });

  factory PushMessage.fromJson(Map<String, dynamic> json) {
    return PushMessage(
      roomId: json['room_id'] as String? ?? '',
      eventId: json['event_id'] as String? ?? '',
      sender: json['sender'] as String? ?? '',
      body: json['body'] as String? ?? '',
      source: PushProviderType.values.firstWhere(
        (e) => e.name == (json['source'] as String? ?? 'unifiedPush'),
        orElse: () => PushProviderType.unifiedPush,
      ),
      receivedAt: DateTime.tryParse(json['received_at'] as String? ?? '') ?? DateTime.now(),
      unreadCount: json['unread_count'] as int?,
      clientName: json['client_name'] as String?,
    );
  }

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

  /// Payload string voor notification tap handling
  String toPayload() => '${clientName ?? ''}|$roomId|$eventId';

  @override
  String toString() => 'PushMessage($sender: $body @ $roomId)';
}

enum PushProviderType {
  unifiedPush,
  none,
}
