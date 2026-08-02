import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_shadows.dart';
import '../../models/loyalty_card.dart';
import '../../providers/wallet_provider.dart';
import '../../providers/app_providers.dart';
import '../../widgets/components/components.dart';
import 'widgets/card_stack.dart';

class WalletDashboardScreen extends ConsumerStatefulWidget {
  const WalletDashboardScreen({super.key});

  @override
  ConsumerState<WalletDashboardScreen> createState() =>
      _WalletDashboardScreenState();
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

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 5) return 'BONSOIR';
    if (hour < 12) return 'BONJOUR';
    if (hour < 18) return 'BON APRÈS-MIDI';
    return 'BONSOIR';
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
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(18),
        boxShadow: AppShadows.resting,
      ),
      child: TextField(
        controller: _searchController,
        focusNode: _searchFocusNode,
        onChanged: _onSearchChanged,
        textInputAction: TextInputAction.search,
        style: AppTextStyles.bodyLarge(color: AppColors.ink),
        decoration: InputDecoration(
          hintText: 'Rechercher une carte ou une enseigne',
          hintStyle: AppTextStyles.bodyMedium(color: AppColors.inkMuted(opacity: 0.4)),
          prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primary),
          prefixIconConstraints:
              const BoxConstraints(minWidth: 48, minHeight: 48),
          suffixIconConstraints:
              const BoxConstraints(minWidth: 48, minHeight: 48),
          suffixIcon: _searchQuery.isEmpty
              ? null
              : IconButton(
                  icon: const Icon(Icons.close_rounded, color: AppColors.ink),
                  onPressed: _clearSearch,
                ),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(vertical: 16, horizontal: 18),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cards = ref.watch(walletProvider);
    final auth = ref.watch(authProvider);
    final unread =
        ref.watch(notificationsProvider).where((n) => !n.isRead).length;
    final firstName = auth.user?.firstName ?? 'vous';
    final filteredCards = _filteredCards(cards);

    return Scaffold(
      backgroundColor: AppColors.surface,
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
                            _greeting(),
                            style: AppTextStyles.eyebrow(color: AppColors.primary),
                          ),
                          const SizedBox(height: 4),
                          Text(firstName, style: AppTextStyles.displayXL()),
                        ],
                      ),
                      Row(
                        children: [
                          Semantics(
                            button: true,
                            label: _isSearching
                                ? 'Fermer la recherche'
                                : 'Rechercher une carte',
                            child: GestureDetector(
                              onTap: _toggleSearch,
                              behavior: HitTestBehavior.opaque,
                              child: Container(
                                width: 44,
                                height: 44,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceCard,
                                  shape: BoxShape.circle,
                                  boxShadow: AppShadows.resting,
                                ),
                                child: Icon(
                                  _isSearching
                                      ? Icons.close_rounded
                                      : Icons.search_rounded,
                                  size: 20,
                                  color: AppColors.ink,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Semantics(
                            button: true,
                            label: unread > 0
                                ? 'Notifications, $unread non lues'
                                : 'Notifications',
                            child: GestureDetector(
                              onTap: () => context.push('/notifications'),
                              behavior: HitTestBehavior.opaque,
                              child: Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  Container(
                                    width: 44,
                                    height: 44,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: AppColors.surfaceCard,
                                      shape: BoxShape.circle,
                                      boxShadow: AppShadows.resting,
                                    ),
                                    child: const Icon(
                                        Icons.notifications_none_rounded,
                                        size: 22,
                                        color: AppColors.ink),
                                  ),
                                  if (unread > 0)
                                    Positioned(
                                      right: 8,
                                      top: 8,
                                      child: Container(
                                        width: 8,
                                        height: 8,
                                        decoration: const BoxDecoration(
                                          color: AppColors.primary,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Vos cartes, réunies. Touchez-en une pour l\'ouvrir.',
                    style: AppTextStyles.bodyMedium(color: AppColors.inkMuted()),
                  ),
                  AnimatedSize(
                    duration: const Duration(milliseconds: 260),
                    curve: Curves.easeInOut,
                    child: Padding(
                      padding: EdgeInsets.only(top: _isSearching ? 24 : 0),
                      child: _isSearching
                          ? _buildSearchField()
                          : const SizedBox.shrink(),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                color: AppColors.primary,
                backgroundColor: AppColors.surfaceCard,
                onRefresh: () =>
                    Future.delayed(const Duration(milliseconds: 700)),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics()),
                  padding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
                  child: filteredCards.isEmpty
                      ? _buildEmptyState(cards.isEmpty)
                      : LoyaltyCardStack(
                          cards: filteredCards,
                          onCardTap: (card) => context.push('/card/${card.id}'),
                        ),
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
            color: AppColors.primary,
            shape: BoxShape.circle,
            boxShadow: AppShadows.raised,
          ),
          child: IconButton(
            icon: const Icon(Icons.qr_code_scanner_outlined,
                color: Colors.white, size: 26),
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

    return const EmptyState(
      icon: Icons.search_off_rounded,
      title: 'Aucune carte trouvée',
      message: 'Essayez un autre nom ou une autre enseigne.',
    );
  }
}

class _EmptyWallet extends StatelessWidget {
  final VoidCallback onScan;
  const _EmptyWallet({required this.onScan});

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: Icons.style_outlined,
      title: 'Aucune carte pour l\'instant',
      message: 'Scannez votre premier QR pour commencer votre collection',
      action: AppButton(
        label: 'Scanner un QR code',
        icon: Icons.qr_code_scanner_outlined,
        fullWidth: false,
        onTap: onScan,
      ),
    );
  }
}
