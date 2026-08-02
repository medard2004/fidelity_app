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
import '../../core/errors/error_translator.dart';
import '../../core/errors/form_error_handler.dart';

/// Page 1 du flux : vérification du mot de passe actuel.
/// Si correct → navigation vers [SetNewPasswordScreen].
class VerifyCurrentPasswordScreen extends ConsumerStatefulWidget {
  const VerifyCurrentPasswordScreen({super.key});

  @override
  ConsumerState<VerifyCurrentPasswordScreen> createState() =>
      _VerifyCurrentPasswordScreenState();
}

class _VerifyCurrentPasswordScreenState
    extends ConsumerState<VerifyCurrentPasswordScreen>
    with SingleTickerProviderStateMixin, FormErrorHandler {
  final _passwordController = TextEditingController();
  bool _obscure = true;
  String? _errorText;

  late AnimationController _shieldAnim;
  late Animation<double> _shieldScale;

  @override
  void initState() {
    super.initState();
    _shieldAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _shieldScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _shieldAnim, curve: Curves.elasticOut),
    );
    _shieldAnim.forward();
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _shieldAnim.dispose();
    super.dispose();
  }

  Future<void> _verify() async {
    if (isBusy) return;

    final password = _passwordController.text.trim();
    if (password.isEmpty) {
      setState(() => _errorText = ErrorMessages.fieldRequired);
      return;
    }

    setState(() => _errorText = null);

    try {
      final valid = await runGuarded(
        () => ref.read(authProvider.notifier).verifyPassword(password),
      );
      if (!mounted || valid == null) return;

      if (valid) {
        // Mot de passe correct → aller à la page 2
        context.push('/set-new-password', extra: password);
      } else {
        // Le mot de passe saisi est en cause : message sous le champ.
        final appError = ErrorTranslator.translate(
          ref.read(authProvider).lastError,
          context: ErrorContext.verifyPassword,
        );
        setState(() => _errorText = appError.fieldErrors['current_password'] ??
            appError.generalMessage ??
            ErrorMessages.passwordCurrentIncorrect);
      }
    } catch (e) {
      if (!mounted) return;
      final appError = ErrorTranslator.translate(
        e,
        context: ErrorContext.verifyPassword,
      );
      setState(() => _errorText =
          appError.generalMessage ?? ErrorMessages.passwordCurrentIncorrect);
    }
  }

  void _onForgotPasswordTap() {
    context.push('/confirm-identity');
  }

  @override
  Widget build(BuildContext context) {
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

                      // ── Icône de bouclier ──────────────────────────────
                      ScaleTransition(
                        scale: _shieldScale,
                        child: Container(
                          width: 88,
                          height: 88,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                AppColors.vertBouteille.withValues(alpha: 0.12),
                                AppColors.laitonBrosse.withValues(alpha: 0.08),
                              ],
                            ),
                            border: Border.all(
                              color: AppColors.laitonLisere(opacity: 0.35),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.ombreChaude(opacity: 0.08),
                                blurRadius: 16,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.shield_outlined,
                            color:
                                AppColors.vertBouteille.withValues(alpha: 0.8),
                            size: 38,
                          ),
                        ),
                      ),

                      const SizedBox(height: 28),

                      // ── Titre + description ────────────────────────────
                      Text(
                        'Vérification\nd\'identité',
                        textAlign: TextAlign.center,
                        style: titleStyle,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Pour votre sécurité, confirmez votre\nmot de passe actuel avant de le modifier.',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.bodyMedium(
                          color: AppColors.encre.withValues(alpha: 0.6),
                        ),
                      ),

                      const SizedBox(height: 40),

                      // ── Champ mot de passe ─────────────────────────────
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Row(
                          children: [
                            Icon(
                              Icons.lock_outline,
                              size: 15,
                              color:
                                  AppColors.laitonBrosse.withValues(alpha: 0.7),
                            ),
                            const SizedBox(width: 6),
                            Text('Mot de passe actuel',
                                style: AppTextStyles.label()),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscure,
                        onChanged: (_) => setState(() => _errorText = null),
                        onFieldSubmitted: (_) => _verify(),
                        style: AppTextStyles.bodyMedium(),
                        decoration: InputDecoration(
                          hintText: 'Entrez votre mot de passe',
                          hintStyle: AppTextStyles.bodyMedium(
                            color: AppColors.encre.withValues(alpha: 0.3),
                          ),
                          filled: true,
                          fillColor: AppColors.saugePale.withValues(alpha: 0.4),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 16),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: _errorText != null
                                  ? AppColors.bordeauxProfond
                                      .withValues(alpha: 0.5)
                                  : AppColors.laitonLisere(opacity: 0.3),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: _errorText != null
                                  ? AppColors.bordeauxProfond
                                      .withValues(alpha: 0.5)
                                  : AppColors.laitonLisere(opacity: 0.3),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: _errorText != null
                                  ? AppColors.bordeauxProfond
                                  : AppColors.laitonBrosse,
                              width: 1.2,
                            ),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscure
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: AppColors.encre.withValues(alpha: 0.45),
                              size: 20,
                            ),
                            onPressed: () =>
                                setState(() => _obscure = !_obscure),
                          ),
                        ),
                      ),

                      // ── Erreur ─────────────────────────────────────────
                      if (_errorText != null) ...[
                        const SizedBox(height: 14),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: AppColors.bordeauxProfond
                                .withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: AppColors.bordeauxProfond
                                  .withValues(alpha: 0.25),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.error_outline_rounded,
                                size: 16,
                                color: AppColors.bordeauxProfond
                                    .withValues(alpha: 0.8),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _errorText!,
                                  style: AppTextStyles.bodySmall(
                                    color: AppColors.bordeauxProfond,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      const SizedBox(height: 16),

                      // ── Lien mot de passe oublié ───────────────────────
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: _onForgotPasswordTap,
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: const Size(0, 0),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text(
                            'Mot de passe oublié ?',
                            style: AppTextStyles.bodySmall(
                              color:
                                  AppColors.laitonBrosse.withValues(alpha: 0.8),
                            ).copyWith(
                              decoration: TextDecoration.underline,
                              decorationColor:
                                  AppColors.laitonBrosse.withValues(alpha: 0.5),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── CTA sticky bottom ──────────────────────────────────────
              const SizedBox(height: 16),
              Consumer(
                builder: (context, ref, child) {
                  return InvitationButton(
                    label: 'Continuer',
                    filled: true,
                    onTap: isBusy ? null : _verify,
                  );
                },
              ),
              const SizedBox(height: 8),

              // ── Indicateur de progression ───────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _StepDot(active: true),
                  const SizedBox(width: 8),
                  _StepDot(active: false),
                ],
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

/// Pastille d'étape (1/2 ou 2/2).
class _StepDot extends StatelessWidget {
  final bool active;
  const _StepDot({required this.active});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: active ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        color: active
            ? AppColors.vertBouteille
            : AppColors.encre.withValues(alpha: 0.15),
      ),
    );
  }
}
