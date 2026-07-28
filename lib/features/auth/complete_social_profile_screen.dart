import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../providers/app_providers.dart';
import '../../widgets/shared/invitation_button.dart';
import '../../widgets/shared/phone_input_with_country_picker.dart';

/// Étape post-connexion sociale (Google/Apple).
/// Collecte : Nom complet · Téléphone · Date de naissance · Email.
class CompleteSocialProfileScreen extends ConsumerStatefulWidget {
  const CompleteSocialProfileScreen({super.key});

  @override
  ConsumerState<CompleteSocialProfileScreen> createState() =>
      _CompleteSocialProfileScreenState();
}

class _CompleteSocialProfileScreenState
    extends ConsumerState<CompleteSocialProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  final _fullNameController = TextEditingController();
  final _phoneInputKey = GlobalKey<PhoneInputWithCountryPickerState>();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();

  DateTime? _birthDate;

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final fullPhone =
        _phoneInputKey.currentState?.fullPhoneNumber ?? _phoneController.text.trim();

    ref.read(authProvider.notifier).completeSocialProfile(
          fullName: _fullNameController.text.trim(),
          phone: fullPhone,
          birthDate: _birthDate,
          email: _emailController.text.trim().isNotEmpty
              ? _emailController.text.trim()
              : null,
        );

    ref.read(signupFlowProvider.notifier).reset();
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
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── En-tête (25px) ───────────────────────────────────
                      Text('Compléter le profil', style: titleStyle),

                      const SizedBox(height: 20),

                      // ── 1. Nom complet ────────────────────────────────────
                      _Label('Nom complet'),
                      const SizedBox(height: 6),
                      _Field(
                        controller: _fullNameController,
                        hintText: 'Prénom Nom',
                        keyboardType: TextInputType.name,
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Veuillez saisir votre nom complet'
                            : null,
                      ),

                      const SizedBox(height: 16),

                      // ── 2. Numéro de téléphone avec indicateur pays ───────
                      _Label('Numéro de téléphone'),
                      const SizedBox(height: 6),
                      PhoneInputWithCountryPicker(
                        key: _phoneInputKey,
                        controller: _phoneController,
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Veuillez saisir votre numéro'
                            : null,
                      ),

                      const SizedBox(height: 16),

                      // ── 3. Date de naissance / anniversaire ──────────────
                      _Label('Date de naissance'),
                      const SizedBox(height: 6),
                      _DatePickerField(
                        value: _birthDate,
                        onChanged: (date) => setState(() => _birthDate = date),
                        validator: (_) => _birthDate == null
                            ? 'Veuillez sélectionner votre date de naissance'
                            : null,
                      ),

                      const SizedBox(height: 16),

                      // ── 4. Email ──────────────────────────────────────────
                      Row(
                        children: [
                          _Label('Email'),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.saugePale,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'Optionnel',
                              style: AppTextStyles.monoSmall().copyWith(
                                letterSpacing: 0.8,
                                color: AppColors.encre.withValues(alpha: 0.5),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      _Field(
                        controller: _emailController,
                        hintText: 'votre@email.com',
                        keyboardType: TextInputType.emailAddress,
                      ),

                      const SizedBox(height: 28),

                      // ── CTA ──────────────────────────────────────────────
                      InvitationButton(
                        label: 'Accéder à l\'application',
                        filled: true,
                        onTap: _submit,
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
