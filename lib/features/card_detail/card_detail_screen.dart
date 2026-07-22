import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/loyalty_card.dart';
import '../../providers/wallet_provider.dart';
import '../../providers/app_providers.dart';
import '../../widgets/shared/brass_qr_plate.dart';
import '../../widgets/shared/grain_overlay.dart';
import '../../models/reward.dart';

class CardDetailScreen extends ConsumerWidget {
  final String cardId;
  const CardDetailScreen({super.key, required this.cardId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final card = ref.watch(walletProvider.select((cards) {
      try {
        return cards.firstWhere((c) => c.id == cardId || c.fallbackId == cardId);
      } catch (_) {
        return null;
      }
    }));
    final rewards = ref.watch(rewardsProvider).where((r) => r.cardId == cardId).toList();

    if (card == null) {
      return const Scaffold(body: Center(child: Text('Carte introuvable')));
    }

    return Scaffold(
      backgroundColor: AppColors.porcelaine,
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar: Back button + VOTRE CARTE header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => context.pop(),
                    icon: const Icon(Icons.arrow_back, color: AppColors.encre, size: 22),
                  ),
                  Expanded(
                    child: Text(
                      'VOTRE CARTE',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.monoSmall(color: AppColors.laitonBrosse).copyWith(
                        letterSpacing: 2.2,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 48), // Balancing back button width
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),

                    // Top QR Code Plate Container
                    _TopQrPlateCard(card: card),

                    const SizedBox(height: 24),

                    // Middle Restaurant Card Widget
                    _MiddleCardWidget(card: card),

                    const SizedBox(height: 32),

                    // Section Title: Récompenses
                    Text('Récompenses', style: AppTextStyles.displayLarge()),

                    const SizedBox(height: 16),

                    // Reward Card Widget
                    if (rewards.isNotEmpty)
                      _DetailedRewardCard(reward: rewards.first)
                    else
                      const _DetailedRewardCard(
                        reward: Reward(
                          id: 'default',
                          cardId: 'default',
                          restaurantName: 'Offre',
                          title: 'Récompense à venir',
                          description: 'Continuez à cumuler pour débloquer votre prochain privilège.',
                          status: RewardStatus.locked,
                        ),
                      ),

                    const SizedBox(height: 32),

                    // Historique Accordion Bar
                    _HistoryAccordionBar(card: card),

                    const SizedBox(height: 40),
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

/// Grand bloc supérieur pour la scannabilité du QR code
class _TopQrPlateCard extends StatelessWidget {
  final LoyaltyCard card;
  const _TopQrPlateCard({required this.card});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
      decoration: BoxDecoration(
        color: const Color(0xFFF3EFE7),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.laitonLisere(opacity: 0.35),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.encre.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          // Inner White Box for QR
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.encre.withOpacity(0.06)),
            ),
            child: SizedBox(
              width: 170,
              height: 170,
              child: CustomPaint(
                painter: _QrPainter(seed: card.fallbackId),
              ),
            ),
          ),

          const SizedBox(height: 14),

          // Action Plein écran
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.north_east_rounded, size: 14, color: AppColors.encre),
              const SizedBox(width: 6),
              Text(
                'Plein écran',
                style: AppTextStyles.bodyMedium(color: AppColors.encre).copyWith(
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Code ID & Copy Icon
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                card.fallbackId,
                style: AppTextStyles.monoMedium(color: AppColors.encre).copyWith(
                  letterSpacing: 2.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Identifiant copié')),
                  );
                },
                child: const Icon(
                  Icons.copy_outlined,
                  size: 16,
                  color: AppColors.laitonBrosse,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Carte du restaurant dans la partie médiane
class _MiddleCardWidget extends StatelessWidget {
  final LoyaltyCard card;
  const _MiddleCardWidget({required this.card});

  bool get _isDark => card.liningColor.computeLuminance() < 0.4;

  @override
  Widget build(BuildContext context) {
    final textColor = _isDark ? AppColors.porcelaine : AppColors.encre;
    final subtextColor = textColor.withOpacity(0.75);

    return Hero(
      tag: 'card_${card.id}',
      child: Material(
        type: MaterialType.transparency,
        child: Container(
          width: double.infinity,
          height: 190,
          decoration: BoxDecoration(
            color: card.liningColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: _isDark
                  ? AppColors.laitonLisere(opacity: 0.3)
                  : AppColors.encre.withOpacity(0.12),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.encre.withOpacity(0.12),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            GrainOverlay(borderRadius: BorderRadius.circular(20)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Ligne 1 : Catégorie & Fallback ID
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

                  const SizedBox(height: 6),

                  // Titre
                  Text(
                    card.restaurantName,
                    style: AppTextStyles.displayLarge(color: textColor).copyWith(
                      fontSize: 28,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Sous-titre & Valeur (CASHBACK / SOLDE / STATUT)
                  if (card.mechanic == LoyaltyMechanic.cashback) ...[
                    Text(
                      'CASHBACK',
                      style: AppTextStyles.monoSmall(color: subtextColor)
                          .copyWith(letterSpacing: 1.4),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          '3  400',
                          style: AppTextStyles.monoLarge(color: textColor).copyWith(
                            fontSize: 32,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 2.0,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'FCFA',
                          style: AppTextStyles.monoMedium(color: textColor).copyWith(
                            fontSize: 15,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ] else if (card.mechanic == LoyaltyMechanic.points) ...[
                    Text(
                      'SOLDE',
                      style: AppTextStyles.monoSmall(color: subtextColor)
                          .copyWith(letterSpacing: 1.4),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          '1  240',
                          style: AppTextStyles.monoLarge(color: textColor).copyWith(
                            fontSize: 32,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 2.0,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'PTS',
                          style: AppTextStyles.monoMedium(color: textColor).copyWith(
                            fontSize: 15,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ] else if (card.mechanic == LoyaltyMechanic.vip) ...[
                    Text(
                      'STATUT',
                      style: AppTextStyles.monoSmall(color: subtextColor)
                          .copyWith(letterSpacing: 1.4),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Container(
                          width: 48,
                          height: 24,
                          decoration: BoxDecoration(
                            color: AppColors.laitonBrosse,
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Platinum dans 3 visites',
                            style: AppTextStyles.bodyMedium(color: textColor).copyWith(
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ] else ...[
                    Text(
                      'TAMPONS',
                      style: AppTextStyles.monoSmall(color: subtextColor)
                          .copyWith(letterSpacing: 1.4),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${card.stampsCurrent} / ${card.stampsGoal}',
                      style: AppTextStyles.monoLarge(color: textColor),
                    ),
                  ],
                ],
              ),
            ),

            // Liseré doré inférieur pour la carte Mac Bouffe
            if (card.mechanic == LoyaltyMechanic.vip)
              Positioned(
                left: 20,
                right: 20,
                bottom: 16,
                child: Container(
                  height: 2,
                  decoration: BoxDecoration(
                    color: AppColors.laitonBrosse,
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
              ),
          ],
        ),
      ),
    ),
    ),
    );
  }
}

/// Carte de récompense individuelle (Maquettes 2, 3, 4)
class _DetailedRewardCard extends StatelessWidget {
  final Reward reward;
  const _DetailedRewardCard({required this.reward});

  @override
  Widget build(BuildContext context) {
    final isLocked = reward.status == RewardStatus.locked;
    final isReady = reward.status == RewardStatus.active;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFE5E2D7),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isReady
              ? AppColors.laitonBrosse
              : AppColors.laitonLisere(opacity: 0.25),
          width: isReady ? 1.2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isLocked ? 'VERROUILLÉ' : (isReady ? 'PRÊT' : 'ACTIF'),
            style: AppTextStyles.monoSmall(color: AppColors.laitonBrosse).copyWith(
              letterSpacing: 1.6,
              fontWeight: FontWeight.w600,
              fontSize: 10,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            reward.title,
            style: AppTextStyles.displayMedium().copyWith(
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            reward.description,
            style: AppTextStyles.bodyMedium(color: AppColors.encre.withOpacity(0.8)),
          ),
          const SizedBox(height: 12),
          Text(
            reward.lockedCondition ??
                (reward.expiresAt != null ? _countdownText(reward.expiresAt!) : 'DISPONIBLE'),
            style: AppTextStyles.monoSmall(
              color: AppColors.encre.withOpacity(0.65),
            ).copyWith(letterSpacing: 1.2),
          ),
        ],
      ),
    );
  }

  String _countdownText(DateTime dt) {
    final diff = dt.difference(DateTime.now());
    if (diff.inDays > 0) return 'EXPIRE DANS ${diff.inDays}J';
    return 'EXPIRE DANS ${diff.inHours}H';
  }
}

/// Accordéon de l'historique de visites
class _HistoryAccordionBar extends StatefulWidget {
  final LoyaltyCard card;
  const _HistoryAccordionBar({required this.card});

  @override
  State<_HistoryAccordionBar> createState() => _HistoryAccordionBarState();
}

class _HistoryAccordionBarState extends State<_HistoryAccordionBar> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFE5E2D7),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  const Icon(Icons.play_arrow_rounded, size: 18, color: AppColors.encre),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      'Historique',
                      style: AppTextStyles.displayMedium().copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Text(
                    '3  VISITES',
                    style: AppTextStyles.monoSmall(color: AppColors.laitonBrosse).copyWith(
                      letterSpacing: 1.6,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_expanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: Column(
                children: const [
                  Divider(color: Colors.black12),
                  SizedBox(height: 8),
                  _HistoryItem(date: '14 JUILLET', action: 'Visite enregistrée (+1)'),
                  _HistoryItem(date: '02 JUIN', action: 'Visite enregistrée (+1)'),
                  _HistoryItem(date: '18 MAI', action: 'Création de la carte'),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _HistoryItem extends StatelessWidget {
  final String date;
  final String action;
  const _HistoryItem({required this.date, required this.action});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(date, style: AppTextStyles.monoSmall(color: AppColors.encre)),
          Text(action, style: AppTextStyles.bodySmall(color: AppColors.encre.withOpacity(0.7))),
        ],
      ),
    );
  }
}

/// Custom QR Code Painter pour le rendu visuel net du QR Code
class _QrPainter extends CustomPainter {
  final String seed;
  _QrPainter({required this.seed});

  @override
  void paint(Canvas canvas, Size size) {
    const grid = 23;
    final cell = size.width / grid;
    final paint = Paint()..color = AppColors.encre;
    int hash = seed.codeUnits.fold(0, (a, b) => a * 31 + b);

    for (int y = 0; y < grid; y++) {
      for (int x = 0; x < grid; x++) {
        hash = (hash * 1103515245 + 12345) & 0x7fffffff;
        final onFinder = (x < 7 && y < 7) ||
            (x > grid - 8 && y < 7) ||
            (x < 7 && y > grid - 8);
        final on = onFinder ? _finderPattern(x % 7, y % 7) : (hash % 4 == 0);
        if (on) {
          canvas.drawRect(
            Rect.fromLTWH(x * cell, y * cell, cell * 0.94, cell * 0.94),
            paint,
          );
        }
      }
    }
  }

  bool _finderPattern(int x, int y) {
    if (x == 0 || x == 6 || y == 0 || y == 6) return true;
    if (x >= 2 && x <= 4 && y >= 2 && y <= 4) return true;
    return false;
  }

  @override
  bool shouldRepaint(covariant _QrPainter oldDelegate) => oldDelegate.seed != seed;
}

