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

/// Supported LLM providers.
enum LlmProviderType {
  groq,
  cerebras,
  ollama,
}

/// Configuration for a single LLM provider.
class LlmProviderConfig {
  final String name;
  final String baseUrl;
  final String model;
  final String apiKey; // empty = no auth needed
  final Map<String, dynamic> extraBody; // provider-specific body params

  const LlmProviderConfig({
    required this.name,
    required this.baseUrl,
    required this.model,
    this.apiKey = '',
    this.extraBody = const {},
  });
}

// WARNING: These keys are embedded in the compiled APK binary.
// Anyone decompiling the APK can extract them. For production,
// consider a server-side proxy or per-user keys.
// ── API keys injected at build time via --dart-define ──────────────
const _groqKey = String.fromEnvironment('GROQ_API_KEY');
const _cerebrasKey = String.fromEnvironment('CEREBRAS_API_KEY');
const _ollamaKey = String.fromEnvironment('OLLAMA_API_KEY');

/// Provider definitions. All expose an OpenAI-compatible
/// `/v1/chat/completions` endpoint, so the request format is identical.
Map<LlmProviderType, LlmProviderConfig> get providerConfigs => {
  LlmProviderType.groq: LlmProviderConfig(
    name: 'Groq (Cloud)',
    baseUrl: 'https://api.groq.com/openai',
    model: 'llama-3.1-8b-instant',
    apiKey: _groqKey,
  ),
  LlmProviderType.cerebras: LlmProviderConfig(
    name: 'Cerebras (Cloud)',
    baseUrl: 'https://api.cerebras.ai',
    model: 'gpt-oss-120b',
    apiKey: _cerebrasKey,
  ),
  LlmProviderType.ollama: LlmProviderConfig(
    name: 'Ollama Cloud',
    baseUrl: 'https://ollama.com',
    model: 'gemma3:4b',
    apiKey: _ollamaKey,
  ),
};

class LlmService {
  // ── Fallback notification ────────────────────────────────────────
  /// Set to a message when fallback was used, cleared on next request.
  static String? lastFallbackMessage;

  // ── Provider resolution ──────────────────────────────────────────────

  static LlmProviderType get currentProvider {
    final raw = AppSettings.llmProvider.value;
    return LlmProviderType.values.firstWhere(
      (p) => p.name == raw,
      orElse: () => LlmProviderType.groq,
    );
  }

  static LlmProviderConfig get _config =>
      providerConfigs[currentProvider]!;

  static String get _baseUrl => _config.baseUrl;

  static bool get isEnabled => AppSettings.llmEnabled.value;

  static String get providerName => _config.name;

  static String get _apiKey => _config.apiKey;

  // ── Chat ─────────────────────────────────────────────────────────────

  /// Send a chat completion request and return the assistant's reply.
  /// Automatically falls back: Groq → Cerebras → Kimi.
  static Future<String> sendMessage(List<LlmMessage> history) async {
    lastFallbackMessage = null;
    final primary = currentProvider;

    // Build fallback chain: primary first, then others in order
    final allProviders = LlmProviderType.values;
    final chain = <LlmProviderType>[primary];
    for (final p in allProviders) {
      if (p != primary) chain.add(p);
    }

    Exception? lastError;
    for (final provider in chain) {
      final config = providerConfigs[provider]!;
      if (config.apiKey.isEmpty) continue; // skip unconfigured
      try {
        final result = await _sendToProvider(config, history);
        // Notify if we fell back to a different provider
        if (provider != primary) {
          lastFallbackMessage =
              'Switched to ${config.name} (${primary.name} unavailable)';
        }
        return result;
      } catch (e) {
        lastError = e is Exception ? e : Exception(e.toString());
        continue;
      }
    }
    // All providers failed — give a clear error
    final errorMsg = lastError?.toString() ?? 'Unknown error';
    if (errorMsg.contains('429') || errorMsg.toLowerCase().contains('rate')) {
      throw Exception('Daily limit reached. Try again tomorrow.');
    }
    if (errorMsg.contains('401') || errorMsg.contains('403')) {
      throw Exception('API key invalid or expired.');
    }
    throw lastError ?? Exception('All providers failed');
  }

  static Future<String> _sendToProvider(
    LlmProviderConfig config,
    List<LlmMessage> history,
  ) async {
    final url = Uri.parse('${config.baseUrl}/v1/chat/completions');

    final headers = <String, String>{
      'Content-Type': 'application/json',
    };
    if (config.apiKey.isNotEmpty) {
      headers['Authorization'] = 'Bearer ${config.apiKey}';
    }

    final body = jsonEncode({
      'model': config.model,
      'messages': history.map((m) => m.toApi()).toList(),
      'stream': false,
      ...config.extraBody,
    });

    final response = await http
        .post(url, headers: headers, body: body)
        .timeout(const Duration(seconds: 60));

    if (response.statusCode != 200) {
      throw Exception('LLM error ${response.statusCode}: ${response.body}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final choices = data['choices'] as List<dynamic>;
    if (choices.isEmpty) throw Exception('Empty response from LLM');
    return choices[0]['message']['content'] as String;
  }

  // ── Connectivity ─────────────────────────────────────────────────────

  /// Check if the current provider is reachable.
  static Future<bool> ping() async {
    try {
      final url = Uri.parse('${_config.baseUrl}/v1/models');

      final headers = <String, String>{};
      if (_config.apiKey.isNotEmpty) {
        headers['Authorization'] = 'Bearer ${_config.apiKey}';
      }

      final response = await http
          .get(url, headers: headers)
          .timeout(const Duration(seconds: 8));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}
