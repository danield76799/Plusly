import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Depth of the inward "notch" carved into the inner side of a middle bubble.
const double kNotchDepth = 12.0;

/// Position of a bubble within a consecutive run from the same sender.
class StackedBubbleShape {
  final bool isOwn;
  final bool isFirst;
  final bool isLast;

  const StackedBubbleShape({
    required this.isOwn,
    required this.isFirst,
    required this.isLast,
  });
}

/// Paints the "eigenwijze" stacked chat bubble:
/// - first bubble: a sharp tail on the OUTER top corner
/// - middle bubbles: straight outer side (melts into the next), and a concave
///   notch on the INNER side to emphasise the run
/// - last bubble: a clean rounded outer bottom corner
///
/// `isOwn == true` flips the geometry so the inner side is on the left.
class StackedBubblePainter extends CustomPainter {
  final Color color;
  final StackedBubbleShape shape;
  final double tailRadius;
  final double round;
  final double notchDepth;

  const StackedBubblePainter({
    required this.color,
    required this.shape,
    this.tailRadius = 4,
    this.round = 14,
    this.notchDepth = kNotchDepth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final path = _buildPath(size);
    canvas.drawPath(path, Paint()..color = color);
  }

  Path _buildPath(Size size) {
    final w = size.width;
    final h = size.height;
    final own = shape.isOwn;
    final first = shape.isFirst;
    final last = shape.isLast;

    // Mirror helper: for outgoing bubbles the inner side is on the left.
    double x(double v) => own ? w - v : v;

    final topOuter = first ? tailRadius : 0.0;
    final bottomOuter = last ? round : 0.0;
    final topInner = round;
    final bottomInner = last ? round : 0.0;

    final mid = h / 2;
    final notch = math.min(notchDepth, h / 2 - 2);
    final hasNotch = !first && !last && h >= 2 * notch + 4;

    final p = Path();
    // start outer-top
    p.moveTo(x(0), topOuter);
    if (first) {
      // sharp tail on the outer top corner
      p.quadraticBezierTo(x(0), 0, x(topOuter), 0);
    } else {
      p.lineTo(x(0), 0);
    }
    // to inner-top (rounded)
    p.lineTo(x(w - topInner), 0);
    p.quadraticBezierTo(x(w), 0, x(w), topInner);

    // inner side: concave notch for the middle bubbles
    if (hasNotch) {
      p.lineTo(x(w), mid + notch);
      p.quadraticBezierTo(x(w - notchDepth), mid, x(w), mid - notch);
      p.lineTo(x(w), bottomInner);
    } else {
      p.lineTo(x(w), bottomInner);
    }

    // outer-bottom
    if (last) {
      p.quadraticBezierTo(x(w), h, x(w - bottomOuter), h);
    } else {
      p.lineTo(x(w), h);
    }
    p.lineTo(x(bottomOuter), h);
    if (last) {
      p.quadraticBezierTo(x(0), h, x(0), h - bottomOuter);
    } else {
      p.lineTo(x(0), h);
    }
    p.lineTo(x(0), topOuter);
    return p;
  }

  @override
  bool shouldRepaint(covariant StackedBubblePainter old) =>
      old.color != color ||
      old.shape.isOwn != shape.isOwn ||
      old.shape.isFirst != shape.isFirst ||
      old.shape.isLast != shape.isLast ||
      old.notchDepth != notchDepth;
}
