import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:Pulsly/config/setting_keys.dart';

class LlmMessage {
  final String role; // 'user' or 'assistant'
  final String content;
  final DateTime timestamp;

  LlmMessage({
    required this.role,
    required this.content,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, String> toApi() => {'role': role, 'content': content};
}

class LlmService {
  static String get _baseUrl => AppSettings.llmGatewayUrl.value;
  static bool get isEnabled => AppSettings.llmEnabled.value;

  /// Send a chat completion request and return the assistant's reply.
  static Future<String> sendMessage(List<LlmMessage> history) async {
    final url = Uri.parse('$_baseUrl/v1/chat/completions');
    final body = jsonEncode({
      'model': 'default',
      'messages': history.map((m) => m.toApi()).toList(),
      'stream': false,
    });

    final response = await http
        .post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: body,
        )
        .timeout(const Duration(seconds: 30));

    if (response.statusCode != 200) {
      throw Exception('Gateway error ${response.statusCode}: ${response.body}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final choices = data['choices'] as List<dynamic>;
    if (choices.isEmpty) throw Exception('Empty response from gateway');
    return choices[0]['message']['content'] as String;
  }

  /// Check if the gateway is reachable.
  static Future<bool> ping() async {
    try {
      final url = Uri.parse('$_baseUrl/v1/models');
      final response =
          await http.get(url).timeout(const Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}
