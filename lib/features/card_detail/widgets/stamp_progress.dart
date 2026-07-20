import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../models/loyalty_card.dart';

/// Progression stylée selon la mécanique : sceaux, jauge fine liseré
/// laiton, ou barre de solde.
class CardProgressWidget extends StatelessWidget {
  final LoyaltyCard card;
  const CardProgressWidget({super.key, required this.card});

  @override
  Widget build(BuildContext context) {
    switch (card.mechanic) {
      case LoyaltyMechanic.stamps:
        return _StampsRow(current: card.stampsCurrent, goal: card.stampsGoal);
      case LoyaltyMechanic.points:
        return _BalanceGauge(
          label: '${card.pointsBalance} PTS',
          progress: (card.pointsBalance % 2000) / 2000,
        );
      case LoyaltyMechanic.cashback:
        return _BalanceGauge(
          label: '${card.cashbackBalanceFcfa} FCFA',
          progress: (card.cashbackBalanceFcfa % 5000) / 5000,
        );
      case LoyaltyMechanic.vip:
        return _VipGauge(card: card);
    }
  }
}

class _StampsRow extends StatelessWidget {
  final int current;
  final int goal;
  const _StampsRow({required this.current, required this.goal});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: List.generate(goal, (i) {
        final filled = i < current;
        return Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: filled ? AppColors.laitonBrosse : Colors.transparent,
            border: Border.all(
              color: filled
                  ? AppColors.laitonBrosse
                  : AppColors.laitonLisere(opacity: 0.35),
              width: 1.4,
            ),
          ),
          child: filled
              ? const Icon(Icons.check, size: 14, color: AppColors.porcelaine)
              : null,
        );
      }),
    );
  }
}

class _BalanceGauge extends StatelessWidget {
  final String label;
  final double progress;
  const _BalanceGauge({required this.label, required this.progress});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.monoLarge()),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress.clamp(0.02, 1),
            minHeight: 4,
            backgroundColor: AppColors.saugePale,
            valueColor: const AlwaysStoppedAnimation(AppColors.laitonBrosse),
          ),
        ),
      ],
    );
  }
}

class _VipGauge extends StatelessWidget {
  final LoyaltyCard card;
  const _VipGauge({required this.card});

  @override
  Widget build(BuildContext context) {
    final isPlatinum = card.vipTier == VipTier.platinum;
    final accent = isPlatinum ? AppColors.bordeauxProfond : AppColors.laitonBrosse;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                border: Border.all(color: accent),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(card.vipTier.label.toUpperCase(),
                  style: AppTextStyles.monoSmall(color: accent)),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text('Prochain palier', style: AppTextStyles.bodySmall()),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: card.vipProgressToNextTier.clamp(0.02, 1),
            minHeight: 4,
            backgroundColor: AppColors.saugePale,
            valueColor: AlwaysStoppedAnimation(accent),
          ),
        ),
      ],
    );
  }
}
