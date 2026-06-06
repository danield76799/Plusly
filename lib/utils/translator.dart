import 'package:Pulsly/services/llm_service.dart';

class Translator {
  /// Translate text using the configured LLM provider (Groq/Cerebras).
  static Future<String> translate(
    String text,
    String targetLanguage,
    String _unusedBaseUrl, // kept for backward compat
  ) async {
    if (text.trim().isEmpty) return '';

    final truncated = text.length > 5000 ? text.substring(0, 5000) : text;
    final langName = _languageName(targetLanguage);

    final messages = [
      LlmMessage(
        role: 'system',
        content:
            'You are a translator. Translate the user\'s message to $langName. '
            'Output ONLY the translation, nothing else. No quotes, no explanation.',
      ),
      LlmMessage(role: 'user', content: truncated),
    ];

    return LlmService.sendMessage(messages);
  }

  static String _languageName(String code) {
    const names = {
      'en': 'English',
      'nl': 'Dutch',
      'de': 'German',
      'fr': 'French',
      'es': 'Spanish',
      'it': 'Italian',
      'pt': 'Portuguese',
      'ru': 'Russian',
      'zh': 'Chinese',
      'ja': 'Japanese',
      'ko': 'Korean',
      'ar': 'Arabic',
      'hi': 'Hindi',
      'tr': 'Turkish',
      'pl': 'Polish',
      'sv': 'Swedish',
      'da': 'Danish',
      'fi': 'Finnish',
      'nb': 'Norwegian',
      'ro': 'Romanian',
      'hu': 'Hungarian',
      'cs': 'Czech',
      'el': 'Greek',
      'he': 'Hebrew',
      'th': 'Thai',
      'vi': 'Vietnamese',
      'id': 'Indonesian',
      'uk': 'Ukrainian',
      'sr': 'Serbian',
      'hr': 'Croatian',
      'sk': 'Slovak',
      'sl': 'Slovenian',
      'lt': 'Lithuanian',
      'lv': 'Latvian',
      'et': 'Estonian',
      'bn': 'Bengali',
      'ta': 'Tamil',
      'te': 'Telugu',
      'ka': 'Georgian',
      'ga': 'Irish',
      'eu': 'Basque',
      'gl': 'Galician',
      'ca': 'Catalan',
      'fil': 'Filipino',
      'fa': 'Persian',
      'eo': 'Esperanto',
      'ia': 'Interlingua',
      'ie': 'Interlingue',
    };
    return names[code] ?? code;
  }
}
