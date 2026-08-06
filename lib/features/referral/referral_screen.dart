import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_shadows.dart';
import '../../l10n/gen/app_localizations.dart';
import '../../models/loyalty_card.dart';
import '../../providers/app_providers.dart';
import '../../providers/settings_provider.dart';
import '../../providers/wallet_provider.dart';
import '../../providers/referral_provider.dart';
import '../../widgets/components/components.dart';
import '../../widgets/shared/app_section_header.dart';
import '../../widgets/shared/notification_bell_button.dart';

/// Écran de Parrainage Partenaire — recommander un restaurant partenaire
/// à ses proches, avec suivi anti-fraude des partages.
///
/// Volontairement simplifié : une seule action évidente (choisir →
/// personnaliser → envoyer), l'historique anti-fraude est replié par
/// défaut plutôt qu'exposé en permanence.
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

  void _addRecipient(AppLocalizations t) {
    final text = _recipientController.text.trim();
    if (text.isEmpty) return;
    final added = ref.read(referralProvider.notifier).addRecipient(text);
    if (added) {
      _recipientController.clear();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t.referralDuplicateRecipient)),
      );
    }
  }

  void _sendShares(LoyaltyCard selectedCard, AppLocalizations t) {
    final result =
        ref.read(referralProvider.notifier).sendReferrals(selectedCard);

    if (result['success'] == true) {
      final added = result['addedCount'] as int;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(t.referralSentSuccess(added)),
          duration: const Duration(seconds: 3),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t.referralNoRecipient)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(themeModeProvider);
    final t = AppLocalizations.of(context)!;
    final cards = ref.watch(walletProvider);
    final refState = ref.watch(referralProvider);
    final unreadNotifs =
        ref.watch(notificationsProvider).where((n) => !n.isRead).length;

    if (cards.isEmpty) {
      return Scaffold(
        backgroundColor: AppColors.surface,
        body: SafeArea(
          child: Column(
            children: [
              AppSectionHeader(
                title: t.referralTitle,
                actions: [NotificationBellButton(unreadCount: unreadNotifs)],
              ),
              Expanded(
                child: Center(
                  child: EmptyState(
                    icon: LucideIcons.users,
                    title: t.referralEmptyTitle,
                    message: t.referralEmptyMessage,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final selectedCard = cards.firstWhere(
      (c) => c.id == refState.selectedRestaurantId,
      orElse: () => cards.first,
    );

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          children: [
            AppSectionHeader(
              title: t.referralTitle,
              actions: [NotificationBellButton(unreadCount: unreadNotifs)],
            ),
            Expanded(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t.referralSubtitle,
                      style: AppTextStyles.bodyMedium(
                          color: AppColors.inkMuted(opacity: 0.65)),
                    ),
                    const SizedBox(height: 16),
                    _ProgressionCard(refState: refState, t: t),
                    const SizedBox(height: 24),
                    SectionEyebrow(t.referralChoosePartner),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 68,
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
                              ref
                                  .read(referralProvider.notifier)
                                  .selectRestaurant(card);
                              _messageController.text =
                                  ref.read(referralProvider).customMessage;
                            },
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                    SectionEyebrow(t.referralMessageLabel),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _messageController,
                      maxLines: 3,
                      onChanged: (val) => ref
                          .read(referralProvider.notifier)
                          .updateMessage(val),
                    ),
                    const SizedBox(height: 20),
                    SectionEyebrow(t.referralRecipientsLabel),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _recipientController,
                            keyboardType: TextInputType.text,
                            textCapitalization: TextCapitalization.words,
                            decoration: InputDecoration(
                                hintText: t.referralRecipientHint),
                            onSubmitted: (_) => _addRecipient(t),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton.filled(
                          onPressed: () => _addRecipient(t),
                          icon:
                              const Icon(LucideIcons.plus, color: Colors.white),
                          style: IconButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
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
                            onDeleted: () => ref
                                .read(referralProvider.notifier)
                                .removeRecipient(r),
                          );
                        }).toList(),
                      ),
                    ],
                    const SizedBox(height: 24),
                    AppButton(
                      label: refState.recipients.isEmpty
                          ? t.referralSendButton
                          : t.referralSendButtonWithCount(
                              refState.recipients.length),
                      icon: LucideIcons.send,
                      onTap: () => _sendShares(selectedCard, t),
                    ),
                    const SizedBox(height: 20),
                    _AntiFraudHistorySection(records: refState.records, t: t),
                    const SizedBox(height: 20),
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

// ─────────────────────────────────────────────────────────────────────────────
// Widgets composants du parrainage
// ─────────────────────────────────────────────────────────────────────────────

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
    return AppTapScale(
      onTap: onTap,
      scaleDown: 0.97,
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
              style: AppTextStyles.label(
                  color: isSelected ? Colors.white : AppColors.ink),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              card.restaurantCategory,
              style: AppTextStyles.bodySmall(
                color: isSelected
                    ? Colors.white.withValues(alpha: 0.75)
                    : AppColors.inkMuted(opacity: 0.55),
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

/// Résumé de progression — points cumulés et jauge, une seule ligne de
/// statut (pas de pill supplémentaire ni de double texte).
class _ProgressionCard extends StatelessWidget {
  final ReferralState refState;
  final AppLocalizations t;
  const _ProgressionCard({required this.refState, required this.t});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        // Carte volontairement toujours sombre (texte blanc) dans les deux
        // thèmes — inkSolid, pas ink qui s'inverserait en blanc en sombre.
        color: AppColors.inkSolid,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppShadows.raised,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            t.referralPointsLabel.toUpperCase(),
            style: AppTextStyles.eyebrow(
                color: Colors.white.withValues(alpha: 0.6)),
          ),
          const SizedBox(height: 10),
          Text(t.referralPointsEarned(refState.pointsEarned),
              style: AppTextStyles.monoLarge(color: Colors.white)),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: refState.progressRatio,
              minHeight: 7,
              backgroundColor: Colors.white.withValues(alpha: 0.12),
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            t.referralSharesToNext(refState.sharesToNextReward),
            style: AppTextStyles.bodySmall(
                color: Colors.white.withValues(alpha: 0.7)),
          ),
        ],
      ),
    );
  }
}

/// Historique anti-fraude — replié par défaut pour ne pas encombrer
/// l'écran ; disponible d'un tap pour qui veut le détail.
class _AntiFraudHistorySection extends StatefulWidget {
  final List<ReferralRecord> records;
  final AppLocalizations t;
  const _AntiFraudHistorySection({required this.records, required this.t});

  @override
  State<_AntiFraudHistorySection> createState() =>
      _AntiFraudHistorySectionState();
}

class _AntiFraudHistorySectionState extends State<_AntiFraudHistorySection> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final t = widget.t;
    return Column(
      children: [
        AppCard(
          onTap: () => setState(() => _expanded = !_expanded),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              const Icon(LucideIcons.shield,
                  size: 16, color: AppColors.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(t.referralHistoryTitle,
                    style: AppTextStyles.titleMedium().copyWith(fontSize: 14)),
              ),
              AnimatedRotation(
                turns: _expanded ? 0.5 : 0.0,
                duration: const Duration(milliseconds: 200),
                child: Icon(LucideIcons.chevronDown,
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
                    padding: const EdgeInsets.all(14),
                    child: widget.records.isEmpty
                        ? Center(
                            child: Text(
                              t.referralHistoryEmpty,
                              style: AppTextStyles.bodySmall(
                                  color: AppColors.inkMuted(opacity: 0.5)),
                            ),
                          )
                        : Column(
                            children: [
                              for (int i = 0;
                                  i <
                                      (widget.records.length > 5
                                          ? 5
                                          : widget.records.length);
                                  i++) ...[
                                if (i > 0)
                                  Divider(height: 20, color: AppColors.border),
                                _HistoryRow(record: widget.records[i]),
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

class _HistoryRow extends StatelessWidget {
  final ReferralRecord record;
  const _HistoryRow({required this.record});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${record.restaurantName} • ${record.recipient}',
                style: AppTextStyles.bodySmall()
                    .copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 2),
              Text(record.fraudNote, style: AppTextStyles.monoSmall()),
            ],
          ),
        ),
        const SizedBox(width: 8),
        StatusBadge(
          label: record.isValidatedClick ? '+1' : '✕',
          tone: record.isValidatedClick ? StatusTone.success : StatusTone.error,
        ),
      ],
    );
  }
}
