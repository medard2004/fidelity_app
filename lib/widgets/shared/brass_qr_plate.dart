import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

/// Le QR code est présenté comme une plaque insérée : encadré laiton,
/// fond porcelaine pur même à l'intérieur d'une carte à doublure sombre,
/// pour rester parfaitement scannable.
class BrassQrPlate extends StatelessWidget {
  final String data;
  final double size;

  const BrassQrPlate({super.key, required this.data, this.size = 190});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.porcelaine,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.laitonBrosse, width: 1.4),
      ),
      child: SizedBox(
        width: size,
        height: size,
        child: CustomPaint(painter: _MockQrPainter(seed: data)),
      ),
    );
  }
}

/// QR mock — un motif déterministe basé sur [seed], suffisant pour la
/// démonstration visuelle sans dépendance externe de génération QR.
class _MockQrPainter extends CustomPainter {
  final String seed;
  _MockQrPainter({required this.seed});

  @override
  void paint(Canvas canvas, Size size) {
    const grid = 21;
    final cell = size.width / grid;
    final paint = Paint()..color = AppColors.encre;
    int hash = seed.codeUnits.fold(0, (a, b) => a * 31 + b);

    for (int y = 0; y < grid; y++) {
      for (int x = 0; x < grid; x++) {
        hash = (hash * 1103515245 + 12345) & 0x7fffffff;
        final onFinder = (x < 7 && y < 7) ||
            (x > grid - 8 && y < 7) ||
            (x < 7 && y > grid - 8);
        final on = onFinder ? _finderPattern(x % 7, y % 7) : (hash % 5 == 0);
        if (on) {
          canvas.drawRect(
            Rect.fromLTWH(x * cell, y * cell, cell * 0.92, cell * 0.92),
            paint,
          );
        }
      }
    }
  }

  bool _finderPattern(int x, int y) {
    if (x == 0 || x == 6 || y == 0 || y == 6) return true;
    if (x >= 2 && x <= 4 && y >= 2 && y <= 4) return true;
    return false;
  }

  @override
  bool shouldRepaint(covariant _MockQrPainter oldDelegate) =>
      oldDelegate.seed != seed;
}

class FallbackIdRow extends StatelessWidget {
  final String fallbackId;
  final VoidCallback onCopy;
  const FallbackIdRow({super.key, required this.fallbackId, required this.onCopy});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(fallbackId, style: AppTextStyles.monoSmall()),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: onCopy,
          child: const Icon(Icons.copy_outlined, size: 14, color: AppColors.laitonBrosse),
        ),
      ],
    );
  }
}
