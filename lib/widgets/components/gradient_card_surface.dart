import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_shadows.dart';

/// Surface premium partagée par toutes les cartes de fidélité et leurs
/// aperçus (pile Wallet, détail, confirmation d'inscription, illustration
/// d'onboarding) : dégradé dérivé de la couleur d'identité de
/// l'établissement, ombre teintée douce et diffuse, reflet diagonal
/// discret et liseré interne clair — un seul point d'implémentation pour
/// garder toutes les cartes visuellement cohérentes. Rayon plus généreux
/// que [AppRadius.card] (utilisé par le reste de l'app) : ces cartes
/// jouent un rôle plus « objet physique » qui appelle des coins plus doux.
class GradientCardSurface extends StatelessWidget {
  static const double defaultRadius = 28;

  final Color color;
  final Widget child;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final double? width;
  final double? height;

  const GradientCardSurface({
    super.key,
    required this.color,
    required this.child,
    this.borderRadius = defaultRadius,
    this.padding,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: AppColors.cardGradient(color),
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
        boxShadow: AppShadows.card(color),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Stack(
          fit: StackFit.passthrough,
          children: [
            // Reflet diagonal — simule un fin balayage de lumière plutôt
            // qu'un simple assombrissement de coin, pour une transition
            // fluide ; opacité toujours très faible, ne couvre jamais
            // le contenu.
            const Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment(-1.0, -1.0),
                    end: Alignment(1.0, 1.0),
                    colors: [
                      Color(0x24FFFFFF),
                      Color(0x0DFFFFFF),
                      Color(0x00FFFFFF),
                    ],
                    stops: [0.0, 0.28, 0.55],
                  ),
                ),
              ),
            ),
            Padding(
              padding: padding ?? EdgeInsets.zero,
              child: child,
            ),
          ],
        ),
      ),
    );
  }
}
