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

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _phoneInputKey = GlobalKey<PhoneInputWithCountryPickerState>();
  final _phoneController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _continueWithPhone() {
    final raw = _phoneController.text.trim();
    if (raw.isEmpty) return;
    final fullPhone = _phoneInputKey.currentState?.fullPhoneNumber ?? raw;
    ref.read(authProvider.notifier).completeLogin(phone: fullPhone);
    context.go('/wallet');
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
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              Text('Bon retour', style: AppTextStyles.displayMedium()),
              const SizedBox(height: 20),
              Text('Numéro de téléphone', style: AppTextStyles.label()),
              const SizedBox(height: 8),
              PhoneInputWithCountryPicker(
                key: _phoneInputKey,
                controller: _phoneController,
              ),
              const SizedBox(height: 20),
              InvitationButton(
                label: 'Se connecter',
                filled: true,
                onTap: _continueWithPhone,
              ),
              const SizedBox(height: 16),
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
              InvitationButton(
                label: 'Continuer avec Google',
                leading: const Icon(SimpleIcons.google,
                    size: 16, color: AppColors.encre),
                onTap: _continueWithGoogle,
              ),
              const SizedBox(height: 10),
              InvitationButton(
                label: 'Continuer avec Apple',
                icon: SimpleIcons.apple,
                onTap: _continueWithApple,
              ),
              const SizedBox(height: 24),
              Center(
                child: GestureDetector(
                  onTap: () => context.push('/signup'),
                  child: Text.rich(
                    TextSpan(
                      text: 'Pas encore membre ? ',
                      style: AppTextStyles.bodyMedium(
                        color: AppColors.encre.withValues(alpha: 0.55),
                      ),
                      children: [
                        TextSpan(
                          text: 'S\'inscrire',
                          style: AppTextStyles.bodyMedium(
                            color: AppColors.laitonBrosse,
                          ).copyWith(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
