import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/loyalty_card.dart';
import '../../providers/wallet_provider.dart';
import '../../providers/app_providers.dart';
import '../../widgets/shared/grain_overlay.dart';
import '../../models/reward.dart';
import 'card_export_service.dart';
import '../../core/utils/toast_service.dart';

class CardDetailScreen extends ConsumerWidget {
  final String cardId;
  const CardDetailScreen({super.key, required this.cardId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final card = ref.watch(walletProvider.select((cardsAsync) {
      final cards = cardsAsync.valueOrNull;
      if (cards == null) return null;
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
            // Top Bar: Back button + VOTRE CARTE header + Export/Share action
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => context.pop(),
                    icon: const Icon(Icons.arrow_back, color: AppColors.encre, size: 20),
                  ),
                  Expanded(
                    child: Text(
                      'VOTRE CARTE',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.monoSmall(color: AppColors.laitonBrosse).copyWith(
                        letterSpacing: 2.5,
                        fontWeight: FontWeight.w500,
                        fontSize: 10,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => _showExportModal(context, card),
                    icon: const Icon(Icons.ios_share_outlined, color: AppColors.laitonBrosse, size: 20),
                    tooltip: 'Exporter / Partager',
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 2),

                    // Top QR Code Plate Container (Compacted for direct visibility without scroll)
                    _TopQrPlateCard(card: card),

                    const SizedBox(height: 8),

                    // Middle Restaurant Card Widget (Compacted to height 140)
                    _MiddleCardWidget(card: card),

                    const SizedBox(height: 12),

                    // Section Title & Header: Récompenses
                    Text(
                      'Récompenses',
                      style: AppTextStyles.displayLarge().copyWith(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 6),

                    // Reward Card Widget (Visible without scroll!)
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

                    const SizedBox(height: 12),

                    // Historique Accordion Bar
                    _HistoryAccordionBar(card: card),

                    const SizedBox(height: 12),
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

/// Modal d'Exportation et de Partage de la carte
void _showExportModal(BuildContext context, LoyaltyCard card) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (context) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: AppColors.porcelaine,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 20,
              offset: Offset(0, -6),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header du modal
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'EXPORTATION',
                      style: AppTextStyles.monoSmall(color: AppColors.laitonBrosse).copyWith(
                        letterSpacing: 2.0,
                        fontSize: 10,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      card.restaurantName,
                      style: AppTextStyles.displayMedium().copyWith(fontSize: 20),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: AppColors.encre, size: 20),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Option 1 : Enregistrer la carte
            _ExportOptionTile(
              icon: Icons.bookmark_add_outlined,
              title: 'Enregistrer la carte',
              subtitle: 'Conserver dans votre Portefeuille d\'application',
              onTap: () {
                Navigator.pop(context);
                CardExportService.exportAndShareCard(context, card, 'save');
              },
            ),

            const SizedBox(height: 12),

            // Option 2 : Télécharger la carte
            _ExportOptionTile(
              icon: Icons.download_outlined,
              title: 'Télécharger la carte',
              subtitle: 'Enregistrer un visuel HD dans votre galerie (Pass format)',
              onTap: () {
                Navigator.pop(context);
                CardExportService.exportAndShareCard(context, card, 'download');
              },
            ),

            const SizedBox(height: 12),

            // Option 3 : Partager la carte
            _ExportOptionTile(
              icon: Icons.share_outlined,
              title: 'Partager la carte',
              subtitle: 'Générer et envoyer une version propre à un proche',
              isHighlight: true,
              onTap: () {
                Navigator.pop(context);
                CardExportService.exportAndShareCard(context, card, 'share');
              },
            ),

            const SizedBox(height: 16),
          ],
        ),
      );
    },
  );
}

class _ExportOptionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool isHighlight;

  const _ExportOptionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.isHighlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isHighlight ? AppColors.vertBouteille : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isHighlight
                ? AppColors.vertBouteille
                : AppColors.laitonLisere(opacity: 0.3),
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isHighlight ? AppColors.porcelaine : AppColors.laitonBrosse,
              size: 22,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.label(
                      color: isHighlight ? AppColors.porcelaine : AppColors.encre,
                    ).copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppTextStyles.bodySmall(
                      color: isHighlight
                          ? AppColors.porcelaine.withOpacity(0.8)
                          : AppColors.encre.withOpacity(0.65),
                    ).copyWith(fontSize: 11),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: isHighlight
                  ? AppColors.porcelaine.withOpacity(0.7)
                  : AppColors.encre.withOpacity(0.3),
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}

/// Bloc supérieur compacté pour la scannabilité du QR code
class _TopQrPlateCard extends StatelessWidget {
  final LoyaltyCard card;
  const _TopQrPlateCard({required this.card});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 16, bottom: 12, left: 16, right: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F1E9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE8E4D9),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Inner White Box for QR
          GestureDetector(
            onTap: () => _showFullScreenQrDialog(context, card),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE8E4D9)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: SizedBox(
                width: 170,
                height: 170,
                child: CustomPaint(
                  painter: _QrPainter(seed: card.fallbackId),
                ),
              ),
            ),
          ),

          const SizedBox(height: 10),

          // Action Plein écran
          GestureDetector(
            onTap: () => _showFullScreenQrDialog(context, card),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.open_in_full, size: 12, color: AppColors.encre.withOpacity(0.85)),
                const SizedBox(width: 6),
                Text(
                  'Plein écran',
                  style: AppTextStyles.bodyMedium(color: AppColors.encre.withOpacity(0.95)).copyWith(
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // Code ID
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                card.fallbackId.replaceAll('-', ' - '),
                style: AppTextStyles.monoMedium(color: AppColors.encre).copyWith(
                  letterSpacing: 2.5,
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () {
                  ToastService.showSuccess('Identifiant copié');
                },
                child: const Icon(
                  Icons.copy_outlined,
                  size: 15,
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

/// Affiche le QR Code en plein écran dans un modal élégant
void _showFullScreenQrDialog(BuildContext context, LoyaltyCard card) {
  showDialog(
    context: context,
    builder: (context) {
      return Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFFF4F1E9),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: const Color(0xFFE8E4D9)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.18),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    card.restaurantName,
                    style: AppTextStyles.displayMedium().copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, color: AppColors.encre, size: 20),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE8E4D9)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: SizedBox(
                  width: 230,
                  height: 230,
                  child: CustomPaint(
                    painter: _QrPainter(seed: card.fallbackId),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                card.fallbackId.replaceAll('-', ' - '),
                style: AppTextStyles.monoMedium(color: AppColors.encre).copyWith(
                  letterSpacing: 2.5,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Présentez ce QR Code lors de votre passage en caisse',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodySmall(color: AppColors.encre.withOpacity(0.7)),
              ),
            ],
          ),
        ),
      );
    },
  );
}

/// Carte du restaurant compactée (hauteur 160px)
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
          height: 140,
          decoration: BoxDecoration(
            color: card.liningColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _isDark
                  ? AppColors.laitonLisere(opacity: 0.3)
                  : AppColors.encre.withOpacity(0.1),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.encre.withOpacity(0.10),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              children: [
                GrainOverlay(borderRadius: BorderRadius.circular(16)),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Ligne 1 : Catégorie & Fallback ID
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              card.restaurantCategory.toUpperCase(),
                              style: AppTextStyles.monoSmall(color: subtextColor).copyWith(
                                letterSpacing: 1.8,
                                fontSize: 9.5,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            card.fallbackId,
                            style: AppTextStyles.monoSmall(color: subtextColor).copyWith(
                              letterSpacing: 1.2,
                              fontSize: 9.5,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),

                      // Titre Restaurant
                      Text(
                        card.restaurantName,
                        style: AppTextStyles.displayLarge(color: textColor).copyWith(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          height: 1.05,
                        ),
                      ),

                      // Section mécanique
                      if (card.mechanic == LoyaltyMechanic.cashback) ...[
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'CASHBACK',
                              style: AppTextStyles.monoSmall(color: subtextColor).copyWith(
                                letterSpacing: 1.5,
                                fontSize: 9.5,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: [
                                Text(
                                  _formatGroupedNumber(card.cashbackBalanceFcfa),
                                  style: AppTextStyles.monoLarge(color: textColor).copyWith(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'FCFA',
                                  style: AppTextStyles.monoMedium(color: textColor).copyWith(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ] else if (card.mechanic == LoyaltyMechanic.points) ...[
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'SOLDE',
                              style: AppTextStyles.monoSmall(color: subtextColor).copyWith(
                                letterSpacing: 1.5,
                                fontSize: 9.5,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: [
                                Text(
                                  _formatGroupedNumber(card.pointsBalance),
                                  style: AppTextStyles.monoLarge(color: textColor).copyWith(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'PTS',
                                  style: AppTextStyles.monoMedium(color: textColor).copyWith(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ] else if (card.mechanic == LoyaltyMechanic.vip) ...[
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'STATUT',
                              style: AppTextStyles.monoSmall(color: subtextColor).copyWith(
                                letterSpacing: 1.5,
                                fontSize: 9.5,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Container(
                                  width: 40,
                                  height: 18,
                                  decoration: BoxDecoration(
                                    color: AppColors.laitonBrosse,
                                    borderRadius: BorderRadius.circular(9),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    'Platinum dans ${((1 - card.vipProgressToNextTier) * 12).ceil()} visites',
                                    style: AppTextStyles.bodyMedium(color: textColor).copyWith(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w400,
                                      height: 1.1,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ] else ...[
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'TAMPONS',
                              style: AppTextStyles.monoSmall(color: subtextColor).copyWith(
                                letterSpacing: 1.5,
                                fontSize: 9.5,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${card.stampsCurrent} / ${card.stampsGoal}',
                              style: AppTextStyles.monoLarge(color: textColor).copyWith(
                                fontSize: 22,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),

                if (card.mechanic == LoyaltyMechanic.vip)
                  Positioned(
                    left: 18,
                    bottom: 14 + 18,
                    child: Container(
                      height: 1,
                      width: 40,
                      color: AppColors.laitonBrosse.withOpacity(0.8),
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

/// Carte de récompense individuelle (frame compact de ~228px aligné à gauche)
class _DetailedRewardCard extends StatelessWidget {
  final Reward reward;
  const _DetailedRewardCard({required this.reward});

  @override
  Widget build(BuildContext context) {
    final isLocked = reward.status == RewardStatus.locked;
    final isReady = reward.status == RewardStatus.active;

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        width: 250,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isReady
              ? const Color(0xFFF2EEE4)
              : const Color(0xFFEBE8DD),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isReady
                ? AppColors.laitonBrosse.withOpacity(0.65)
                : const Color(0xFFDFDACB),
            width: isReady ? 1.2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isReady ? 0.04 : 0.02),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Pillule de statut supérieure
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isReady ? 'PRÊT' : (isLocked ? 'VERROUILLÉ' : 'UTILISÉ'),
                  style: AppTextStyles.monoSmall(
                    color: AppColors.laitonBrosse,
                  ).copyWith(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 1.5,
                  ),
                ),
                if (isReady)
                  const Icon(Icons.star_rounded, size: 14, color: AppColors.laitonBrosse),
              ],
            ),

            const SizedBox(height: 8),

            // Titre de la récompense
            Text(
              reward.title,
              style: AppTextStyles.displayMedium().copyWith(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                height: 1.15,
                color: AppColors.encre,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: 3),

            // Description
            Text(
              reward.description,
              style: AppTextStyles.bodyMedium().copyWith(
                fontSize: 11.5,
                color: AppColors.encre.withOpacity(0.7),
                height: 1.25,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            if (isLocked && reward.lockedCondition != null) ...[
              const SizedBox(height: 8),
              Container(
                height: 1,
                width: double.infinity,
                color: AppColors.laitonBrosse.withOpacity(0.4),
              ),
              const SizedBox(height: 6),
              Text(
                reward.lockedCondition!,
                style: AppTextStyles.monoSmall().copyWith(
                  fontSize: 9.5,
                  color: AppColors.laitonBrosse,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Accordéon de l'historique
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
    return Column(
      children: [
        GestureDetector(
          onTap: () => setState(() => _expanded = !_expanded),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF4F1E9),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE8E4D9)),
            ),
            child: Row(
              children: [
                AnimatedRotation(
                  turns: _expanded ? 0.25 : 0.0,
                  duration: const Duration(milliseconds: 200),
                  child: const Icon(Icons.play_arrow, color: AppColors.encre, size: 16),
                ),
                const Spacer(),
                Text(
                  'Historique',
                  style: AppTextStyles.displayMedium().copyWith(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                const Spacer(),
                Text(
                  '3 VISITES',
                  style: AppTextStyles.monoSmall(color: AppColors.laitonBrosse).copyWith(
                    letterSpacing: 1.5,
                    fontWeight: FontWeight.w500,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ),

        if (_expanded)
          Container(
            margin: const EdgeInsets.only(top: 8),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE8E4D9)),
            ),
            child: Column(
              children: const [
                _HistoryRow(date: '14 Juillet 2026', detail: '+1 tampon · Passage en caisse'),
                Divider(height: 16),
                _HistoryRow(date: '02 Juin 2026', detail: '+1 tampon · Passage en caisse'),
                Divider(height: 16),
                _HistoryRow(date: '18 Mai 2026', detail: 'Offre de bienvenue validée'),
              ],
            ),
          ),
      ],
    );
  }
}

class _HistoryRow extends StatelessWidget {
  final String date;
  final String detail;
  const _HistoryRow({required this.date, required this.detail});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(date, style: AppTextStyles.bodySmall(color: AppColors.encre).copyWith(fontSize: 11)),
        Text(detail, style: AppTextStyles.monoSmall().copyWith(fontSize: 10)),
      ],
    );
  }
}

String _formatGroupedNumber(int number) {
  final str = number.toString();
  final reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
  return str.replaceAllMapped(reg, (Match m) => '${m[1]} ');
}

/// CustomPainter du QR Code haute précision
class _QrPainter extends CustomPainter {
  final String seed;
  const _QrPainter({required this.seed});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF1B1A17)
      ..style = PaintingStyle.fill;

    final cellWidth = size.width / 21;
    final cellHeight = size.height / 21;

    final hash = seed.codeUnits.fold<int>(0, (prev, elem) => prev + elem);

    // Dessin du quadrillage QR
    for (int r = 0; r < 21; r++) {
      for (int c = 0; c < 21; c++) {
        if ((r < 7 && c < 7) || (r < 7 && c > 13) || (r > 13 && c < 7)) {
          continue;
        }
        final isFilled = ((r * 21 + c + hash) % 3) == 0 || ((r * c + hash) % 5) == 0;
        if (isFilled) {
          final rect = Rect.fromLTWH(
            c * cellWidth + cellWidth * 0.08,
            r * cellHeight + cellHeight * 0.08,
            cellWidth * 0.84,
            cellHeight * 0.84,
          );
          canvas.drawRRect(
            RRect.fromRectAndRadius(rect, Radius.circular(cellWidth * 0.25)),
            paint,
          );
        }
      }
    }

    // Dessin des 3 Finder Patterns
    _drawFinderPattern(canvas, 0, 0, cellWidth, cellHeight, paint);
    _drawFinderPattern(canvas, 14 * cellWidth, 0, cellWidth, cellHeight, paint);
    _drawFinderPattern(canvas, 0, 14 * cellHeight, cellWidth, cellHeight, paint);
  }

  void _drawFinderPattern(Canvas canvas, double x, double y, double cw, double ch, Paint paint) {
    final outerRect = Rect.fromLTWH(x, y, 7 * cw, 7 * ch);
    canvas.drawRRect(
      RRect.fromRectAndRadius(outerRect, Radius.circular(cw * 1.5)),
      paint,
    );

    final innerWhite = Rect.fromLTWH(x + cw, y + ch, 5 * cw, 5 * ch);
    final whitePaint = Paint()..color = Colors.white;
    canvas.drawRRect(
      RRect.fromRectAndRadius(innerWhite, Radius.circular(cw * 1.0)),
      whitePaint,
    );

    final centerRect = Rect.fromLTWH(x + 2 * cw, y + 2 * ch, 3 * cw, 3 * ch);
    canvas.drawRRect(
      RRect.fromRectAndRadius(centerRect, Radius.circular(cw * 0.8)),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _QrPainter oldDelegate) => oldDelegate.seed != seed;
}
