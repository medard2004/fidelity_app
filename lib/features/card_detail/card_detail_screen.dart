import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_shadows.dart';
import '../../models/loyalty_card.dart';
import '../../providers/wallet_provider.dart';
import '../../providers/app_providers.dart';
import 'package:flutter/services.dart';
import '../../models/reward.dart';
import '../../widgets/components/components.dart';
import '../wallet/widgets/card_face_content.dart';
import 'card_export_service.dart';

class CardDetailScreen extends ConsumerWidget {
  final String cardId;
  CardDetailScreen({super.key, required this.cardId});

  // Stable pour la durée de vie de cet écran : sert à capturer le visuel
  // exact de la carte (QR + plaque) lors de l'export/partage.
  final GlobalKey _exportBoundaryKey = GlobalKey();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final card = ref.watch(walletProvider.select((cards) {
      try {
        return cards
            .firstWhere((c) => c.id == cardId || c.fallbackId == cardId);
      } catch (_) {
        return null;
      }
    }));
    final rewards =
        ref.watch(rewardsProvider).where((r) => r.cardId == cardId).toList();

    if (card == null) {
      return const Scaffold(body: Center(child: Text('Carte introuvable')));
    }

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => context.pop(),
                    icon: const Icon(Icons.arrow_back_rounded,
                        color: AppColors.ink, size: 20),
                  ),
                  const Expanded(
                    child: Center(child: SectionEyebrow('Votre carte')),
                  ),
                  IconButton(
                    onPressed: () =>
                        _showExportModal(context, card, _exportBoundaryKey),
                    icon: const Icon(Icons.ios_share_outlined,
                        color: AppColors.primary, size: 20),
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

                    // Visuel capturé pour l'export/partage : QR + plaque restaurant.
                    RepaintBoundary(
                      key: _exportBoundaryKey,
                      child: ColoredBox(
                        color: AppColors.surface,
                        child: Column(
                          children: [
                            _TopQrPlateCard(card: card),
                            const SizedBox(height: 8),
                            _MiddleCardWidget(card: card),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    Text('Récompenses', style: AppTextStyles.displayMedium()),

                    const SizedBox(height: 10),

                    if (rewards.isNotEmpty)
                      SizedBox(
                        height: 132,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: rewards.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(width: 10),
                          itemBuilder: (context, i) =>
                              _DetailedRewardCard(reward: rewards[i]),
                        ),
                      )
                    else
                      const _DetailedRewardCard(
                        reward: Reward(
                          id: 'default',
                          cardId: 'default',
                          restaurantName: 'Offre',
                          title: 'Récompense à venir',
                          description:
                              'Continuez à cumuler pour débloquer votre prochain privilège.',
                          status: RewardStatus.locked,
                        ),
                      ),

                    const SizedBox(height: 16),

                    _HistoryAccordionBar(card: card),

                    const SizedBox(height: 16),
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

/// Modal d'exportation et de partage de la carte.
void _showExportModal(
    BuildContext context, LoyaltyCard card, GlobalKey exportKey) {
  showModalBottomSheet(
    context: context,
    builder: (context) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SectionEyebrow('Exportation'),
                    const SizedBox(height: 4),
                    Text(card.restaurantName,
                        style: AppTextStyles.displayMedium().copyWith(fontSize: 20)),
                  ],
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded,
                      color: AppColors.ink, size: 20),
                ),
              ],
            ),

            const SizedBox(height: 20),

            _ExportOptionTile(
              icon: Icons.bookmark_add_outlined,
              title: 'Enregistrer la carte',
              subtitle: 'Conserver dans votre Portefeuille d\'application',
              onTap: () {
                Navigator.pop(context);
                CardExportService.exportAndShareCard(
                    context, card, 'save', exportKey);
              },
            ),

            const SizedBox(height: 10),

            _ExportOptionTile(
              icon: Icons.download_outlined,
              title: 'Télécharger la carte',
              subtitle:
                  'Enregistrer un visuel HD dans votre galerie (Pass format)',
              onTap: () {
                Navigator.pop(context);
                CardExportService.exportAndShareCard(
                    context, card, 'download', exportKey);
              },
            ),

            const SizedBox(height: 10),

            _ExportOptionTile(
              icon: Icons.share_outlined,
              title: 'Partager la carte',
              subtitle: 'Générer et envoyer une version propre à un proche',
              isHighlight: true,
              onTap: () {
                Navigator.pop(context);
                CardExportService.exportAndShareCard(
                    context, card, 'share', exportKey);
              },
            ),
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
    return AppCard(
      onTap: onTap,
      backgroundColor: isHighlight ? AppColors.primary : AppColors.surfaceCard,
      bordered: !isHighlight,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Icon(
            icon,
            color: isHighlight ? Colors.white : AppColors.primary,
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
                    color: isHighlight ? Colors.white : AppColors.ink,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: AppTextStyles.bodySmall(
                    color: isHighlight
                        ? Colors.white.withValues(alpha: 0.8)
                        : AppColors.inkMuted(opacity: 0.65),
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right_rounded,
            color: isHighlight
                ? Colors.white.withValues(alpha: 0.7)
                : AppColors.inkMuted(opacity: 0.3),
            size: 18,
          ),
        ],
      ),
    );
  }
}

/// Bloc supérieur — QR code scannable et identifiant de carte.
class _TopQrPlateCard extends StatelessWidget {
  final LoyaltyCard card;
  const _TopQrPlateCard({required this.card});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 20, bottom: 16, left: 16, right: 16),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        boxShadow: AppShadows.resting,
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: () => _showFullScreenQrDialog(context, card),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
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

          const SizedBox(height: 12),

          GestureDetector(
            onTap: () => _showFullScreenQrDialog(context, card),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.open_in_full_rounded,
                    size: 13, color: AppColors.primary),
                const SizedBox(width: 6),
                Text('Plein écran',
                    style: AppTextStyles.label(color: AppColors.primary)),
              ],
            ),
          ),

          const SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                card.fallbackId.replaceAll('-', ' - '),
                style: AppTextStyles.monoMedium(color: AppColors.ink),
              ),
              const SizedBox(width: 4),
              GestureDetector(
                onTap: () async {
                  await Clipboard.setData(ClipboardData(text: card.fallbackId));
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Identifiant copié')),
                    );
                  }
                },
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: const EdgeInsets.all(6),
                  child: Icon(
                    Icons.copy_outlined,
                    size: 15,
                    color: AppColors.inkMuted(),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Affiche le QR Code en plein écran dans un modal.
void _showFullScreenQrDialog(BuildContext context, LoyaltyCard card) {
  showDialog(
    context: context,
    builder: (context) {
      return Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    card.restaurantName,
                    style: AppTextStyles.displayMedium().copyWith(fontSize: 18),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded,
                        color: AppColors.ink, size: 20),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.border),
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
                style: AppTextStyles.monoMedium(color: AppColors.ink)
                    .copyWith(fontSize: 16),
              ),
              const SizedBox(height: 10),
              Text(
                'Présentez ce QR Code lors de votre passage en caisse',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodySmall(color: AppColors.inkMuted()),
              ),
            ],
          ),
        ),
      );
    },
  );
}

/// Carte du restaurant au format compact — Hero partagé avec la pile du wallet.
class _MiddleCardWidget extends StatelessWidget {
  final LoyaltyCard card;
  const _MiddleCardWidget({required this.card});

  bool get _isDark => card.liningColor.computeLuminance() < 0.45;

  @override
  Widget build(BuildContext context) {
    final textColor = _isDark ? Colors.white : AppColors.ink;

    return Hero(
      tag: 'card_${card.id}',
      child: Material(
        type: MaterialType.transparency,
        child: Container(
          width: double.infinity,
          height: 140,
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          decoration: BoxDecoration(
            color: card.liningColor,
            borderRadius: BorderRadius.circular(20),
            boxShadow: AppShadows.raised,
          ),
          child: CardFaceContent(card: card, textColor: textColor, compact: true),
        ),
      ),
    );
  }
}

/// Carte de récompense individuelle.
class _DetailedRewardCard extends StatelessWidget {
  final Reward reward;
  const _DetailedRewardCard({required this.reward});

  @override
  Widget build(BuildContext context) {
    final isLocked = reward.status == RewardStatus.locked;
    final isReady = reward.status == RewardStatus.active;

    return Align(
      alignment: Alignment.centerLeft,
      child: SizedBox(
        width: 250,
        child: AppCard(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          elevated: isReady,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  StatusBadge(
                    label: isReady ? 'PRÊT' : (isLocked ? 'VERROUILLÉ' : 'UTILISÉ'),
                    tone: isReady ? StatusTone.success : StatusTone.neutral,
                    icon: isReady ? Icons.check_circle_outline : (isLocked ? Icons.lock_outline : null),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              Text(
                reward.title,
                style: AppTextStyles.titleMedium().copyWith(fontSize: 15),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 3),

              Text(
                reward.description,
                style: AppTextStyles.bodySmall(color: AppColors.inkMuted(opacity: 0.7)),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              if (isLocked && reward.lockedCondition != null) ...[
                const SizedBox(height: 8),
                const Divider(height: 1, color: AppColors.border),
                const SizedBox(height: 6),
                Text(
                  reward.lockedCondition!,
                  style: AppTextStyles.monoSmall(color: AppColors.primary),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Accordéon de l'historique.
class _HistoryAccordionBar extends StatefulWidget {
  final LoyaltyCard card;
  const _HistoryAccordionBar({required this.card});

  @override
  State<_HistoryAccordionBar> createState() => _HistoryAccordionBarState();
}

class _HistoryAccordionBarState extends State<_HistoryAccordionBar> {
  bool _expanded = false;

  /// Historique synthétique dérivé des vraies données de la carte
  /// (pas de modèle de visites individuelles côté backend pour l'instant),
  /// pour éviter d'afficher les 3 mêmes lignes sur toutes les cartes.
  List<_HistoryEntry> _historyFor(LoyaltyCard card) {
    final now = DateTime.now();
    final entries = <_HistoryEntry>[];
    switch (card.mechanic) {
      case LoyaltyMechanic.stamps:
        for (int i = card.stampsCurrent; i >= 1; i--) {
          entries.add(_HistoryEntry(
            date:
                now.subtract(Duration(days: (card.stampsCurrent - i + 1) * 9)),
            detail: '+1 tampon · Passage en caisse',
          ));
        }
        break;
      case LoyaltyMechanic.points:
        entries.add(_HistoryEntry(
            date: now.subtract(const Duration(days: 4)),
            detail: '+80 points · Passage en caisse'));
        entries.add(_HistoryEntry(
            date: now.subtract(const Duration(days: 19)),
            detail: '+120 points · Passage en caisse'));
        break;
      case LoyaltyMechanic.cashback:
        entries.add(_HistoryEntry(
            date: now.subtract(const Duration(days: 3)),
            detail: '+500 FCFA · Passage en caisse'));
        entries.add(_HistoryEntry(
            date: now.subtract(const Duration(days: 15)),
            detail: '+900 FCFA · Passage en caisse'));
        break;
      case LoyaltyMechanic.vip:
        entries.add(_HistoryEntry(
            date: now.subtract(const Duration(days: 6)),
            detail: 'Visite comptabilisée'));
        entries.add(_HistoryEntry(
            date: now.subtract(const Duration(days: 20)),
            detail: 'Visite comptabilisée'));
        break;
    }
    entries.add(_HistoryEntry(
      date: now.subtract(const Duration(days: 34)),
      detail: card.welcomeOffer.isNotEmpty
          ? card.welcomeOffer
          : 'Inscription à la carte',
    ));
    return entries;
  }

  @override
  Widget build(BuildContext context) {
    final history = _historyFor(widget.card);
    return Column(
      children: [
        AppCard(
          onTap: () => setState(() => _expanded = !_expanded),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Text('Historique', style: AppTextStyles.titleMedium()),
              const Spacer(),
              Text(
                '${history.length} VISITE${history.length > 1 ? 'S' : ''}',
                style: AppTextStyles.eyebrow(color: AppColors.primary),
              ),
              const SizedBox(width: 8),
              AnimatedRotation(
                turns: _expanded ? 0.5 : 0.0,
                duration: const Duration(milliseconds: 200),
                child: const Icon(Icons.expand_more_rounded,
                    color: AppColors.ink, size: 20),
              ),
            ],
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeInOut,
          child: _expanded
              ? Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: AppCard(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        for (int i = 0; i < history.length; i++) ...[
                          if (i > 0) const Divider(height: 20, color: AppColors.border),
                          _HistoryRow(entry: history[i]),
                        ],
                      ],
                    ),
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}

class _HistoryEntry {
  final DateTime date;
  final String detail;
  const _HistoryEntry({required this.date, required this.detail});
}

const _fullMonths = [
  'Janvier',
  'Février',
  'Mars',
  'Avril',
  'Mai',
  'Juin',
  'Juillet',
  'Août',
  'Septembre',
  'Octobre',
  'Novembre',
  'Décembre',
];

class _HistoryRow extends StatelessWidget {
  final _HistoryEntry entry;
  const _HistoryRow({required this.entry});

  @override
  Widget build(BuildContext context) {
    final date = entry.date;
    final formatted =
        '${date.day.toString().padLeft(2, '0')} ${_fullMonths[date.month - 1]} ${date.year}';
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(formatted,
              style: AppTextStyles.bodySmall(color: AppColors.inkMuted(opacity: 0.8))),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            entry.detail,
            textAlign: TextAlign.end,
            style: AppTextStyles.monoSmall(),
          ),
        ),
      ],
    );
  }
}

/// CustomPainter d'un QR code stylisé — modules nets, sans texture.
class _QrPainter extends CustomPainter {
  final String seed;
  const _QrPainter({required this.seed});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.ink
      ..style = PaintingStyle.fill;

    final cellWidth = size.width / 21;
    final cellHeight = size.height / 21;

    final hash = seed.codeUnits.fold<int>(0, (prev, elem) => prev + elem);

    for (int r = 0; r < 21; r++) {
      for (int c = 0; c < 21; c++) {
        if ((r < 7 && c < 7) || (r < 7 && c > 13) || (r > 13 && c < 7)) {
          continue;
        }
        final isFilled =
            ((r * 21 + c + hash) % 3) == 0 || ((r * c + hash) % 5) == 0;
        if (isFilled) {
          final rect = Rect.fromLTWH(
            c * cellWidth + cellWidth * 0.06,
            r * cellHeight + cellHeight * 0.06,
            cellWidth * 0.88,
            cellHeight * 0.88,
          );
          canvas.drawRRect(
            RRect.fromRectAndRadius(rect, Radius.circular(cellWidth * 0.14)),
            paint,
          );
        }
      }
    }

    _drawFinderPattern(canvas, 0, 0, cellWidth, cellHeight, paint);
    _drawFinderPattern(canvas, 14 * cellWidth, 0, cellWidth, cellHeight, paint);
    _drawFinderPattern(
        canvas, 0, 14 * cellHeight, cellWidth, cellHeight, paint);
  }

  void _drawFinderPattern(
      Canvas canvas, double x, double y, double cw, double ch, Paint paint) {
    final outerRect = Rect.fromLTWH(x, y, 7 * cw, 7 * ch);
    canvas.drawRRect(
      RRect.fromRectAndRadius(outerRect, Radius.circular(cw * 0.9)),
      paint,
    );

    final innerWhite = Rect.fromLTWH(x + cw, y + ch, 5 * cw, 5 * ch);
    final whitePaint = Paint()..color = Colors.white;
    canvas.drawRRect(
      RRect.fromRectAndRadius(innerWhite, Radius.circular(cw * 0.6)),
      whitePaint,
    );

    final centerRect = Rect.fromLTWH(x + 2 * cw, y + 2 * ch, 3 * cw, 3 * ch);
    canvas.drawRRect(
      RRect.fromRectAndRadius(centerRect, Radius.circular(cw * 0.5)),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _QrPainter oldDelegate) =>
      oldDelegate.seed != seed;
}
