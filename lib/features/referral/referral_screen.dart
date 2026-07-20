import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../providers/app_providers.dart';
import '../../widgets/shared/invitation_button.dart';

class ReferralScreen extends ConsumerWidget {
  const ReferralScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;
    final code = user?.referralCode ?? '—';
    final invited = user?.friendsInvited ?? 0;
    final joined = user?.friendsJoined ?? 0;

    return Scaffold(
      backgroundColor: AppColors.porcelaine,
      appBar: AppBar(title: Text('Parrainage', style: AppTextStyles.displayMedium())),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 24),
            Text(
              'Invitez vos proches, gagnez des récompenses ensemble.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium(color: AppColors.encre.withOpacity(0.6)),
            ),
            const SizedBox(height: 48),
            // Traitement monumental — gravé sur une plaque.
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 36),
              decoration: BoxDecoration(
                color: AppColors.encre,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.laitonBrosse, width: 1.2),
              ),
              child: Column(
                children: [
                  Text('VOTRE CODE', style: AppTextStyles.monoSmall(color: AppColors.laitonBrosse)),
                  const SizedBox(height: 10),
                  Text(
                    code,
                    style: AppTextStyles.displayXL(color: AppColors.porcelaine),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            InvitationButton(
              label: 'Partager sur WhatsApp',
              filled: true,
              icon: Icons.chat_outlined,
              onTap: () {},
            ),
            const SizedBox(height: 12),
            InvitationButton(label: 'Envoyer par SMS', icon: Icons.sms_outlined, onTap: () {}),
            const SizedBox(height: 12),
            InvitationButton(label: 'Copier le lien', icon: Icons.link, onTap: () {}),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _Indicator(filled: true),
                _Indicator(filled: joined >= 1),
                _Indicator(filled: joined >= 2),
                const SizedBox(width: 10),
                Text('$invited amis invités · $joined a rejoint',
                    style: AppTextStyles.bodySmall()),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Indicator extends StatelessWidget {
  final bool filled;
  const _Indicator({required this.filled});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: filled ? AppColors.laitonBrosse : Colors.transparent,
          border: Border.all(color: AppColors.laitonBrosse, width: 1),
        ),
      ),
    );
  }
}
