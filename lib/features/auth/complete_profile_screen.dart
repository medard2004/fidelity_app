import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../l10n/gen/app_localizations.dart';
import '../../providers/app_providers.dart';
import '../../providers/settings_provider.dart';
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
    ref.watch(themeModeProvider);
    final t = AppLocalizations.of(context)!;
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  children: [
                    const Icon(LucideIcons.circleCheckBig,
                        color: Colors.white, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        user != null && user.firstName.isNotEmpty
                            ? t.completeProfileWelcomeNamed(user.firstName)
                            : t.completeProfileWelcomeAnon,
                        style: AppTextStyles.bodyMedium(color: Colors.white)
                            .copyWith(height: 1.3),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Text(t.completeProfileTitle,
                  style: AppTextStyles.displayMedium()),
              const SizedBox(height: 20),
              Text(t.editProfileFullName, style: AppTextStyles.label()),
              const SizedBox(height: 6),
              TextField(
                controller: _fullNameController,
                keyboardType: TextInputType.name,
                decoration:
                    InputDecoration(hintText: t.editProfileFullNameHint),
              ),
              const SizedBox(height: 16),
              Text(t.editProfileBirthDate, style: AppTextStyles.label()),
              const SizedBox(height: 6),
              AppDatePickerField(
                value: _birthDate,
                onChanged: (date) => setState(() => _birthDate = date),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Text(t.editProfileEmail, style: AppTextStyles.label()),
                  const SizedBox(width: 8),
                  StatusBadge(label: t.commonOptional),
                ],
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(hintText: t.editProfileEmailHint),
              ),
              const SizedBox(height: 28),
              AppButton(label: t.completeProfileSubmit, onTap: _complete),
              const SizedBox(height: 10),
              Center(
                child: TextButton(
                  onPressed: _skip,
                  child: Text(
                    t.completeProfileSkip,
                    style: AppTextStyles.bodyMedium(
                        color: AppColors.inkMuted(opacity: 0.45)),
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
