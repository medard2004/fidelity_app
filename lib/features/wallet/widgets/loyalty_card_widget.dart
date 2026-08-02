import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../models/loyalty_card.dart';
import 'card_face_content.dart';

/// Face d'une carte du wallet — surface plate, coins généreux,
/// ombre neutre. Le contenu (catégorie/nom/mécanique) est délégué à
/// [CardFaceContent], partagé avec l'écran de détail de carte.
class LoyaltyCardWidget extends StatelessWidget {
  final LoyaltyCard card;
  final double height;

  const LoyaltyCardWidget({super.key, required this.card, this.height = 190});

  bool get _isDark => card.liningColor.computeLuminance() < 0.45;

  @override
  Widget build(BuildContext context) {
    final textColor = _isDark ? Colors.white : AppColors.ink;

    return Container(
      height: height,
      decoration: BoxDecoration(
        color: card.liningColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppShadows.raised,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        child: CardFaceContent(card: card, textColor: textColor),
      ),
    );
  }
}
