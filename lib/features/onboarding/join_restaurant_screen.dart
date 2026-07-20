import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_radius.dart';
import '../../models/loyalty_card.dart';
import '../../providers/wallet_provider.dart';
import '../../widgets/shared/brass_bordered_container.dart';
import '../../widgets/shared/invitation_button.dart';

class JoinRestaurantScreen extends ConsumerStatefulWidget {
  const JoinRestaurantScreen({super.key});

  @override
  ConsumerState<JoinRestaurantScreen> createState() => _JoinRestaurantScreenState();
}

class _JoinRestaurantScreenState extends ConsumerState<JoinRestaurantScreen>
    with SingleTickerProviderStateMixin {
  bool _joining = false;

  static const _demoCard = LoyaltyCard(
    id: 'card_new_demo',
    restaurantName: 'Chez Awa',
    restaurantCategory: 'Restaurant traditionnel',
    mechanic: LoyaltyMechanic.stamps,
    liningColor: AppColors.doublureMacBouffe,
    stampsCurrent: 1,
    stampsGoal: 8,
    fallbackId: 'AWA-90031',
    welcomeOffer: 'Un plat découverte offert pour votre arrivée',
  );

  Future<void> _join() async {
    setState(() => _joining = true);
    await Future.delayed(const Duration(milliseconds: 900));
    ref.read(walletProvider.notifier).joinRestaurant(_demoCard);
    if (mounted) context.go('/wallet');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.encre,
      body: Stack(
        children: [
          // Visuel d'ambiance simulé (voile porcelaine semi-transparent).
          Positioned.fill(
            child: Container(color: AppColors.doublureMacBouffe),
          ),
          Positioned.fill(
            child: Container(color: AppColors.porcelaine.withOpacity(0.14)),
          ),
          SafeArea(
            child: Column(
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: IconButton(
                    onPressed: () => context.go('/wallet'),
                    icon: const Icon(Icons.close, color: AppColors.porcelaine),
                  ),
                ),
                const Spacer(),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 500),
                  child: _joining
                      ? _CardRevealAnimation(card: _demoCard)
                      : _JoinCard(card: _demoCard, onJoin: _join),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _JoinCard extends StatelessWidget {
  final LoyaltyCard card;
  final VoidCallback onJoin;
  const _JoinCard({required this.card, required this.onJoin});

  @override
  Widget build(BuildContext context) {
    return Padding(
      key: const ValueKey('join'),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Rejoindre ${card.restaurantName}',
            style: AppTextStyles.displayLarge(color: AppColors.porcelaine),
          ),
          const SizedBox(height: 16),
          BrassBorderedContainer(
            backgroundColor: AppColors.porcelaine,
            child: Row(
              children: [
                const Icon(Icons.card_giftcard, color: AppColors.laitonBrosse, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(card.welcomeOffer, style: AppTextStyles.bodyMedium()),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          InvitationButton(
            label: 'Rejoindre le programme',
            filled: true,
            onTap: onJoin,
          ),
        ],
      ),
    );
  }
}

class _CardRevealAnimation extends StatelessWidget {
  final LoyaltyCard card;
  const _CardRevealAnimation({required this.card});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      key: const ValueKey('reveal'),
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 700),
      curve: Curves.easeOutBack,
      builder: (context, t, _) {
        return Transform.translate(
          offset: Offset(0, (1 - t) * 120),
          child: Opacity(
            opacity: t.clamp(0, 1),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                height: 180,
                decoration: BoxDecoration(
                  color: card.liningColor,
                  borderRadius: BorderRadius.circular(AppRadius.card),
                  border: Border.all(color: AppColors.laitonBrosse, width: 1),
                ),
                child: Center(
                  child: Text(
                    'Carte créée',
                    style: AppTextStyles.displayMedium(color: AppColors.porcelaine),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
