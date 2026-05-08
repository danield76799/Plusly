import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// Optimized bubble background that caches the gradient shader
/// and minimizes repaints during scrolling.
class BubbleBackgroundOptimized extends StatelessWidget {
  final List<Color> colors;
  final bool ignore;
  final Widget child;
  final ScrollController? scrollController;

  const BubbleBackgroundOptimized({
    super.key,
    required this.colors,
    required this.ignore,
    required this.child,
    this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    if (ignore) return child;
    return RepaintBoundary(
      child: CustomPaint(
        painter: BubblePainterOptimized(
          repaint: scrollController,
          colors: colors,
          context: context,
        ),
        child: child,
      ),
    );
  }
}

class BubblePainterOptimized extends CustomPainter {
  final BuildContext context;
  final List<Color> colors;
  ui.Shader? _cachedShader;
  Size? _lastSize;
  ScrollableState? _scrollable;

  BubblePainterOptimized({
    required this.context,
    required this.colors,
    required super.repaint,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Only recalculate shader if size changed
    if (_cachedShader == null || _lastSize != size) {
      _lastSize = size;
      _cachedShader = _createShader(size);
    }

    if (_cachedShader != null) {
      canvas.drawRect(
        Offset.zero & size,
        Paint()..shader = _cachedShader,
      );
    }
  }

  ui.Shader? _createShader(Size size) {
    final scrollable = _scrollable ??= Scrollable.of(context);
    final scrollableBox = scrollable.context.findRenderObject() as RenderBox;
    final scrollableRect = Offset.zero & scrollableBox.size;
    final bubbleBox = context.findRenderObject() as RenderBox;

    final origin = bubbleBox.localToGlobal(
      Offset.zero,
      ancestor: scrollableBox,
    );

    return ui.Gradient.linear(
      scrollableRect.topCenter,
      scrollableRect.bottomCenter,
      colors,
      [0.0, 1.0],
      TileMode.clamp,
      Matrix4.translationValues(-origin.dx, -origin.dy, 0.0).storage,
    );
  }

  @override
  bool shouldRepaint(BubblePainterOptimized oldDelegate) {
    // Only repaint if colors changed or scroll position significantly changed
    if (oldDelegate.colors != colors) return true;

    final scrollable = Scrollable.of(context);
    final oldScrollable = _scrollable;
    _scrollable = scrollable;

    // Use a threshold to avoid repainting on every small scroll change
    final oldPosition = oldScrollable?.position.pixels ?? 0;
    final newPosition = scrollable.position.pixels;
    return (newPosition - oldPosition).abs() > 10; // 10px threshold
  }
}
