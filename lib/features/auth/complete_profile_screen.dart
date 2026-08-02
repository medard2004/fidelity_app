import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../providers/app_providers.dart';
import '../../widgets/components/components.dart';

/// Étape post-inscription : Nom complet · Date de naissance · Email (optionnel).
class CompleteProfileScreen extends ConsumerStatefulWidget {
  const CompleteProfileScreen({super.key});

  @override
  ConsumerState<CompleteProfileScreen> createState() =>
      _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends ConsumerState<CompleteProfileScreen> {
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  DateTime? _birthDate;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _complete() {
    ref.read(authProvider.notifier).updateProfile(
          firstName: _fullNameController.text.trim().isNotEmpty
              ? _fullNameController.text.trim()
              : null,
          email: _emailController.text.trim().isNotEmpty
              ? _emailController.text.trim()
              : null,
        );
    ref.read(authProvider.notifier).completeProfile(
          email: _emailController.text.trim().isNotEmpty
              ? _emailController.text.trim()
              : null,
        );
    context.go('/wallet');
  }

  void _skip() {
    ref.read(authProvider.notifier).completeProfile();
    context.go('/wallet');
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).user;

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppCard(
                backgroundColor: AppColors.primary,
                bordered: false,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle_outline, color: Colors.white, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Bienvenue${user != null && user.firstName.isNotEmpty ? ", ${user.firstName}" : ""} !\nVotre compte a été créé.',
                        style: AppTextStyles.bodyMedium(color: Colors.white).copyWith(height: 1.3),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              Text('Complétez votre profil', style: AppTextStyles.displayMedium()),

              const SizedBox(height: 20),

              Text('Nom complet', style: AppTextStyles.label()),
              const SizedBox(height: 6),
              TextField(
                controller: _fullNameController,
                keyboardType: TextInputType.name,
                decoration: const InputDecoration(hintText: 'Prénom Nom'),
              ),

              const SizedBox(height: 16),

              Text('Date de naissance', style: AppTextStyles.label()),
              const SizedBox(height: 6),
              AppDatePickerField(
                value: _birthDate,
                onChanged: (date) => setState(() => _birthDate = date),
              ),

              const SizedBox(height: 16),

              Row(
                children: [
                  Text('Email', style: AppTextStyles.label()),
                  const SizedBox(width: 8),
                  const StatusBadge(label: 'Optionnel'),
                ],
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(hintText: 'votre@email.com'),
              ),

              const SizedBox(height: 28),

              AppButton(label: 'Accéder à l\'application', onTap: _complete),

              const SizedBox(height: 10),

              Center(
                child: TextButton(
                  onPressed: _skip,
                  child: Text(
                    'Passer cette étape',
                    style: AppTextStyles.bodyMedium(color: AppColors.inkMuted(opacity: 0.45)),
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
