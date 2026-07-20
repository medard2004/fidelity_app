import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../providers/app_providers.dart';
import '../../providers/wallet_provider.dart';
import '../../widgets/shared/invitation_button.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;
    final cards = ref.watch(walletProvider);

    if (user == null) return const SizedBox.shrink();

    return Scaffold(
      backgroundColor: AppColors.porcelaine,
      appBar: AppBar(title: Text('Profil', style: AppTextStyles.displayMedium())),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 40),
        children: [
          Center(
            child: Container(
              width: 84,
              height: 84,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.saugePale,
                border: Border.all(color: AppColors.laitonBrosse, width: 1.2),
              ),
              child: Center(
                child: Text(
                  user.firstName.isNotEmpty ? user.firstName[0].toUpperCase() : '?',
                  style: AppTextStyles.displayXL(),
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Center(child: Text(user.firstName, style: AppTextStyles.displayMedium())),
          Center(
            child: Text(user.maskedPhoneNumber,
                style: AppTextStyles.monoSmall(color: AppColors.encre.withOpacity(0.6))),
          ),
          const SizedBox(height: 28),
          if (user.isBirthdayMonth) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.bordeauxProfond.withOpacity(0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.bordeauxProfond.withOpacity(0.4)),
              ),
              child: Row(
                children: [
                  const Text('🎂', style: TextStyle(fontSize: 18)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'C\'est le mois de votre anniversaire — des attentions vous attendent.',
                      style: AppTextStyles.bodySmall(color: AppColors.bordeauxProfond),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
          if (user.email == null) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.saugePale.withOpacity(0.5),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                'Ajoutez votre email pour ne rien manquer',
                style: AppTextStyles.bodyMedium(color: AppColors.encre.withOpacity(0.7)),
              ),
            ),
            const SizedBox(height: 24),
          ],
          Text('Notifications par restaurant', style: AppTextStyles.label()),
          const SizedBox(height: 8),
          ...cards.map((c) => _NotifToggleRow(name: c.restaurantName)),
          const SizedBox(height: 32),
          Center(
            child: DiscreetTextButton(
              label: 'Déconnexion',
              onTap: () {
                ref.read(authProvider.notifier).signOut();
                context.go('/signup');
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _NotifToggleRow extends StatefulWidget {
  final String name;
  const _NotifToggleRow({required this.name});

  @override
  State<_NotifToggleRow> createState() => _NotifToggleRowState();
}

class _NotifToggleRowState extends State<_NotifToggleRow> {
  bool _enabled = true;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(widget.name, style: AppTextStyles.bodyMedium()),
          Switch(
            value: _enabled,
            onChanged: (v) => setState(() => _enabled = v),
            activeColor: AppColors.vertBouteille,
          ),
        ],
      ),
    );
  }
}
