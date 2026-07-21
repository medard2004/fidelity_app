import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../providers/wallet_provider.dart';
import '../../providers/app_providers.dart';
import 'widgets/card_stack.dart';

class WalletDashboardScreen extends ConsumerWidget {
  const WalletDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cards = ref.watch(walletProvider);
    final auth = ref.watch(authProvider);
    final unread = ref.watch(notificationsProvider).where((n) => !n.isRead).length;
    final firstName = auth.user?.firstName ?? 'vous';

    return Scaffold(
      backgroundColor: AppColors.porcelaine,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
              sliver: SliverToBoxAdapter(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Bonjour, $firstName', style: AppTextStyles.displayLarge()),
                    GestureDetector(
                      onTap: () => context.push('/notifications'),
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          const Icon(Icons.notifications_none_rounded,
                              size: 26, color: AppColors.encre),
                          if (unread > 0)
                            Positioned(
                              right: -1,
                              top: -1,
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
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(24, 36, 24, 0),
              sliver: SliverToBoxAdapter(
                child: cards.isEmpty
                    ? _EmptyWallet(onScan: () => context.push('/onboarding/scan'))
                    : LoyaltyCardStack(
                        cards: cards,
                        onCardTap: (card) => context.push('/card/${card.id}'),
                      ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/onboarding/scan'),
        backgroundColor: AppColors.porcelaine,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
          side: BorderSide(color: AppColors.laitonLisere(opacity: 0.6)),
        ),
        elevation: 2,
        child: const Icon(Icons.qr_code_scanner, color: AppColors.encre),
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
            style: AppTextStyles.bodyMedium(color: AppColors.encre.withOpacity(0.6)),
          ),
        ],
      ),
    );
  }
}
