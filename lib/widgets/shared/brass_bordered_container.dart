import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';

/// Conteneur signature : fond porcelaine/sauge, fin liseré laiton,
/// ombre douce et chaude. Utilisé pour encarts, plaques QR, cartons.
class BrassBorderedContainer extends StatelessWidget {
  final Widget child;
  final Color backgroundColor;
  final double radius;
  final EdgeInsetsGeometry padding;
  final bool elevated;
  final double borderOpacity;

  const BrassBorderedContainer({
    super.key,
    required this.child,
    this.backgroundColor = AppColors.porcelaine,
    this.radius = AppRadius.card,
    this.padding = const EdgeInsets.all(16),
    this.elevated = true,
    this.borderOpacity = 0.45,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(
          color: AppColors.laitonLisere(opacity: borderOpacity),
          width: 1,
        ),
        boxShadow: elevated
            ? [
                BoxShadow(
                  color: AppColors.ombreChaude(opacity: 0.10),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ]
            : null,
      ),
      child: child,
    );
  }
}
