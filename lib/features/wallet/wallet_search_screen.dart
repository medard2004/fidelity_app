import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../l10n/gen/app_localizations.dart';
import '../../models/loyalty_card.dart';
import '../../providers/settings_provider.dart';
import '../../providers/wallet_provider.dart';
import '../../widgets/components/components.dart';
import 'widgets/loyalty_card_widget.dart';

/// Recherche plein écran des cartes du Wallet — écran dédié plutôt qu'un
/// champ qui s'ouvre dans l'en-tête : clavier déjà ouvert à l'arrivée,
/// résultats filtrés en direct sous forme de liste.
class WalletSearchScreen extends ConsumerStatefulWidget {
  const WalletSearchScreen({super.key});

  @override
  ConsumerState<WalletSearchScreen> createState() => _WalletSearchScreenState();
}

class _WalletSearchScreenState extends ConsumerState<WalletSearchScreen> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  String _query = '';

  @override
  void initState() {
    super.initState();
    Future.microtask(() => _focusNode.requestFocus());
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  List<LoyaltyCard> _filtered(List<LoyaltyCard> cards) {
    final query = _query.trim().toLowerCase();
    if (query.isEmpty) return cards;

    return cards.where((card) {
      return card.restaurantName.toLowerCase().contains(query) ||
          card.restaurantCategory.toLowerCase().contains(query) ||
          card.fallbackId.toLowerCase().contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(themeModeProvider);
    final t = AppLocalizations.of(context)!;
    final cards = ref.watch(walletProvider);
    final results = _filtered(cards);

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
              child: Row(
                children: [
                  AppTapScale(
                    onTap: () => context.pop(),
                    child: SizedBox(
                      width: 40,
                      height: 40,
                      child: Icon(LucideIcons.arrowLeft,
                          color: AppColors.ink, size: 20),
                    ),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      focusNode: _focusNode,
                      onChanged: (value) => setState(() => _query = value),
                      textInputAction: TextInputAction.search,
                      style: AppTextStyles.bodyLarge(),
                      decoration: InputDecoration(
                        hintText: t.walletSearchHint,
                        hintStyle: AppTextStyles.bodyLarge(
                            color: AppColors.inkMuted(opacity: 0.4)),
                        border: InputBorder.none,
                        isDense: true,
                      ),
                    ),
                  ),
                  if (_query.isNotEmpty)
                    AppTapScale(
                      onTap: () {
                        _controller.clear();
                        setState(() => _query = '');
                        _focusNode.requestFocus();
                      },
                      child: SizedBox(
                        width: 40,
                        height: 40,
                        child:
                            Icon(LucideIcons.x, color: AppColors.ink, size: 18),
                      ),
                    ),
                ],
              ),
            ),
            Divider(height: 1, color: AppColors.border),
            Expanded(
              child: results.isEmpty
                  ? Center(
                      child: EmptyState(
                        icon: LucideIcons.searchX,
                        title: cards.isEmpty
                            ? t.walletEmptyTitle
                            : t.walletSearchNoResultsTitle,
                        message: cards.isEmpty
                            ? t.walletEmptyMessage
                            : t.walletSearchNoResultsMessage,
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                      itemCount: results.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 16),
                      itemBuilder: (context, i) {
                        final card = results[i];
                        return GestureDetector(
                          onTap: () => context.push('/card/${card.id}'),
                          child: LoyaltyCardWidget(card: card, height: 140),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
