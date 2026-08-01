import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../widgets/shared/invitation_button.dart';
import '../../providers/app_providers.dart';
import '../../core/errors/app_error.dart';
import '../../core/errors/error_messages.dart';
import '../../core/errors/form_error_handler.dart';
import '../../widgets/shared/loading_overlay.dart';

class ResetPasswordScreen extends ConsumerStatefulWidget {
  final String accountId; // phone or email
  final String token; // reset token from verify-otp

  const ResetPasswordScreen(
      {super.key, required this.accountId, required this.token});

  @override
  ConsumerState<ResetPasswordScreen> createState() =>
      _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen>
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

    try {
      final success = await runLoading(
        context,
        () => ref.read(authProvider.notifier).resetPassword(
              widget.accountId,
              widget.token,
              password,
            ),
        message: 'Enregistrement…',
      );
      if (!mounted || success == null) return;

      if (success) {
        showSuccessToast(ErrorMessages.resetSuccess);
        context.go('/login');
      } else {
        final appError = handleError(
          ref.read(authProvider).lastError,
          context: ErrorContext.resetPassword,
        );
        // Un refus portant sur le mot de passe reste affiché sous les champs.
        final passwordError = appError.fieldErrors['password'];
        if (passwordError != null) {
          setState(() => _errorText = passwordError);
        }
      }
    } catch (e) {
      if (mounted) handleError(e, context: ErrorContext.resetPassword);
    }
  }

  @override
  Widget build(BuildContext context) {
    final titleStyle = GoogleFonts.bodoniModa(
      fontSize: 48,
      fontWeight: FontWeight.w600,
      color: AppColors.encre,
      height: 1.1,
    );

    return Scaffold(
      backgroundColor: AppColors.porcelaine,
      appBar: AppBar(
        backgroundColor: AppColors.porcelaine,
        elevation: 0,
        leading: const BackButton(color: AppColors.encre),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Nouveau mot de passe', style: titleStyle),
              const SizedBox(height: 16),
              Text(
                'Créez un nouveau mot de passe pour votre compte.',
                style: AppTextStyles.bodyMedium(
                  color: AppColors.encre.withValues(alpha: 0.65),
                ),
              ),
              const SizedBox(height: 32),

              // ── Champ Mot de passe ───────────────────────────────────────
              Text('Nouveau mot de passe', style: AppTextStyles.label()),
              const SizedBox(height: 8),
              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                onChanged: (_) => setState(() => _errorText = null),
                style: AppTextStyles.bodyMedium(),
                decoration: InputDecoration(
                  hintText: '••••••••',
                  hintStyle: AppTextStyles.bodyMedium(
                    color: AppColors.encre.withValues(alpha: 0.35),
                  ),
                  filled: true,
                  fillColor: AppColors.saugePale.withValues(alpha: 0.4),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide:
                        BorderSide(color: AppColors.laitonLisere(opacity: 0.3)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide:
                        BorderSide(color: AppColors.laitonLisere(opacity: 0.3)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                        color: AppColors.laitonBrosse, width: 1.2),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: AppColors.encre.withValues(alpha: 0.5),
                      size: 20,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // ── Critères de mot de passe ───────────────────────────────
              _ValidationRule(
                label: 'Au moins 8 caractères',
                isValid: _hasMinLength,
              ),
              const SizedBox(height: 8),
              _ValidationRule(
                label: 'Une majuscule',
                isValid: _hasUppercase,
              ),
              const SizedBox(height: 8),
              _ValidationRule(
                label: 'Un chiffre',
                isValid: _hasDigit,
              ),
              const SizedBox(height: 24),

              // ── Champ Confirmation ───────────────────────────────────────
              Text('Confirmer le mot de passe', style: AppTextStyles.label()),
              const SizedBox(height: 8),
              TextFormField(
                controller: _confirmController,
                obscureText: _obscureConfirm,
                onChanged: (_) => setState(() => _errorText = null),
                style: AppTextStyles.bodyMedium(),
                decoration: InputDecoration(
                  hintText: '••••••••',
                  hintStyle: AppTextStyles.bodyMedium(
                    color: AppColors.encre.withValues(alpha: 0.35),
                  ),
                  filled: true,
                  fillColor: AppColors.saugePale.withValues(alpha: 0.4),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                        color: _errorText != null
                            ? AppColors.bordeauxProfond
                            : AppColors.laitonLisere(opacity: 0.3)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                        color: _errorText != null
                            ? AppColors.bordeauxProfond
                            : AppColors.laitonLisere(opacity: 0.3)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: _errorText != null
                          ? AppColors.bordeauxProfond
                          : AppColors.laitonBrosse,
                      width: 1.2,
                    ),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirm
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: AppColors.encre.withValues(alpha: 0.5),
                      size: 20,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureConfirm = !_obscureConfirm;
                      });
                    },
                  ),
                ),
              ),

              if (_errorText != null) ...[
                const SizedBox(height: 8),
                Text(
                  _errorText!,
                  style: AppTextStyles.bodySmall(color: AppColors.bordeauxProfond),
                ),
              ],

              const SizedBox(height: 48),

              // ── CTA ────────────────────────────────────────────────
              Consumer(
                builder: (context, ref, child) {
                  return InvitationButton(
                    label: 'Enregistrer',
                    filled: true,
                    onTap: _submit,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ValidationRule extends StatelessWidget {
  final String label;
  final bool isValid;

  const _ValidationRule({required this.label, required this.isValid});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          isValid ? Icons.check_circle_rounded : Icons.radio_button_unchecked,
          color: isValid
              ? AppColors.vertBouteille
              : AppColors.encre.withValues(alpha: 0.3),
          size: 16,
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: AppTextStyles.bodySmall(
            color: isValid
                ? AppColors.vertBouteille
                : AppColors.encre.withValues(alpha: 0.5),
          ),
        ),
      ],
    );
  }
}
