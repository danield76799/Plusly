import 'package:extera_next/generated/l10n/l10n.dart';
import 'package:extera_next/utils/platform_infos.dart';
import 'package:extera_next/utils/url_launcher.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:matrix/matrix.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'package:extera_next/pages/register/register.dart';

class RecaptchaStage extends StatefulWidget {
  final RegisterController controller;

  const RecaptchaStage({required this.controller, super.key});

  @override
  State<RecaptchaStage> createState() => _RecaptchaStageState();
}

class _RecaptchaStageState extends State<RecaptchaStage> {
  WebViewController? _webViewController;
  bool _loading = true;
  bool _completed = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initWebView();
  }

  void _initWebView() {
    if (kIsWeb || PlatformInfos.isDesktop) return;

    final fallbackUrl = widget.controller.getFallbackUrl(
      AuthenticationTypes.recaptcha,
    );

    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.transparent)
      ..addJavaScriptChannel(
        'RecaptchaChannel',
        onMessageReceived: (message) {
          _handleCompletion();
        },
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (_) async {
            if (mounted) setState(() => _loading = false);
            await _injectStyles();
            await _injectMessageListener();
          },
          onNavigationRequest: (request) {
            // The fallback page sometimes navigates to a success URL
            // containing 'authDone' or '/_matrix/client/.../complete'.
            final url = request.url.toLowerCase();
            if (url.contains('authdone') ||
                url.contains('auth/complete') ||
                url.contains('verifycomplete')) {
              _handleCompletion();
              return .prevent;
            }
            return .navigate;
          },
          onWebResourceError: (error) {
            if (!mounted) return;
            if (error.isForMainFrame == false) return;
            setState(() {
              _loading = false;
              _error = L10n.of(context).captchaLoadFailed(error.description);
            });
          },
        ),
      )
      ..loadRequest(fallbackUrl);
  }

  Future<void> _injectStyles() async {
    final controller = _webViewController;
    if (controller == null) return;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bg = isDark ? '#0f0f0f' : 'transparent';
    final fg = isDark ? '#ffffff' : '#1a1a1a';

    const css = r'''
      html, body {
        background: __BG__ !important;
        color: __FG__ !important;
        font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
        margin: 0 !important;
        padding: 16px !important;
        display: flex !important;
        flex-direction: column !important;
        align-items: center !important;
        justify-content: center !important;
        min-height: 100vh !important;
        box-sizing: border-box !important;
      }
      h1, h2, h3, p:not(.recaptcha-text) {
        color: __FG__ !important;
        text-align: center !important;
        max-width: 320px !important;
      }
      .g-recaptcha, #g-recaptcha {
        margin: 16px auto !important;
      }
      input[type=submit], button {
        background: #6750A4 !important;
        color: #ffffff !important;
        border: none !important;
        border-radius: 20px !important;
        padding: 12px 24px !important;
        font-size: 14px !important;
        font-weight: 500 !important;
        cursor: pointer !important;
        margin-top: 16px !important;
      }
    ''';

    final escaped = css
        .replaceAll('__BG__', bg)
        .replaceAll('__FG__', fg)
        .replaceAll('`', r'\`')
        .replaceAll(r'$', r'\$');

    await controller.runJavaScript('''
      (function() {
        var s = document.getElementById('extera-style');
        if (!s) {
          s = document.createElement('style');
          s.id = 'extera-style';
          document.head.appendChild(s);
        }
        s.textContent = `$escaped`;
      })();
    ''');
  }

  Future<void> _injectMessageListener() async {
    final controller = _webViewController;
    if (controller == null) return;
    await controller.runJavaScript(r'''
      (function() {
        if (window.__exteraRecaptchaInstalled) return;
        window.__exteraRecaptchaInstalled = true;
        function notify(reason) {
          try { RecaptchaChannel.postMessage(reason || 'done'); } catch (e) {}
        }
        // 1) postMessage from the auth fallback page.
        window.addEventListener('message', function(e) {
          try {
            var d = e.data;
            if (!d) return;
            if (typeof d === 'string') {
              if (d.indexOf('authDone') !== -1 || d === 'verifyComplete') notify('postmsg-string');
              return;
            }
            if (d.type === 'm.login.recaptcha' || d.type === 'authDone') notify('postmsg-type');
            if (d.session) notify('postmsg-session');
          } catch (err) {}
        });
        // 2) Global onAuthDone hook (Synapse).
        var prev = window.onAuthDone;
        window.onAuthDone = function() {
          if (typeof prev === 'function') { try { prev(); } catch (e) {} }
          notify('onAuthDone');
        };
        // 3) Form submit fallback.
        document.addEventListener('submit', function() {
          setTimeout(function() { notify('submit-timeout'); }, 1500);
        }, true);
        // 4) Poll the page text for "You may now close this window"
        //    in multiple languages — this is what Synapse renders after
        //    a successful captcha submission on the fallback page.
        var phrases = [
          'you may now close this window',
          'now close this window',
          'окно можно закрыть',
          'это окно можно закрыть',
          'теперь это окно',
          'authentication successful',
          'verification successful',
          'аутентификация успешна'
        ];
        function checkText() {
          try {
            var t = (document.body.innerText || '').toLowerCase();
            for (var i = 0; i < phrases.length; i++) {
              if (t.indexOf(phrases[i]) !== -1) {
                notify('text:' + phrases[i]);
                return true;
              }
            }
          } catch (e) {}
          return false;
        }
        // Initial check + periodic polling for 60s.
        if (!checkText()) {
          var ticks = 0;
          var iv = setInterval(function() {
            ticks++;
            if (checkText() || ticks > 120) clearInterval(iv);
          }, 500);
        }
        // 5) Also observe DOM mutations for instant detection.
        try {
          var obs = new MutationObserver(function() { checkText(); });
          obs.observe(document.body, { childList: true, subtree: true, characterData: true });
        } catch (e) {}
      })();
    ''');
  }

  void _handleCompletion() {
    if (_completed || !mounted) return;
    _completed = true;
    widget.controller.completeRecaptchaViaFallback();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline,
                size: 48,
                color: theme.colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: TextStyle(color: theme.colorScheme.error),
              ),
            ],
          ),
        ),
      );
    }

    if (kIsWeb || PlatformInfos.isDesktop) {
      return _FallbackCaptcha(controller: widget.controller);
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            L10n.of(context).pleaseCompleteCaptcha,
            style: theme.textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
        ),
        Expanded(
          child: Stack(
            children: [
              if (_webViewController != null)
                WebViewWidget(controller: _webViewController!),
              if (_loading)
                const Center(child: CircularProgressIndicator.adaptive()),
            ],
          ),
        ),
        if (widget.controller.loading)
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: LinearProgressIndicator(),
          ),
      ],
    );
  }
}

class _FallbackCaptcha extends StatelessWidget {
  final RegisterController controller;

  const _FallbackCaptcha({required this.controller});

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
              Icons.security_outlined,
              size: 48,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              L10n.of(context).completeCaptchaInBrowser,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                final url = controller.getFallbackUrl('m.login.recaptcha');
                controller.completeFallbackStage('m.login.recaptcha');
                UrlLauncher(context, url.toString()).launchUrl();
              },
              icon: const Icon(Icons.open_in_browser),
              label: Text(L10n.of(context).openLinkInBrowser),
            ),
          ],
        ),
      ),
    );
  }
}
