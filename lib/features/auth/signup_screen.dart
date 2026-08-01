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
                      const _Label('Nom complet'),
                      const SizedBox(height: 6),
                      _Field(
                        controller: _fullNameController,
                        hintText: 'Prénom Nom',
                        keyboardType: TextInputType.name,
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Veuillez saisir votre nom complet'
                            : null,
                      ),

                      const SizedBox(height: 14),

                      // ── 2. Date de naissance ────────────────────────────
                      const _Label('Date de naissance'),
                      const SizedBox(height: 6),
                      _DatePickerField(
                        value: _birthDate,
                        onChanged: (date) => setState(() => _birthDate = date),
                        validator: (_) => _birthDate == null
                            ? 'Veuillez sélectionner votre date de naissance'
                            : null,
                      ),

                      const SizedBox(height: 14),

                      // ── 3. Numéro de téléphone avec indicateur pays ──────
                      const _Label('Numéro de téléphone'),
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

                      // ── CTA Inscription directe ─────────────────────────
                      InvitationButton(
                        label: 'S\'inscrire',
                        filled: true,
                        onTap: _submit,
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
          borderSide: const BorderSide(color: Colors.redAccent, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.2),
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
                        ? Colors.redAccent
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
                  style: const TextStyle(color: Colors.redAccent, fontSize: 12),
                ),
              ),
          ],
        );
      },
    );
  }
}
