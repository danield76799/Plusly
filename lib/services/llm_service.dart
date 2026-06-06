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
  ollama,
  groq,
  cerebras,
}

/// Configuration for a single LLM provider.
class LlmProviderConfig {
  final String name;
  final String baseUrl;
  final String model;
  final String apiKey; // empty = no auth needed

  const LlmProviderConfig({
    required this.name,
    required this.baseUrl,
    required this.model,
    this.apiKey = '',
  });
}

// ── API keys injected at build time via --dart-define ──────────────
const _groqKey = String.fromEnvironment('GROQ_API_KEY');
const _cerebrasKey = String.fromEnvironment('CEREBRAS_API_KEY');

/// Provider definitions. All three expose an OpenAI-compatible
/// `/v1/chat/completions` endpoint, so the request format is identical.
Map<LlmProviderType, LlmProviderConfig> get providerConfigs => {
  LlmProviderType.ollama: const LlmProviderConfig(
    name: 'Plusly local LLM (private but slower)',
    baseUrl: '', // overridden by settings llmGatewayUrl
    model: 'qwen3.5:4b',
  ),
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
};

class LlmService {
  // ── Provider resolution ──────────────────────────────────────────────

  static LlmProviderType get currentProvider {
    final raw = AppSettings.llmProvider.value;
    return LlmProviderType.values.firstWhere(
      (p) => p.name == raw,
      orElse: () => LlmProviderType.ollama,
    );
  }

  static LlmProviderConfig get _config =>
      providerConfigs[currentProvider]!;

  /// Effective base URL: Ollama uses the user-configured gateway URL,
  /// cloud providers use their hardcoded endpoint.
  static String get _baseUrl {
    if (currentProvider == LlmProviderType.ollama) {
      return AppSettings.llmGatewayUrl.value;
    }
    return _config.baseUrl;
  }

  static bool get isEnabled => AppSettings.llmEnabled.value;

  static String get providerName => _config.name;

  static String get _apiKey => _config.apiKey;

  // ── Chat ─────────────────────────────────────────────────────────────

  /// Send a chat completion request and return the assistant's reply.
  /// Automatically falls back from Groq → Cerebras on failure.
  static Future<String> sendMessage(List<LlmMessage> history) async {
    final primary = currentProvider;
    // Build fallback chain: primary first, then the other cloud provider
    final chain = <LlmProviderType>[primary];
    if (primary == LlmProviderType.groq) {
      chain.add(LlmProviderType.cerebras);
    } else if (primary == LlmProviderType.cerebras) {
      chain.add(LlmProviderType.groq);
    }

    Exception? lastError;
    for (final provider in chain) {
      final config = providerConfigs[provider]!;
      try {
        return await _sendToProvider(config, history);
      } catch (e) {
        lastError = e is Exception ? e : Exception(e.toString());
        // If this was the last provider in chain, rethrow
        if (provider == chain.last) break;
        // Otherwise try next provider
        continue;
      }
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
