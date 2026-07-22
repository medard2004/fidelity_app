import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../models/loyalty_card.dart';
import '../../../widgets/shared/grain_overlay.dart';

/// Une carte du wallet, traitée comme une plaque gravée selon la maquette 1.
class LoyaltyCardWidget extends StatelessWidget {
  final LoyaltyCard card;
  final double height;

  const LoyaltyCardWidget({super.key, required this.card, this.height = 190});

  bool get _isDark => card.liningColor.computeLuminance() < 0.4;

  @override
  Widget build(BuildContext context) {
    final textColor = _isDark ? AppColors.porcelaine : AppColors.encre;
    final subtextColor = textColor.withOpacity(0.75);

    return Container(
      height: height,
      decoration: BoxDecoration(
        color: card.liningColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _isDark
              ? AppColors.laitonLisere(opacity: 0.3)
              : AppColors.encre.withOpacity(0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.ombreChaude(opacity: 0.18),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          GrainOverlay(borderRadius: BorderRadius.circular(20)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Ligne supérieure : Catégorie à gauche, Code ID à droite
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        card.restaurantCategory.toUpperCase(),
                        style: AppTextStyles.monoSmall(color: subtextColor)
                            .copyWith(letterSpacing: 1.8),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      card.fallbackId,
                      style: AppTextStyles.monoSmall(color: subtextColor)
                          .copyWith(letterSpacing: 1.5),
                    ),
                  ],
                ),

                // Titre principal du restaurant
                if (card.restaurantName != 'Bistrot de Quartier')
                  Text(
                    card.restaurantName,
                    style: AppTextStyles.displayLarge(color: textColor).copyWith(
                      fontSize: 26,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  )
                else
                  const SizedBox.shrink(),

                // Bloc inférieur selon la mécanique (Statut / Cashback / Points)
                _buildCardBottom(textColor),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardBottom(Color textColor) {
    if (card.mechanic == LoyaltyMechanic.vip) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'STATUT',
            style: AppTextStyles.monoSmall(color: textColor.withOpacity(0.7)),
          ),
          const SizedBox(height: 6),
          Container(
            width: 48,
            height: 24,
            decoration: BoxDecoration(
              color: AppColors.laitonBrosse,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ],
      );
    } else if (card.mechanic == LoyaltyMechanic.cashback) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'CASHBACK',
            style: AppTextStyles.monoSmall(color: textColor.withOpacity(0.7)),
          ),
          Text(
            '${card.cashbackBalanceFcfa} FCFA',
            style: AppTextStyles.monoMedium(color: textColor),
          ),
        ],
      );
    } else if (card.mechanic == LoyaltyMechanic.points) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'SOLDE',
            style: AppTextStyles.monoSmall(color: textColor.withOpacity(0.7)),
          ),
          Text(
            '${card.pointsBalance} PTS',
            style: AppTextStyles.monoMedium(color: textColor),
          ),
        ],
      );
    }

    return const SizedBox.shrink();
  }
}


