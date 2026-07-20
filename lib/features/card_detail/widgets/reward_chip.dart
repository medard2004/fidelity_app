import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_radius.dart';
import '../../../models/reward.dart';

class RewardChip extends StatelessWidget {
  final Reward reward;
  const RewardChip({super.key, required this.reward});

  @override
  Widget build(BuildContext context) {
    final isActive = reward.status == RewardStatus.active;
    final isLocked = reward.status == RewardStatus.locked;

    return Container(
      width: 168,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isLocked ? AppColors.saugePale.withOpacity(0.6) : AppColors.porcelaine,
        borderRadius: BorderRadius.circular(AppRadius.chip),
        border: Border.all(
          color: isActive
              ? AppColors.laitonBrosse
              : AppColors.laitonLisere(opacity: 0.2),
          width: isActive ? 1.3 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            reward.title,
            style: AppTextStyles.bodyMedium(
              color: isLocked ? AppColors.encre.withOpacity(0.5) : AppColors.encre,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          if (isLocked)
            Text(reward.lockedCondition ?? '', style: AppTextStyles.monoSmall())
          else if (reward.expiresAt != null)
            Text(
              _countdownLabel(reward),
              style: AppTextStyles.monoSmall(
                color: reward.isExpiringSoon ? AppColors.bordeauxProfond : AppColors.encre,
              ),
            )
          else
            Text('ACTIVE', style: AppTextStyles.monoSmall(color: AppColors.laitonBrosse)),
        ],
      ),
    );
  }

  String _countdownLabel(Reward r) {
    final diff = r.expiresAt!.difference(DateTime.now());
    if (diff.isNegative) return 'EXPIRÉE';
    if (diff.inHours < 24) return 'EXPIRE DANS ${diff.inHours}H';
    return 'EXPIRE DANS ${diff.inDays}J';
  }
}
