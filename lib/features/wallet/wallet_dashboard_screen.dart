import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/loyalty_card.dart';
import '../../providers/wallet_provider.dart';
import '../../providers/app_providers.dart';
import 'widgets/card_stack.dart';

class WalletDashboardScreen extends ConsumerStatefulWidget {
  const WalletDashboardScreen({super.key});

  @override
  ConsumerState<WalletDashboardScreen> createState() => _WalletDashboardScreenState();
}

class _WalletDashboardScreenState extends ConsumerState<WalletDashboardScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  bool _isSearching = false;
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _searchQuery = '';
        _searchController.clear();
        _searchFocusNode.unfocus();
      }
    });
    if (_isSearching) {
      Future.microtask(() => _searchFocusNode.requestFocus());
    }
  }

  void _clearSearch() {
    setState(() {
      _searchQuery = '';
      _searchController.clear();
    });
    _searchFocusNode.requestFocus();
  }

  void _onSearchChanged(String value) {
    setState(() {
      _searchQuery = value;
    });
  }

  List<LoyaltyCard> _filteredCards(List<LoyaltyCard> cards) {
    final query = _searchQuery.trim().toLowerCase();
    if (query.isEmpty) return cards;

    return cards.where((card) {
      return card.restaurantName.toLowerCase().contains(query) ||
          card.restaurantCategory.toLowerCase().contains(query) ||
          card.fallbackId.toLowerCase().contains(query);
    }).toList();
  }

  Widget _buildSearchField() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.saugePale,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.laitonLisere(opacity: 0.18)),
      ),
      child: TextField(
        controller: _searchController,
        focusNode: _searchFocusNode,
        onChanged: _onSearchChanged,
        textInputAction: TextInputAction.search,
        style: AppTextStyles.bodyLarge(color: AppColors.encre),
        decoration: InputDecoration(
          hintText: 'Rechercher une carte ou une enseigne',
          hintStyle: AppTextStyles.bodyMedium(color: AppColors.encre.withAlpha(140)),
          prefixIcon: Icon(Icons.search_rounded, color: AppColors.encre.withAlpha(191)),
          suffixIcon: _searchQuery.isEmpty
              ? null
              : IconButton(
                  icon: const Icon(Icons.close_rounded, color: AppColors.encre),
                  onPressed: _clearSearch,
                ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 18),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cards = ref.watch(walletProvider);
    final auth = ref.watch(authProvider);
    final unread = ref.watch(notificationsProvider).where((n) => !n.isRead).length;
    final firstName = auth.user?.firstName ?? 'vous';
    final filteredCards = _filteredCards(cards);

    return Scaffold(
      backgroundColor: AppColors.porcelaine,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'BONSOIR',
                            style: AppTextStyles.monoSmall(color: AppColors.laitonBrosse)
                                .copyWith(letterSpacing: 2.2, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 4),
                          Text(firstName, style: AppTextStyles.displayXL(color: AppColors.encre)),
                        ],
                      ),
                      Row(
                        children: [
                          GestureDetector(
                            onTap: _toggleSearch,
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: const BoxDecoration(
                                color: AppColors.saugePale,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                _isSearching ? Icons.close_rounded : Icons.search_rounded,
                                size: 22,
                                color: AppColors.encre,
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          GestureDetector(
                            onTap: () => context.push('/notifications'),
                            child: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: const BoxDecoration(
                                    color: AppColors.saugePale,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.notifications_none_rounded,
                                      size: 24, color: AppColors.encre),
                                ),
                                if (unread > 0)
                                  Positioned(
                                    right: 6,
                                    top: 6,
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
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Vos cartes, réunies. Touchez-en une pour l\'ouvrir.',
                    style: AppTextStyles.bodyMedium(color: AppColors.encre.withAlpha(217)),
                  ),
                  AnimatedSize(
                    duration: const Duration(milliseconds: 260),
                    curve: Curves.easeInOut,
                    child: Padding(
                      padding: EdgeInsets.only(top: _isSearching ? 24 : 0),
                      child: _isSearching ? _buildSearchField() : const SizedBox.shrink(),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
                child: filteredCards.isEmpty
                    ? _buildEmptyState(cards.isEmpty)
                    : LoyaltyCardStack(
                        cards: filteredCards,
                        onCardTap: (card) => context.push('/card/${card.id}'),
                      ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 8, right: 4),
        child: Container(
          width: 58,
          height: 58,
          decoration: BoxDecoration(
            color: AppColors.porcelaine,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.laitonBrosse, width: 1.2),
            boxShadow: [
              BoxShadow(
                color: AppColors.encre.withAlpha(20),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: IconButton(
            icon: const Icon(Icons.qr_code_scanner_outlined, color: AppColors.encre, size: 26),
            onPressed: () => context.push('/onboarding/scan'),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isWalletEmpty) {
    if (isWalletEmpty) {
      return _EmptyWallet(onScan: () => context.push('/onboarding/scan'));
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Column(
        children: [
          const Icon(Icons.search_off_rounded, size: 40, color: AppColors.laitonBrosse),
          const SizedBox(height: 16),
          Text('Aucune carte trouvée', style: AppTextStyles.displayMedium()),
          const SizedBox(height: 8),
          Text(
            'Essayez un autre nom ou une autre enseigne.',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium(color: AppColors.encre.withAlpha(153)),
          ),
        ],
      ),
    );
  }
}

class _EmptyWallet extends StatelessWidget {
  final VoidCallback onScan;
  const _EmptyWallet({required this.onScan});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Column(
        children: [
          const Icon(Icons.style_outlined, size: 40, color: AppColors.laitonBrosse),
          const SizedBox(height: 16),
          Text('Aucune carte pour l\'instant', style: AppTextStyles.displayMedium()),
          const SizedBox(height: 8),
          Text(
            'Scannez votre premier QR pour commencer votre collection',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium(color: AppColors.encre.withAlpha(153)),
          ),
        ],
      ),
    );
  }
}
