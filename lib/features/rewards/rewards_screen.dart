import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/reward.dart';
import '../../providers/app_providers.dart';

/// Écran des Récompenses et Privilèges (En-tête statique & format compact)
class RewardsScreen extends ConsumerWidget {
  const RewardsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rewards = ref.watch(rewardsProvider);
    final unreadNotifs = ref.watch(notificationsProvider.notifier).unreadCount;

    final activeRewards =
        rewards.where((r) => r.status == RewardStatus.active).toList();
    final lockedRewards =
        rewards.where((r) => r.status == RewardStatus.locked).toList();
    final usedRewards =
        rewards.where((r) => r.status == RewardStatus.used).toList();

    final titleStyle = GoogleFonts.bodoniModa(
      fontSize: 25,
      fontWeight: FontWeight.w600,
      color: AppColors.encre,
      height: 1.1,
    );

    return Scaffold(
      backgroundColor: AppColors.porcelaine,
      body: SafeArea(
        child: Column(
          children: [
            // ── En-tête Statique (Fixe au défilement) ─────────────────────────
            Container(
              color: AppColors.porcelaine,
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'VOS PRIVILÈGES',
                        style: AppTextStyles.monoSmall(
                          color: AppColors.laitonBrosse,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text('Récompenses', style: titleStyle),
                    ],
                  ),

                  // Bouton Notification uniforme avec badge
                  GestureDetector(
                    onTap: () => context.push('/notifications'),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.porcelaine,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.laitonLisere(opacity: 0.35),
                            ),
                          ),
                          child: const Icon(
                            Icons.notifications_none,
                            color: AppColors.encre,
                            size: 20,
                          ),
                        ),
                        if (unreadNotifs > 0)
                          Positioned(
                            top: -2,
                            right: -2,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: AppColors.bordeauxProfond,
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                '$unreadNotifs',
                                style: const TextStyle(
                                  color: AppColors.porcelaine,
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Séparateur discret sous l'en-tête statique
            Divider(
              height: 1,
              color: AppColors.encre.withValues(alpha: 0.06),
            ),

            // ── Contenu Défilant ──────────────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── 1. Privilèges Actifs ─────────────────────────────────
                    if (activeRewards.isNotEmpty)
                      ...activeRewards.map((reward) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _ActiveRewardCard(reward: reward),
                          ))
                    else
                      const _EmptySectionCard(
                        message: 'Aucun privilège disponible pour le moment.',
                      ),

                    const SizedBox(height: 14),

                    // ── 2. Section "À débloquer" ──────────────────────────────
                    Text(
                      'À débloquer',
                      style: GoogleFonts.bodoniModa(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.encre,
                      ),
                    ),
                    const SizedBox(height: 10),

                    if (lockedRewards.isNotEmpty)
                      ...lockedRewards.map((reward) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: _LockedRewardCard(reward: reward),
                          ))
                    else
                      const _EmptySectionCard(
                        message:
                            'Toutes les récompenses sont actuellement débloquées !',
                      ),

                    const SizedBox(height: 20),

                    // ── 3. Section "Historique" ───────────────────────────────
                    Text(
                      'Historique',
                      style: GoogleFonts.bodoniModa(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.encre,
                      ),
                    ),
                    const SizedBox(height: 10),

                    if (usedRewards.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: AppColors.porcelaine,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.laitonLisere(opacity: 0.3),
                          ),
                        ),
                        child: Column(
                          children: usedRewards
                              .map((reward) => Padding(
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 8),
                                    child: _HistoryRewardRow(reward: reward),
                                  ))
                              .toList(),
                        ),
                      )
                    else
                      const _EmptySectionCard(
                        message: 'Aucune récompense utilisée récemment.',
                      ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Carte de récompense active (Format compact)
class _ActiveRewardCard extends StatelessWidget {
  final Reward reward;
  const _ActiveRewardCard({required this.reward});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF2EEE4),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFDFDACB),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
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
                style: AppTextStyles.monoSmall(color: AppColors.laitonBrosse)
                    .copyWith(
                  letterSpacing: 1.4,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (reward.expiresAt != null)
                Text(
                  reward.daysRemainingText,
                  style: AppTextStyles.monoSmall(
                    color: AppColors.encre.withValues(alpha: 0.7),
                  ).copyWith(
                    letterSpacing: 1.0,
                    fontSize: 10,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),

          Text(
            reward.title,
            style: GoogleFonts.bodoniModa(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: AppColors.encre,
              height: 1.15,
            ),
          ),
          const SizedBox(height: 4),

          Text(
            reward.description,
            style: AppTextStyles.bodyMedium(
              color: AppColors.encre.withValues(alpha: 0.7),
            ).copyWith(
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

/// Carte de récompense verrouillée (Format compact)
class _LockedRewardCard extends StatelessWidget {
  final Reward reward;
  const _LockedRewardCard({required this.reward});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFEBE8DD).withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.laitonLisere(opacity: 0.25),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                reward.restaurantName.toUpperCase(),
                style: AppTextStyles.monoSmall(
                  color: AppColors.encre.withValues(alpha: 0.6),
                ).copyWith(
                  letterSpacing: 1.2,
                  fontSize: 10,
                ),
              ),
              const Icon(
                Icons.lock_outline,
                size: 14,
                color: AppColors.laitonBrosse,
              ),
            ],
          ),
          const SizedBox(height: 4),

          Text(
            reward.title,
            style: GoogleFonts.bodoniModa(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.encre,
              height: 1.15,
            ),
          ),
          const SizedBox(height: 4),

          Text(
            reward.lockedCondition ?? reward.description,
            style: AppTextStyles.monoSmall(
              color: AppColors.encre.withValues(alpha: 0.6),
            ).copyWith(
              fontSize: 10.5,
            ),
          ),
        ],
      ),
    );
  }
}

/// Ligne d'historique (Format compact)
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
          style: AppTextStyles.monoSmall(
            color: AppColors.encre.withValues(alpha: 0.8),
          ).copyWith(
            fontSize: 10.5,
          ),
        ),
        Expanded(
          child: Text(
            '${reward.restaurantName}  ·  ${reward.title}',
            style: AppTextStyles.bodyMedium(
              color: AppColors.encre.withValues(alpha: 0.8),
            ).copyWith(
              fontSize: 11.5,
            ),
            textAlign: TextAlign.end,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

/// Widget d'état vide
class _EmptySectionCard extends StatelessWidget {
  final String message;
  const _EmptySectionCard({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFEBE8DD).withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: const Color(0xFFDFDACB).withValues(alpha: 0.4),
        ),
      ),
      child: Text(
        message,
        style: AppTextStyles.bodyMedium(
          color: AppColors.encre.withValues(alpha: 0.5),
        ).copyWith(
          fontSize: 12,
          fontStyle: FontStyle.italic,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
