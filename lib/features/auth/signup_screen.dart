import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:simple_icons/simple_icons.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/user.dart';
import '../../providers/app_providers.dart';
import '../../widgets/components/components.dart';
import '../../widgets/shared/phone_input_with_country_picker.dart';

/// Formulaire d'inscription complet : Nom · Date de naissance · Téléphone → /wallet
class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _phoneInputKey = GlobalKey<PhoneInputWithCountryPickerState>();
  final _phoneController = TextEditingController();
  DateTime? _birthDate;

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final fullPhone = _phoneInputKey.currentState?.fullPhoneNumber ??
        _phoneController.text.trim();

    ref.read(signupFlowProvider.notifier).startPhoneSignup(
          fullName: _fullNameController.text.trim(),
          phone: fullPhone,
          birthDate: _birthDate,
        );

    final flow = ref.read(signupFlowProvider);
    ref.read(authProvider.notifier).completeSignupOtp(flow);

    context.go('/wallet');
  }

  void _goToLogin() {
    context.go('/auth');
  }

  void _continueWithGoogle() {
    ref
        .read(signupFlowProvider.notifier)
        .startSocialSignup(provider: AuthProvider.google);
    ref.read(authProvider.notifier).completeSocialLogin(AuthProvider.google);
    context.go('/complete-social-profile');
  }

  void _continueWithApple() {
    ref
        .read(signupFlowProvider.notifier)
        .startSocialSignup(provider: AuthProvider.apple);
    ref.read(authProvider.notifier).completeSocialLogin(AuthProvider.apple);
    context.go('/complete-social-profile');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight - 32),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Créer un compte', style: AppTextStyles.displayXL()),
                      const SizedBox(height: 20),

                      Text('Nom complet', style: AppTextStyles.label()),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _fullNameController,
                        keyboardType: TextInputType.name,
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Veuillez saisir votre nom complet'
                            : null,
                        decoration: const InputDecoration(hintText: 'Prénom Nom'),
                      ),

                      const SizedBox(height: 14),

                      Text('Date de naissance', style: AppTextStyles.label()),
                      const SizedBox(height: 6),
                      AppDatePickerField(
                        value: _birthDate,
                        onChanged: (date) => setState(() => _birthDate = date),
                        validator: (_) => _birthDate == null
                            ? 'Veuillez sélectionner votre date de naissance'
                            : null,
                      ),

                      const SizedBox(height: 14),

                      Text('Numéro de téléphone', style: AppTextStyles.label()),
                      const SizedBox(height: 6),
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

                      AppButton(label: 'S\'inscrire', onTap: _submit),

                      const SizedBox(height: 18),

                      const OrDivider(),

                      const SizedBox(height: 18),

                      AppButton(
                        label: 'S\'inscrire avec Google',
                        variant: AppButtonVariant.outline,
                        leading: const Icon(SimpleIcons.google, size: 16, color: AppColors.ink),
                        onTap: _continueWithGoogle,
                      ),
                      const SizedBox(height: 10),
                      AppButton(
                        label: 'S\'inscrire avec Apple',
                        variant: AppButtonVariant.outline,
                        icon: SimpleIcons.apple,
                        onTap: _continueWithApple,
                      ),

                      const SizedBox(height: 20),

                      Center(
                        child: GestureDetector(
                          onTap: _goToLogin,
                          child: Text.rich(
                            TextSpan(
                              text: 'Déjà membre ? ',
                              style: AppTextStyles.bodyMedium(color: AppColors.inkMuted(opacity: 0.55)),
                              children: [
                                TextSpan(
                                  text: 'Se connecter',
                                  style: AppTextStyles.bodyMedium(color: AppColors.primary)
                                      .copyWith(fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
