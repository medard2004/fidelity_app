import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:simple_icons/simple_icons.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/user.dart';
import '../../providers/app_providers.dart';
import '../../widgets/shared/invitation_button.dart';
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
    final titleStyle = GoogleFonts.bodoniModa(
      fontSize: 25,
      fontWeight: FontWeight.w600,
      color: AppColors.encre,
      height: 1.1,
    );

    return Scaffold(
      backgroundColor: AppColors.porcelaine,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - 32,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── En-tête (25px) ─────────────────────────────────────────
                    Text('Connexion', style: titleStyle),

                    const SizedBox(height: 24),

                    // ── Champ téléphone avec indicateur pays ───────────────────
                    Text('Numéro de téléphone', style: AppTextStyles.label()),
                    const SizedBox(height: 8),
                    PhoneInputWithCountryPicker(
                      key: _phoneInputKey,
                      controller: _phoneController,
                    ),

                    const SizedBox(height: 20),

                    // ── CTA Connexion ──────────────────────────────────────────
                    InvitationButton(
                      label: 'Se connecter',
                      filled: true,
                      onTap: _continueWithPhone,
                    ),

                    const SizedBox(height: 18),

                    // ── Séparateur ─────────────────────────────────────────────
                    _Divider(),

                    const SizedBox(height: 18),

                    // ── Connexion sociale ──────────────────────────────────────
                    InvitationButton(
                      label: 'Continuer avec Google',
                      leading: const _GoogleLogo(),
                      onTap: _continueWithGoogle,
                    ),
                    const SizedBox(height: 10),
                    InvitationButton(
                      label: 'Continuer avec Apple',
                      icon: SimpleIcons.apple,
                      onTap: _continueWithApple,
                    ),

                    const SizedBox(height: 24),

                    // ── Lien textuel Créer un compte ──────────────────────────
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

// ─────────────────────────────────────────────────────────────────────────────
// Widgets locaux
// ─────────────────────────────────────────────────────────────────────────────

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
        Expanded(
            child: Divider(color: AppColors.encre.withValues(alpha: 0.15))),
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
            child: Divider(color: AppColors.encre.withValues(alpha: 0.15))),
      ],
    );
  }
}
