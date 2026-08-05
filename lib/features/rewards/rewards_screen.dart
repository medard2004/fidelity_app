import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_shadows.dart';
import '../../models/reward.dart';
import '../../providers/app_providers.dart';
import '../../widgets/components/components.dart';

/// Écran des Récompenses et Privilèges.
class RewardsScreen extends ConsumerWidget {
  const RewardsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rewards = ref.watch(rewardsProvider);
    final unreadNotifs =
        ref.watch(notificationsProvider).where((n) => !n.isRead).length;

    final activeRewards =
        rewards.where((r) => r.status == RewardStatus.active).toList();
    final lockedRewards =
        rewards.where((r) => r.status == RewardStatus.locked).toList();
    final usedRewards =
        rewards.where((r) => r.status == RewardStatus.used).toList();

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          children: [
            // ── En-tête statique ─────────────────────────────────────────
            Container(
              color: AppColors.surface,
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SectionEyebrow('Vos privilèges'),
                      const SizedBox(height: 4),
                      Text('Récompenses', style: AppTextStyles.displayLarge()),
                    ],
                  ),
                  Semantics(
                    button: true,
                    label: unreadNotifs > 0
                        ? 'Notifications, $unreadNotifs non lues'
                        : 'Notifications',
                    child: GestureDetector(
                      onTap: () => context.push('/notifications'),
                      behavior: HitTestBehavior.opaque,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: AppColors.surfaceCard,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: AppShadows.resting,
                            ),
                            child: const Icon(
                              LucideIcons.bell,
                              color: AppColors.ink,
                              size: 20,
                            ),
                          ),
                          if (unreadNotifs > 0)
                            Positioned(
                              top: 2,
                              right: 2,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: AppColors.error,
                                  shape: BoxShape.circle,
                                ),
                                child: Text(
                                  '$unreadNotifs',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const Divider(height: 1, color: AppColors.border),

            // ── Contenu défilant ─────────────────────────────────────────
            Expanded(
              child: RefreshIndicator(
                color: AppColors.primary,
                backgroundColor: AppColors.surfaceCard,
                onRefresh: () =>
                    Future.delayed(const Duration(milliseconds: 700)),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (activeRewards.isNotEmpty)
                        ...activeRewards.map((reward) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _ActiveRewardCard(
                                reward: reward,
                                onRedeem: () =>
                                    _confirmRedeem(context, ref, reward),
                              ),
                            ))
                      else
                        const EmptyState(
                          compact: true,
                          icon: LucideIcons.gift,
                          title: 'Aucun privilège disponible',
                          message: 'Revenez bientôt pour de nouvelles offres.',
                        ),

                      const SizedBox(height: 16),

                      Text('À débloquer', style: AppTextStyles.titleMedium()),
                      const SizedBox(height: 10),

                      if (lockedRewards.isNotEmpty)
                        ...lockedRewards.map((reward) => Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: _LockedRewardCard(reward: reward),
                            ))
                      else
                        const EmptyState(
                          compact: true,
                          icon: LucideIcons.lockOpen,
                          title: 'Tout est débloqué',
                          message: 'Aucune récompense verrouillée pour le moment.',
                        ),

                      const SizedBox(height: 20),

                      Text('Historique', style: AppTextStyles.titleMedium()),
                      const SizedBox(height: 10),

                      if (usedRewards.isNotEmpty)
                        AppCard(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          child: Column(
                            children: usedRewards
                                .map((reward) => Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8),
                                      child: _HistoryRewardRow(reward: reward),
                                    ))
                                .toList(),
                          ),
                        )
                      else
                        const EmptyState(
                          compact: true,
                          icon: LucideIcons.history,
                          title: 'Aucun historique',
                          message: 'Vos récompenses utilisées apparaîtront ici.',
                        ),

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void _confirmRedeem(BuildContext context, WidgetRef ref, Reward reward) {
  showDialog(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text('Utiliser cette récompense ?',
          style: AppTextStyles.titleMedium()),
      content: Text(
        '« ${reward.title} » sera marquée comme utilisée et retirée de vos privilèges actifs. Présentez cet écran à l\'enseigne avant de confirmer.',
        style: AppTextStyles.bodyMedium(color: AppColors.inkMuted(opacity: 0.75)),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(),
          child: Text('Annuler',
              style: AppTextStyles.label(color: AppColors.inkMuted(opacity: 0.6))),
        ),
        TextButton(
          onPressed: () {
            ref.read(rewardsProvider.notifier).redeem(reward.id);
            Navigator.of(dialogContext).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('Récompense marquée comme utilisée')),
            );
          },
          child: Text('Confirmer',
              style: AppTextStyles.label(color: AppColors.primary)),
        ),
      ],
    ),
  );
}

/// Carte de récompense active.
class _ActiveRewardCard extends StatelessWidget {
  final Reward reward;
  final VoidCallback onRedeem;
  const _ActiveRewardCard({required this.reward, required this.onRedeem});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      elevated: true,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                reward.restaurantName.toUpperCase(),
                style: AppTextStyles.eyebrow(color: AppColors.primary),
              ),
              if (reward.expiresAt != null)
                StatusBadge(
                  label: reward.daysRemainingText,
                  tone: reward.isExpiringSoon ? StatusTone.warning : StatusTone.neutral,
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(reward.title, style: AppTextStyles.titleMedium().copyWith(fontSize: 17)),
          const SizedBox(height: 4),
          Text(
            reward.description,
            style: AppTextStyles.bodyMedium(color: AppColors.inkMuted(opacity: 0.7)),
          ),
          const SizedBox(height: 14),
          AppButton(label: 'Utiliser', onTap: onRedeem, height: 46),
        ],
      ),
    );
  }
}

/// Carte de récompense verrouillée.
class _LockedRewardCard extends StatelessWidget {
  final Reward reward;
  const _LockedRewardCard({required this.reward});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      backgroundColor: AppColors.surfaceMuted,
      bordered: false,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                reward.restaurantName.toUpperCase(),
                style: AppTextStyles.eyebrow(color: AppColors.inkMuted(opacity: 0.55)),
              ),
              Icon(LucideIcons.lock, size: 14, color: AppColors.inkMuted()),
            ],
          ),
          const SizedBox(height: 6),
          Text(reward.title, style: AppTextStyles.titleMedium().copyWith(fontSize: 15)),
          const SizedBox(height: 4),
          Text(
            reward.lockedCondition ?? reward.description,
            style: AppTextStyles.bodySmall(color: AppColors.inkMuted(opacity: 0.65)),
          ),
        ],
      ),
    );
  }
}

/// Ligne d'historique.
class _HistoryRewardRow extends StatelessWidget {
  final Reward reward;
  const _HistoryRewardRow({required this.reward});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          reward.formattedUsedDate,
          style: AppTextStyles.monoSmall(color: AppColors.inkMuted(opacity: 0.8)),
        ),
        Expanded(
          child: Text(
            '${reward.restaurantName}  ·  ${reward.title}',
            style: AppTextStyles.bodyMedium(color: AppColors.inkMuted(opacity: 0.8)),
            textAlign: TextAlign.end,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
