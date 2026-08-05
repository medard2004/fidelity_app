import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_shadows.dart';
import '../../models/loyalty_card.dart';
import '../../providers/wallet_provider.dart';
import '../../providers/referral_provider.dart';
import '../../widgets/components/components.dart';

/// Écran de Parrainage Partenaire
/// Permet de :
/// 1. Choisir le restaurant partenaire à parrainer.
/// 2. Personnaliser le message d'invitation.
/// 3. Sélectionner/saisir plusieurs destinataires.
/// 4. Partager l'invitation avec système anti-fraude (100 partages valides = 3 points).
class ReferralScreen extends ConsumerStatefulWidget {
  const ReferralScreen({super.key});

  @override
  ConsumerState<ReferralScreen> createState() => _ReferralScreenState();
}

class _ReferralScreenState extends ConsumerState<ReferralScreen> {
  final _recipientController = TextEditingController();
  late final TextEditingController _messageController;

  @override
  void initState() {
    super.initState();
    final initialMessage = ref.read(referralProvider).customMessage;
    _messageController = TextEditingController(text: initialMessage);
  }

  @override
  void dispose() {
    _recipientController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _addRecipient() {
    final text = _recipientController.text.trim();
    if (text.isEmpty) return;
    final added = ref.read(referralProvider.notifier).addRecipient(text);
    if (added) {
      _recipientController.clear();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ce destinataire est déjà dans votre liste d\'envoi.'),
        ),
      );
    }
  }

  void _sendShares(LoyaltyCard selectedCard) {
    final result =
        ref.read(referralProvider.notifier).sendReferrals(selectedCard);

    if (result['success'] == true) {
      final added = result['addedCount'] as int;
      final dup = result['duplicateCount'] as int;

      final message = StringBuffer();
      if (added > 0) {
        message.write('$added invitation(s) envoyée(s) et validée(s) ! ');
      }
      if (dup > 0) {
        message.write('$dup doublon(s) ignoré(s) (Anti-fraude).');
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message.toString()),
          duration: const Duration(seconds: 4),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Veuillez ajouter au moins un destinataire avant d\'envoyer.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cards = ref.watch(walletProvider);
    final refState = ref.watch(referralProvider);

    if (cards.isEmpty) {
      return Scaffold(
        backgroundColor: AppColors.surface,
        appBar: AppBar(
          centerTitle: true,
          title: Text('Parrainage', style: AppTextStyles.displayMedium().copyWith(fontSize: 20)),
        ),
        body: const Center(
          child: EmptyState(
            icon: LucideIcons.users,
            title: 'Aucune carte à parrainer',
            message:
                'Rejoignez au moins un établissement pour pouvoir le recommander à vos proches.',
          ),
        ),
      );
    }

    // Trouver le partenaire actuellement sélectionné
    final selectedCard = cards.firstWhere(
      (c) => c.id == refState.selectedRestaurantId,
      orElse: () => cards.first,
    );

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        centerTitle: true,
        title: Text('Parrainage', style: AppTextStyles.displayMedium().copyWith(fontSize: 20)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Faites découvrir vos commerces et partenaires favoris à vos proches et cumulez des points de fidélité.',
              style: AppTextStyles.bodyMedium(color: AppColors.inkMuted(opacity: 0.65)),
            ),

            const SizedBox(height: 20),

            _ProgressionCard(refState: refState),

            const SizedBox(height: 24),

            const _StepHeader(stepNumber: '1', title: 'Choisir le partenaire à parrainer'),
            const SizedBox(height: 10),
            SizedBox(
              height: 72,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: cards.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (context, i) {
                  final card = cards[i];
                  final isSelected = card.id == selectedCard.id;
                  return _RestaurantSelectorChip(
                    card: card,
                    isSelected: isSelected,
                    onTap: () {
                      ref.read(referralProvider.notifier).selectRestaurant(card);
                      _messageController.text = ref.read(referralProvider).customMessage;
                    },
                  );
                },
              ),
            ),

            const SizedBox(height: 24),

            const _StepHeader(stepNumber: '2', title: 'Personnaliser votre invitation'),
            const SizedBox(height: 10),
            TextField(
              controller: _messageController,
              maxLines: 3,
              onChanged: (val) => ref.read(referralProvider.notifier).updateMessage(val),
            ),

            const SizedBox(height: 24),

            const _StepHeader(stepNumber: '3', title: 'Ajouter des destinataires'),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _recipientController,
                    keyboardType: TextInputType.text,
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(hintText: '+228 90 00 00 00 ou Nom'),
                    onSubmitted: (_) => _addRecipient(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  onPressed: _addRecipient,
                  icon: const Icon(LucideIcons.plus, color: Colors.white),
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.all(14),
                  ),
                ),
              ],
            ),

            if (refState.recipients.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: refState.recipients.map((r) {
                  return SelectableChip(
                    label: r,
                    onDeleted: () => ref.read(referralProvider.notifier).removeRecipient(r),
                  );
                }).toList(),
              ),
            ],

            const SizedBox(height: 28),

            AppButton(
              label:
                  'Partager l\'invitation (${refState.recipients.length} destinataire${refState.recipients.length > 1 ? "s" : ""})',
              icon: LucideIcons.send,
              onTap: () => _sendShares(selectedCard),
            ),

            const SizedBox(height: 28),

            _AntiFraudHistorySection(records: refState.records),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Widgets composants du parrainage
// ─────────────────────────────────────────────────────────────────────────────

class _StepHeader extends StatelessWidget {
  final String stepNumber;
  final String title;

  const _StepHeader({required this.stepNumber, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 22,
          height: 22,
          decoration: const BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              stepNumber,
              style: AppTextStyles.monoSmall(color: Colors.white).copyWith(fontWeight: FontWeight.w600),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(title, style: AppTextStyles.titleMedium().copyWith(fontSize: 14)),
      ],
    );
  }
}

class _RestaurantSelectorChip extends StatelessWidget {
  final LoyaltyCard card;
  final bool isSelected;
  final VoidCallback onTap;

  const _RestaurantSelectorChip({
    required this.card,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 150,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surfaceCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
          ),
          boxShadow: isSelected ? null : AppShadows.resting,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              card.restaurantName,
              style: AppTextStyles.label(color: isSelected ? Colors.white : AppColors.ink),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              card.restaurantCategory,
              style: AppTextStyles.bodySmall(
                color: isSelected ? Colors.white.withValues(alpha: 0.75) : AppColors.inkMuted(opacity: 0.55),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _ProgressionCard extends StatelessWidget {
  final ReferralState refState;
  const _ProgressionCard({required this.refState});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.ink,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppShadows.raised,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Flexible(
                child: Text(
                  'VOS POINTS PARRAINAGE',
                  style: AppTextStyles.eyebrow(color: Colors.white.withValues(alpha: 0.6)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '100 partages = 3 pts',
                  style: AppTextStyles.monoSmall(color: Colors.white.withValues(alpha: 0.8)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text('${refState.pointsEarned}', style: AppTextStyles.monoLarge(color: Colors.white)),
              const SizedBox(width: 6),
              Text(
                'POINTS ACCUMULÉS',
                style: AppTextStyles.monoSmall(color: Colors.white.withValues(alpha: 0.6)),
              ),
            ],
          ),
          const SizedBox(height: 14),

          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: refState.progressRatio,
              minHeight: 7,
              backgroundColor: Colors.white.withValues(alpha: 0.12),
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${refState.totalUniqueShares} partages uniques validés',
                style: AppTextStyles.bodySmall(color: Colors.white.withValues(alpha: 0.75)),
              ),
              Text(
                'Encore ${refState.sharesToNextReward} partages',
                style: AppTextStyles.monoSmall(color: Colors.white.withValues(alpha: 0.6)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AntiFraudHistorySection extends StatelessWidget {
  final List<ReferralRecord> records;
  const _AntiFraudHistorySection({required this.records});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(LucideIcons.shield, size: 16, color: AppColors.primary),
            const SizedBox(width: 6),
            Text('Suivi anti-fraude & clics validés', style: AppTextStyles.titleMedium().copyWith(fontSize: 13)),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Seuls les partages uniques avec clics confirmés comptent pour débloquer des points.',
          style: AppTextStyles.bodySmall(color: AppColors.inkMuted(opacity: 0.6)),
        ),
        const SizedBox(height: 12),
        AppCard(
          padding: const EdgeInsets.all(14),
          child: records.isEmpty
              ? Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Center(
                    child: Text(
                      'Aucun partage effectué pour le moment.',
                      style: AppTextStyles.bodySmall(color: AppColors.inkMuted(opacity: 0.5)),
                    ),
                  ),
                )
              : ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: records.length > 5 ? 5 : records.length,
                  separatorBuilder: (_, __) => const Divider(height: 20, color: AppColors.border),
                  itemBuilder: (context, i) {
                    final rec = records[i];
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${rec.restaurantName} • ${rec.recipient}',
                                style: AppTextStyles.bodySmall().copyWith(fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 2),
                              Text(rec.fraudNote, style: AppTextStyles.monoSmall()),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        StatusBadge(
                          label: rec.isValidatedClick ? '+1 VALIDE' : 'REJETÉ',
                          tone: rec.isValidatedClick ? StatusTone.success : StatusTone.error,
                        ),
                      ],
                    );
                  },
                ),
        ),
      ],
    );
  }
}
