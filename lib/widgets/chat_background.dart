import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../config/setting_keys.dart';

/// Beschikbare ingebouwde chatachtergronden. `none` betekent: geen
/// achtergrond (de normale effense achtergrond).
const List<String> kChatBackgrounds = <String>[
  'none',
  'dusk',
  'forest',
  'ocean',
  'dots',
  'waves',
  'stars',
  'lattice',
];

/// True zodra er een achtergrond actief is: een eigen wallpaper (bestand)
/// of een ingebouwde achtergrond.
bool hasChatBackground() =>
    AppSettings.wallpaperPath.value.isNotEmpty ||
    AppSettings.chatBackground.value != 'none';

/// Ingebouwde chatachtergronden als CustomPainter: strak, subtiel en
/// zonder schermafbeeldingen. Voor donkere én lichte modus.
class ChatBackground extends StatelessWidget {
  final String background;

  const ChatBackground({super.key, required this.background});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _BackgroundPainter(
        background,
        Theme.of(context).brightness,
      ),
      size: Size.infinite,
    );
  }
}

class _BackgroundPainter extends CustomPainter {
  final String background;
  final Brightness brightness;

  _BackgroundPainter(this.background, this.brightness);

  bool get isDark => brightness == Brightness.dark;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    switch (background) {
      case 'dusk':
        _gradient(
          canvas,
          rect,
          isDark
              ? const [Color(0xFF2B2440), Color(0xFF1B1729), Color(0xFF141B33)]
              : const [Color(0xFFE9DDF0), Color(0xFFD8CDE3), Color(0xFFC9CDE4)],
        );
        _radialGlow(canvas, rect,
            center: Offset(size.width * 0.85, size.height * 0.95),
            radius: size.width * 0.9,
            color: const Color(0xFFE0885A).withValues(alpha: isDark ? 0.28 : 0.35));
        _radialGlow(canvas, rect,
            center: Offset(size.width * 0.1, size.height * 0.08),
            radius: size.width * 0.8,
            color: const Color(0xFF6A5ACD).withValues(alpha: isDark ? 0.30 : 0.25));
      case 'forest':
        _gradient(
          canvas,
          rect,
          isDark
              ? const [Color(0xFF1E3325), Color(0xFF16241B), Color(0xFF0E1A13)]
              : const [Color(0xFFE3EFE2), Color(0xFFCEE0D2), Color(0xFFBAD2C2)],
        );
        _radialGlow(canvas, rect,
            center: Offset(size.width * 0.85, size.height * 0.15),
            radius: size.width * 0.8,
            color: const Color(0xFF3F7D54).withValues(alpha: isDark ? 0.35 : 0.4));
      case 'ocean':
        _gradient(
          canvas,
          rect,
          isDark
              ? const [Color(0xFF17384C), Color(0xFF102A3C), Color(0xFF0B1F2E)]
              : const [Color(0xFFDFEDF5), Color(0xFFC4DDE9), Color(0xFFA9CCDE)],
        );
        _radialGlow(canvas, rect,
            center: Offset(size.width * 0.15, size.height * 0.2),
            radius: size.width * 0.85,
            color: const Color(0xFF2F7A9E).withValues(alpha: isDark ? 0.35 : 0.3));
      case 'dots':
        canvas.drawRect(
          rect,
          Paint()..color = isDark ? const Color(0xFF14181F) : const Color(0xFFF0F3F8),
        );
        _dots(canvas, size);
      case 'waves':
        canvas.drawRect(
          rect,
          Paint()..color = isDark ? const Color(0xFF131A22) : const Color(0xFFEFF3F7),
        );
        _waves(canvas, size);
      case 'stars':
        _gradient(
          canvas,
          rect,
          isDark
              ? const [Color(0xFF0A1026), Color(0xFF131A36), Color(0xFF090D1F)]
              : const [Color(0xFFDFE6F5), Color(0xFFCBD6EC), Color(0xFFB4C3E0)],
        );
        _stars(canvas, size);
      case 'lattice':
        canvas.drawRect(
          rect,
          Paint()..color = isDark ? const Color(0xFF161A1F) : const Color(0xFFF3F1EC),
        );
        _lattice(canvas, size);
      default:
        canvas.drawRect(
          rect,
          Paint()..color = ThemeData().scaffoldBackgroundColor,
        );
    }
    _vignette(canvas, rect);
  }

  void _gradient(Canvas canvas, Rect rect, List<Color> colors) {
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: colors,
      ).createShader(rect);
    canvas.drawRect(rect, paint);
  }

  void _radialGlow(
    Canvas canvas,
    Rect rect, {
    required Offset center,
    required double radius,
    required Color color,
  }) {
    final paint = Paint()
      ..shader = RadialGradient(
        colors: [color, color.withValues(alpha: 0)],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawRect(rect, paint);
  }

  Color get _patternColor => isDark ? Colors.white : const Color(0xFF1F2A44);

  void _dots(Canvas canvas, Size size) {
    final paint = Paint()..color = _patternColor.withValues(alpha: 0.14);
    const spacing = 26.0;
    for (var y = spacing / 2; y < size.height; y += spacing) {
      for (var x = spacing / 2; x < size.width; x += spacing) {
        canvas.drawCircle(Offset(x, y), 1.7, paint);
      }
    }
  }

  void _waves(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..color = _patternColor.withValues(alpha: 0.14);
    const wavelength = 120.0;
    const amplitude = 9.0;
    const rowHeight = 44.0;
    for (var row = -1; row * rowHeight < size.height + rowHeight; row++) {
      final yBase = row * rowHeight + 24;
      final phase = row.isEven ? 0.0 : wavelength / 2;
      final path = Path();
      var x = -10.0;
      path.moveTo(x, yBase + math.sin((x + phase) * 2 * math.pi / wavelength) * amplitude);
      while (x < size.width + 10) {
        x += 6;
        path.lineTo(x, yBase + math.sin((x + phase) * 2 * math.pi / wavelength) * amplitude);
      }
      canvas.drawPath(path, paint);
    }
  }

  void _stars(Canvas canvas, Size size) {
    final rng = math.Random(1234);
    final starPaint = Paint();
    for (var i = 0; i < 130; i++) {
      final x = rng.nextDouble() * size.width;
      final y = rng.nextDouble() * size.height;
      final r = 0.4 + rng.nextDouble() * 1.5;
      final alpha = 0.25 + rng.nextDouble() * 0.75;
      starPaint.color = Colors.white.withValues(alpha: isDark ? alpha : alpha * 0.35);
      canvas.drawCircle(Offset(x, y), r, starPaint);
    }
    // Een paar helderdere "vonkjes" (kruisjes)
    final sparkle = Paint()
      ..color = Colors.white.withValues(alpha: isDark ? 0.8 : 0.3)
      ..strokeWidth = 1.1;
    for (var i = 0; i < 7; i++) {
      final x = rng.nextDouble() * size.width;
      final y = rng.nextDouble() * size.height;
      final s = 2.5 + rng.nextDouble() * 2.5;
      canvas.drawLine(Offset(x - s, y), Offset(x + s, y), sparkle);
      canvas.drawLine(Offset(x, y - s), Offset(x, y + s), sparkle);
    }
  }

  void _lattice(Canvas canvas, Size size) {
    final paint = Paint()
      ..strokeWidth = 1.1
      ..color = _patternColor.withValues(alpha: 0.09);
    const spacing = 30.0;
    final diag = size.width + size.height;
    for (var d = -diag; d < diag * 2; d += spacing) {
      canvas.drawLine(Offset(d, 0), Offset(d + size.height, size.height), paint);
      canvas.drawLine(Offset(d, 0), Offset(d - size.height, size.height), paint);
    }
  }

  void _vignette(Canvas canvas, Rect rect) {
    final paint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(0, -0.15),
        radius: 1.15,
        colors: [
          Colors.transparent,
          Colors.black.withValues(alpha: isDark ? 0.28 : 0.10),
        ],
        stops: const [0.55, 1.0],
      ).createShader(rect);
    canvas.drawRect(rect, paint);
  }

  @override
  bool shouldRepaint(covariant _BackgroundPainter old) =>
      old.background != background || old.brightness != brightness;
}
