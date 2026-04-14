import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:matrix/matrix.dart';

/// Service to write recent chats data for the Android home screen widget
class ChatWidgetService {
  static const String _chatDataFileName = 'chat_widget_data.json';
  static const int _maxChats = 6;
  static const int _maxMessageChars = 40;

  /// Get the file where chat data is stored (accessible by widget)
  static Future<File> _getChatDataFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/$_chatDataFileName');
  }

  /// Update the widget with the latest chat data from all rooms
  static Future<void> updateWidgetData(List<Room> rooms) async {
    if (rooms.isEmpty) return;

    // Sort rooms by last event timestamp (most recent first)
    final sortedRooms = List<Room>.from(rooms)
      ..sort((a, b) {
        final aTime = a.lastEvent?.originServerTs ?? DateTime(1970);
        final bTime = b.lastEvent?.originServerTs ?? DateTime(1970);
        return bTime.compareTo(aTime);
      });

    // Take the most recent chats
    final recentRooms = sortedRooms.take(_maxChats);

    final chatData = recentRooms.map((room) {
      final lastEvent = room.lastEvent;
      String lastMessage = '';
      
      if (lastEvent != null) {
        if (lastEvent.type == EventTypes.Message) {
          lastMessage = lastEvent.body;
        } else if (lastEvent.type == EventTypes.Encrypted) {
          lastMessage = '🔒 Encrypted message';
        } else {
          lastMessage = lastEvent.type;
        }
      }
      
      // Truncate message
      if (lastMessage.length > _maxMessageChars) {
        lastMessage = '${lastMessage.substring(0, _maxMessageChars)}…';
      }

      // Get online status (simplified - would need presence data for real online status)
      final isOnline = false; // Default to offline, can be enhanced with presence

      return {
        'chatId': room.id,
        'name': room.getLocalizedDisplayname(),
        'lastMessage': lastMessage,
        'isOnline': isOnline,
      };
    }).toList();

    // Write to a file in the app's documents directory
    final file = await _getChatDataFile();
    await file.writeAsString(jsonEncode(chatData));
  }

  /// Clear the widget data
  static Future<void> clearWidgetData() async {
    try {
      final file = await _getChatDataFile();
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      // Ignore errors when clearing
    }
  }
}
