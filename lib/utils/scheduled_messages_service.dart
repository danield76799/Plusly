import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:matrix/matrix.dart';

/// Model for a scheduled message
class ScheduledMessage {
  final String id;
  final String roomId;
  final String senderId;
  final Map<String, dynamic> content;
  final DateTime scheduledAt;
  final String? replyEventId;
  final String? threadRootEventId;
  final String? threadLastEventId;
  bool isSent;

  ScheduledMessage({
    required this.id,
    required this.roomId,
    required this.senderId,
    required this.content,
    required this.scheduledAt,
    this.replyEventId,
    this.threadRootEventId,
    this.threadLastEventId,
    this.isSent = false,
  });

  factory ScheduledMessage.fromJson(Map<String, dynamic> json) {
    return ScheduledMessage(
      id: json['id'] as String,
      roomId: json['room_id'] as String,
      senderId: json['sender_id'] as String,
      content: Map<String, dynamic>.from(json['content'] as Map),
      scheduledAt: DateTime.parse(json['scheduled_at'] as String),
      replyEventId: json['reply_event_id'] as String?,
      threadRootEventId: json['thread_root_event_id'] as String?,
      threadLastEventId: json['thread_last_event_id'] as String?,
      isSent: json['is_sent'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'room_id': roomId,
      'sender_id': senderId,
      'content': content,
      'scheduled_at': scheduledAt.toIso8601String(),
      'reply_event_id': replyEventId,
      'thread_root_event_id': threadRootEventId,
      'thread_last_event_id': threadLastEventId,
      'is_sent': isSent,
    };
  }
}

/// Service to manage scheduled messages client-side
class ScheduledMessagesService {
  static const String _scheduledMessagesFileName = 'scheduled_messages.json';
  static List<ScheduledMessage>? _cachedMessages;

  /// Get the file path for scheduled messages storage
  static Future<File> _getStorageFile() async {
    if (kIsWeb) {
      final dir = await getApplicationDocumentsDirectory();
      return File('${dir.path}/$_scheduledMessagesFileName');
    }
    final dir = await getApplicationSupportDirectory();
    return File('${dir.path}/$_scheduledMessagesFileName');
  }

  /// Load all scheduled messages from storage
  static Future<List<ScheduledMessage>> loadScheduledMessages() async {
    if (_cachedMessages != null) return List.from(_cachedMessages!);

    try {
      final file = await _getStorageFile();
      if (!await file.exists()) {
        _cachedMessages = [];
        return [];
      }

      final contents = await file.readAsString();
      final List<dynamic> jsonList = jsonDecode(contents);
      _cachedMessages = jsonList
          .map(
            (json) => ScheduledMessage.fromJson(json as Map<String, dynamic>),
          )
          .toList();

      // Sort by scheduled time
      _cachedMessages!.sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));

      return List.from(_cachedMessages!);
    } catch (e) {
      Logs().e('Failed to load scheduled messages', e);
      _cachedMessages = [];
      return [];
    }
  }

  /// Save all scheduled messages to storage
  static Future<void> _saveScheduledMessages() async {
    try {
      final file = await _getStorageFile();
      final jsonList = _cachedMessages?.map((m) => m.toJson()).toList() ?? [];
      await file.writeAsString(jsonEncode(jsonList));
    } catch (e) {
      Logs().e('Failed to save scheduled messages', e);
    }
  }

  /// Add a new scheduled message
  static Future<void> addScheduledMessage(ScheduledMessage message) async {
    await loadScheduledMessages();
    _cachedMessages!.add(message);
    await _saveScheduledMessages();
    Logs().d(
      'Scheduled message added: ${message.id} for room ${message.roomId}',
    );
  }

  /// Remove a scheduled message (after it's sent or cancelled)
  static Future<void> removeScheduledMessage(String id) async {
    await loadScheduledMessages();
    _cachedMessages!.removeWhere((m) => m.id == id);
    await _saveScheduledMessages();
    Logs().d('Scheduled message removed: $id');
  }

  /// Get all pending (not yet sent) scheduled messages
  static Future<List<ScheduledMessage>> getPendingMessages() async {
    final messages = await loadScheduledMessages();
    return messages.where((m) => !m.isSent).toList();
  }

  /// Get scheduled messages for a specific room
  static Future<List<ScheduledMessage>> getMessagesForRoom(
    String roomId,
  ) async {
    final messages = await loadScheduledMessages();
    return messages.where((m) => m.roomId == roomId && !m.isSent).toList();
  }

  /// Check and send any messages that are due (within 30 seconds of scheduled time)
  static Future<void> checkAndSendDueMessages(Client client) async {
    final pending = await getPendingMessages();
    final now = DateTime.now();

    for (final message in pending) {
      // Only send messages scheduled within the last 30 seconds
      // This prevents all "missed" messages from being sent at once
      final diff = now.difference(message.scheduledAt);
      if (diff.inSeconds.abs() <= 30) {
        // Message is due now - send it
        await _sendScheduledMessage(client, message);
      } else if (message.scheduledAt.isBefore(now.subtract(const Duration(minutes: 1)))) {
        // Message is more than 1 minute in the past - mark as missed
        Logs().w('Scheduled message ${message.id} is in the past, marking as missed');
        message.isSent = true; // Mark as processed
        await _saveScheduledMessages();
      }
    }
  }

  /// Send a single scheduled message
  static Future<bool> _sendScheduledMessage(
    Client client,
    ScheduledMessage message,
  ) async {
    // Prevent double-sending by marking as sent before async operations
    if (message.isSent) return true;
    message.isSent = true;
    await _saveScheduledMessages();

    try {
      final room = client.getRoomById(message.roomId);
      if (room == null) {
        Logs().e('Room not found for scheduled message: ${message.roomId}');
        await removeScheduledMessage(message.id);
        return false;
      }

      // Send the message based on content type
      final body = message.content['body'] as String? ?? '';
      if (body.isNotEmpty) {
        await room.sendTextEvent(
          body,
          inReplyTo: message.replyEventId != null
              ? await room.getEventById(message.replyEventId!)
              : null,
        );
      } else {
        // Fallback to generic event send
        await room.sendEvent(message.content);
      }

      // Remove from scheduled messages after successful send
      await removeScheduledMessage(message.id);

      Logs().d('Scheduled message sent successfully: ${message.id}');
      return true;
    } catch (e) {
      Logs().e('Failed to send scheduled message: ${message.id}', e);
      // Reset isSent flag on failure so it can be retried
      message.isSent = false;
      await _saveScheduledMessages();
      return false;
    }
  }

  /// Clear the cache (useful after app restart)
  static void clearCache() {
    _cachedMessages = null;
  }
}
