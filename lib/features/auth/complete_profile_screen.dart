import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../providers/app_providers.dart';
import '../../widgets/shared/invitation_button.dart';

/// Étape post-inscription par téléphone : Ville · Quartier · Email (optionnel).
class CompleteProfileScreen extends ConsumerStatefulWidget {
  const CompleteProfileScreen({super.key});

  @override
  ConsumerState<CompleteProfileScreen> createState() =>
      _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends ConsumerState<CompleteProfileScreen> {
  final _cityController = TextEditingController();
  final _neighborhoodController = TextEditingController();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _cityController.dispose();
    _neighborhoodController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _complete() {
    ref.read(authProvider.notifier).completeProfile(
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
      backgroundColor: AppColors.porcelaine,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Encart de bienvenue ────────────────────────────────────────
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: BoxDecoration(
                  color: AppColors.vertBouteille,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle_outline,
                        color: AppColors.porcelaine, size: 22),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Bienvenue${user != null ? ", ${user.firstName}" : ""} !\nVotre compte a été créé avec succès.',
                        style: AppTextStyles.bodyMedium(
                                color: AppColors.porcelaine)
                            .copyWith(height: 1.4),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 36),

              // ── Titre ──────────────────────────────────────────────────────
              Text('Complétez votre profil', style: AppTextStyles.displayLarge()),
              const SizedBox(height: 10),
              Text(
                'Ces informations permettent aux établissements de personnaliser vos avantages. Vous pouvez les renseigner plus tard depuis votre profil.',
                style: AppTextStyles.bodyMedium(
                  color: AppColors.encre.withOpacity(0.6),
                ),
              ),

              const SizedBox(height: 36),

              // ── Ville ──────────────────────────────────────────────────────
              _SectionLabel('Ville'),
              const SizedBox(height: 8),
              _StyledField(
                controller: _cityController,
                hintText: 'Ex. Lomé',
                keyboardType: TextInputType.text,
              ),

              const SizedBox(height: 20),

              // ── Quartier ───────────────────────────────────────────────────
              _SectionLabel('Quartier'),
              const SizedBox(height: 8),
              _StyledField(
                controller: _neighborhoodController,
                hintText: 'Ex. Bè, Adidogomé…',
                keyboardType: TextInputType.text,
              ),

              const SizedBox(height: 20),

              // ── Email ──────────────────────────────────────────────────────
              Row(
                children: [
                  _SectionLabel('Email'),
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
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
              _StyledField(
                controller: _emailController,
                hintText: 'votre@email.com',
                keyboardType: TextInputType.emailAddress,
              ),

              const SizedBox(height: 40),

              // ── CTA ────────────────────────────────────────────────────────
              InvitationButton(
                label: 'Accéder à l\'application',
                filled: true,
                onTap: _complete,
              ),

              const SizedBox(height: 14),

              Center(
                child: TextButton(
                  onPressed: _skip,
                  child: Text(
                    'Passer cette étape',
                    style: AppTextStyles.bodyMedium(
                      color: AppColors.encre.withOpacity(0.45),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),
            ],
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

  const _StyledField({
    required this.controller,
    required this.hintText,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: AppTextStyles.bodyLarge(),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle:
            AppTextStyles.bodyLarge(color: AppColors.encre.withOpacity(0.35)),
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
      ),
    );
  }
}
