import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../providers/app_providers.dart';
import '../../widgets/components/components.dart';
import '../../widgets/shared/phone_input_with_country_picker.dart';

/// Étape post-connexion sociale (Google/Apple).
/// Collecte : Nom complet · Téléphone · Date de naissance.
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

    ref.read(authProvider.notifier).completeSocialProfile(
          fullName: _fullNameController.text.trim(),
          phone: fullPhone,
          birthDate: _birthDate,
        );

    ref.read(signupFlowProvider.notifier).reset();
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
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Compléter le profil', style: AppTextStyles.displayXL()),

                      const SizedBox(height: 20),

                      Text('Nom complet', style: AppTextStyles.label()),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _fullNameController,
                        keyboardType: TextInputType.name,
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Veuillez saisir votre nom complet'
                            : null,
                        decoration: const InputDecoration(hintText: 'Prénom Nom'),
                      ),

                      const SizedBox(height: 16),

                      Text('Numéro de téléphone', style: AppTextStyles.label()),
                      const SizedBox(height: 6),
                      PhoneInputWithCountryPicker(
                        key: _phoneInputKey,
                        controller: _phoneController,
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Veuillez saisir votre numéro'
                            : null,
                      ),

                      const SizedBox(height: 16),

                      Text('Date de naissance', style: AppTextStyles.label()),
                      const SizedBox(height: 6),
                      AppDatePickerField(
                        value: _birthDate,
                        onChanged: (date) => setState(() => _birthDate = date),
                        validator: (_) => _birthDate == null
                            ? 'Veuillez sélectionner votre date de naissance'
                            : null,
                      ),

                      const SizedBox(height: 28),

                      AppButton(label: 'Accéder à l\'application', onTap: _submit),
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
