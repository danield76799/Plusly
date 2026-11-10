import 'package:flutter/material.dart';

/// WhatsApp-achtige "staart" onder een berichtbubbel.
///
/// WhatsApp tekent een klein hoekje onder de bubbel, zodat het bericht
/// als een spraakballon leest. Plusly had alleen afgeronde hoeken, wat
/// eerder Telegram-achtig oogde.
///
/// De staart zit **achter** de bubbel: de bubbel zelf tekent zijn
/// hoekradius over de bovenkant van de staart. Zo ontstaat de bekende
/// WhatsApp-vorm zonder dat de bubbel een gat krijgt.
///
/// Geometrie (eigen bericht, staart rechts):
/// - het puntje wijst naar rechts-onder
/// - de bovenzijde loopt in de bubbel weg (die tekent erover)
/// - de onderzijde is een kromme lijn, net als WhatsApp
class BubbleTail extends StatelessWidget {
  /// Kleur van de bubbel; de staart moet exact dezelfde zijn.
  final Color color;

  /// true = eigen bericht (staart rechts-onder), false = van iemand anders.
  final bool ownMessage;

  /// false = de bubbel heeft geen staart (bijv. media zonder bubbel).
  final bool visible;

  const BubbleTail({
    super.key,
    required this.color,
    required this.ownMessage,
    this.visible = true,
  });

  @override
  Widget build(BuildContext context) {
    if (!visible) return const SizedBox.shrink();
    return SizedBox(
      width: 10,
      height: 12,
      child: CustomPaint(
        painter: _BubbleTailPainter(color: color, ownMessage: ownMessage),
      ),
    );
  }
}

class _BubbleTailPainter extends CustomPainter {
  final Color color;
  final bool ownMessage;

  _BubbleTailPainter({required this.color, required this.ownMessage});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;

    // Het staartje is een klein hoekje dat naar buiten wijst:
    // eigen bericht -> rechts-onder, bericht van iemand anders -> links-onder.
    // De bovenkant (y=0) valt onder de bubbel en blijft daarom onzichtbaar.
    final path = Path();
    if (ownMessage) {
      path.moveTo(0, 0);
      path.lineTo(size.width, 0);
      path.lineTo(size.width, size.height * 0.55);
      path.quadraticBezierTo(
        size.width,
        size.height,
        size.width * 0.35,
        size.height,
      );
    } else {
      path.moveTo(size.width, 0);
      path.lineTo(0, 0);
      path.lineTo(0, size.height * 0.55);
      path.quadraticBezierTo(
        0,
        size.height,
        size.width * 0.65,
        size.height,
      );
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_BubbleTailPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.ownMessage != ownMessage;
}
