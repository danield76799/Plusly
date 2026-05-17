import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class SavedMessage {
  final String id;
  final String roomId;
  final String sender;
  final String content;
  final DateTime savedAt;

  SavedMessage({
    required this.id,
    required this.roomId,
    required this.sender,
    required this.content,
    required this.savedAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'roomId': roomId,
    'sender': sender,
    'content': content,
    'savedAt': savedAt.toIso8601String(),
  };

  factory SavedMessage.fromJson(Map<String, dynamic> json) => SavedMessage(
    id: json['id'],
    roomId: json['roomId'],
    sender: json['sender'],
    content: json['content'],
    savedAt: DateTime.parse(json['savedAt']),
  );
}

class FavoritesService {
  static const String _key = 'saved_messages';

  static Future<List<SavedMessage>> getFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString(_key);
    if (data == null) return [];
    
    final List<dynamic> jsonList = jsonDecode(data);
    return jsonList.map((e) => SavedMessage.fromJson(e)).toList();
  }

  static Future<void> saveMessage(SavedMessage message) async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = await getFavorites();
    favorites.add(message);
    
    final String data = jsonEncode(favorites.map((e) => e.toJson()).toList());
    await prefs.setString(_key, data);
  }

  static Future<void> removeMessage(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = await getFavorites();
    favorites.removeWhere((msg) => msg.id == id);
    
    final String data = jsonEncode(favorites.map((e) => e.toJson()).toList());
    await prefs.setString(_key, data);
  }

  static Future<List<SavedMessage>> searchFavorites(String query) async {
    final favorites = await getFavorites();
    return favorites.where((msg) => 
      msg.content.toLowerCase().contains(query.toLowerCase()) ||
      msg.sender.toLowerCase().contains(query.toLowerCase())
    ).toList();
  }

  static Future<Map<String, List<SavedMessage>>> getFavoritesByPerson() async {
    final favorites = await getFavorites();
    final Map<String, List<SavedMessage>> result = {};
    
    for (final msg in favorites) {
      if (!result.containsKey(msg.sender)) {
        result[msg.sender] = [];
      }
      result[msg.sender]!.add(msg);
    }
    
    return result;
  }
}
