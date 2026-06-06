import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:Pulsly/config/setting_keys.dart';
import 'package:Pulsly/services/llm_service.dart';
import 'package:Pulsly/pages/ai_hub/llm_settings_page.dart';

class AiHubPage extends StatefulWidget {
  const AiHubPage({super.key});

  @override
  State<AiHubPage> createState() => _AiHubPageState();
}

class _AiHubPageState extends State<AiHubPage> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  final _messages = <LlmMessage>[];
  bool _isLoading = false;
  bool _isConnected = false;

  @override
  void initState() {
    super.initState();
    _checkPrivacyAndConnect();
  }

  Future<void> _checkPrivacyAndConnect() async {
    // Show privacy disclaimer if not accepted yet
    if (!AppSettings.llmPrivacyAccepted.value) {
      await Future.delayed(const Duration(milliseconds: 300));
      if (!mounted) return;
      final accepted = await _showPrivacyDialog();
      if (!accepted) {
        if (mounted) Navigator.of(context).pop();
        return;
      }
      await AppSettings.llmPrivacyAccepted.setItem(true);
    }

    // Enable LLM
    if (!AppSettings.llmEnabled.value) {
      await AppSettings.llmEnabled.setItem(true);
    }

    // Check gateway connection
    _isConnected = await LlmService.ping();
    if (mounted) setState(() {});
  }

  Future<bool> _showPrivacyDialog() async {
    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.auto_awesome, color: Colors.amber),
                SizedBox(width: 8),
                Text('AI Features'),
              ],
            ),
            content: const SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Plusly AI can use a local LLM server (private) or cloud providers (Groq, Cerebras) for smart replies and translations.',
                    style: TextStyle(fontSize: 15),
                  ),
                  SizedBox(height: 12),
                  Text(
                    '⚠️ With cloud providers, your messages are sent to a remote server. '
                    'Plusly local LLM keeps everything on your own server. '
                    'You can change provider at any time in AI settings.',
                    style: TextStyle(fontSize: 13, color: Colors.orange),
                  ),
                  SizedBox(height: 12),
                  Text(
                    'You can disable AI features at any time in Settings.',
                    style: TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Decline'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Accept & Continue'),
              ),
            ],
          ),
        ) ??
        false;
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _isLoading) return;

    _controller.clear();
    setState(() {
      _messages.add(LlmMessage(role: 'user', content: text));
      _isLoading = true;
    });
    _scrollToBottom();

    try {
      final reply = await LlmService.sendMessage(_messages);
      if (mounted) {
        setState(() {
          _messages.add(LlmMessage(role: 'assistant', content: reply));
          _isLoading = false;
        });
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _messages.add(
            LlmMessage(
              role: 'assistant',
              content: '⚠️ Error: ${e.toString().replaceFirst('Exception: ', '')}',
            ),
          );
          _isLoading = false;
        });
        _scrollToBottom();
      }
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _clearChat() {
    setState(() => _messages.clear());
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Assistant'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          if (_messages.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: 'Clear chat',
              onPressed: _clearChat,
            ),
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'AI Settings',
            onPressed: () async {
              await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const LlmSettingsPage(),
                ),
              );
              // Refresh connection after returning from settings
              _isConnected = await LlmService.ping();
              if (mounted) setState(() {});
            },
          ),
          IconButton(
            icon: Icon(
              _isConnected ? Icons.cloud_done : Icons.cloud_off,
              color: _isConnected ? Colors.green : Colors.red,
            ),
            tooltip: _isConnected ? 'Connected' : 'Disconnected',
            onPressed: () async {
              _isConnected = await LlmService.ping();
              if (mounted) setState(() {});
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Connection status banner
          if (!_isConnected)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
              color: theme.colorScheme.errorContainer,
              child: Row(
                children: [
                  Icon(Icons.cloud_off, size: 16, color: theme.colorScheme.error),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${LlmService.providerName} not reachable. Check settings.',
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.colorScheme.onErrorContainer,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Messages
          Expanded(
            child: _messages.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.auto_awesome_outlined,
                          size: 64,
                          color: theme.colorScheme.outline,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Ask me anything',
                          style: TextStyle(
                            fontSize: 18,
                            color: theme.colorScheme.outline,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Powered by ${LlmService.providerName}',
                          style: TextStyle(
                            fontSize: 13,
                            color: theme.colorScheme.outline,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    itemCount: _messages.length + (_isLoading ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == _messages.length) {
                        // Loading indicator
                        return _MessageBubble(
                          message: LlmMessage(
                            role: 'assistant',
                            content: '...',
                          ),
                          isLoading: true,
                        );
                      }
                      return _MessageBubble(
                        message: _messages[index],
                        onCopy: () {
                          Clipboard.setData(
                            ClipboardData(text: _messages[index].content),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Copied to clipboard'),
                              duration: Duration(seconds: 1),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),

          // Input
          Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              border: Border(
                top: BorderSide(color: theme.dividerColor, width: 0.5),
              ),
            ),
            padding: EdgeInsets.only(
              left: 12,
              right: 4,
              top: 8,
              bottom: MediaQuery.of(context).padding.bottom + 8,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Container(
                    constraints: const BoxConstraints(maxHeight: 120),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: TextField(
                      controller: _controller,
                      maxLines: null,
                      textInputAction: TextInputAction.newline,
                      decoration: const InputDecoration(
                        hintText: 'Ask AI...',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                Material(
                  color: theme.colorScheme.primary,
                  shape: const CircleBorder(),
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: _isLoading ? null : _sendMessage,
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Icon(
                        Icons.send,
                        color: theme.colorScheme.onPrimary,
                        size: 20,
                      ),
                    ),
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

class _MessageBubble extends StatelessWidget {
  final LlmMessage message;
  final bool isLoading;
  final VoidCallback? onCopy;

  const _MessageBubble({
    required this.message,
    this.isLoading = false,
    this.onCopy,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isUser = message.role == 'user';

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.8,
        ),
        margin: const EdgeInsets.symmetric(vertical: 4),
        child: GestureDetector(
          onLongPress: onCopy,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isUser
                  ? theme.colorScheme.primary
                  : theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(16),
                topRight: const Radius.circular(16),
                bottomLeft: Radius.circular(isUser ? 16 : 4),
                bottomRight: Radius.circular(isUser ? 4 : 16),
              ),
            ),
            child: isLoading
                ? SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: theme.colorScheme.outline,
                    ),
                  )
                : Text(
                    message.content,
                    style: TextStyle(
                      fontSize: 15,
                      color: isUser
                          ? theme.colorScheme.onPrimary
                          : theme.colorScheme.onSurface,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
