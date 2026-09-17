import 'dart:async';

import 'package:flutter/material.dart';

import 'package:matrix/matrix.dart';

import 'package:Pulsly/config/setting_keys.dart';
import 'package:Pulsly/generated/l10n/l10n.dart';
import 'package:Pulsly/services/llm_service.dart';

import 'chat.dart';

/// CometChat-style smart replies: up to three short suggested replies shown
/// as chips above the composer. Generated from the last incoming message
/// (plus a bit of context) via the configured LLM provider
/// (Groq → Cerebras → Ollama fallback chain).
///
/// Design rules:
/// - Only appears for the latest *incoming* text message; typing, sending
///   or clearing the composer hides the chips.
/// - Tapping a chip sends the suggestion directly (no edit round-trip).
/// - E2EE rooms ask once for consent before content leaves the device.
class SmartReplyChips extends StatefulWidget {
  final ChatController controller;

  const SmartReplyChips(this.controller, {super.key});

  @override
  State<SmartReplyChips> createState() => _SmartReplyChipsState();
}

class _SmartReplyChipsState extends State<SmartReplyChips> {
  List<String>? _suggestions;
  List<String>? _cachedSuggestions;
  Event? _generatedFor;
  Timer? _debounce;
  bool _loading = false;
  String? _error;

  bool get _hasContent => _suggestions != null || _error != null || _loading;

  ChatController get controller => widget.controller;
  Timeline? get timeline => controller.timeline;

  @override
  void initState() {
    super.initState();
    controller.sendController.addListener(_onComposerChanged);
    _maybeGenerate();
    // De timeline laadt async; na die load vuurt geen rebuild — dus hier
    // zelf wachten en dan pas genereren. Zonder dit verschijnen de chips
    // pas bij een NIEUW bericht terwijl de chat open staat.
    (controller.loadTimelineFuture ?? Future.value())
        .whenComplete(() => _maybeGenerate());
  }

  @override
  void didUpdateWidget(covariant SmartReplyChips oldWidget) {
    super.didUpdateWidget(oldWidget);
    _maybeGenerate();
  }

  void _onComposerChanged() {
    // Typing/editing suppresses the chips; clearing brings them back.
    if (!mounted) return;
    final hasText = controller.sendController.text.trim().isNotEmpty;
    if (hasText && _suggestions != null) {
      setState(() => _suggestions = null);
    } else if (!hasText && !_loading && _generatedFor != null) {
      // Restore chips for the same event they were generated for.
      setState(() {
        _suggestions = _cachedSuggestions;
      });
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  /// The last real (non-local-echo, non-own) text message in the timeline.
  Event? _latestIncomingTextEvent() {
    final events = timeline?.events;
    if (events == null || events.isEmpty) return null;
    final ownId = controller.room.client.userID;
    for (final event in events.reversed) {
      if (event.status != EventStatus.synced) continue;
      if (event.senderId == ownId) continue;
      final type = event.messageType;
      if (type != MessageTypes.Text && type != MessageTypes.Notice &&
          type != MessageTypes.Emote) {
        continue;
      }
      if (event.isRichMessage) {
        if (event.formattedText.trim().isEmpty) continue;
      } else if (event.text.trim().isEmpty) {
        continue;
      }
      return event;
    }
    return null;
  }

  void _maybeGenerate() {
    if (!AppSettings.llmShowSmartReplies.value) return;
    final event = _latestIncomingTextEvent();
    if (event == null) {
      if (_hasContent) {
        setState(() {
          _suggestions = null;
          _error = null;
          _loading = false;
          _generatedFor = null;
        });
      }
      return;
    }
    if (_generatedFor?.eventId == event.eventId) return;
    if (controller.sendController.text.trim().isNotEmpty ||
        controller.editEvent != null ||
        controller.replyEvent != null) {
      return; // don't fight with an active composer
    }
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 700), () {
      if (!mounted) return;
      _generate(event);
    });
  }

  Future<void> _generate(Event event) async {
    setState(() {
      _loading = true;
      _error = null;
      _suggestions = null;
      _generatedFor = event;
    });
    try {
      // Privacy: in E2EE rooms the content leaves the device unencrypted
      // towards the LLM provider. Ask once per room before doing that.
      if (controller.room.encrypted &&
          !AppSettings.llmEncryptedRoomConsent.value) {
        final l10n = L10n.of(context);
        final proceed = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(l10n.encryptedRoomWarning),
            content: Text(l10n.encryptedRoomAIDescription),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: Text(l10n.cancel),
              ),
              TextButton(
                onPressed: () {
                  AppSettings.llmEncryptedRoomConsent.setItem(true);
                  Navigator.of(ctx).pop(true);
                },
                child: Text(L10n.of(context).ok),
              ),
            ],
          ),
        );
        if (proceed != true) {
          if (mounted) {
            setState(() {
              _loading = false;
              _error = 'consent';
            });
          }
          return;
        }
      }

      // Consent is rond (of was al gegeven) — genereer nu echt.
      final suggestions = await LlmService.generateSmartReplies(event.text);
      if (!mounted) return;
      setState(() {
        _suggestions = suggestions;
        _cachedSuggestions = suggestions;
        _loading = false;
      });
    } catch (e) {
      Logs().w('SmartReplies: generation failed: $e');
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  Future<void> _send(String suggestion) async {
    controller.sendController.text = suggestion;
    await controller.send();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final show = _suggestions != null &&
        _suggestions!.isNotEmpty &&
        controller.sendController.text.trim().isEmpty &&
        controller.editEvent == null &&
        controller.replyEvent == null;
    if (show) {
      return Padding(
        padding: const EdgeInsets.only(left: 8, right: 8, top: 4, bottom: 2),
        child: Row(
          children: [
            for (var i = 0; i < _suggestions!.length; i++) ...[
              if (i > 0) const SizedBox(width: 6),
              Expanded(
                child: ActionChip(
                  label: Text(
                    _suggestions![i],
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  labelStyle: TextStyle(
                    fontSize: 11,
                    color: theme.colorScheme.onSurface,
                  ),
                  backgroundColor: theme
                      .colorScheme.surfaceContainerHighest
                      .withValues(alpha: 0.6),
                  side: BorderSide(
                    color:
                        theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
                  ),
                  onPressed: () => _send(_suggestions![i]),
                ),
              ),
            ],
          ],
        ),
      );
    }
    // Diagnose: als de flow draait maar faalt, laat dat ZIEN (andere
    // fouten dan 'consent' worden als mini-bar getoond — zodat stille
    // failures traceerbaar zijn bij testen).
    if (_error != null && _error != 'consent') {
      return Padding(
        padding: const EdgeInsets.only(left: 12, right: 12, top: 2),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'AI-suggesties: $_error',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.error,
            ),
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }
}