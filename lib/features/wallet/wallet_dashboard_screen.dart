import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_shadows.dart';
import '../../l10n/gen/app_localizations.dart';
import '../../providers/wallet_provider.dart';
import '../../providers/app_providers.dart';
import '../../providers/settings_provider.dart';
import '../../widgets/components/components.dart';
import '../../widgets/shared/app_section_header.dart';
import '../../widgets/shared/notification_bell_button.dart';
import 'widgets/card_stack.dart';

class WalletDashboardScreen extends ConsumerWidget {
  const WalletDashboardScreen({super.key});

  String _greeting(AppLocalizations t) {
    final hour = DateTime.now().hour;
    if (hour < 5) return t.walletGreetingEvening;
    if (hour < 12) return t.walletGreetingMorning;
    if (hour < 18) return t.walletGreetingAfternoon;
    return t.walletGreetingEvening;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(themeModeProvider);
    final t = AppLocalizations.of(context)!;
    final cards = ref.watch(walletProvider);
    final auth = ref.watch(authProvider);
    final unread =
        ref.watch(notificationsProvider).where((n) => !n.isRead).length;
    final firstName = auth.user?.firstName ?? t.walletFallbackName;

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          children: [
            AppSectionHeader(
              eyebrow: _greeting(t),
              title: firstName,
              actions: [
                Semantics(
                  button: true,
                  label: t.walletSearchSemanticLabel,
                  child: AppTapScale(
                    onTap: () => context.push('/wallet/search'),
                    child: Container(
                      width: 44,
                      height: 44,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceCard,
                        shape: BoxShape.circle,
                        boxShadow: AppShadows.resting,
                      ),
                      child: Icon(LucideIcons.search,
                          size: 20, color: AppColors.ink),
                    ),
                  ),
                ),
                NotificationBellButton(unreadCount: unread),
              ],
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
                  child: cards.isEmpty
                      ? _EmptyWallet(
                          t: t, onScan: () => context.push('/onboarding/scan'))
                      : LoyaltyCardStack(
                          cards: cards,
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
            icon:
                const Icon(LucideIcons.scanLine, color: Colors.white, size: 26),
            onPressed: () => context.push('/onboarding/scan'),
          ),
        ),
      ),
    );
  }
}

class _EmptyWallet extends StatelessWidget {
  final AppLocalizations t;
  final VoidCallback onScan;
  const _EmptyWallet({required this.t, required this.onScan});

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: LucideIcons.layers,
      title: t.walletEmptyTitle,
      message: t.walletEmptyMessage,
      action: AppButton(
        label: t.walletScanButton,
        icon: LucideIcons.scanLine,
        fullWidth: false,
        onTap: onScan,
      ),
    );
  }
}
