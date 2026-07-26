import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:simple_icons/simple_icons.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/user.dart';
import '../../providers/app_providers.dart';
import '../../widgets/shared/invitation_button.dart';

/// Formulaire d'inscription : Nom complet · Date de naissance · Téléphone → OTP
class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
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

    ref.read(signupFlowProvider.notifier).startPhoneSignup(
          fullName: _fullNameController.text.trim(),
          phone: _phoneController.text.trim(),
          birthDate: _birthDate,
        );

    context.push('/otp', extra: {
      'phone': _phoneController.text.trim(),
      'context': 'signup',
    });
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
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── En-tête ────────────────────────────────────────────────
                Text('Créer un compte', style: AppTextStyles.displayXL()),
                const SizedBox(height: 8),
                Text(
                  'Rejoignez la communauté et cumulez des avantages exclusifs.',
                  style: AppTextStyles.bodyMedium(
                    color: AppColors.encre.withOpacity(0.6),
                  ),
                ),

                const SizedBox(height: 40),

                // ── Nom complet ────────────────────────────────────────────
                _SectionLabel('Nom complet'),
                const SizedBox(height: 8),
                _StyledTextField(
                  controller: _fullNameController,
                  hintText: 'Prénom Nom',
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.name,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Veuillez saisir votre nom complet';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                // ── Date de naissance (Sélecteur Jour/Mois/Année) ─────────
                _SectionLabel('Date de naissance'),
                const SizedBox(height: 8),
                _DatePickerField(
                  value: _birthDate,
                  onChanged: (date) => setState(() => _birthDate = date),
                  validator: (_) => _birthDate == null
                      ? 'Veuillez sélectionner votre date de naissance'
                      : null,
                ),

                const SizedBox(height: 20),

                // ── Numéro de téléphone ───────────────────────────────────
                _SectionLabel('Numéro de téléphone'),
                const SizedBox(height: 8),
                _StyledTextField(
                  controller: _phoneController,
                  hintText: '+228 90 12 34 56',
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.done,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Veuillez saisir votre numéro de téléphone';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 12),

                // ── Note OTP ───────────────────────────────────────────────
                Row(
                  children: [
                    const Icon(Icons.info_outline,
                        size: 13, color: AppColors.laitonBrosse),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Un code de vérification vous sera envoyé par SMS.',
                        style: AppTextStyles.bodySmall(
                          color: AppColors.encre.withOpacity(0.6),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 36),

                // ── CTA ────────────────────────────────────────────────────
                InvitationButton(
                  label: 'S\'inscrire et vérifier mon numéro',
                  filled: true,
                  onTap: _submit,
                ),

                const SizedBox(height: 24),

                // ── Séparateur ─────────────────────────────────────────────────
                Row(
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
                ),

                const SizedBox(height: 20),

                // ── Inscription sociale ────────────────────────────────────────
                InvitationButton(
                  label: 'S\'inscrire avec Google',
                  leading: const Icon(SimpleIcons.google, size: 16, color: AppColors.encre),
                  onTap: _continueWithGoogle,
                ),
                const SizedBox(height: 12),
                InvitationButton(
                  label: 'S\'inscrire avec Apple',
                  icon: SimpleIcons.apple,
                  onTap: _continueWithApple,
                ),

                const SizedBox(height: 32),

                // ── Lien connexion ─────────────────────────────────────────
                Center(
                  child: GestureDetector(
                    onTap: _goToLogin,
                    child: Text.rich(
                      TextSpan(
                        text: 'Déjà membre ? ',
                        style: AppTextStyles.bodyMedium(
                            color: AppColors.encre.withOpacity(0.55)),
                        children: [
                          TextSpan(
                            text: 'Se connecter',
                            style: AppTextStyles.bodyMedium(
                                color: AppColors.laitonBrosse)
                                .copyWith(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Widgets locaux
// ─────────────────────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) =>
      Text(text, style: AppTextStyles.label());
}

class _StyledTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final String? Function(String?)? validator;

  const _StyledTextField({
    required this.controller,
    required this.hintText,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      style: AppTextStyles.bodyLarge(),
      validator: validator,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: AppTextStyles.bodyLarge(
          color: AppColors.encre.withOpacity(0.35),
        ),
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
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 16),
                decoration: BoxDecoration(
                  color: AppColors.saugePale.withOpacity(0.4),
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
                            ? 'Sélectionner le jour, le mois et l\'année'
                            : '${value!.day.toString().padLeft(2, '0')}/'
                                '${value!.month.toString().padLeft(2, '0')}/'
                                '${value!.year}',
                        style: AppTextStyles.bodyLarge(
                          color: value == null
                              ? AppColors.encre.withOpacity(0.35)
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
                  style: const TextStyle(
                      color: Colors.redAccent, fontSize: 12),
                ),
              ),
          ],
        );
      },
    );
  }
}
