import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/loyalty_card.dart';
import '../../providers/wallet_provider.dart';
import '../../providers/referral_provider.dart';
import '../../widgets/shared/invitation_button.dart';
import '../../core/utils/toast_service.dart';

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
      ToastService.showWarning('Ce destinataire est déjà dans votre liste d\'envoi.');
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

      ToastService.showSuccess(message.toString(), duration: const Duration(seconds: 4));
    } else {
      ToastService.showWarning('Veuillez ajouter au moins un destinataire avant d\'envoyer.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final cards = ref.watch(walletProvider);
    final refState = ref.watch(referralProvider);

    // Trouver le partenaire actuellement sélectionné
    final selectedCard = cards.firstWhere(
      (c) => c.id == refState.selectedRestaurantId,
      orElse: () => cards.first,
    );

    return Scaffold(
      backgroundColor: AppColors.porcelaine,
      appBar: AppBar(
        backgroundColor: AppColors.porcelaine,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Parrainage',
          style: AppTextStyles.displayMedium().copyWith(fontSize: 20),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── En-tête explicatif ──────────────────────────────────────────
            Text(
              'Faites découvrir vos commerces et partenaires favoris à vos proches et cumulez des points de fidélité.',
              style: AppTextStyles.bodyMedium(
                color: AppColors.encre.withOpacity(0.65),
              ),
            ),

            const SizedBox(height: 20),

            // ── Carte de Progression (Règle : 100 partages valides = 3 points) ──
            _ProgressionCard(refState: refState),

            const SizedBox(height: 24),

            // ── Étape 1 : Choisir un partenaire ──────────────────
            _StepHeader(
              stepNumber: '1',
              title: 'Choisir le partenaire à parrainer',
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 70,
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
                      _messageController.text =
                          ref.read(referralProvider).customMessage;
                    },
                  );
                },
              ),
            ),

            const SizedBox(height: 24),

            // ── Étape 2 : Personnaliser le message d'invitation ─────────────
            _StepHeader(
              stepNumber: '2',
              title: 'Personnaliser votre invitation',
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _messageController,
              maxLines: 3,
              style: AppTextStyles.bodyMedium(),
              onChanged: (val) {
                ref.read(referralProvider.notifier).updateMessage(val);
              },
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.all(14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: AppColors.laitonLisere(opacity: 0.3)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: AppColors.laitonLisere(opacity: 0.3)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AppColors.laitonBrosse, width: 1.2),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // ── Étape 3 : Sélectionner plusieurs destinataires ─────────────
            _StepHeader(
              stepNumber: '3',
              title: 'Ajouter des destinataires',
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _recipientController,
                    keyboardType: TextInputType.phone,
                    style: AppTextStyles.bodyMedium(),
                    decoration: InputDecoration(
                      hintText: '+228 90 00 00 00 ou Nom',
                      hintStyle: AppTextStyles.bodyMedium(
                        color: AppColors.encre.withOpacity(0.35),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: AppColors.laitonLisere(opacity: 0.3)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: AppColors.laitonLisere(opacity: 0.3)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.laitonBrosse, width: 1.2),
                      ),
                    ),
                    onSubmitted: (_) => _addRecipient(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  onPressed: _addRecipient,
                  icon: const Icon(Icons.add, color: AppColors.porcelaine),
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.vertBouteille,
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
                  return Chip(
                    backgroundColor: AppColors.saugePale,
                    side: BorderSide(color: AppColors.laitonLisere(opacity: 0.3)),
                    label: Text(r, style: AppTextStyles.bodySmall(color: AppColors.encre)),
                    deleteIcon: const Icon(Icons.close, size: 14, color: AppColors.encre),
                    onDeleted: () {
                      ref.read(referralProvider.notifier).removeRecipient(r);
                    },
                  );
                }).toList(),
              ),
            ],

            const SizedBox(height: 28),

            // ── Étape 4 : Bouton de Partage & Action ────────────────────────
            InvitationButton(
              label: 'Partager l\'invitation (${refState.recipients.length} destinataire${refState.recipients.length > 1 ? "s" : ""})',
              filled: true,
              icon: Icons.send_rounded,
              onTap: () => _sendShares(selectedCard),
            ),

            const SizedBox(height: 28),

            // ── Section Anti-Fraude & Suivi des Partages ─────────────────────
            _AntiFraudHistorySection(records: refState.records),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Widgets Composants du Parrainage
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
            color: AppColors.laitonBrosse,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              stepNumber,
              style: AppTextStyles.monoSmall(color: AppColors.porcelaine).copyWith(
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: AppTextStyles.label().copyWith(fontSize: 14, fontWeight: FontWeight.w600),
        ),
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
        width: 145,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.vertBouteille : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? AppColors.vertBouteille
                : AppColors.laitonLisere(opacity: 0.3),
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.vertBouteille.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              card.restaurantName,
              style: AppTextStyles.label(
                color: isSelected ? AppColors.porcelaine : AppColors.encre,
              ).copyWith(fontSize: 12, fontWeight: FontWeight.w600),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              card.restaurantCategory,
              style: AppTextStyles.monoSmall(
                color: isSelected
                    ? AppColors.porcelaine.withOpacity(0.75)
                    : AppColors.encre.withOpacity(0.55),
              ).copyWith(fontSize: 8.5),
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
        color: AppColors.encre,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.laitonBrosse, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: AppColors.encre.withOpacity(0.15),
            blurRadius: 16,
            offset: const Offset(0, 6),
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
                'VOS POINTS PARRAINAGE',
                style: AppTextStyles.monoSmall(color: AppColors.laitonBrosse).copyWith(
                  letterSpacing: 1.8,
                  fontSize: 10,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.laitonBrosse.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.laitonBrosse.withOpacity(0.4)),
                ),
                child: Text(
                  '100 partages = 3 pts',
                  style: AppTextStyles.monoSmall(color: AppColors.laitonBrosse).copyWith(
                    fontSize: 9,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '${refState.pointsEarned}',
                style: AppTextStyles.monoLarge(color: AppColors.porcelaine).copyWith(
                  fontSize: 32,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                'POINTS ACCUMULÉS',
                style: AppTextStyles.monoSmall(color: AppColors.porcelaine.withOpacity(0.7)).copyWith(
                  fontSize: 11,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Barre de progression
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: refState.progressRatio,
              minHeight: 7,
              backgroundColor: Colors.white12,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.laitonBrosse),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${refState.totalUniqueShares} partages uniques validés',
                style: AppTextStyles.bodySmall(color: AppColors.porcelaine.withOpacity(0.8)).copyWith(fontSize: 11),
              ),
              Text(
                'Encore ${refState.sharesToNextReward} partages (+3 pts)',
                style: AppTextStyles.monoSmall(color: AppColors.laitonBrosse).copyWith(fontSize: 9.5),
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
            const Icon(Icons.shield_outlined, size: 16, color: AppColors.laitonBrosse),
            const SizedBox(width: 6),
            Text(
              'Suivi Anti-Fraude & Clics Validés',
              style: AppTextStyles.label().copyWith(fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Seuls les partages uniques avec clics confirmés comptent pour débloquer des points.',
          style: AppTextStyles.bodySmall(color: AppColors.encre.withOpacity(0.6)).copyWith(fontSize: 11),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.laitonLisere(opacity: 0.25)),
          ),
          child: records.isEmpty
              ? Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Center(
                    child: Text(
                      'Aucun partage effectué pour le moment.',
                      style: AppTextStyles.bodySmall(color: AppColors.encre.withOpacity(0.5)),
                    ),
                  ),
                )
              : ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: records.length > 5 ? 5 : records.length,
                  separatorBuilder: (_, __) => const Divider(height: 12),
                  itemBuilder: (context, i) {
                    final rec = records[i];
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${rec.restaurantName} • ${rec.recipient}',
                              style: AppTextStyles.bodySmall(color: AppColors.encre).copyWith(
                                fontWeight: FontWeight.w600,
                                fontSize: 11.5,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              rec.fraudNote,
                              style: AppTextStyles.monoSmall(
                                color: rec.isValidatedClick ? Colors.green.shade700 : Colors.red.shade700,
                              ).copyWith(fontSize: 9.5),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: rec.isValidatedClick
                                ? Colors.green.shade50
                                : Colors.red.shade50,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: rec.isValidatedClick
                                  ? Colors.green.shade200
                                  : Colors.red.shade200,
                            ),
                          ),
                          child: Text(
                            rec.isValidatedClick ? '+1 VALIDE' : 'REJETÉ',
                            style: AppTextStyles.monoSmall(
                              color: rec.isValidatedClick ? Colors.green.shade800 : Colors.red.shade800,
                            ).copyWith(fontSize: 8.5, fontWeight: FontWeight.w600),
                          ),
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
