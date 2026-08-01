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
import '../../widgets/shared/loading_overlay.dart';

/// Écran de création de mot de passe (étape finale de l'inscription).
class CreatePasswordScreen extends ConsumerStatefulWidget {
  const CreatePasswordScreen({super.key});

  @override
  ConsumerState<CreatePasswordScreen> createState() =>
      _CreatePasswordScreenState();
}

class _CreatePasswordScreenState extends ConsumerState<CreatePasswordScreen>
    with FormErrorHandler {
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  String? _errorText;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  bool get _hasMinLength => _passwordController.text.length >= 8;
  bool get _hasUppercase => _passwordController.text.contains(RegExp(r'[A-Z]'));
  bool get _hasDigit => _passwordController.text.contains(RegExp(r'[0-9]'));

  Future<void> _submit() async {
    if (isBusy) return;

    final password = _passwordController.text;
    final confirm = _confirmController.text;

    if (password.isEmpty || confirm.isEmpty) {
      setState(() => _errorText = ErrorMessages.fieldRequired);
      return;
    }
    if (password.length < 8) {
      setState(() => _errorText = ErrorMessages.passwordTooShort);
      return;
    }
    if (password != confirm) {
      setState(() => _errorText = ErrorMessages.passwordMismatch);
      return;
    }

    setState(() => _errorText = null);

    // Finaliser l'inscription avec le flow existant
    final flow = ref.read(signupFlowProvider);

    try {
      final success = await runLoading(
        context,
        () => ref.read(authProvider.notifier).register(flow, password),
        message: 'Création du compte…',
      );
      if (!mounted || success == null) return;

      if (success) {
        showSuccessToast(ErrorMessages.signupSuccess);
        context.go('/wallet');
      } else {
        final appError = handleError(
          ref.read(authProvider).lastError,
          context: ErrorContext.signup,
        );
        // Une erreur portant sur le mot de passe s'affiche sous les champs.
        final passwordError = appError.fieldErrors['password'];
        if (passwordError != null) {
          setState(() => _errorText = passwordError);
        }
      }
    } catch (e) {
      if (mounted) handleError(e, context: ErrorContext.signup);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Removing authState dependency for button text
    final titleStyle = GoogleFonts.bodoniModa(
      fontSize: 48,
      fontWeight: FontWeight.w600,
      color: AppColors.encre,
      height: 1.1,
    );

    return Scaffold(
      backgroundColor: AppColors.porcelaine,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - 32,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Bouton retour ──────────────────────────────────────
                    GestureDetector(
                      onTap: () => context.pop(),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.saugePale.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 16,
                          color: AppColors.encre,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // ── Titre ──────────────────────────────────────────────
                    Text('Sécurisez\nvotre compte', style: titleStyle),
                    const SizedBox(height: 8),
                    Text(
                      'Créez un mot de passe pour protéger votre compte.',
                      style: AppTextStyles.bodyMedium(
                        color: AppColors.encre.withValues(alpha: 0.55),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // ── Mot de passe ───────────────────────────────────────
                    Text('Mot de passe', style: AppTextStyles.label()),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      style: AppTextStyles.bodyMedium(),
                      onChanged: (_) => setState(() {}),
                      decoration: _inputDecoration(
                        hintText: '8 caractères minimum',
                        obscure: _obscurePassword,
                        onToggle: () => setState(
                            () => _obscurePassword = !_obscurePassword),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // ── Indicateurs de force ──────────────────────────────
                    _PasswordRule(
                      label: 'Au moins 8 caractères',
                      met: _hasMinLength,
                    ),
                    const SizedBox(height: 4),
                    _PasswordRule(
                      label: 'Au moins une majuscule',
                      met: _hasUppercase,
                    ),
                    const SizedBox(height: 4),
                    _PasswordRule(
                      label: 'Au moins un chiffre',
                      met: _hasDigit,
                    ),
                    const SizedBox(height: 24),

                    // ── Confirmation ───────────────────────────────────────
                    Text('Confirmer le mot de passe',
                        style: AppTextStyles.label()),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _confirmController,
                      obscureText: _obscureConfirm,
                      style: AppTextStyles.bodyMedium(),
                      onChanged: (_) => setState(() => _errorText = null),
                      decoration: _inputDecoration(
                        hintText: 'Retapez votre mot de passe',
                        obscure: _obscureConfirm,
                        onToggle: () =>
                            setState(() => _obscureConfirm = !_obscureConfirm),
                      ),
                    ),

                    // ── Erreur ─────────────────────────────────────────────
                    if (_errorText != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        _errorText!,
                        style: AppTextStyles.bodySmall(
                          color: AppColors.bordeauxProfond,
                        ),
                      ),
                    ],

                    const SizedBox(height: 32),

                    // ── CTA ────────────────────────────────────────────────
                    InvitationButton(
                      label: 'Créer mon compte',
                      filled: true,
                      onTap: _submit,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hintText,
    required bool obscure,
    required VoidCallback onToggle,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: AppTextStyles.bodyMedium(
        color: AppColors.encre.withValues(alpha: 0.35),
      ),
      filled: true,
      fillColor: AppColors.saugePale.withValues(alpha: 0.4),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
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
      suffixIcon: IconButton(
        icon: Icon(
          obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
          color: AppColors.encre.withValues(alpha: 0.5),
          size: 20,
        ),
        onPressed: onToggle,
      ),
    );
  }
}

/// Indicateur visuel de règle de mot de passe (check vert ou gris).
class _PasswordRule extends StatelessWidget {
  final String label;
  final bool met;

  const _PasswordRule({required this.label, required this.met});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          met ? Icons.check_circle_rounded : Icons.circle_outlined,
          size: 14,
          color: met
              ? AppColors.vertBouteille
              : AppColors.encre.withValues(alpha: 0.25),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: AppTextStyles.bodySmall(
            color: met
                ? AppColors.vertBouteille
                : AppColors.encre.withValues(alpha: 0.4),
          ),
        ),
      ],
    );
  }
}
