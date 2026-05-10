import 'dart:convert';
import 'package:http/http.dart' as http;

class Translator {
  static const Duration _timeout = Duration(seconds: 15);
  
  // Hardcoded DeepL API key for testing
  static const String _apiKey = '24be0b7a-6eba-4bc9-8a28-accc070fa881:fx';
  
  static Future<String> translate(
    String str,
    String targetLanguage,
    String baseUrl,
  ) async {
    final uri = Uri.parse('$baseUrl/v2/translate');
    
    try {
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Authorization': 'DeepL-Auth-Key $_apiKey',
        },
        body: {
          'text': str.length > 5000 ? str.substring(0, 5000) : str,
          'target_lang': targetLanguage.toUpperCase(),
          'source_lang': 'auto',
        },
      ).timeout(_timeout);
      
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return responseData['translations']?[0]?['text'] ?? '';
      } else if (response.statusCode == 403) {
        throw Exception('Invalid DeepL API key');
      } else if (response.statusCode == 429) {
        throw Exception('DeepL rate limit exceeded. Try again later.');
      } else {
        throw Exception('DeepL API error: ${response.statusCode}');
      }
    } on http.ClientException catch (e) {
      throw Exception('Network error during translation: $e');
    } catch (e) {
      if (e.toString().contains('TimeoutException')) {
        throw Exception('Translation timeout - DeepL may be slow. Try again.');
      }
      rethrow;
    }
  }
}