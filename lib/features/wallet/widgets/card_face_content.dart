import 'package:flutter/material.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_radius.dart';
import '../../../models/loyalty_card.dart';

/// Sépare les milliers d'un nombre par un espace fine (ex. 12 400).
String formatGroupedNumber(int number) {
  final str = number.toString();
  final reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
  return str.replaceAllMapped(reg, (Match m) => '${m[1]} ');
}

/// Contenu d'une face de carte de fidélité — catégorie/ID, nom de
/// l'enseigne, puis bloc spécifique au mécanisme de fidélité
/// (tampons/points/cashback/VIP). Un seul point d'implémentation,
/// utilisé à la fois par [LoyaltyCardWidget] (pile du wallet, format
/// plein) et par l'écran de détail de carte (format compact) —
/// auparavant deux implémentations dupliquées.
class CardFaceContent extends StatelessWidget {
  final LoyaltyCard card;
  final Color textColor;
  final bool compact;

  const CardFaceContent({
    super.key,
    required this.card,
    required this.textColor,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final subtextColor = textColor.withValues(alpha: 0.7);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    card.restaurantCategory.toUpperCase(),
                    style: AppTextStyles.monoSmall(color: subtextColor),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  card.fallbackId,
                  style: AppTextStyles.monoSmall(color: subtextColor),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
            SizedBox(height: compact ? 8 : 10),
            Text(
              card.restaurantName,
              style: AppTextStyles.displayLarge(color: textColor).copyWith(
                fontSize: compact ? 20 : 25,
                height: 1.05,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        _MechanicStat(card: card, textColor: textColor, subtextColor: subtextColor),
      ],
    );
  }
}

class _MechanicStat extends StatelessWidget {
  final LoyaltyCard card;
  final Color textColor;
  final Color subtextColor;

  const _MechanicStat({
    required this.card,
    required this.textColor,
    required this.subtextColor,
  });

  @override
  Widget build(BuildContext context) {
    switch (card.mechanic) {
      case LoyaltyMechanic.vip:
        return Row(
          children: [
            Container(
              constraints: const BoxConstraints(minWidth: 44, minHeight: 22),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
              child: Text(
                card.vipTier.label.toUpperCase(),
                style: AppTextStyles.monoSmall(color: textColor)
                    .copyWith(fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                card.vipTier == VipTier.platinum
                    ? 'Palier maximum atteint'
                    : 'Platinum dans ${((1 - card.vipProgressToNextTier) * 12).ceil()} visites',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.bodySmall(color: subtextColor),
              ),
            ),
          ],
        );
      case LoyaltyMechanic.cashback:
        return _valueRow('CASHBACK', formatGroupedNumber(card.cashbackBalanceFcfa), 'FCFA');
      case LoyaltyMechanic.points:
        return _valueRow('SOLDE', formatGroupedNumber(card.pointsBalance), 'PTS');
      case LoyaltyMechanic.stamps:
        return _valueRow('TAMPONS', '${card.stampsCurrent}/${card.stampsGoal}', null);
    }
  }

  Widget _valueRow(String label, String value, String? suffix) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: AppTextStyles.monoSmall(color: subtextColor)),
        const SizedBox(height: 2),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(value, style: AppTextStyles.monoLarge(color: textColor)),
            if (suffix != null) ...[
              const SizedBox(width: 6),
              Text(suffix, style: AppTextStyles.monoMedium(color: subtextColor)),
            ],
          ],
        ),
      ],
    );
  }
}
