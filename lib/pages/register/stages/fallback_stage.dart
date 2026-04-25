import 'dart:async';

import 'package:extera_next/generated/l10n/l10n.dart';
import 'package:flutter/material.dart';

import 'package:url_launcher/url_launcher.dart';

import 'package:extera_next/pages/register/register.dart';

class FallbackStage extends StatefulWidget {
  final RegisterController controller;
  final String stageType;

  const FallbackStage({
    required this.controller,
    required this.stageType,
    super.key,
  });

  @override
  State<FallbackStage> createState() => _FallbackStageState();
}

class _FallbackStageState extends State<FallbackStage> {
  bool _opened = false;
  AppLifecycleListener? _listener;
  Completer<void>? _resumeCompleter;

  Future<void> _openFallback() async {
    final url = widget.controller.getFallbackUrl(widget.stageType);
    setState(() => _opened = true);

    _resumeCompleter = Completer<void>();
    _listener = AppLifecycleListener(
      onResume: () {
        if (_resumeCompleter != null && !_resumeCompleter!.isCompleted) {
          _resumeCompleter!.complete();
        }
      },
    );

    await launchUrl(url, mode: LaunchMode.inAppBrowserView);
    await _resumeCompleter!.future;
    _listener?.dispose();
    _listener = null;

    if (!mounted) return;

    // Complete the stage after returning from the browser.
    widget.controller.completeFallbackStage(widget.stageType);
  }

  @override
  void dispose() {
    _listener?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.open_in_browser_outlined,
              size: 48,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              L10n.of(context).additionalVerificationRequired,
              style: theme.textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              L10n.of(context).additionalVerificationText(widget.stageType),
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            if (!_opened) ...[
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                ),
                onPressed: widget.controller.loading ? null : _openFallback,
                icon: const Icon(Icons.open_in_browser),
                label: Text(L10n.of(context).openLinkInBrowser),
              ),
            ] else ...[
              if (widget.controller.loading)
                const CircularProgressIndicator.adaptive()
              else
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                  ),
                  onPressed: () =>
                      widget.controller.completeFallbackStage(widget.stageType),
                  child: Text(L10n.of(context).continueText),
                ),
            ],
          ],
        ),
      ),
    );
  }
}
