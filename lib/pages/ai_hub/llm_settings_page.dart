import 'package:flutter/material.dart';
import 'package:Pulsly/config/setting_keys.dart';
import 'package:Pulsly/services/llm_service.dart';

class LlmSettingsPage extends StatefulWidget {
  const LlmSettingsPage({super.key});

  @override
  State<LlmSettingsPage> createState() => _LlmSettingsPageState();
}

class _LlmSettingsPageState extends State<LlmSettingsPage> {
  late LlmProviderType _selectedProvider;
  final _groqKeyController = TextEditingController();
  final _cerebrasKeyController = TextEditingController();
  final _ollamaUrlController = TextEditingController();
  bool _testing = false;
  bool? _connectionOk;

  @override
  void initState() {
    super.initState();
    _selectedProvider = LlmService.currentProvider;
    _groqKeyController.text = AppSettings.llmGroqApiKey.value;
    _cerebrasKeyController.text = AppSettings.llmCerebrasApiKey.value;
    _ollamaUrlController.text = AppSettings.llmGatewayUrl.value;
  }

  @override
  void dispose() {
    _groqKeyController.dispose();
    _cerebrasKeyController.dispose();
    _ollamaUrlController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    await AppSettings.llmProvider.setItem(_selectedProvider.name);
    await AppSettings.llmGroqApiKey.setItem(_groqKeyController.text.trim());
    await AppSettings.llmCerebrasApiKey
        .setItem(_cerebrasKeyController.text.trim());
    await AppSettings.llmGatewayUrl.setItem(_ollamaUrlController.text.trim());
  }

  Future<void> _testConnection() async {
    setState(() {
      _testing = true;
      _connectionOk = null;
    });

    await _save();
    final ok = await LlmService.ping();

    if (mounted) {
      setState(() {
        _testing = false;
        _connectionOk = ok;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Provider'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Provider selector ─────────────────────────────────
          Text(
            'Provider',
            style: theme.textTheme.titleSmall?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          ...LlmProviderType.values.map((p) {
            final cfg = providerConfigs[p]!;
            return RadioListTile<LlmProviderType>(
              value: p,
              groupValue: _selectedProvider,
              onChanged: (v) {
                if (v != null) setState(() => _selectedProvider = v);
              },
              title: Text(cfg.name),
              subtitle: Text(
                cfg.model,
                style: const TextStyle(fontSize: 12),
              ),
              secondary: cfg.requiresApiKey
                  ? const Icon(Icons.vpn_key, size: 18)
                  : const Icon(Icons.home, size: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            );
          }),

          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 16),

          // ── Provider-specific settings ────────────────────────
          if (_selectedProvider == LlmProviderType.ollama) ...[
            Text(
              'Ollama Server URL',
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _ollamaUrlController,
              decoration: const InputDecoration(
                hintText: 'http://13.140.136.172:11434',
                border: OutlineInputBorder(),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
              keyboardType: TextInputType.url,
            ),
            const SizedBox(height: 8),
            Text(
              'Make sure Ollama is running and accessible from the internet.',
              style: TextStyle(
                fontSize: 12,
                color: theme.colorScheme.outline,
              ),
            ),
          ],

          if (_selectedProvider == LlmProviderType.groq) ...[
            Text(
              'Groq API Key',
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _groqKeyController,
              decoration: const InputDecoration(
                hintText: 'gsk_...',
                border: OutlineInputBorder(),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
              obscureText: true,
              keyboardType: TextInputType.visiblePassword,
            ),
            const SizedBox(height: 8),
            Text(
              'Free tier available at console.groq.com',
              style: TextStyle(
                fontSize: 12,
                color: theme.colorScheme.outline,
              ),
            ),
          ],

          if (_selectedProvider == LlmProviderType.cerebras) ...[
            Text(
              'Cerebras API Key',
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _cerebrasKeyController,
              decoration: const InputDecoration(
                hintText: 'csk-...',
                border: OutlineInputBorder(),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
              obscureText: true,
              keyboardType: TextInputType.visiblePassword,
            ),
            const SizedBox(height: 8),
            Text(
              'Free tier available at cloud.cerebras.ai',
              style: TextStyle(
                fontSize: 12,
                color: theme.colorScheme.outline,
              ),
            ),
          ],

          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 16),

          // ── Test connection ───────────────────────────────────
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _testing ? null : _testConnection,
              icon: _testing
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.wifi_find),
              label: Text(_testing ? 'Testing...' : 'Test Connection'),
            ),
          ),

          if (_connectionOk != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _connectionOk!
                    ? Colors.green.withValues(alpha: 0.1)
                    : Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    _connectionOk! ? Icons.check_circle : Icons.error,
                    color: _connectionOk! ? Colors.green : Colors.red,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _connectionOk!
                        ? 'Connected successfully'
                        : 'Connection failed — check your settings',
                    style: TextStyle(
                      color: _connectionOk! ? Colors.green : Colors.red,
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 24),

          // ── Info card ─────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.info_outline,
                        size: 16, color: theme.colorScheme.outline),
                    const SizedBox(width: 6),
                    Text(
                      'All providers use the OpenAI-compatible API format.',
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.colorScheme.outline,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Ollama runs on your own server — no data leaves your network. '
                  'Groq and Cerebras are cloud services with free tiers.',
                  style: TextStyle(
                    fontSize: 11,
                    color: theme.colorScheme.outline,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
