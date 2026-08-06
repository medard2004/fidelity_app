import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../l10n/gen/app_localizations.dart';
import '../../models/reward.dart';
import '../../providers/app_providers.dart';
import '../../providers/settings_provider.dart';
import '../../widgets/components/components.dart';
import '../../widgets/shared/app_section_header.dart';
import '../../widgets/shared/notification_bell_button.dart';

/// Écran des Récompenses et Privilèges.
class RewardsScreen extends ConsumerWidget {
  const RewardsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(themeModeProvider);
    final t = AppLocalizations.of(context)!;
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
            AppSectionHeader(
              title: t.rewardsTitle,
              actions: [NotificationBellButton(unreadCount: unreadNotifs)],
            ),

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
                        EmptyState(
                          compact: true,
                          icon: LucideIcons.gift,
                          title: t.rewardsEmptyActiveTitle,
                          message: t.rewardsEmptyActiveMessage,
                        ),
                      const SizedBox(height: 16),
                      Text(t.rewardsToUnlock,
                          style: AppTextStyles.titleMedium()),
                      const SizedBox(height: 10),
                      if (lockedRewards.isNotEmpty)
                        ...lockedRewards.map((reward) => Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: _LockedRewardCard(reward: reward),
                            ))
                      else
                        EmptyState(
                          compact: true,
                          icon: LucideIcons.lockOpen,
                          title: t.rewardsAllUnlockedTitle,
                          message: t.rewardsAllUnlockedMessage,
                        ),
                      const SizedBox(height: 20),
                      Text(t.commonHistory, style: AppTextStyles.titleMedium()),
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
                        EmptyState(
                          compact: true,
                          icon: LucideIcons.history,
                          title: t.rewardsHistoryEmptyTitle,
                          message: t.rewardsHistoryEmptyMessage,
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
  final t = AppLocalizations.of(context)!;
  showDialog(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title:
          Text(t.rewardsRedeemConfirmTitle, style: AppTextStyles.titleMedium()),
      content: Text(
        t.rewardsRedeemConfirmMessage(reward.title),
        style:
            AppTextStyles.bodyMedium(color: AppColors.inkMuted(opacity: 0.75)),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(),
          child: Text(t.commonCancel,
              style:
                  AppTextStyles.label(color: AppColors.inkMuted(opacity: 0.6))),
        ),
        TextButton(
          onPressed: () {
            ref.read(rewardsProvider.notifier).redeem(reward.id);
            Navigator.of(dialogContext).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(t.rewardsRedeemSuccess)),
            );
          },
          child: Text(t.commonConfirm,
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
    final t = AppLocalizations.of(context)!;
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
                  label: reward.daysRemainingText(t.commonCountdownPrefix),
                  tone: reward.isExpiringSoon
                      ? StatusTone.warning
                      : StatusTone.neutral,
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(reward.title,
              style: AppTextStyles.titleMedium().copyWith(fontSize: 17)),
          const SizedBox(height: 4),
          Text(
            reward.description,
            style: AppTextStyles.bodyMedium(
                color: AppColors.inkMuted(opacity: 0.7)),
          ),
          const SizedBox(height: 14),
          AppButton(label: t.rewardsUseButton, onTap: onRedeem, height: 46),
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
                style: AppTextStyles.eyebrow(
                    color: AppColors.inkMuted(opacity: 0.55)),
              ),
              Icon(LucideIcons.lock, size: 14, color: AppColors.inkMuted()),
            ],
          ),
          const SizedBox(height: 6),
          Text(reward.title,
              style: AppTextStyles.titleMedium().copyWith(fontSize: 15)),
          const SizedBox(height: 4),
          Text(
            reward.lockedCondition ?? reward.description,
            style: AppTextStyles.bodySmall(
                color: AppColors.inkMuted(opacity: 0.65)),
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
    final dateFormatLocale =
        Localizations.localeOf(context).languageCode == 'fr'
            ? 'fr_FR'
            : 'en_US';
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          reward.formattedUsedDate(dateFormatLocale),
          style:
              AppTextStyles.monoSmall(color: AppColors.inkMuted(opacity: 0.8)),
        ),
        Expanded(
          child: Text(
            '${reward.restaurantName}  ·  ${reward.title}',
            style: AppTextStyles.bodyMedium(
                color: AppColors.inkMuted(opacity: 0.8)),
            textAlign: TextAlign.end,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
