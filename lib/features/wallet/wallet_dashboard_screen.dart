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
                        GestureDetector(
                          onTap: () => context.push('/notifications'),
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              const Icon(Icons.notifications_none_rounded,
                                  size: 26, color: AppColors.encre),
                              if (unread > 0)
                                Positioned(
                                  right: 0,
                                  top: 0,
                                  child: Container(
                                    width: 7,
                                    height: 7,
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
                    const SizedBox(height: 24),
                    Text(
                      'Vos cartes, réunies. Touchez-en une pour l\'ouvrir.',
                      style: AppTextStyles.bodyMedium(color: AppColors.encre.withOpacity(0.85)),
                    ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
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
                color: AppColors.encre.withOpacity(0.08),
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
