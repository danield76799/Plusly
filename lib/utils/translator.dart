import 'dart:convert';

import 'package:http/http.dart' as http;

class Translator {
  static const String _deepLApiKey = '24be0b7a-6eba-4bc9-8a28-accc070fa881:fx';

  static Future<String> translate(
    String str,
    String targetLanguage,
    String baseUrl,
  ) async {
    // DeepL API format
    final url = Uri.parse('$baseUrl/v2/translate');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
        'Authorization': 'DeepL-Auth-Key $_deepLApiKey',
      },
      body: {
        'text': str,
        'target_lang': targetLanguage.toUpperCase(),
        'source_lang': 'auto',
      },
    );
    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      return responseData['translations']?[0]?['text'] ?? '';
    } else {
      throw Exception('Failed to translate text: ${response.statusCode}');
    }
  }
}
