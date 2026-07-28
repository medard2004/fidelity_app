import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/reward.dart';
import '../../providers/app_providers.dart';

/// Écran des Récompenses et Privilèges (Design conforme à la maquette)
class RewardsScreen extends ConsumerWidget {
  const RewardsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rewards = ref.watch(rewardsProvider);
    final notifications = ref.watch(notificationsProvider);
    final unreadCount = notifications.where((n) => !n.isRead).length;

    final activeRewards =
        rewards.where((r) => r.status == RewardStatus.active).toList();
    final lockedRewards =
        rewards.where((r) => r.status == RewardStatus.locked).toList();
    final usedRewards =
        rewards.where((r) => r.status == RewardStatus.used).toList();

    return Scaffold(
      backgroundColor: AppColors.porcelaine,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header Section ─────────────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'VOS PRIVILÈGES',
                        style: AppTextStyles.monoSmall(
                          color: AppColors.laitonBrosse,
                        ).copyWith(
                          letterSpacing: 2.2,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Récompenses',
                        style: AppTextStyles.displayXL(
                          color: AppColors.encre,
                        ).copyWith(
                          fontSize: 36,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),

                  // Bouton Cloche de Notification
                  GestureDetector(
                    onTap: () => context.push('/notifications'),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          child: const Icon(
                            Icons.notifications_none_outlined,
                            size: 24,
                            color: AppColors.encre,
                          ),
                        ),
                        if (unreadCount > 0)
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: AppColors.laitonBrosse,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              // ── 1. Privilèges Actifs (Cartes en haut) ─────────────────────
              if (activeRewards.isNotEmpty)
                ...activeRewards.map((reward) => Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _ActiveRewardCard(reward: reward),
                    ))
              else
                const _EmptySectionCard(
                  message: 'Aucun privilège disponible pour le moment.',
                ),

              const SizedBox(height: 16),

              // ── 2. Section "À débloquer" ──────────────────────────────────
              Text(
                'À débloquer',
                style: AppTextStyles.displayMedium(color: AppColors.encre).copyWith(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 14),

              if (lockedRewards.isNotEmpty)
                ...lockedRewards.map((reward) => Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: _LockedRewardCard(reward: reward),
                    ))
              else
                const _EmptySectionCard(
                  message: 'Toutes les récompenses sont actuellement débloquées !',
                ),

              const SizedBox(height: 24),

              // ── 3. Section "Historique" ───────────────────────────────────
              Text(
                'Historique',
                style: AppTextStyles.displayMedium(color: AppColors.encre).copyWith(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 16),

              if (usedRewards.isNotEmpty)
                Column(
                  children: usedRewards
                      .map((reward) => Padding(
                            padding: const EdgeInsets.only(bottom: 14),
                            child: _HistoryRewardRow(reward: reward),
                          ))
                      .toList(),
                )
              else
                const _EmptySectionCard(
                  message: 'Aucune récompense utilisée récemment.',
                ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

/// Carte de récompense active (Débloquée / Disponible)
class _ActiveRewardCard extends StatelessWidget {
  final Reward reward;
  const _ActiveRewardCard({required this.reward});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF2EEE4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFDFDACB),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                reward.restaurantName.toUpperCase(),
                style: AppTextStyles.monoSmall(color: AppColors.laitonBrosse).copyWith(
                  letterSpacing: 1.8,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (reward.expiresAt != null)
                Text(
                  reward.daysRemainingText,
                  style: AppTextStyles.monoSmall(
                    color: AppColors.encre.withOpacity(0.75),
                  ).copyWith(
                    letterSpacing: 1.2,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),

          Text(
            reward.title,
            style: AppTextStyles.displayMedium(color: AppColors.encre).copyWith(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              height: 1.15,
            ),
          ),
          const SizedBox(height: 4),

          Text(
            reward.description,
            style: AppTextStyles.bodyMedium(
              color: AppColors.encre.withOpacity(0.75),
            ).copyWith(
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

/// Carte de récompense verrouillée ("À débloquer")
class _LockedRewardCard extends StatelessWidget {
  final Reward reward;
  const _LockedRewardCard({required this.reward});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFEBE8DD),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            reward.restaurantName.toUpperCase(),
            style: AppTextStyles.monoSmall(color: AppColors.encre.withOpacity(0.7)).copyWith(
              letterSpacing: 1.8,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),

          Text(
            reward.title,
            style: AppTextStyles.displayMedium(color: AppColors.encre).copyWith(
              fontSize: 17,
              fontWeight: FontWeight.w500,
              height: 1.15,
            ),
          ),
          const SizedBox(height: 6),

          Text(
            reward.lockedCondition ?? reward.description,
            style: AppTextStyles.monoSmall(color: AppColors.encre.withOpacity(0.65)).copyWith(
              letterSpacing: 1.2,
              fontSize: 11,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}

/// Ligne d'historique des récompenses utilisées
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
          style: AppTextStyles.monoSmall(color: AppColors.encre.withOpacity(0.85)).copyWith(
            letterSpacing: 1.4,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          '${reward.restaurantName}  ·  ${reward.title}',
          style: AppTextStyles.monoSmall(color: AppColors.encre.withOpacity(0.85)).copyWith(
            letterSpacing: 0.5,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

/// Widget d'état vide pour une section
class _EmptySectionCard extends StatelessWidget {
  final String message;
  const _EmptySectionCard({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEBE8DD).withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFDFDACB).withOpacity(0.5)),
      ),
      child: Text(
        message,
        style: AppTextStyles.bodyMedium(color: AppColors.encre.withOpacity(0.5)).copyWith(
          fontSize: 12.5,
          fontStyle: FontStyle.italic,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
