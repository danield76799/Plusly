import 'dart:convert';
import 'package:http/http.dart' as http;

class Translator {
  static const Duration _timeout = Duration(seconds: 15);
  
  // DeepL API key (free tier)
  static const String _apiKey = '24be0b7a-6eba-4bc9-8a28-accc070fa881:fx';
  
  static Future<String> translate(
    String str,
    String targetLanguage,
    String baseUrl,
  ) async {
    // Build full URL ensuring /v2/translate
    String fullUrl = baseUrl;
    if (!fullUrl.endsWith('/v2/translate')) {
      fullUrl = fullUrl.endsWith('/') 
        ? '${fullUrl}v2/translate' 
        : '$fullUrl/v2/translate';
    }
    
    final uri = Uri.parse(fullUrl);
    
    // Build request body - no source_lang for free tier (auto-detect is built-in)
    final body = {
      'text': str.length > 5000 ? str.substring(0, 5000) : str,
      'target_lang': targetLanguage.toUpperCase(),
    };
    
    try {
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Authorization': 'DeepL-Auth-Key $_apiKey',
        },
        body: body,
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
        throw Exception('Translation timeout - try again.');
      }
      rethrow;
    }
  }
}