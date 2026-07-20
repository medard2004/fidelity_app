import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../widgets/shared/invitation_button.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _phoneController = TextEditingController();
  final _firstNameController = TextEditingController();
  DateTime? _birthDate;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.porcelaine,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              Text('Carte', style: AppTextStyles.displayXL()),
              const SizedBox(height: 8),
              Text(
                'Votre portefeuille de fidélité, réuni en un seul geste.',
                style: AppTextStyles.bodyMedium(color: AppColors.encre.withOpacity(0.65)),
              ),
              const SizedBox(height: 48),
              Text('Prénom', style: AppTextStyles.label()),
              const SizedBox(height: 8),
              TextField(
                controller: _firstNameController,
                style: AppTextStyles.bodyLarge(),
                decoration: const InputDecoration(hintText: 'Votre prénom'),
              ),
              const SizedBox(height: 20),
              Text('Numéro de téléphone', style: AppTextStyles.label()),
              const SizedBox(height: 8),
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                style: AppTextStyles.bodyLarge(),
                decoration: const InputDecoration(hintText: '+228 90 12 34 56'),
              ),
              const SizedBox(height: 20),
              Text('Date de naissance', style: AppTextStyles.label()),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime(2000, 1, 1),
                    firstDate: DateTime(1930),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) setState(() => _birthDate = picked);
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
                  decoration: BoxDecoration(
                    color: AppColors.saugePale.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.laitonLisere(opacity: 0.25)),
                  ),
                  child: Text(
                    _birthDate == null
                        ? 'Sélectionner une date'
                        : '${_birthDate!.day}/${_birthDate!.month}/${_birthDate!.year}',
                    style: AppTextStyles.bodyMedium(
                      color: _birthDate == null
                          ? AppColors.encre.withOpacity(0.4)
                          : AppColors.encre,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              InvitationButton(
                label: 'Continuer',
                filled: true,
                onTap: () => context.push('/otp', extra: _phoneController.text),
              ),
              const SizedBox(height: 14),
              InvitationButton(
                label: 'Continuer avec Google',
                icon: Icons.g_mobiledata,
                onTap: () => context.push('/otp', extra: _phoneController.text),
              ),
              const SizedBox(height: 10),
              InvitationButton(
                label: 'Continuer avec Apple',
                icon: Icons.apple,
                onTap: () => context.push('/otp', extra: _phoneController.text),
              ),
              const SizedBox(height: 28),
              Center(
                child: TextButton(
                  onPressed: () => context.push('/login'),
                  child: Text(
                    'Déjà membre ? Se connecter',
                    style: AppTextStyles.bodyMedium(color: AppColors.vertBouteille),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
