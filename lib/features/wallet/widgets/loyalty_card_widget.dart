import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/loyalty_card.dart';
import '../../../widgets/components/gradient_card_surface.dart';
import 'card_face_content.dart';

/// Face d'une carte du wallet — dégradé premium dérivé de l'identité de
/// l'établissement, profondeur et reflet via [GradientCardSurface]. Le
/// contenu (catégorie/nom/mécanique) est délégué à [CardFaceContent],
/// partagé avec l'écran de détail de carte.
///
/// Passe automatiquement en mise en page compacte sous 160px de hauteur
/// (listes, aperçus) pour ne jamais déborder — évite d'avoir à s'en
/// souvenir à chaque site d'appel ; [compact] permet de forcer l'un ou
/// l'autre mode si besoin.
class LoyaltyCardWidget extends StatelessWidget {
  final LoyaltyCard card;
  final double height;
  final bool? compact;

  const LoyaltyCardWidget({
    super.key,
    required this.card,
    this.height = 148,
    this.compact,
  });

  bool get _isDark => card.liningColor.computeLuminance() < 0.45;

  @override
  Widget build(BuildContext context) {
    final textColor = _isDark ? Colors.white : AppColors.ink;
    final isCompact = compact ?? height < 160;

    return GradientCardSurface(
      color: card.liningColor,
      height: height,
      padding:
          EdgeInsets.symmetric(horizontal: 20, vertical: isCompact ? 14 : 18),
      child:
          CardFaceContent(card: card, textColor: textColor, compact: isCompact),
    );
  }
}
