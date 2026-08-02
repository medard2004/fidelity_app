import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../providers/app_providers.dart';
import '../../widgets/shared/invitation_button.dart';
import '../../core/errors/app_error.dart';
import '../../core/errors/error_messages.dart';
import '../../core/errors/form_error_handler.dart';

/// Page intermédiaire affichée depuis les paramètres de sécurité.
/// Montre le numéro/email de l'utilisateur et demande confirmation
/// avant d'envoyer le code OTP de réinitialisation.
class ConfirmIdentityScreen extends ConsumerStatefulWidget {
  const ConfirmIdentityScreen({super.key});

  @override
  ConsumerState<ConfirmIdentityScreen> createState() =>
      _ConfirmIdentityScreenState();
}

class _ConfirmIdentityScreenState extends ConsumerState<ConfirmIdentityScreen>
    with SingleTickerProviderStateMixin, FormErrorHandler {
  late AnimationController _iconAnim;
  late Animation<double> _iconScale;

  /// 'phone' or 'email' — tracks which method is selected
  String _selectedMethod = 'phone';

  @override
  void initState() {
    super.initState();
    _iconAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _iconScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _iconAnim, curve: Curves.elasticOut),
    );
    _iconAnim.forward();
  }

  @override
  void dispose() {
    _iconAnim.dispose();
    super.dispose();
  }

  Future<void> _sendCode() async {
    if (isBusy) return;

    final user = ref.read(authProvider).user;
    if (user == null) return;

    final identifier = _selectedMethod == 'email'
        ? user.email!
        : user.phoneNumber;

    try {
      final success = await runGuarded(
        () => ref.read(authProvider.notifier).forgotPassword(identifier),
        useOverlay: true,
        loadingMessage: 'Envoi du code...',
      );

      if (mounted && (success ?? false)) {
        showSuccessToast(ErrorMessages.forgotCodeSent);
        context.push('/otp', extra: {
          'phone': identifier,
          'context': 'forgotPassword',
          'isAuthReset': true,
        });
      } else if (mounted) {
        handleError(
          ref.read(authProvider).lastError,
          context: ErrorContext.forgotPassword,
        );
      }
    } catch (e) {
      if (mounted) handleError(e, context: ErrorContext.forgotPassword);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).user;
    if (user == null) return const SizedBox.shrink();

    final hasEmail = user.email != null && user.email!.isNotEmpty;

    final titleStyle = GoogleFonts.bodoniModa(
      fontSize: 28,
      fontWeight: FontWeight.w600,
      color: AppColors.encre,
      height: 1.15,
    );

    return Scaffold(
      backgroundColor: AppColors.porcelaine,
      appBar: AppBar(
        backgroundColor: AppColors.porcelaine,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: const BackButton(color: AppColors.encre),
        title: Text(
          'SÉCURITÉ',
          style: AppTextStyles.monoSmall(color: AppColors.laitonBrosse)
              .copyWith(letterSpacing: 1.5),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 32),

                      // ── Icône animée ──────────────────────────────────
                      ScaleTransition(
                        scale: _iconScale,
                        child: Container(
                          width: 88,
                          height: 88,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                AppColors.vertBouteille
                                    .withValues(alpha: 0.12),
                                AppColors.laitonBrosse
                                    .withValues(alpha: 0.08),
                              ],
                            ),
                            border: Border.all(
                              color: AppColors.laitonLisere(opacity: 0.35),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color:
                                    AppColors.ombreChaude(opacity: 0.08),
                                blurRadius: 16,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.verified_user_outlined,
                            color: AppColors.vertBouteille
                                .withValues(alpha: 0.8),
                            size: 38,
                          ),
                        ),
                      ),

                      const SizedBox(height: 28),

                      // ── Titre + description ──────────────────────────
                      Text(
                        'Confirmer\nvotre identité',
                        textAlign: TextAlign.center,
                        style: titleStyle,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Un code de vérification sera envoyé\npour réinitialiser votre mot de passe.',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.bodyMedium(
                          color: AppColors.encre.withValues(alpha: 0.6),
                        ),
                      ),

                      const SizedBox(height: 36),

                      // ── Sélection de la méthode ───────────────────────
                      _MethodCard(
                        icon: Icons.sms_outlined,
                        title: 'Par SMS',
                        subtitle: user.maskedPhoneNumber,
                        selected: _selectedMethod == 'phone',
                        onTap: () =>
                            setState(() => _selectedMethod = 'phone'),
                      ),

                      if (hasEmail) ...[
                        const SizedBox(height: 12),
                        _MethodCard(
                          icon: Icons.email_outlined,
                          title: 'Par email',
                          subtitle: user.email!,
                          selected: _selectedMethod == 'email',
                          onTap: () =>
                              setState(() => _selectedMethod = 'email'),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              // ── CTA sticky bottom ─────────────────────────────────
              const SizedBox(height: 16),
              InvitationButton(
                label: 'Envoyer le code',
                filled: true,
                loading: isBusy,
                onTap: isBusy ? null : _sendCode,
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

/// Carte sélectionnable pour le choix de la méthode (SMS / Email).
class _MethodCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  const _MethodCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.vertBouteille.withValues(alpha: 0.06)
              : AppColors.porcelaine,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected
                ? AppColors.vertBouteille.withValues(alpha: 0.5)
                : AppColors.laitonLisere(opacity: 0.35),
            width: selected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: selected
                    ? AppColors.vertBouteille.withValues(alpha: 0.12)
                    : AppColors.saugePale.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                size: 20,
                color: selected
                    ? AppColors.vertBouteille
                    : AppColors.laitonBrosse,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.bodyMedium(
                      color: AppColors.encre,
                    ).copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: AppTextStyles.bodySmall(
                      color: AppColors.encre.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected
                    ? AppColors.vertBouteille
                    : Colors.transparent,
                border: Border.all(
                  color: selected
                      ? AppColors.vertBouteille
                      : AppColors.encre.withValues(alpha: 0.2),
                  width: selected ? 2 : 1.5,
                ),
              ),
              child: selected
                  ? const Icon(
                      Icons.check,
                      size: 14,
                      color: AppColors.porcelaine,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
