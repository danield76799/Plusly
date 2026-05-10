import 'dart:convert';

import 'package:http/http.dart' as http;

class Translator {
  static Future<String> translate(
    String str,
    String targetLanguage,
    String baseUrl,
  ) async {
    // LibreTranslate API format
    final url = Uri.parse('$baseUrl/translate');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'q': str,
        'source': 'auto',
        'target': targetLanguage,
        'format': 'text',
      }),
    );
    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      return responseData['translatedText'] ?? '';
    } else {
      throw Exception('Failed to translate text: ${response.statusCode}');
    }
  }
}
