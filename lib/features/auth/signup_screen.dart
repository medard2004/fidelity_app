import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:simple_icons/simple_icons.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/user.dart';
import '../../providers/app_providers.dart';
import '../../widgets/shared/invitation_button.dart';
import '../../widgets/shared/phone_input_with_country_picker.dart';

/// Formulaire d'inscription : Téléphone avec indicateur pays → Inscription directe
class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneInputKey = GlobalKey<PhoneInputWithCountryPickerState>();
  final _phoneController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final fullPhone =
        _phoneInputKey.currentState?.fullPhoneNumber ?? _phoneController.text.trim();

    ref.read(signupFlowProvider.notifier).startPhoneSignup(
          fullName: '',
          phone: fullPhone,
        );

    final flow = ref.read(signupFlowProvider);
    ref.read(authProvider.notifier).completeSignupOtp(flow);

    context.go('/complete-profile');
  }

  void _goToLogin() {
    context.go('/auth');
  }

  void _continueWithGoogle() {
    ref.read(signupFlowProvider.notifier).startSocialSignup(provider: AuthProvider.google);
    ref.read(authProvider.notifier).completeSocialLogin(AuthProvider.google);
    context.go('/complete-social-profile');
  }

  void _continueWithApple() {
    ref.read(signupFlowProvider.notifier).startSocialSignup(provider: AuthProvider.apple);
    ref.read(authProvider.notifier).completeSocialLogin(AuthProvider.apple);
    context.go('/complete-social-profile');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.porcelaine,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),

                // ── En-tête compact (22px) ────────────────────────────────────
                Text('Créer un compte', style: AppTextStyles.displayMedium()),
                const SizedBox(height: 20),

                // ── Numéro de téléphone avec indicateur pays ─────────────────
                Text('Numéro de téléphone', style: AppTextStyles.label()),
                const SizedBox(height: 8),
                PhoneInputWithCountryPicker(
                  key: _phoneInputKey,
                  controller: _phoneController,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Veuillez saisir votre numéro de téléphone';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                // ── CTA Inscription directe ──────────────────────────────────
                InvitationButton(
                  label: 'S\'inscrire',
                  filled: true,
                  onTap: _submit,
                ),

                const SizedBox(height: 20),

                // ── Séparateur ───────────────────────────────────────────────
                Row(
                  children: [
                    Expanded(
                      child: Divider(
                        color: AppColors.encre.withValues(alpha: 0.15),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        'OU',
                        style: AppTextStyles.monoSmall(
                          color: AppColors.encre.withValues(alpha: 0.4),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Divider(
                        color: AppColors.encre.withValues(alpha: 0.15),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // ── Inscription sociale ──────────────────────────────────────
                InvitationButton(
                  label: 'S\'inscrire avec Google',
                  leading: const Icon(SimpleIcons.google,
                      size: 16, color: AppColors.encre),
                  onTap: _continueWithGoogle,
                ),
                const SizedBox(height: 10),
                InvitationButton(
                  label: 'S\'inscrire avec Apple',
                  icon: SimpleIcons.apple,
                  onTap: _continueWithApple,
                ),

                const SizedBox(height: 24),

                // ── Lien connexion ───────────────────────────────────────────
                Center(
                  child: GestureDetector(
                    onTap: _goToLogin,
                    child: Text.rich(
                      TextSpan(
                        text: 'Déjà membre ? ',
                        style: AppTextStyles.bodyMedium(
                          color: AppColors.encre.withValues(alpha: 0.55),
                        ),
                        children: [
                          TextSpan(
                            text: 'Se connecter',
                            style: AppTextStyles.bodyMedium(
                              color: AppColors.laitonBrosse,
                            ).copyWith(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
