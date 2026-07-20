import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../widgets/shared/invitation_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phoneController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.porcelaine,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Bon retour', style: AppTextStyles.displayXL()),
              const SizedBox(height: 8),
              Text(
                'Connectez-vous pour retrouver votre wallet.',
                style: AppTextStyles.bodyMedium(color: AppColors.encre.withOpacity(0.65)),
              ),
              const SizedBox(height: 48),
              Text('Numéro de téléphone', style: AppTextStyles.label()),
              const SizedBox(height: 8),
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                style: AppTextStyles.bodyLarge(),
                decoration: const InputDecoration(hintText: '+228 90 12 34 56'),
              ),
              const SizedBox(height: 28),
              InvitationButton(
                label: 'Recevoir le code',
                filled: true,
                onTap: () => context.push('/otp', extra: _phoneController.text),
              ),
              const SizedBox(height: 14),
              InvitationButton(
                label: 'Continuer avec Google',
                icon: Icons.g_mobiledata,
                onTap: () => context.push('/otp', extra: _phoneController.text),
              ),
              const SizedBox(height: 10),
              InvitationButton(
                label: 'Continuer avec Apple',
                icon: Icons.apple,
                onTap: () => context.push('/otp', extra: _phoneController.text),
              ),
              const SizedBox(height: 28),
              Center(
                child: TextButton(
                  onPressed: () => context.pop(),
                  child: Text(
                    'Pas encore de compte ? S\'inscrire',
                    style: AppTextStyles.bodyMedium(color: AppColors.vertBouteille),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
