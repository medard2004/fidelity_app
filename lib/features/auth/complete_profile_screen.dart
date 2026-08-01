import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../providers/app_providers.dart';
import '../../widgets/shared/invitation_button.dart';
import '../../core/errors/app_error.dart';
import '../../core/errors/error_messages.dart';
import '../../core/errors/form_error_handler.dart';
import 'package:country_picker/country_picker.dart';

/// Étape post-inscription : Nom complet · Date de naissance · Email (optionnel).
class CompleteProfileScreen extends ConsumerStatefulWidget {
  const CompleteProfileScreen({super.key});

  @override
  ConsumerState<CompleteProfileScreen> createState() =>
      _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends ConsumerState<CompleteProfileScreen>
    with FormErrorHandler {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _cityController = TextEditingController();
  String? _selectedCountry;
  DateTime? _birthDate;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  Future<void> _complete() async {
    if (isBusy) return;

    final user = ref.read(authProvider).user;
    if (user == null) {
      context.go('/wallet');
      return;
    }

    clearAllFieldErrors();
    if (!(_formKey.currentState?.validate() ?? false)) return;

    try {
      final valName = _fullNameController.text.trim();
      final valEmail = _emailController.text.trim();
      final valCity = _cityController.text.trim();

      await runLoading(
        context,
        () => ref.read(authProvider.notifier).updateFullProfile(
              fullName: valName.isNotEmpty ? valName : user.fullName,
              phoneNumber: user.phoneNumber,
              birthDate: _birthDate ?? user.birthDate,
              email: valEmail,
              city: valCity,
              country: _selectedCountry,
            ),
        message: 'Enregistrement…',
      );

      // Also mark as profile completed locally (updateFullProfile already does this)
      if (mounted) {
        showSuccessToast(ErrorMessages.profileSaveSuccess);
        context.go('/wallet');
      }
    } catch (e) {
      if (mounted) {
        handleError(
          e,
          context: ErrorContext.completeProfile,
          formKey: _formKey,
        );
      }
    }
  }

  void _skip() {
    ref.read(authProvider.notifier).completeProfile();
    context.go('/wallet');
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).user;

    return Scaffold(
      backgroundColor: AppColors.porcelaine,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Encart de bienvenue compact ────────────────────────────────
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.vertBouteille,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle_outline,
                          color: AppColors.porcelaine, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Bienvenue${user != null && user.firstName.isNotEmpty ? ", ${user.firstName}" : ""} !\nVotre compte a été créé.',
                          style: AppTextStyles.bodyMedium(
                            color: AppColors.porcelaine,
                          ).copyWith(height: 1.3),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // ── Titre (22px) ───────────────────────────────────────────────
                Text('Complétez votre profil',
                    style: AppTextStyles.displayMedium()),

                const SizedBox(height: 20),

                // ── 1. Nom complet ─────────────────────────────────────────────
                _SectionLabel('Nom complet'),
                const SizedBox(height: 6),
                _StyledField(
                  controller: _fullNameController,
                  hintText: 'Prénom Nom',
                  keyboardType: TextInputType.name,
                  onChanged: (_) => clearFieldError('first_name'),
                  validator: fieldValidator('first_name'),
                ),

                const SizedBox(height: 16),

                // ── 2. Date de naissance / anniversaire ───────────────────────
                _SectionLabel('Date de naissance'),
                const SizedBox(height: 6),
                _DatePickerField(
                  value: _birthDate,
                  onChanged: (date) => setState(() => _birthDate = date),
                ),

                const SizedBox(height: 16),

                // ── 3. Email ───────────────────────────────────────────────────
                Row(
                  children: [
                    _SectionLabel('Email'),
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
                _StyledField(
                  controller: _emailController,
                  hintText: 'votre@email.com',
                  keyboardType: TextInputType.emailAddress,
                  onChanged: (_) => clearFieldError('email'),
                  // Champ facultatif : on ne valide le format que s'il est rempli.
                  validator: fieldValidator(
                    'email',
                    extra: (v) => v.contains('@') && v.contains('.')
                        ? null
                        : ErrorMessages.emailInvalid,
                  ),
                ),

                const SizedBox(height: 16),

                // ── 4. Pays et Ville ───────────────────────────────────────────
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _SectionLabel('Pays'),
                          const SizedBox(height: 6),
                          GestureDetector(
                            onTap: () {
                              showCountryPicker(
                                context: context,
                                showPhoneCode: false,
                                onSelect: (Country country) {
                                  setState(() {
                                    _selectedCountry = country.name;
                                  });
                                },
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 14),
                              decoration: BoxDecoration(
                                color:
                                    AppColors.saugePale.withValues(alpha: 0.4),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: AppColors.laitonLisere(opacity: 0.3),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      _selectedCountry ?? 'Sélectionner',
                                      style: AppTextStyles.bodyMedium(
                                        color: _selectedCountry == null
                                            ? AppColors.encre
                                                .withValues(alpha: 0.35)
                                            : AppColors.encre,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const Icon(Icons.arrow_drop_down,
                                      color: AppColors.laitonBrosse),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _SectionLabel('Ville'),
                          const SizedBox(height: 6),
                          _StyledField(
                            controller: _cityController,
                            hintText: 'Votre ville',
                            keyboardType: TextInputType.text,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 28),

                // ── CTA ────────────────────────────────────────────────────────
                InvitationButton(
                  label: 'Accéder à l\'application',
                  filled: true,
                  isLoading: isBusy,
                  onTap: isBusy ? null : _complete,
                ),

                const SizedBox(height: 10),

                Center(
                  child: TextButton(
                    onPressed: _skip,
                    child: Text(
                      'Passer cette étape',
                      style: AppTextStyles.bodyMedium(
                        color: AppColors.encre.withValues(alpha: 0.45),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),
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

class _StyledField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;

  const _StyledField({
    required this.controller,
    required this.hintText,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      onChanged: onChanged,
      style: AppTextStyles.bodyMedium(),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: AppTextStyles.bodyMedium(
            color: AppColors.encre.withValues(alpha: 0.35)),
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
      ),
    );
  }
}

class _DatePickerField extends StatelessWidget {
  final DateTime? value;
  final void Function(DateTime) onChanged;

  const _DatePickerField({
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
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
        }
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.saugePale.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: AppColors.laitonLisere(opacity: 0.3),
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
    );
  }
}
