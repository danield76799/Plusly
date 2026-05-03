import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:extera_next/config/themes.dart';
import 'package:extera_next/generated/l10n/l10n.dart';
import 'package:extera_next/widgets/app_lock.dart';

const int _pinLength = 4;

class LockScreen extends StatefulWidget {
  const LockScreen({super.key});

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen>
    with SingleTickerProviderStateMixin {
  String _pin = '';
  String? _errorText;
  int _coolDownSeconds = 5;
  bool _inputBlocked = false;
  Timer? _coolDownTimer;
  int _remainingSeconds = 0;

  late final AnimationController _shakeController;
  late final Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _shakeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
    );
  }

  @override
  void dispose() {
    _coolDownTimer?.cancel();
    _shakeController.dispose();
    super.dispose();
  }

  void _onDigitPressed(String digit) {
    if (_inputBlocked) return;
    HapticFeedback.selectionClick();
    if (_pin.length >= _pinLength) return;
    setState(() {
      _pin += digit;
      _errorText = null;
    });
    if (_pin.length == _pinLength) {
      // Slight delay so the user sees the last filled dot
      Future.delayed(const Duration(milliseconds: 120), _tryUnlock);
    }
  }

  void _onBackspacePressed() {
    if (_inputBlocked) return;
    if (_pin.isEmpty) return;
    HapticFeedback.selectionClick();
    setState(() {
      _pin = _pin.substring(0, _pin.length - 1);
      _errorText = null;
    });
  }

  void _tryUnlock() {
    if (_pin.length != _pinLength) {
      setState(() {
        _errorText = L10n.of(context).invalidInput;
        _pin = '';
      });
      _triggerShake();
      return;
    }

    if (AppLock.of(context).unlock(_pin)) {
      setState(() {
        _pin = '';
        _errorText = null;
        _inputBlocked = false;
      });
      return;
    }

    HapticFeedback.heavyImpact();
    _triggerShake();
    setState(() {
      _errorText = L10n.of(context).wrongPinEntered(_coolDownSeconds);
      _inputBlocked = true;
      _remainingSeconds = _coolDownSeconds;
      _pin = '';
    });
    _startCoolDownTicker();
  }

  void _triggerShake() {
    _shakeController.forward(from: 0).then((_) => _shakeController.reset());
  }

  void _startCoolDownTicker() {
    _coolDownTimer?.cancel();
    _coolDownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        _remainingSeconds--;
        if (_remainingSeconds > 0) {
          _errorText = L10n.of(context).wrongPinEntered(_remainingSeconds);
        }
      });
      if (_remainingSeconds <= 0) {
        timer.cancel();
        setState(() {
          _inputBlocked = false;
          _coolDownSeconds *= 2;
          _errorText = null;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: FluffyThemes.columnWidth,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Spacer(),
                  // Lock icon badge
                  Center(
                    child: Container(
                      width: 88,
                      height: 88,
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(28),
                      ),
                      child: Icon(
                        Icons.lock_rounded,
                        size: 44,
                        color: colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    L10n.of(context).pleaseEnterYourPin,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 32),
                  // PIN dots with shake animation
                  AnimatedBuilder(
                    animation: _shakeAnimation,
                    builder: (context, child) {
                      final dx = (_shakeController.isAnimating)
                          ? (8 *
                                (1 - _shakeAnimation.value) *
                                ((_shakeAnimation.value * 6).floor().isEven
                                    ? 1
                                    : -1))
                          : 0.0;
                      return Transform.translate(
                        offset: Offset(dx, 0),
                        child: child,
                      );
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(_pinLength, (index) {
                        final filled = index < _pin.length;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          curve: Curves.easeOut,
                          margin: const EdgeInsets.symmetric(horizontal: 10),
                          width: filled ? 18 : 14,
                          height: filled ? 18 : 14,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: filled
                                ? (_errorText != null
                                      ? colorScheme.error
                                      : colorScheme.primary)
                                : colorScheme.surfaceContainerHighest,
                            border: Border.all(
                              color: filled
                                  ? Colors.transparent
                                  : colorScheme.outlineVariant,
                              width: 1.5,
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Error/cooldown text
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: SizedBox(
                      key: ValueKey(_errorText ?? ''),
                      height: 24,
                      child: Center(
                        child: Text(
                          _errorText ?? '',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.error,
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (_inputBlocked)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 8,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          minHeight: 6,
                          backgroundColor: colorScheme.surfaceContainerHighest,
                        ),
                      ),
                    ),
                  const Spacer(),
                  // Numpad
                  _Numpad(
                    onDigit: _onDigitPressed,
                    onBackspace: _onBackspacePressed,
                    backspaceEnabled: _pin.isNotEmpty && !_inputBlocked,
                    disabled: _inputBlocked,
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Numpad extends StatelessWidget {
  const _Numpad({
    required this.onDigit,
    required this.onBackspace,
    required this.backspaceEnabled,
    required this.disabled,
  });

  final ValueChanged<String> onDigit;
  final VoidCallback onBackspace;
  final bool backspaceEnabled;
  final bool disabled;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Compute a comfortable button size based on available width.
        final maxWidth = constraints.maxWidth;
        const spacing = 12.0;
        final buttonSize = ((maxWidth - spacing * 2) / 3).clamp(56.0, 88.0);

        Widget buildRow(List<Widget> children) => Padding(
          padding: const EdgeInsets.only(bottom: spacing),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (int i = 0; i < children.length; i++) ...[
                if (i > 0) const SizedBox(width: spacing),
                children[i],
              ],
            ],
          ),
        );

        Widget digit(String d) => _NumpadKey(
          size: buttonSize,
          onPressed: disabled ? null : () => onDigit(d),
          child: Text(
            d,
            style: TextStyle(
              fontSize: buttonSize * 0.42,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        );

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            buildRow([digit('1'), digit('2'), digit('3')]),
            buildRow([digit('4'), digit('5'), digit('6')]),
            buildRow([digit('7'), digit('8'), digit('9')]),
            buildRow([
              SizedBox(width: buttonSize, height: buttonSize),
              digit('0'),
              _NumpadKey(
                size: buttonSize,
                onPressed: backspaceEnabled ? onBackspace : null,
                tonal: true,
                child: Icon(
                  Icons.backspace_outlined,
                  size: buttonSize * 0.34,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ]),
          ],
        );
      },
    );
  }
}

class _NumpadKey extends StatefulWidget {
  const _NumpadKey({
    required this.size,
    required this.onPressed,
    required this.child,
    this.tonal = false,
  });

  final double size;
  final VoidCallback? onPressed;
  final Widget child;
  final bool tonal;

  @override
  State<_NumpadKey> createState() => _NumpadKeyState();
}

class _NumpadKeyState extends State<_NumpadKey>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 120),
    reverseDuration: const Duration(milliseconds: 220),
    lowerBound: 0.0,
    upperBound: 1.0,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _setPressed(bool pressed) {
    if (pressed) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final enabled = widget.onPressed != null;
    final baseColor = widget.tonal
        ? colorScheme.secondaryContainer
        : colorScheme.surfaceContainerHigh;
    final pressedColor = widget.tonal
        ? colorScheme.secondary.withValues(alpha: 0.35)
        : colorScheme.primary.withValues(alpha: 0.20);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final t = _controller.value;
        // Scale down slightly + morph radius (Material 3 Expressive feel)
        final scale = 1.0 - 0.06 * t;
        final radius = widget.size * (0.34 - 0.10 * t);
        final color = Color.lerp(baseColor, pressedColor, t)!;

        return Opacity(
          opacity: enabled ? 1.0 : 0.5,
          child: Transform.scale(
            scale: scale,
            child: Material(
              color: color,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(radius),
              ),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: widget.onPressed,
                onTapDown: enabled ? (_) => _setPressed(true) : null,
                onTapUp: enabled ? (_) => _setPressed(false) : null,
                onTapCancel: enabled ? () => _setPressed(false) : null,
                splashFactory: NoSplash.splashFactory,
                highlightColor: Colors.transparent,
                child: SizedBox(
                  width: widget.size,
                  height: widget.size,
                  child: Center(child: widget.child),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
