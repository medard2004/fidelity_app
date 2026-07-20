import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_radius.dart';
import '../../models/loyalty_card.dart';
import '../../providers/wallet_provider.dart';
import '../../providers/app_providers.dart';
import '../../widgets/shared/brass_qr_plate.dart';
import '../../widgets/shared/grain_overlay.dart';
import 'widgets/stamp_progress.dart';
import 'widgets/reward_chip.dart';

class CardDetailScreen extends ConsumerWidget {
  final String cardId;
  const CardDetailScreen({super.key, required this.cardId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final card = ref.watch(walletProvider.select((cards) {
      try {
        return cards.firstWhere((c) => c.id == cardId);
      } catch (_) {
        return null;
      }
    }));
    final rewards = ref.watch(rewardsProvider).where((r) => r.cardId == cardId).toList();

    if (card == null) {
      return const Scaffold(body: Center(child: Text('Carte introuvable')));
    }

    final textColor = card.liningColor.computeLuminance() < 0.4
        ? AppColors.porcelaine
        : AppColors.encre;

    return Scaffold(
      backgroundColor: card.liningColor,
      body: Stack(
        children: [
          GrainOverlay(opacity: 0.02),
          SafeArea(
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          onPressed: () => context.pop(),
                          icon: Icon(Icons.arrow_back, color: textColor),
                        ),
                        Text(card.restaurantName,
                            style: AppTextStyles.displayMedium(color: textColor)),
                        const SizedBox(width: 48),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Column(
                      children: [
                        Hero(
                          tag: 'card_${card.id}',
                          child: BrassQrPlate(data: card.fallbackId),
                        ),
                        const SizedBox(height: 10),
                        FallbackIdRow(
                          fallbackId: card.fallbackId,
                          onCopy: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Identifiant copié')),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.porcelaine,
                      borderRadius: BorderRadius.circular(AppRadius.card),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Progression', style: AppTextStyles.label()),
                        const SizedBox(height: 14),
                        CardProgressWidget(card: card),
                        const SizedBox(height: 22),
                        Text('Récompenses', style: AppTextStyles.label()),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 96,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: rewards.length,
                            separatorBuilder: (_, __) => const SizedBox(width: 10),
                            itemBuilder: (context, i) => RewardChip(reward: rewards[i]),
                          ),
                        ),
                        const SizedBox(height: 22),
                        _HistoryAccordion(card: card),
                      ],
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 40)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HistoryAccordion extends StatefulWidget {
  final LoyaltyCard card;
  const _HistoryAccordion({required this.card});

  @override
  State<_HistoryAccordion> createState() => _HistoryAccordionState();
}

class _HistoryAccordionState extends State<_HistoryAccordion> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => setState(() => _open = !_open),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Historique', style: AppTextStyles.label()),
              Icon(_open ? Icons.expand_less : Icons.expand_more,
                  size: 18, color: AppColors.encre.withOpacity(0.5)),
            ],
          ),
        ),
        AnimatedCrossFade(
          crossFadeState: _open ? CrossFadeState.showFirst : CrossFadeState.showSecond,
          duration: const Duration(milliseconds: 220),
          firstChild: Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Column(
              children: [
                _HistoryRow(date: '12/07', label: 'Visite enregistrée', value: '+1'),
                _HistoryRow(date: '02/07', label: 'Récompense utilisée', value: '—'),
                _HistoryRow(date: '18/06', label: 'Visite enregistrée', value: '+1'),
              ],
            ),
          ),
          secondChild: const SizedBox.shrink(),
        ),
      ],
    );
  }
}

class _HistoryRow extends StatelessWidget {
  final String date;
  final String label;
  final String value;
  const _HistoryRow({required this.date, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Text(date, style: AppTextStyles.monoSmall()),
          const SizedBox(width: 12),
          Expanded(child: Text(label, style: AppTextStyles.bodySmall())),
          Text(value, style: AppTextStyles.monoSmall()),
        ],
      ),
    );
  }
}
