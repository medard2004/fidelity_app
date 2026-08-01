import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// Motif de chargement unique de l'app : 3 points à l'opacité respirante,
/// déphasés de 120° pour un effet de cascade continu. Utilisable en ligne
/// (bouton) ou centré (overlay plein écran, écran de démarrage).
class LoadingDots extends StatefulWidget {
  final Color color;
  final double dotSize;

  const LoadingDots({
    super.key,
    this.color = AppColors.encre,
    this.dotSize = 6,
  });

  @override
  State<LoadingDots> createState() => _LoadingDotsState();
}

class _LoadingDotsState extends State<LoadingDots>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            final phase =
                _controller.value * 2 * math.pi - i * (2 * math.pi / 3);
            final opacity = 0.3 + 0.7 * (0.5 + 0.5 * math.sin(phase));
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: widget.dotSize * 0.4),
              child: Opacity(
                opacity: opacity,
                child: Container(
                  width: widget.dotSize,
                  height: widget.dotSize,
                  decoration: BoxDecoration(
                    color: widget.color,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
