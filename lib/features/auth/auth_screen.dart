import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../widgets/shared/invitation_button.dart';

/// Écran d'authentification unifiée : entrée unique pour connexion & inscription.
class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _phoneController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.porcelaine,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              Text('Carte', style: AppTextStyles.displayXL()),
              const SizedBox(height: 8),
              Text(
                'Votre portefeuille de fidélité, réuni en un seul geste.',
                style: AppTextStyles.bodyMedium(
                  color: AppColors.encre.withOpacity(0.65),
                ),
              ),
              const SizedBox(height: 52),
              Text('Numéro de téléphone', style: AppTextStyles.label()),
              const SizedBox(height: 10),
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                style: AppTextStyles.bodyLarge(),
                decoration: InputDecoration(
                  hintText: '+228 90 12 34 56',
                  filled: true,
                  fillColor: AppColors.saugePale.withOpacity(0.4),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: AppColors.laitonLisere(opacity: 0.3),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: AppColors.laitonLisere(opacity: 0.3),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                      color: AppColors.laitonBrosse,
                      width: 1.2,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              InvitationButton(
                label: 'Continuer',
                filled: true,
                onTap: () => context.push('/otp', extra: _phoneController.text),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Divider(color: AppColors.encre.withOpacity(0.15)),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      'OU',
                      style: AppTextStyles.monoSmall(
                        color: AppColors.encre.withOpacity(0.4),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Divider(color: AppColors.encre.withOpacity(0.15)),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              InvitationButton(
                label: 'Continuer avec Google',
                icon: Icons.g_mobiledata,
                onTap: () => context.push('/otp', extra: _phoneController.text),
              ),
              const SizedBox(height: 12),
              InvitationButton(
                label: 'Continuer avec Apple',
                icon: Icons.apple,
                onTap: () => context.push('/otp', extra: _phoneController.text),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
