import 'package:flutter/material.dart';
import 'package:Pulsly/config/setting_keys.dart';
import 'package:Pulsly/services/llm_service.dart';
import 'package:Pulsly/generated/l10n/l10n.dart';

class LlmSettingsPage extends StatefulWidget {
  const LlmSettingsPage({super.key});

  @override
  State<LlmSettingsPage> createState() => _LlmSettingsPageState();
}

class _LlmSettingsPageState extends State<LlmSettingsPage> {
  late LlmProviderType _selectedProvider;
  bool _testing = false;
  bool? _connectionOk;

  @override
  void initState() {
    super.initState();
    _selectedProvider = LlmService.currentProvider;
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _save() async {
    await AppSettings.llmProvider.setItem(_selectedProvider.name);
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
        title: Text(L10n.of(context).aiSettings),
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
            L10n.of(context).aiProvider,
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
              secondary: const Icon(Icons.cloud, size: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            );
          }),

          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 16),

          // ── Cloud provider info ───────────────────────────────
          Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.cloud_done, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      L10n.of(context).aiProviderReady(providerConfigs[_selectedProvider]!.name),
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),

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
              label: Text(_testing ? '...' : L10n.of(context).testConnection),
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
                        ? L10n.of(context).connectedSuccessfully
                        : L10n.of(context).connectionFailed,
                    style: TextStyle(
                      color: _connectionOk! ? Colors.green : Colors.red,
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 16),

          // ── Revoke privacy consent ───────────────────────────
          if (AppSettings.llmPrivacyAccepted.value)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: Text(L10n.of(context).revokeConsent),
                      content: Text(L10n.of(context).revokeConsentDescription),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(ctx).pop(false),
                          child: Text(L10n.of(context).cancel),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(ctx).pop(true),
                          child: Text(L10n.of(context).ok),
                        ),
                      ],
                    ),
                  );
                  if (confirm == true && context.mounted) {
                    await AppSettings.llmPrivacyAccepted.setItem(false);
                    await AppSettings.llmEnabled.setItem(false);
                    if (context.mounted) {
                      Navigator.of(context).pop();
                    }
                  }
                },
                icon: const Icon(Icons.privacy_tip_outlined, size: 18),
                label: Text(L10n.of(context).revokeConsent),
                style: OutlinedButton.styleFrom(
                  foregroundColor: theme.colorScheme.error,
                ),
              ),
            ),

          const SizedBox(height: 24),

          // ── Info ──────────────────────────────────────────────
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
                    Expanded(
                      child: Text(
                        L10n.of(context).aiFreeTierInfo,
                        style: TextStyle(
                          fontSize: 12,
                          color: theme.colorScheme.outline,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
