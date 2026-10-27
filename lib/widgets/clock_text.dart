import 'dart:async';

import 'package:flutter/material.dart';

/// Een klok met de huidige tijd (HH:MM).
///
/// Staat in de kop van de chatlijst (home) en in de kop van een gesprek.
/// De widget bouwt zichzelf alleen op als de minuut verandert, niet elke
/// seconde de hele kop.
class ClockText extends StatefulWidget {
  final double fontSize;
  final FontWeight fontWeight;
  final Color? color;

  const ClockText({
    this.fontSize = 16,
    this.fontWeight = FontWeight.w600,
    this.color,
    super.key,
  });

  @override
  State<ClockText> createState() => _ClockTextState();
}

class _ClockTextState extends State<ClockText> {
  Timer? _timer;
  String _text = '';

  @override
  void initState() {
    super.initState();
    _update();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _update());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _update() {
    final now = DateTime.now();
    final text =
        '${now.hour.toString().padLeft(2, '0')}:'
        '${now.minute.toString().padLeft(2, '0')}';
    if (text == _text) return;
    if (!mounted) return;
    setState(() => _text = text);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Text(
      _text,
      style: TextStyle(
        fontSize: widget.fontSize,
        fontWeight: widget.fontWeight,
        color: widget.color ?? theme.colorScheme.onSurface,
      ),
    );
  }
}
