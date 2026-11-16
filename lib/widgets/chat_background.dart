import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

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

/// De per-chat override uit de JSON-kaart, of null als die er niet/ongeldig is.
/// Een override is 'default', 'none' of een id uit [kChatBackgrounds].
String? _perRoomOverride(String? roomId) {
  if (roomId == null || roomId.isEmpty) return null;
  final raw = AppSettings.chatBackgroundPerRoom.value;
  if (raw.trim().isEmpty) return null;
  try {
    final decoded = jsonDecode(raw);
    if (decoded is! Map) return null;
    final v = decoded[roomId];
    if (v is String && v.isNotEmpty) return v;
  } catch (_) {
    // Kapotte JSON: negeren en terugvallen op de globale instelling.
  }
  return null;
}

/// De ruwe override voor [roomId]: 'default' | 'none' | een ingebouwd id.
String perRoomChatBackground(String roomId) =>
    _perRoomOverride(roomId) ?? 'default';

/// Zet (of wist) de per-chat override. 'default' verwijdert de override,
/// zodat de chat weer de globale instelling volgt.
Future<void> setChatBackgroundForRoom(String roomId, String value) async {
  var map = <String, dynamic>{};
  final raw = AppSettings.chatBackgroundPerRoom.value;
  try {
    final decoded = jsonDecode(raw);
    if (decoded is Map) {
      map = decoded.map((k, v) => MapEntry(k.toString(), v));
    }
  } catch (_) {
    map = <String, dynamic>{};
  }
  if (value == 'default') {
    map.remove(roomId);
  } else {
    map[roomId] = value;
  }
  await AppSettings.chatBackgroundPerRoom.setItem(jsonEncode(map));
}

/// Wat er uiteindelijk getekend moet worden voor [roomId]:
/// 'wallpaper' (eigen foto), 'none', of een ingebouwd id uit [kChatBackgrounds].
/// Eigen foto telt alleen mee als er geen per-chat override is.
String chatBackgroundMode([String? roomId]) {
  final override = _perRoomOverride(roomId);
  if (override != null && override != 'default') {
    return override; // 'none' of een ingebouwd id
  }
  if (AppSettings.wallpaperPath.value.isNotEmpty) return 'wallpaper';
  return AppSettings.chatBackground.value; // 'none' of een ingebouwd id
}

/// True zodra er een achtergrond actief is: een eigen wallpaper (bestand),
/// een ingebouwde achtergrond, of een per-chat afwijking daarvan.
bool hasChatBackground([String? roomId]) => chatBackgroundMode(roomId) != 'none';

/// Ingebouwde chatachtergronden als CustomPainter: contrastrijk en duidelijk
/// herkenbaar, in zowel lichte als donkere modus.
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
              ? const [Color(0xFF241A45), Color(0xFF4A2447), Color(0xFF8A4A3A)]
              : const [Color(0xFFD8B9E8), Color(0xFFE3A8B4), Color(0xFFF2C18F)],
        );
        _radialGlow(canvas, rect,
            center: Offset(size.width * 0.85, size.height * 0.98),
            radius: size.width * 1.0,
            color: const Color(0xFFF2834B).withValues(alpha: isDark ? 0.55 : 0.65));
        _radialGlow(canvas, rect,
            center: Offset(size.width * 0.08, size.height * 0.02),
            radius: size.width * 0.9,
            color: const Color(0xFF6A4FD0).withValues(alpha: isDark ? 0.55 : 0.45));
        break;
      case 'forest':
        _gradient(
          canvas,
          rect,
          isDark
              ? const [Color(0xFF0F2A1E), Color(0xFF16382A), Color(0xFF081E14)]
              : const [Color(0xFFCFE8D2), Color(0xFF9CCFA9), Color(0xFFDFF0E0)],
        );
        // Lichtstralen schuin door het bladerdak
        _diagonalBeams(canvas, size,
            color: const Color(0xFFB7F0C8),
            alpha: isDark ? 0.16 : 0.30);
        _radialGlow(canvas, rect,
            center: Offset(size.width * 0.85, size.height * 0.12),
            radius: size.width * 0.85,
            color: const Color(0xFF3E9E63).withValues(alpha: isDark ? 0.45 : 0.5));
        break;
      case 'ocean':
        _gradient(
          canvas,
          rect,
          isDark
              ? const [Color(0xFF082A44), Color(0xFF0E3F5C), Color(0xFF041B2E)]
              : const [Color(0xFFBCDCEF), Color(0xFF8FC4DE), Color(0xFFE4F2F8)],
        );
        _radialGlow(canvas, rect,
            center: Offset(size.width * 0.15, size.height * 0.15),
            radius: size.width * 0.9,
            color: const Color(0xFF3EC6E8).withValues(alpha: isDark ? 0.5 : 0.55));
        _radialGlow(canvas, rect,
            center: Offset(size.width * 0.9, size.height * 0.85),
            radius: size.width * 0.8,
            color: const Color(0xFF1E6FA8).withValues(alpha: isDark ? 0.5 : 0.4));
        _waves(canvas, size,
            alpha: isDark ? 0.32 : 0.28, amplitude: 11, wavelength: 150);
        break;
      case 'dots':
        canvas.drawRect(
          rect,
          Paint()..color = isDark ? const Color(0xFF1A1E28) : const Color(0xFFEDEFF5),
        );
        _dots(canvas, size);
        break;
      case 'waves':
        canvas.drawRect(
          rect,
          Paint()..color = isDark ? const Color(0xFF121E2E) : const Color(0xFFE3EBF4),
        );
        _waves(canvas, size,
            alpha: isDark ? 0.45 : 0.4, amplitude: 12, wavelength: 110);
        break;
      case 'stars':
        _gradient(
          canvas,
          rect,
          isDark
              ? const [Color(0xFF070B22), Color(0xFF141A3E), Color(0xFF05071A)]
              : const [Color(0xFFC9D4F0), Color(0xFFAEBCE8), Color(0xFFE4E9F7)],
        );
        _radialGlow(canvas, rect,
            center: Offset(size.width * 0.75, size.height * 0.25),
            radius: size.width * 0.75,
            color: const Color(0xFF7A5CFF).withValues(alpha: isDark ? 0.4 : 0.3));
        _radialGlow(canvas, rect,
            center: Offset(size.width * 0.15, size.height * 0.75),
            radius: size.width * 0.7,
            color: const Color(0xFF2EA8A0).withValues(alpha: isDark ? 0.35 : 0.3));
        _stars(canvas, size);
        break;
      case 'lattice':
        canvas.drawRect(
          rect,
          Paint()..color = isDark ? const Color(0xFF1B1A17) : const Color(0xFFF5EFDF),
        );
        _lattice(canvas, size);
        break;
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

  void _diagonalBeams(Canvas canvas, Size size,
      {required Color color, required double alpha}) {
    final paint = Paint()..color = color.withValues(alpha: alpha);
    for (var i = -2; i < 8; i++) {
      final x = size.width * (i / 6.0);
      final path = Path()
        ..moveTo(x, -40)
        ..lineTo(x + size.width * 0.28, -40)
        ..lineTo(x + size.width * 0.28 - size.height * 0.55, size.height + 40)
        ..lineTo(x - size.height * 0.55, size.height + 40)
        ..close();
      canvas.drawPath(path, paint);
    }
  }

  Color get _patternColor =>
      isDark ? Colors.white : const Color(0xFF141B2E);

  void _dots(Canvas canvas, Size size) {
    final paint = Paint()..color = _patternColor.withValues(alpha: isDark ? 0.5 : 0.4);
    const spacing = 22.0;
    for (var y = spacing / 2; y < size.height; y += spacing) {
      for (var x = spacing / 2; x < size.width; x += spacing) {
        canvas.drawCircle(Offset(x, y), 2.3, paint);
      }
    }
  }

  void _waves(Canvas canvas, Size size,
      {required double alpha,
      required double amplitude,
      required double wavelength}) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..color = _patternColor.withValues(alpha: alpha);
    const rowHeight = 42.0;
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
    for (var i = 0; i < 170; i++) {
      final x = rng.nextDouble() * size.width;
      final y = rng.nextDouble() * size.height;
      final r = 0.5 + rng.nextDouble() * 1.7;
      final alpha = 0.35 + rng.nextDouble() * 0.65;
      starPaint.color = Colors.white.withValues(alpha: isDark ? alpha : alpha * 0.5);
      canvas.drawCircle(Offset(x, y), r, starPaint);
    }
    final sparkle = Paint()
      ..color = Colors.white.withValues(alpha: isDark ? 0.9 : 0.4)
      ..strokeWidth = 1.3;
    for (var i = 0; i < 9; i++) {
      final x = rng.nextDouble() * size.width;
      final y = rng.nextDouble() * size.height;
      final s = 2.5 + rng.nextDouble() * 3.0;
      canvas.drawLine(Offset(x - s, y), Offset(x + s, y), sparkle);
      canvas.drawLine(Offset(x, y - s), Offset(x, y + s), sparkle);
    }
  }

  void _lattice(Canvas canvas, Size size) {
    final paint = Paint()
      ..strokeWidth = 1.5
      ..color = _patternColor.withValues(alpha: isDark ? 0.22 : 0.24);
    const spacing = 28.0;
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
          Colors.black.withValues(alpha: isDark ? 0.30 : 0.12),
        ],
        stops: const [0.55, 1.0],
      ).createShader(rect);
    canvas.drawRect(rect, paint);
  }

  @override
  bool shouldRepaint(covariant _BackgroundPainter old) =>
      old.background != background || old.brightness != brightness;
}


/// Luistert naar alle chat-achtergrond-instellingen (globaal, per-chat,
/// wallpaper-pad/opacity/blur) en rendert de juiste laag, zodat een keuze
/// direct zichtbaar is zonder dat de chat opnieuw geopend hoeft te worden.
class ChatBackdrop extends StatelessWidget {
  final String? roomId;
  final double width;
  final double height;

  const ChatBackdrop({
    super.key,
    required this.roomId,
    required this.width,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    final listenable = Listenable.merge([
      AppSettingsNotifier.of(AppSettings.chatBackground.key),
      AppSettingsNotifier.of(AppSettings.chatBackgroundPerRoom.key),
      AppSettingsNotifier.of(AppSettings.wallpaperPath.key),
      AppSettingsNotifier.of(AppSettings.wallpaperOpacity.key),
      AppSettingsNotifier.of(AppSettings.wallpaperBlur.key),
    ]);
    return AnimatedBuilder(
      animation: listenable,
      builder: (context, _) {
        final mode = chatBackgroundMode(roomId);
        if (mode == 'none') return const SizedBox.shrink();
        if (mode == 'wallpaper') {
          final path = AppSettings.wallpaperPath.value;
          if (path.isEmpty) return const SizedBox.shrink();
          return Stack(
            children: [
              Positioned.fill(
                child: ClipRect(
                  child: OverflowBox(
                    alignment: Alignment.topCenter,
                    maxHeight: height,
                    maxWidth: width,
                    child: Opacity(
                      opacity: AppSettings.wallpaperOpacity.value,
                      child: ImageFiltered(
                        imageFilter: ui.ImageFilter.blur(
                          sigmaX: AppSettings.wallpaperBlur.value,
                          sigmaY: AppSettings.wallpaperBlur.value,
                        ),
                        child: Image.file(
                          File(path),
                          fit: BoxFit.cover,
                          height: height,
                          width: width,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              // Leesbaarheids-dim over de wallpaper.
              const Positioned.fill(
                child: ColoredBox(color: Color(0x99000000)),
              ),
            ],
          );
        }
        return Positioned.fill(child: ChatBackground(background: mode));
      },
    );
  }
}
