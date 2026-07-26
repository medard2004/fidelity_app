import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:simple_icons/simple_icons.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/user.dart';
import '../../providers/app_providers.dart';
import '../../widgets/shared/invitation_button.dart';

/// Écran de connexion : numéro de téléphone ou fournisseur social.
class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final _phoneController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _continueWithPhone() {
    final phone = _phoneController.text.trim();
    context.push('/otp', extra: {'phone': phone, 'context': 'login'});
  }

  void _continueWithGoogle() {
    ref.read(authProvider.notifier).completeSocialLogin(AuthProvider.google);
    ref.read(authProvider.notifier).completeSocialProfile(
      fullName: 'John Doe (Google)',
      phone: '+228 90 00 00 00',
      birthDate: DateTime(1990, 1, 1),
    );
    context.go('/wallet');
  }

  void _continueWithApple() {
    ref.read(authProvider.notifier).completeSocialLogin(AuthProvider.apple);
    ref.read(authProvider.notifier).completeSocialProfile(
      fullName: 'Jane Doe (Apple)',
      phone: '+228 91 11 11 11',
      birthDate: DateTime(1992, 2, 2),
    );
    context.go('/wallet');
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

              // ── En-tête ────────────────────────────────────────────────────
              Text('Carte', style: AppTextStyles.displayXL()),
              const SizedBox(height: 8),
              Text(
                'Votre portefeuille de fidélité, réuni en un seul geste.',
                style: AppTextStyles.bodyMedium(
                  color: AppColors.encre.withOpacity(0.65),
                ),
              ),

              const SizedBox(height: 52),

              // ── Champ téléphone ────────────────────────────────────────────
              Text('Numéro de téléphone', style: AppTextStyles.label()),
              const SizedBox(height: 10),
              _PhoneField(controller: _phoneController),

              const SizedBox(height: 32),

              // ── CTA Connexion ──────────────────────────────────────────────
              InvitationButton(
                label: 'Se connecter',
                filled: true,
                onTap: _continueWithPhone,
              ),

              const SizedBox(height: 12),

              // ── Bouton Créer un compte ─────────────────────────────────────
              InvitationButton(
                label: 'Créer un compte',
                onTap: () => context.push('/signup'),
              ),

              const SizedBox(height: 24),

              // ── Séparateur ─────────────────────────────────────────────────
              _Divider(),

              const SizedBox(height: 20),

              // ── Connexion sociale ──────────────────────────────────────────
              InvitationButton(
                label: 'Continuer avec Google',
                leading: const _GoogleLogo(),
                onTap: _continueWithGoogle,
              ),
              const SizedBox(height: 12),
              InvitationButton(
                label: 'Continuer avec Apple',
                icon: SimpleIcons.apple,
                onTap: _continueWithApple,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Widgets locaux
// ─────────────────────────────────────────────────────────────────────────────

class _PhoneField extends StatelessWidget {
  final TextEditingController controller;
  const _PhoneField({required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
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
          borderSide: BorderSide(color: AppColors.laitonLisere(opacity: 0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: AppColors.laitonLisere(opacity: 0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
            color: AppColors.laitonBrosse,
            width: 1.2,
          ),
        ),
      ),
    );
  }
}

class _GoogleLogo extends StatelessWidget {
  const _GoogleLogo();

  @override
  Widget build(BuildContext context) {
    return const Icon(
      SimpleIcons.google,
      size: 16,
      color: AppColors.encre,
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Divider(color: AppColors.encre.withOpacity(0.15))),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'OU',
            style: AppTextStyles.monoSmall(
              color: AppColors.encre.withOpacity(0.4),
            ),
          ),
        ),
        Expanded(child: Divider(color: AppColors.encre.withOpacity(0.15))),
      ],
    );
  }
}
