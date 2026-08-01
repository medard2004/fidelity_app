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

/// Formulaire d'inscription complet : Nom · Date de naissance · Téléphone → /wallet
class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen>
    with FormErrorHandler {
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

  Future<void> _submit() async {
    clearAllFieldErrors();
    if (!_formKey.currentState!.validate()) return;

    final fullPhone = _phoneInputKey.currentState?.fullPhoneNumber ??
        _phoneController.text.trim();

    final confirmed = await PhoneConfirmationDialog.show(
      context,
      phoneNumber: fullPhone,
    );

    if (confirmed && mounted) {
      try {
        final notifier = ref.read(signupFlowProvider.notifier);
        notifier.startPhoneSignup(
          fullName: _fullNameController.text.trim(),
          phone: fullPhone,
          birthDate: _birthDate,
        );

        final flowData = ref.read(signupFlowProvider);
        final isValid = await runGuarded(
          () => ref.read(authProvider.notifier).validateRegisterStep1(flowData),
          useOverlay: true,
          loadingMessage: 'Vérification...',
        );

        if (!mounted || isValid == null) return;
        if (isValid) {
          context.push('/create-password');
        } else {
          // Numéro déjà utilisé, invalide ou refusé : s'affiche sous le champ.
          handleError(
            ref.read(authProvider).lastError,
            context: ErrorContext.signup,
            formKey: _formKey,
          );
        }
      } catch (e) {
        if (mounted) handleError(e, context: ErrorContext.signup, formKey: _formKey);
      }
    }
  }

  void _goToLogin() {
    context.go('/auth');
  }

  Future<void> _continueWithGoogle() async {
    try {
      final result = await runGuarded(
        () async {
          final idToken = await SocialAuthService.signInWithGoogle();
          if (idToken == null) return null;
          return ref
              .read(authProvider.notifier)
              .socialLogin(AuthProvider.google, idToken, action: 'signup');
        },
        useOverlay: true,
        loadingMessage: 'Inscription via Google...',
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
              .socialLogin(AuthProvider.apple, idToken, action: 'signup');
        },
        useOverlay: true,
        loadingMessage: 'Inscription via Apple...',
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
                      // ── En-tête (25px) ──────────────────────────────────
                      Text('Créer un compte', style: titleStyle),
                      const SizedBox(height: 20),

                      // ── 1. Nom complet ──────────────────────────────────
                      _Label('Nom complet'),
                      const SizedBox(height: 6),
                      _Field(
                        controller: _fullNameController,
                        hintText: 'Prénom Nom',
                        keyboardType: TextInputType.name,
                        validator: fieldValidator(
                          'first_name',
                          requiredMessage: ErrorMessages.fieldRequired,
                        ),
                      ),

                      const SizedBox(height: 14),

                      // ── 2. Date de naissance ────────────────────────────
                      _Label('Date de naissance'),
                      const SizedBox(height: 6),
                      _DatePickerField(
                        value: _birthDate,
                        onChanged: (date) => setState(() => _birthDate = date),
                        validator: (_) => _birthDate == null
                            ? ErrorMessages.birthdateRequired
                            : fieldError('birthdate'),
                      ),

                      const SizedBox(height: 14),

                      // ── 3. Numéro de téléphone avec indicateur pays ──────
                      _Label('Numéro de téléphone'),
                      const SizedBox(height: 6),
                      PhoneInputWithCountryPicker(
                        key: _phoneInputKey,
                        controller: _phoneController,
                        validator: fieldValidator(
                          'phone',
                          requiredMessage: ErrorMessages.fieldRequired,
                        ),
                      ),

                      const SizedBox(height: 20),

                      // ── CTA Inscription directe ─────────────────────────
                      Consumer(
                        builder: (context, ref, child) {
                          return InvitationButton(
                            label: 'Suivant',
                            filled: true,
                            loading: isBusy,
                            onTap: isBusy ? null : _submit,
                          );
                        },
                      ),

                      const SizedBox(height: 16),

                      // ── Séparateur ──────────────────────────────────────
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

                      const SizedBox(height: 14),

                      // ── Inscription sociale ─────────────────────────────
                      InvitationButton(
                        label: 'S\'inscrire avec Google',
                        leading: SvgPicture.asset(
                          'assets/icons/google_logo.svg',
                          width: 16,
                          height: 16,
                        ),
                        onTap: isBusy ? null : _continueWithGoogle,
                      ),
                      const SizedBox(height: 10),
                      InvitationButton(
                        label: 'S\'inscrire avec Apple',
                        icon: SimpleIcons.apple,
                        onTap: isBusy ? null : _continueWithApple,
                      ),

                      const SizedBox(height: 20),

                      // ── Lien connexion ──────────────────────────────────
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

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);
  @override
  Widget build(BuildContext context) =>
      Text(text, style: AppTextStyles.label());
}

class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;

  const _Field({
    required this.controller,
    required this.hintText,
    this.keyboardType = TextInputType.text,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: AppTextStyles.bodyMedium(),
      validator: validator,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: AppTextStyles.bodyMedium(
          color: AppColors.encre.withValues(alpha: 0.35),
        ),
        filled: true,
        fillColor: AppColors.saugePale.withValues(alpha: 0.4),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
          borderSide:
              const BorderSide(color: AppColors.laitonBrosse, width: 1.2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.bordeauxProfond, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.bordeauxProfond, width: 1.2),
        ),
      ),
    );
  }
}

class _DatePickerField extends StatelessWidget {
  final DateTime? value;
  final void Function(DateTime) onChanged;
  final String? Function(DateTime?)? validator;

  const _DatePickerField({
    required this.value,
    required this.onChanged,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return FormField<DateTime>(
      initialValue: value,
      validator: validator,
      builder: (state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: value ?? DateTime(2000, 1, 1),
                  firstDate: DateTime(1930),
                  lastDate: DateTime.now().subtract(
                    const Duration(days: 365 * 16),
                  ),
                  helpText: 'Date de naissance',
                  builder: (context, child) => Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: const ColorScheme.light(
                        primary: AppColors.vertBouteille,
                        surface: AppColors.porcelaine,
                      ),
                    ),
                    child: child!,
                  ),
                );
                if (picked != null) {
                  onChanged(picked);
                  state.didChange(picked);
                }
              },
              child: Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.saugePale.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: state.hasError
                        ? AppColors.bordeauxProfond
                        : AppColors.laitonLisere(opacity: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        value == null
                            ? 'Sélectionner une date'
                            : '${value!.day.toString().padLeft(2, '0')}/'
                                '${value!.month.toString().padLeft(2, '0')}/'
                                '${value!.year}',
                        style: AppTextStyles.bodyMedium(
                          color: value == null
                              ? AppColors.encre.withValues(alpha: 0.35)
                              : AppColors.encre,
                        ),
                      ),
                    ),
                    const Icon(Icons.calendar_today_outlined,
                        size: 16, color: AppColors.laitonBrosse),
                  ],
                ),
              ),
            ),
            if (state.hasError)
              Padding(
                padding: const EdgeInsets.only(top: 6, left: 4),
                child: Text(
                  state.errorText!,
                  style: const TextStyle(color: AppColors.bordeauxProfond, fontSize: 12),
                ),
              ),
          ],
        );
      },
    );
  }
}
