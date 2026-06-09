import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class Translator {
  static const Duration _timeout = Duration(seconds: 30);

  // Groq OpenAI-compatible endpoint
  static const String _groqEndpoint = 'https://api.groq.com/openai/v1/chat/completions';
  static const String _model = 'llama-3.1-8b-instant';

  // Provided at build time via:
  //   flutter build apk --dart-define=GROQ_API_KEY=***
  static const String _groqApiKey = String.fromEnvironment('GROQ_API_KEY');

  /// Translate [str] to [targetLanguage] (ISO 639-1 code, e.g. 'nl', 'en', 'de')
  /// using Groq's llama-3.1-8b-instant model. Returns the translated text.
  ///
  /// The [baseUrl] argument is deprecated and ignored — it remains for
  /// backwards compatibility with the previous LibreTranslate call sites.
  static Future<String> translate(
    String str,
    String targetLanguage, [
    String? baseUrl,
  ]) async {
    if (_groqApiKey.isEmpty) {
      throw Exception(
        'Translate: GROQ_API_KEY not provided. Rebuild with '
        '"--dart-define=GROQ_API_KEY=..." or set it in the build pipeline.',
      );
    }
    return _translateGroq(str, targetLanguage);
  }

  static Future<String> _translateGroq(
    String str,
    String targetLanguage,
  ) async {
    debugPrint('Translate via Groq → $targetLanguage');

    // Truncate to keep us comfortably under Groq's TPM limit.
    final input = str.length > 4000 ? str.substring(0, 4000) : str;

    final body = {
      'model': _model,
      'messages': [
        {
          'role': 'system',
          'content':
              'You are a translation engine. Translate the user message to '
              'the target language. Output ONLY the translation — no quotes, '
              'no explanations, no language tags, no preamble.',
        },
        {
          'role': 'user',
          'content': 'Target language: $targetLanguage\n\n$input',
        },
      ],
      'temperature': 0.1,
      'max_tokens': 4000,
    };

    try {
      final response = await http
          .post(
            Uri.parse(_groqEndpoint),
            headers: {
              'Authorization': 'Bearer $_groqApiKey',
              'Content-Type': 'application/json',
            },
            body: jsonEncode(body),
          )
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final text = data['choices']?[0]?['message']?['content'] as String?;
        if (text == null || text.isEmpty) {
          throw Exception('Translate: empty response from Groq');
        }
        return text.trim();
      }
      throw Exception(
        'Translate: Groq error ${response.statusCode} - ${response.body}',
      );
    } on http.ClientException catch (e) {
      throw Exception('Translate network error: $e');
    } catch (e) {
      if (e.toString().contains('TimeoutException')) {
        throw Exception('Translate timeout - try again.');
      }
      rethrow;
    }
  }
}
