import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../providers/app_providers.dart';
import '../../widgets/shared/invitation_button.dart';
import '../../widgets/shared/otp_input_row.dart';

/// Étape post-connexion sociale (Google/Apple).
/// Collecte : Nom complet · Téléphone + OTP · Date de naissance · Ville · Quartier · Email.
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
  final _phoneController = TextEditingController();
  final _cityController = TextEditingController();
  final _neighborhoodController = TextEditingController();
  final _emailController = TextEditingController();

  DateTime? _birthDate;
  bool _phoneVerified = false;
  bool _showOtpField = false;

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _cityController.dispose();
    _neighborhoodController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _requestOtp() {
    if (_phoneController.text.trim().isEmpty) return;
    setState(() => _showOtpField = true);
  }

  void _onOtpCompleted(String code) {
    // En production : appel API pour vérifier le code.
    setState(() {
      _phoneVerified = true;
      _showOtpField = false;
    });

    // Stocker dans le flow
    ref.read(signupFlowProvider.notifier).setSocialDetails(
          fullName: _fullNameController.text.trim(),
          phone: _phoneController.text.trim(),
          birthDate: _birthDate,
        );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (!_phoneVerified) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez vérifier votre numéro de téléphone.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    ref.read(authProvider.notifier).completeSocialProfile(
          fullName: _fullNameController.text.trim(),
          phone: _phoneController.text.trim(),
          birthDate: _birthDate,
          city: _cityController.text.trim().isNotEmpty
              ? _cityController.text.trim()
              : null,
          neighborhood: _neighborhoodController.text.trim().isNotEmpty
              ? _neighborhoodController.text.trim()
              : null,
          email: _emailController.text.trim().isNotEmpty
              ? _emailController.text.trim()
              : null,
        );

    ref.read(signupFlowProvider.notifier).reset();
    context.go('/wallet');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.porcelaine,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 40),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── En-tête ────────────────────────────────────────────────
                Text('Dernière étape', style: AppTextStyles.displayXL()),
                const SizedBox(height: 10),
                Text(
                  'Votre numéro et votre date de naissance sont indispensables pour bénéficier de vos programmes de fidélité.',
                  style: AppTextStyles.bodyMedium(
                    color: AppColors.encre.withOpacity(0.6),
                  ),
                ),

                const SizedBox(height: 10),

                // ── Banderole informationnelle ─────────────────────────────
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.laitonBrosse.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.laitonBrosse.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.star_border_rounded,
                          size: 16, color: AppColors.laitonBrosse),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Requis pour accéder aux offres de fidélité et aux avantages d\'anniversaire.',
                          style: AppTextStyles.bodySmall(
                            color: AppColors.laitonBrosse,
                          ).copyWith(color: AppColors.laitonBrosse),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // ── Nom complet ────────────────────────────────────────────
                _Label('Nom complet'),
                const SizedBox(height: 8),
                _Field(
                  controller: _fullNameController,
                  hintText: 'Prénom Nom',
                  keyboardType: TextInputType.name,
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Veuillez saisir votre nom complet'
                      : null,
                ),

                const SizedBox(height: 20),

                // ── Numéro de téléphone + OTP ──────────────────────────────
                _Label('Numéro de téléphone'),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _Field(
                        controller: _phoneController,
                        hintText: '+228 90 12 34 56',
                        keyboardType: TextInputType.phone,
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Veuillez saisir votre numéro'
                            : null,
                        suffix: _phoneVerified
                            ? const Icon(Icons.check_circle,
                                color: Colors.green, size: 18)
                            : null,
                      ),
                    ),
                    const SizedBox(width: 10),
                    if (!_phoneVerified)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: GestureDetector(
                          onTap: _requestOtp,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 16),
                            decoration: BoxDecoration(
                              color: AppColors.vertBouteille,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              'Vérifier',
                              style: AppTextStyles.label(
                                  color: AppColors.porcelaine),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),

                // ── Champ OTP inline ───────────────────────────────────────
                if (_showOtpField) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.saugePale.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: AppColors.laitonLisere(opacity: 0.2)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Code envoyé au ${_phoneController.text.trim()}',
                          style: AppTextStyles.bodySmall(
                            color: AppColors.encre.withOpacity(0.65),
                          ),
                        ),
                        const SizedBox(height: 12),
                        OtpInputRow(onCompleted: _onOtpCompleted),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 20),

                // ── Date de naissance ──────────────────────────────────────
                _Label('Date de naissance'),
                const SizedBox(height: 8),
                _DatePickerField(
                  value: _birthDate,
                  onChanged: (date) => setState(() => _birthDate = date),
                  validator: (_) => _birthDate == null
                      ? 'Veuillez sélectionner votre date de naissance'
                      : null,
                ),

                const SizedBox(height: 28),

                // ── Séparateur ─────────────────────────────────────────────
                Row(
                  children: [
                    Expanded(
                        child: Divider(
                            color: AppColors.encre.withOpacity(0.1))),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        'INFOS COMPLÉMENTAIRES',
                        style: AppTextStyles.monoSmall().copyWith(
                          letterSpacing: 1.4,
                          color: AppColors.encre.withOpacity(0.35),
                        ),
                      ),
                    ),
                    Expanded(
                        child: Divider(
                            color: AppColors.encre.withOpacity(0.1))),
                  ],
                ),

                const SizedBox(height: 20),

                // ── Ville ──────────────────────────────────────────────────
                _Label('Ville'),
                const SizedBox(height: 8),
                _Field(
                  controller: _cityController,
                  hintText: 'Ex. Lomé',
                ),

                const SizedBox(height: 20),

                // ── Quartier ───────────────────────────────────────────────
                _Label('Quartier'),
                const SizedBox(height: 8),
                _Field(
                  controller: _neighborhoodController,
                  hintText: 'Ex. Bè, Adidogomé…',
                ),

                const SizedBox(height: 20),

                // ── Email ──────────────────────────────────────────────────
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
                          color: AppColors.encre.withOpacity(0.5),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _Field(
                  controller: _emailController,
                  hintText: 'votre@email.com',
                  keyboardType: TextInputType.emailAddress,
                ),

                const SizedBox(height: 40),

                // ── CTA ────────────────────────────────────────────────────
                InvitationButton(
                  label: 'Accéder à l\'application',
                  filled: true,
                  onTap: _submit,
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
  final Widget? suffix;

  const _Field({
    required this.controller,
    required this.hintText,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: AppTextStyles.bodyLarge(),
      validator: validator,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle:
            AppTextStyles.bodyLarge(color: AppColors.encre.withOpacity(0.35)),
        suffixIcon: suffix,
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
          borderSide:
              const BorderSide(color: Colors.redAccent, width: 1.2),
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
                            ? 'Sélectionner une date'
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
