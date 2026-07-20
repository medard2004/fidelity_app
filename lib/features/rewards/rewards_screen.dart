import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_radius.dart';
import '../../models/reward.dart';
import '../../providers/app_providers.dart';

class RewardsScreen extends ConsumerWidget {
  const RewardsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rewards = ref.watch(rewardsProvider);
    final active = rewards.where((r) => r.status == RewardStatus.active).toList();
    final locked = rewards.where((r) => r.status == RewardStatus.locked).toList();
    final used = rewards.where((r) => r.status == RewardStatus.used).toList();

    return Scaffold(
      backgroundColor: AppColors.porcelaine,
      appBar: AppBar(title: Text('Récompenses', style: AppTextStyles.displayMedium())),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 40),
        children: [
          if (active.isNotEmpty) ...[
            Text('Actives', style: AppTextStyles.label()),
            const SizedBox(height: 12),
            ...active.map((r) => _RewardCard(reward: r)),
            const SizedBox(height: 28),
          ],
          if (locked.isNotEmpty) ...[
            Text('Verrouillées', style: AppTextStyles.label()),
            const SizedBox(height: 12),
            ...locked.map((r) => _RewardCard(reward: r)),
            const SizedBox(height: 28),
          ],
          if (used.isNotEmpty) ...[
            Text('Utilisées', style: AppTextStyles.label(color: AppColors.encre.withOpacity(0.5))),
            const SizedBox(height: 12),
            ...used.map((r) => _RewardCard(reward: r)),
          ],
        ],
      ),
    );
  }
}

class _RewardCard extends StatelessWidget {
  final Reward reward;
  const _RewardCard({required this.reward});

  @override
  Widget build(BuildContext context) {
    final isActive = reward.status == RewardStatus.active;
    final isUsed = reward.status == RewardStatus.used;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isUsed ? AppColors.saugePale.withOpacity(0.4) : AppColors.porcelaine,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(
          color: isActive
              ? AppColors.laitonBrosse
              : AppColors.laitonLisere(opacity: 0.2),
          width: isActive ? 1.3 : 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(reward.restaurantName,
                    style: AppTextStyles.bodySmall(color: AppColors.encre.withOpacity(0.5))),
                const SizedBox(height: 4),
                Text(reward.title,
                    style: AppTextStyles.displayEngraved(
                        color: isUsed ? AppColors.encre.withOpacity(0.5) : AppColors.encre)),
                const SizedBox(height: 4),
                Text(reward.description, style: AppTextStyles.bodySmall()),
              ],
            ),
          ),
          if (reward.status == RewardStatus.locked)
            Text(reward.lockedCondition ?? '', style: AppTextStyles.monoSmall())
          else if (reward.status == RewardStatus.used)
            Text('UTILISÉE', style: AppTextStyles.monoSmall())
          else if (reward.expiresAt != null)
            Text(
              'EXPIRE BIENTÔT',
              style: AppTextStyles.monoSmall(
                color: reward.isExpiringSoon ? AppColors.bordeauxProfond : AppColors.laitonBrosse,
              ),
            ),
        ],
      ),
    );
  }
}
