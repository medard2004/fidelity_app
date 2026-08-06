import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_shadows.dart';

/// Conteneur de surface unique — remplace `BrassBorderedContainer` et
/// les ~10 conteneurs "carte" dupliqués à la main à travers l'app.
/// Fond blanc, bordure hairline neutre, ombre optionnelle à 1 niveau.
class AppCard extends StatelessWidget {
  final Widget child;
  final Color? backgroundColor;
  final double radius;
  final EdgeInsetsGeometry padding;
  final bool elevated;
  final bool bordered;
  final VoidCallback? onTap;

  const AppCard({
    super.key,
    required this.child,
    this.backgroundColor,
    this.radius = AppRadius.card,
    this.padding = const EdgeInsets.all(16),
    this.elevated = false,
    this.bordered = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final content = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(radius),
        border: bordered ? Border.all(color: AppColors.border) : null,
        boxShadow: elevated ? AppShadows.resting : null,
      ),
      child: child,
    );

    if (onTap == null) return content;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(radius),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(radius),
        child: content,
      ),
    );
  }
}
