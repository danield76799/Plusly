import 'dart:convert';
import 'package:http/http.dart' as http;

class Translator {
  static const Duration _timeout = Duration(seconds: 30);
  
  
  static Future<String> translate(
    String str,
    String targetLanguage,
    String baseUrl,
  ) async {
    // Always use LibreTranslate, remove DeepL dependency
    return _translateLibreTranslate(str, targetLanguage, baseUrl);
  }
  
  static Future<String> _translateLibreTranslate(
    String str,
    String targetLanguage,
    String baseUrl,
  ) async {
    final uri = Uri.parse('$baseUrl/translate');
    
    final body = {
      'q': str.length > 5000 ? str.substring(0, 5000) : str,
      'source': 'auto',
      'target': targetLanguage,
      'format': 'text',
    };
    
    try {
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      ).timeout(_timeout);
      
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return responseData['translatedText'] ?? '';
      } else {
        throw Exception('LibreTranslate error: ${response.statusCode}');
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