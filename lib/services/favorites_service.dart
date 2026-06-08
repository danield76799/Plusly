import 'dart:convert';
import 'package:matrix/matrix.dart';
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
    id: json['id'] ?? '',
    roomId: json['roomId'] ?? '',
    sender: json['sender'] ?? 'Unknown',
    content: json['content'] ?? '',
    savedAt: DateTime.tryParse(json['savedAt'] ?? '') ?? DateTime.now(),
  );
}

class FavoritesService {
  static const String _key = 'saved_messages';
  static List<SavedMessage> _cache = [];
  static bool _initialized = false;

  static Future<void> _init() async {
    if (_initialized) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? data = prefs.getString(_key);
      if (data != null && data.isNotEmpty) {
        final List<dynamic> jsonList = jsonDecode(data);
        _cache = jsonList.map((e) => SavedMessage.fromJson(e)).toList();
      }
    } catch (e) {
      Logs().e('Favorites init error: $e');
      _cache = [];
    }
    _initialized = true;
  }

  static Future<List<SavedMessage>> getFavorites() async {
    await _init();
    return List.from(_cache);
  }

  static Future<void> saveMessage(SavedMessage message) async {
    await _init();
    _cache.add(message);
    await _persist();
  }

  static Future<void> removeMessage(String id) async {
    await _init();
    _cache.removeWhere((msg) => msg.id == id);
    await _persist();
  }

  static Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String data = jsonEncode(_cache.map((e) => e.toJson()).toList());
      await prefs.setString(_key, data);
    } catch (e) {
      Logs().e('Favorites persist error: $e');
    }
  }

  static Future<List<SavedMessage>> searchFavorites(String query) async {
    final favorites = await getFavorites();
    if (query.isEmpty) return favorites;
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