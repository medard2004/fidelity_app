import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_radius.dart';
import '../../../models/loyalty_card.dart';
import '../../../widgets/shared/grain_overlay.dart';

/// Une carte du wallet, traitée comme une plaque gravée : fond
/// porcelaine ou doublure teintée, liseré laiton, ombre chaude, grain.
class LoyaltyCardWidget extends StatelessWidget {
  final LoyaltyCard card;
  final double height;

  const LoyaltyCardWidget({super.key, required this.card, this.height = 190});

  bool get _isDark => card.liningColor.computeLuminance() < 0.4;

  @override
  Widget build(BuildContext context) {
    final textColor = _isDark ? AppColors.porcelaine : AppColors.encre;

    return Container(
      height: height,
      decoration: BoxDecoration(
        color: card.liningColor,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.laitonLisere(opacity: 0.5), width: 1),
        boxShadow: [
          BoxShadow(
            color: AppColors.ombreChaude(opacity: 0.16),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          GrainOverlay(borderRadius: BorderRadius.circular(AppRadius.card)),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        card.restaurantName,
                        style: AppTextStyles.displayMedium(color: textColor),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    _MechanicBadge(card: card, textColor: textColor),
                  ],
                ),
                Text(
                  card.restaurantCategory,
                  style: AppTextStyles.bodySmall(color: textColor).copyWith(
                    color: textColor.withOpacity(0.65),
                  ),
                ),
                const Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(card.quickStat, style: AppTextStyles.monoMedium(color: textColor)),
                    Icon(Icons.qr_code_2,
                        size: 20, color: AppColors.laitonBrosse.withOpacity(0.9)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MechanicBadge extends StatelessWidget {
  final LoyaltyCard card;
  final Color textColor;
  const _MechanicBadge({required this.card, required this.textColor});

  @override
  Widget build(BuildContext context) {
    if (card.mechanic != LoyaltyMechanic.vip) return const SizedBox.shrink();
    final isPlatinum = card.vipTier == VipTier.platinum;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: isPlatinum ? AppColors.bordeauxProfond : AppColors.laitonBrosse,
        ),
      ),
      child: Text(
        card.vipTier.label.toUpperCase(),
        style: AppTextStyles.monoSmall(
          color: isPlatinum ? AppColors.bordeauxProfond : AppColors.laitonBrosse,
        ),
      ),
    );
  }
}

/// Dernière "carte" de la pile : discrète, invitation à rejoindre.
class JoinRestaurantGhostCard extends StatelessWidget {
  final VoidCallback onTap;
  final double height;
  const JoinRestaurantGhostCard({super.key, required this.onTap, this.height = 190});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.card),
          border: Border.all(
            color: AppColors.laitonLisere(opacity: 0.4),
            width: 1,
            style: BorderStyle.solid,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.add, color: AppColors.laitonBrosse),
              const SizedBox(height: 6),
              Text('Rejoindre un restaurant', style: AppTextStyles.bodyMedium(
                  color: AppColors.encre.withOpacity(0.6))),
            ],
          ),
        ),
      ),
    );
  }
}
