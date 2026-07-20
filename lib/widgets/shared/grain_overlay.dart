import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

/// Overlay de grain très subtil (opacité 2-3%) pour éviter l'aplat
/// numérique plat sur les cartes.
class GrainOverlay extends StatelessWidget {
  final double opacity;
  final BorderRadius? borderRadius;

  const GrainOverlay({super.key, this.opacity = 0.025, this.borderRadius});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: ClipRRect(
        borderRadius: borderRadius ?? BorderRadius.zero,
        child: Opacity(
          opacity: opacity,
          child: CustomPaint(
            painter: _GrainPainter(),
            size: Size.infinite,
          ),
        ),
      ),
    );
  }
}

class _GrainPainter extends CustomPainter {
  static ui.Image? _cached;

  @override
  void paint(Canvas canvas, Size size) {
    final rnd = Random(7);
    final paint = Paint()..color = Colors.black;
    // Bruit léger : petits points épars plutôt qu'une texture coûteuse.
    for (int i = 0; i < (size.width * size.height / 900).clamp(0, 4000); i++) {
      final dx = rnd.nextDouble() * size.width;
      final dy = rnd.nextDouble() * size.height;
      canvas.drawCircle(Offset(dx, dy), 0.6, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
