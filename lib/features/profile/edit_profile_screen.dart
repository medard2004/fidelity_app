import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../providers/app_providers.dart';
import '../../widgets/shared/phone_input_with_country_picker.dart';
import '../../widgets/shared/phone_confirmation_dialog.dart';
import 'package:country_picker/country_picker.dart';
import '../../core/errors/app_error.dart';
import '../../core/errors/error_messages.dart';
import '../../core/errors/form_error_handler.dart';

/// Types de champs éditables depuis la page d'informations personnelles.
enum EditFieldType { fullName, phone, birthDate, email, city, country }

class EditFieldScreen extends ConsumerStatefulWidget {
  final EditFieldType fieldType;

  const EditFieldScreen({super.key, required this.fieldType});

  @override
  ConsumerState<EditFieldScreen> createState() => _EditFieldScreenState();
}

class _EditFieldScreenState extends ConsumerState<EditFieldScreen>
    with FormErrorHandler {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _controller;
  final _phoneInputKey = GlobalKey<PhoneInputWithCountryPickerState>();
  DateTime? _birthDate;
  String? _selectedCountry;

  String get _title => switch (widget.fieldType) {
        EditFieldType.fullName => 'Nom complet',
        EditFieldType.phone => 'Téléphone',
        EditFieldType.birthDate => 'Date de naissance',
        EditFieldType.email => 'Email',
        EditFieldType.city => 'Ville',
        EditFieldType.country => 'Pays',
      };

  @override
  void initState() {
    super.initState();
    final user = ref.read(authProvider).user;
    _controller = TextEditingController(
      text: switch (widget.fieldType) {
        EditFieldType.fullName => user?.fullName ?? '',
        EditFieldType.phone =>
          (user?.phoneNumber ?? '').replaceFirst(RegExp(r'^\+\d+\s*'), ''),
        EditFieldType.email => user?.email ?? '',
        EditFieldType.city => user?.city ?? '',
        EditFieldType.country => '',
        EditFieldType.birthDate => '',
      },
    );
    if (widget.fieldType == EditFieldType.birthDate) {
      _birthDate = user?.birthDate;
    } else if (widget.fieldType == EditFieldType.country) {
      _selectedCountry = user?.country;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (isBusy) return;

    final user = ref.read(authProvider).user;
    if (user == null) return;

    // Champ vide : message sous le champ, et surtout pas de spinner bloqué.
    clearAllFieldErrors();
    if (!(_formKey.currentState?.validate() ?? false)) return;

    // Confirmation téléphone : interaction UI, résolue avant d'ouvrir l'overlay
    // de chargement (qui ne doit couvrir que l'appel réseau lui-même).
    String? confirmedPhone;
    if (widget.fieldType == EditFieldType.phone) {
      final fullPhone = _phoneInputKey.currentState?.fullPhoneNumber ??
          _controller.text.trim();
      final confirmed =
          await PhoneConfirmationDialog.show(context, phoneNumber: fullPhone);
      if (!confirmed || !mounted) return;
      confirmedPhone = fullPhone;
    }

    if (widget.fieldType == EditFieldType.birthDate && _birthDate == null) {
      showErrorToast(ErrorMessages.birthdateRequired);
      return;
    }

    try {
      await runLoading(
        context,
        () async {
          switch (widget.fieldType) {
            case EditFieldType.fullName:
              final val = _controller.text.trim();
              await ref.read(authProvider.notifier).updateFullProfile(
                    fullName: val,
                    phoneNumber: user.phoneNumber,
                    birthDate: user.birthDate,
                    email: user.email,
                    country: user.country,
                  );

            case EditFieldType.phone:
              await ref.read(authProvider.notifier).updateFullProfile(
                    fullName: user.fullName,
                    phoneNumber: confirmedPhone!,
                    birthDate: user.birthDate,
                    email: user.email,
                    country: user.country,
                  );

            case EditFieldType.birthDate:
              await ref.read(authProvider.notifier).updateFullProfile(
                    fullName: user.fullName,
                    phoneNumber: user.phoneNumber,
                    birthDate: _birthDate,
                    email: user.email,
                    country: user.country,
                  );

            case EditFieldType.email:
              await ref.read(authProvider.notifier).updateFullProfile(
                    fullName: user.fullName,
                    phoneNumber: user.phoneNumber,
                    birthDate: user.birthDate,
                    email: _controller.text.trim(),
                    country: user.country,
                  );

            case EditFieldType.city:
              await ref.read(authProvider.notifier).updateFullProfile(
                    fullName: user.fullName,
                    phoneNumber: user.phoneNumber,
                    birthDate: user.birthDate,
                    email: user.email,
                    city: _controller.text.trim(),
                    country: user.country,
                  );

            case EditFieldType.country:
              await ref.read(authProvider.notifier).updateFullProfile(
                    fullName: user.fullName,
                    phoneNumber: user.phoneNumber,
                    birthDate: user.birthDate,
                    email: user.email,
                    city: user.city,
                    country: _selectedCountry,
                  );
          }
        },
        message: 'Enregistrement…',
      );

      if (mounted) {
        context.pop();
        showSuccessToast(ErrorMessages.profileSaveSuccess);
      }
    } catch (e) {
      if (mounted) {
        handleError(
          e,
          context: ErrorContext.updateProfile,
          formKey: _formKey,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.porcelaine,
      appBar: AppBar(
        backgroundColor: AppColors.porcelaine,
        elevation: 0,
        leading: const BackButton(color: AppColors.encre),
        title: Text(
          'MODIFIER',
          style: AppTextStyles.monoSmall(color: AppColors.laitonBrosse)
              .copyWith(letterSpacing: 2.5, fontWeight: FontWeight.w500),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _title,
              style: GoogleFonts.bodoniModa(
                fontSize: 28,
                fontWeight: FontWeight.w600,
                color: AppColors.encre,
              ),
            ),
            const SizedBox(height: 24),

            // ── Champ d'édition ──────────────────────────────────────────
            Form(key: _formKey, child: _buildField()),

            const Spacer(),

            // ── Bouton Sauvegarder ───────────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: isBusy ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.vertBouteille,
                  foregroundColor: AppColors.porcelaine,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: isBusy
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: AppColors.porcelaine,
                        ),
                      )
                    : Text(
                        'Enregistrer',
                        style: AppTextStyles.bodyMedium(
                          color: AppColors.porcelaine,
                        ).copyWith(fontWeight: FontWeight.w600),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField() {
    switch (widget.fieldType) {
      case EditFieldType.fullName:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Nom complet', style: AppTextStyles.label()),
            const SizedBox(height: 8),
            TextFormField(
              controller: _controller,
              autofocus: true,
              style: AppTextStyles.bodyMedium(),
              decoration: _decoration('Prénom Nom'),
              onChanged: (_) => clearFieldError('first_name'),
              validator: fieldValidator(
                'first_name',
                requiredMessage: ErrorMessages.fieldRequired,
              ),
            ),
          ],
        );

      case EditFieldType.phone:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Numéro de téléphone', style: AppTextStyles.label()),
            const SizedBox(height: 8),
            PhoneInputWithCountryPicker(
              key: _phoneInputKey,
              controller: _controller,
              validator: fieldValidator(
                'phone',
                requiredMessage: ErrorMessages.fieldRequired,
              ),
            ),
          ],
        );

      case EditFieldType.birthDate:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Date de naissance', style: AppTextStyles.label()),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _birthDate ?? DateTime(2000, 1, 1),
                  firstDate: DateTime(1930),
                  lastDate: DateTime.now(),
                );
                if (picked != null) setState(() => _birthDate = picked);
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
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
                        _birthDate == null
                            ? 'Sélectionner une date'
                            : '${_birthDate!.day.toString().padLeft(2, '0')}/${_birthDate!.month.toString().padLeft(2, '0')}/${_birthDate!.year}',
                        style: AppTextStyles.bodyMedium(
                          color: _birthDate == null
                              ? AppColors.encre.withValues(alpha: 0.35)
                              : AppColors.encre,
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.calendar_today_outlined,
                      size: 16,
                      color: AppColors.laitonBrosse,
                    ),
                  ],
                ),
              ),
            ),
          ],
        );

      case EditFieldType.email:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Adresse email', style: AppTextStyles.label()),
            const SizedBox(height: 8),
            TextFormField(
              controller: _controller,
              autofocus: true,
              keyboardType: TextInputType.emailAddress,
              style: AppTextStyles.bodyMedium(),
              decoration: _decoration('votre@email.com'),
              onChanged: (_) => clearFieldError('email'),
              // Facultatif : format vérifié seulement si l'utilisateur saisit.
              validator: fieldValidator(
                'email',
                extra: (v) => v.contains('@') && v.contains('.')
                    ? null
                    : ErrorMessages.emailInvalid,
              ),
            ),
          ],
        );

      case EditFieldType.city:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Ville', style: AppTextStyles.label()),
            const SizedBox(height: 8),
            TextFormField(
              controller: _controller,
              autofocus: true,
              keyboardType: TextInputType.text,
              textCapitalization: TextCapitalization.words,
              style: AppTextStyles.bodyMedium(),
              decoration: _decoration('Votre ville'),
              onChanged: (_) => clearFieldError('city'),
              validator: fieldValidator('city'),
            ),
          ],
        );

      case EditFieldType.country:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Pays', style: AppTextStyles.label()),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () {
                // Ignore lint rule since we need this import dynamically or we just add it to the file top
                // Wait, I need to add the import to the top of the file!
                // I will add it using another ReplaceContent
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
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
                        _selectedCountry ?? 'Sélectionner un pays',
                        style: AppTextStyles.bodyMedium(
                          color: _selectedCountry == null
                              ? AppColors.encre.withValues(alpha: 0.35)
                              : AppColors.encre,
                        ),
                      ),
                    ),
                    const Icon(Icons.arrow_drop_down,
                        color: AppColors.laitonBrosse),
                  ],
                ),
              ),
            ),
          ],
        );
    }
  }

  InputDecoration _decoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: AppTextStyles.bodyMedium(
        color: AppColors.encre.withValues(alpha: 0.35),
      ),
      filled: true,
      fillColor: AppColors.saugePale.withValues(alpha: 0.4),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
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
        borderSide: const BorderSide(
          color: AppColors.laitonBrosse,
          width: 1.2,
        ),
      ),
    );
  }
}
