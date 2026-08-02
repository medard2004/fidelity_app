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

/// Écran de connexion : numéro de téléphone ou fournisseur social.
class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
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
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight - 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Connexion', style: AppTextStyles.displayXL()),

                    const SizedBox(height: 24),

                    Text('Numéro de téléphone', style: AppTextStyles.label()),
                    const SizedBox(height: 8),
                    PhoneInputWithCountryPicker(
                      key: _phoneInputKey,
                      controller: _phoneController,
                    ),

                    const SizedBox(height: 20),

                    AppButton(label: 'Se connecter', onTap: _continueWithPhone),

                    const SizedBox(height: 20),

                    const OrDivider(),

                    const SizedBox(height: 20),

                    AppButton(
                      label: 'Continuer avec Google',
                      variant: AppButtonVariant.outline,
                      leading: const Icon(SimpleIcons.google, size: 16, color: AppColors.ink),
                      onTap: _continueWithGoogle,
                    ),
                    const SizedBox(height: 10),
                    AppButton(
                      label: 'Continuer avec Apple',
                      variant: AppButtonVariant.outline,
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
                            style: AppTextStyles.bodyMedium(color: AppColors.inkMuted(opacity: 0.55)),
                            children: [
                              TextSpan(
                                text: 'S\'inscrire',
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
            );
          },
        ),
      ),
    );
  }
}
