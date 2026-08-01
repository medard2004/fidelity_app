import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:simple_icons/simple_icons.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/user.dart';
import '../../providers/app_providers.dart';
import '../../widgets/shared/invitation_button.dart';
import '../../widgets/shared/phone_input_with_country_picker.dart';
import '../../widgets/shared/phone_confirmation_dialog.dart';
import '../../services/social_auth_service.dart';
import '../../core/errors/app_error.dart';
import '../../core/errors/error_messages.dart';
import '../../core/errors/form_error_handler.dart';
import '../../core/utils/loading_overlay_service.dart';
import '../../widgets/shared/keyboard_dismiss_pop_scope.dart';

/// Écran de connexion : numéro de téléphone ou fournisseur social.
class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> with FormErrorHandler {
  final _formKey = GlobalKey<FormState>();
  final _phoneInputKey = GlobalKey<PhoneInputWithCountryPickerState>();
  final _phoneController = TextEditingController();

  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _continueWithPhone() async {
    // Les champs manquants sont signalés sous chaque champ, pas en Toast.
    clearAllFieldErrors();
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final raw = _phoneController.text.trim();
    final password = _passwordController.text;
    final fullPhone = _phoneInputKey.currentState?.fullPhoneNumber ?? raw;

    final confirmed = await PhoneConfirmationDialog.show(
      context,
      phoneNumber: fullPhone,
    );

    if (confirmed && mounted) {
      try {
        final success = await runGuarded(
          () => ref.read(authProvider.notifier).login(fullPhone, password),
          useOverlay: true,
          loadingMessage: 'Connexion en cours...',
        );
        if (!mounted || success == null) return;
        if (success) {
          context.go('/wallet');
        } else {
          handleError(
            ref.read(authProvider).lastError,
            context: ErrorContext.login,
            formKey: _formKey,
          );
        }
      } catch (e) {
        if (mounted) handleError(e, context: ErrorContext.login, formKey: _formKey);
      }
    }
  }

  Future<void> _continueWithGoogle() async {
    try {
      final result = await runGuarded(
        () async {
          final idToken = await SocialAuthService.signInWithGoogle();
          if (idToken == null) return null;
          return ref
              .read(authProvider.notifier)
              .socialLogin(AuthProvider.google, idToken, action: 'login');
        },
        useOverlay: true,
        loadingMessage: 'Connexion via Google...',
      );

      if (!mounted || result == null) return;
      if (result['success'] == true) {
        if (result['needs_profile_completion'] == true) {
          final client = result['client'] as AppUser;
          ref.read(signupFlowProvider.notifier).startSocialSignup(
                provider: AuthProvider.google,
                fullName: client.fullName,
                email: client.email ?? '',
              );
          context.go('/complete-social-profile');
        } else {
          context.go('/wallet');
        }
      } else {
        handleError(
          ref.read(authProvider).lastError,
          context: ErrorContext.socialLogin,
        );
      }
    } catch (e) {
      // Une annulation par l'utilisateur est silencieuse (géré par handleError).
      if (mounted) handleError(e, context: ErrorContext.socialLogin);
    }
  }

  Future<void> _continueWithApple() async {
    try {
      final result = await runGuarded(
        () async {
          final idToken = await SocialAuthService.signInWithApple();
          if (idToken == null) return null;
          return ref
              .read(authProvider.notifier)
              .socialLogin(AuthProvider.apple, idToken, action: 'login');
        },
        useOverlay: true,
        loadingMessage: 'Connexion via Apple...',
      );

      if (!mounted || result == null) return;
      if (result['success'] == true) {
        if (result['needs_profile_completion'] == true) {
          final client = result['client'] as AppUser;
          ref.read(signupFlowProvider.notifier).startSocialSignup(
                provider: AuthProvider.apple,
                fullName: client.fullName,
                email: client.email ?? '',
              );
          context.go('/complete-social-profile');
        } else {
          context.go('/wallet');
        }
      } else {
        handleError(
          ref.read(authProvider).lastError,
          context: ErrorContext.socialLogin,
        );
      }
    } catch (e) {
      if (mounted) handleError(e, context: ErrorContext.socialLogin);
    }
  }

  @override
  Widget build(BuildContext context) {
    final titleStyle = GoogleFonts.bodoniModa(
      fontSize: 48,
      fontWeight: FontWeight.w600,
      color: AppColors.encre,
      height: 1.1,
    );

    return KeyboardDismissPopScope(
      child: Scaffold(
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
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── En-tête (48px) ─────────────────────────────────────────
                      Text('Connexion', style: titleStyle),

                      const SizedBox(height: 24),

                      // ── Champ téléphone avec indicateur pays ───────────────────
                      Text('Numéro de téléphone', style: AppTextStyles.label()),
                      const SizedBox(height: 8),
                      PhoneInputWithCountryPicker(
                        key: _phoneInputKey,
                        controller: _phoneController,
                        validator: fieldValidator(
                          'phone',
                          requiredMessage: ErrorMessages.fieldRequired,
                        ),
                      ),

                      const SizedBox(height: 20),

                      // ── Champ mot de passe ─────────────────────────────────────
                      Text('Mot de passe', style: AppTextStyles.label()),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        style: AppTextStyles.bodyMedium(),
                        onChanged: (_) => clearFieldError('password'),
                        validator: fieldValidator(
                          'password',
                          requiredMessage: ErrorMessages.fieldRequired,
                        ),
                        decoration: InputDecoration(
                          hintText: '••••••••',
                          hintStyle: AppTextStyles.bodyMedium(
                            color: AppColors.encre.withValues(alpha: 0.35),
                          ),
                          filled: true,
                          fillColor: AppColors.saugePale.withValues(alpha: 0.4),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 15),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                                color: AppColors.laitonLisere(opacity: 0.3)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                                color: AppColors.laitonLisere(opacity: 0.3)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                              color: AppColors.laitonBrosse,
                              width: 1.2,
                            ),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: AppColors.bordeauxProfond, width: 1),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: AppColors.bordeauxProfond, width: 1.2),
                          ),
                          errorStyle: AppTextStyles.bodySmall(color: AppColors.bordeauxProfond),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: AppColors.encre.withValues(alpha: 0.5),
                              size: 20,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerRight,
                        child: GestureDetector(
                          onTap: () => context.push('/forgot-password'),
                          child: Text(
                            'Mot de passe oublié ?',
                            style: AppTextStyles.bodyMedium(
                              color: AppColors.encre.withValues(alpha: 0.6),
                            ).copyWith(
                              fontWeight: FontWeight.w600,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // ── CTA Connexion ──────────────────────────────────────────
                      InvitationButton(
                        label: 'Se connecter',
                        filled: true,
                        loading: isBusy,
                        onTap: isBusy ? null : _continueWithPhone,
                      ),

                      const SizedBox(height: 18),

                      // ── Séparateur ─────────────────────────────────────────────
                      _Divider(),

                      const SizedBox(height: 18),

                      // ── Connexion sociale ──────────────────────────────────────
                      InvitationButton(
                        label: 'Continuer avec Google',
                        leading: const _GoogleLogo(),
                        onTap: isBusy ? null : _continueWithGoogle,
                      ),
                      const SizedBox(height: 10),
                      InvitationButton(
                        label: 'Continuer avec Apple',
                        icon: SimpleIcons.apple,
                        onTap: isBusy ? null : _continueWithApple,
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
                                  ).copyWith(
                                    fontWeight: FontWeight.w600,
                                    decoration: TextDecoration.underline,
                                  ),
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
    return SvgPicture.asset(
      'assets/icons/google_logo.svg',
      width: 16,
      height: 16,
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
