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
import '../../widgets/shared/loading_overlay.dart';

/// Page 2 du flux : saisie du nouveau mot de passe.
/// Reçoit le mot de passe actuel vérifié en paramètre [currentPassword].
class SetNewPasswordScreen extends ConsumerStatefulWidget {
  final String currentPassword;

  const SetNewPasswordScreen({super.key, required this.currentPassword});

  @override
  ConsumerState<SetNewPasswordScreen> createState() =>
      _SetNewPasswordScreenState();
}

class _SetNewPasswordScreenState extends ConsumerState<SetNewPasswordScreen>
    with FormErrorHandler {
  final _newPasswordController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _obscureNew = true;
  bool _obscureConfirm = true;
  String? _errorText;
  bool _success = false;

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  // ── Validations ─────────────────────────────────────────────────────────────
  bool get _hasMinLength => _newPasswordController.text.length >= 8;
  bool get _hasUppercase =>
      _newPasswordController.text.contains(RegExp(r'[A-Z]'));
  bool get _hasDigit => _newPasswordController.text.contains(RegExp(r'[0-9]'));
  bool get _passwordsMatch =>
      _newPasswordController.text == _confirmController.text &&
      _confirmController.text.isNotEmpty;

  Future<void> _submit() async {
    if (isBusy) return;

    final newPwd = _newPasswordController.text;
    final confirm = _confirmController.text;

    if (newPwd.isEmpty || confirm.isEmpty) {
      setState(() => _errorText = ErrorMessages.fieldRequired);
      return;
    }
    if (newPwd.length < 8) {
      setState(() => _errorText = ErrorMessages.passwordTooShort);
      return;
    }
    if (!_hasUppercase) {
      setState(() => _errorText = ErrorMessages.passwordNeedsUppercase);
      return;
    }
    if (!_hasDigit) {
      setState(() => _errorText = ErrorMessages.passwordNeedsDigit);
      return;
    }
    if (newPwd != confirm) {
      setState(() => _errorText = ErrorMessages.passwordMismatch);
      return;
    }
    if (widget.currentPassword == newPwd) {
      setState(() => _errorText = ErrorMessages.passwordMustDiffer);
      return;
    }

    setState(() => _errorText = null);

    LoadingOverlay.show(context, message: 'Enregistrement…');
    try {
      final success = await ref
          .read(authProvider.notifier)
          .changePassword(widget.currentPassword, newPwd);
      LoadingOverlay.hide();

      if (mounted) {
        if (success) {
          setState(() => _success = true);
          // Pop les deux pages après le succès
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) {
              // Pop back to profile (2 levels: set-new-password + change-password)
              context.pop();
              context.pop();
            }
          });
        } else {
          final appError = ErrorTranslator.translate(
            ref.read(authProvider).lastError,
            context: ErrorContext.changePassword,
          );
          setState(() => _errorText =
              appError.fieldErrors['current_password'] ??
                  appError.fieldErrors['password'] ??
                  appError.generalMessage ??
                  ErrorMessages.passwordChangeFailed);
        }
      }
    } catch (e) {
      LoadingOverlay.hide();
      if (!mounted) return;
      final appError = ErrorTranslator.translate(
        e,
        context: ErrorContext.changePassword,
      );
      setState(() => _errorText =
          appError.generalMessage ?? ErrorMessages.passwordChangeFailed);
    }
  }

  @override
  Widget build(BuildContext context) {
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
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          child: _success ? _buildSuccessView() : _buildFormView(),
        ),
      ),
    );
  }

  // ── Écran de succès ─────────────────────────────────────────────────────────
  Widget _buildSuccessView() {
    return Center(
      key: const ValueKey('success'),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 600),
              curve: Curves.elasticOut,
              builder: (context, value, child) => Transform.scale(
                scale: value,
                child: child,
              ),
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.vertBouteille.withValues(alpha: 0.1),
                  border: Border.all(
                    color: AppColors.vertBouteille.withValues(alpha: 0.3),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.vertBouteille.withValues(alpha: 0.1),
                      blurRadius: 24,
                      spreadRadius: 4,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: AppColors.vertBouteille,
                  size: 48,
                ),
              ),
            ),
            const SizedBox(height: 28),
            Text(
              'Mot de passe modifié !',
              style: GoogleFonts.bodoniModa(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: AppColors.encre,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Votre compte est désormais sécurisé\navec votre nouveau mot de passe.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium(
                color: AppColors.encre.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Formulaire ──────────────────────────────────────────────────────────────
  Widget _buildFormView() {
    final titleStyle = GoogleFonts.bodoniModa(
      fontSize: 28,
      fontWeight: FontWeight.w600,
      color: AppColors.encre,
      height: 1.15,
    );

    return Column(
      key: const ValueKey('form'),
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),

                // ── En-tête ────────────────────────────────────────────
                Center(
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.laitonBrosse.withValues(alpha: 0.12),
                          AppColors.vertBouteille.withValues(alpha: 0.08),
                        ],
                      ),
                      border: Border.all(
                        color: AppColors.laitonLisere(opacity: 0.35),
                        width: 1.5,
                      ),
                    ),
                    child: Icon(
                      Icons.lock_reset_rounded,
                      color: AppColors.laitonBrosse.withValues(alpha: 0.8),
                      size: 32,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: Text(
                    'Nouveau mot de passe',
                    style: titleStyle,
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    'Choisissez un mot de passe sécurisé\npour protéger votre compte.',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodyMedium(
                      color: AppColors.encre.withValues(alpha: 0.6),
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // ── Nouveau mot de passe ──────────────────────────────
                _buildFieldLabel(
                    'Nouveau mot de passe', Icons.lock_outline_rounded),
                const SizedBox(height: 8),
                _buildPasswordField(
                  controller: _newPasswordController,
                  obscure: _obscureNew,
                  toggleObscure: () =>
                      setState(() => _obscureNew = !_obscureNew),
                  hint: '••••••••',
                ),

                const SizedBox(height: 16),

                // ── Critères de sécurité ──────────────────────────────
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.saugePale.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.laitonLisere(opacity: 0.2),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'CRITÈRES DE SÉCURITÉ',
                        style: AppTextStyles.monoSmall(
                          color: AppColors.laitonBrosse.withValues(alpha: 0.8),
                        ).copyWith(fontSize: 10, letterSpacing: 1.2),
                      ),
                      const SizedBox(height: 10),
                      _ValidationRule(
                        label: 'Au moins 8 caractères',
                        isValid: _hasMinLength,
                      ),
                      const SizedBox(height: 6),
                      _ValidationRule(
                        label: 'Une lettre majuscule',
                        isValid: _hasUppercase,
                      ),
                      const SizedBox(height: 6),
                      _ValidationRule(
                        label: 'Un chiffre',
                        isValid: _hasDigit,
                      ),
                      const SizedBox(height: 6),
                      _ValidationRule(
                        label: 'Confirmation identique',
                        isValid: _passwordsMatch,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // ── Confirmation ──────────────────────────────────────
                _buildFieldLabel(
                    'Confirmer le mot de passe', Icons.check_circle_outline),
                const SizedBox(height: 8),
                _buildPasswordField(
                  controller: _confirmController,
                  obscure: _obscureConfirm,
                  toggleObscure: () =>
                      setState(() => _obscureConfirm = !_obscureConfirm),
                  hint: '••••••••',
                  hasError: _errorText != null &&
                      _errorText!.contains('correspondent'),
                ),

                // ── Erreur ───────────────────────────────────────────
                if (_errorText != null) ...[
                  const SizedBox(height: 14),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.bordeauxProfond.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color:
                            AppColors.bordeauxProfond.withValues(alpha: 0.25),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.error_outline_rounded,
                          size: 16,
                          color:
                              AppColors.bordeauxProfond.withValues(alpha: 0.8),
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

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),

        // ── CTA sticky bottom ────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
          child: Column(
            children: [
              Consumer(
                builder: (context, ref, child) {
                  return InvitationButton(
                    label: 'Enregistrer le mot de passe',
                    filled: true,
                    onTap: _submit,
                  );
                },
              ),
              const SizedBox(height: 8),

              // ── Indicateur de progression ───────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _StepDot(active: false),
                  const SizedBox(width: 8),
                  _StepDot(active: true),
                ],
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ],
    );
  }

  // ── Helpers ─────────────────────────────────────────────────────────────────
  Widget _buildFieldLabel(String label, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          size: 15,
          color: AppColors.laitonBrosse.withValues(alpha: 0.7),
        ),
        const SizedBox(width: 6),
        Text(label, style: AppTextStyles.label()),
      ],
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required bool obscure,
    required VoidCallback toggleObscure,
    required String hint,
    bool hasError = false,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      onChanged: (_) => setState(() => _errorText = null),
      style: AppTextStyles.bodyMedium(),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: AppTextStyles.bodyMedium(
          color: AppColors.encre.withValues(alpha: 0.3),
        ),
        filled: true,
        fillColor: AppColors.saugePale.withValues(alpha: 0.4),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: hasError
                ? AppColors.bordeauxProfond.withValues(alpha: 0.5)
                : AppColors.laitonLisere(opacity: 0.3),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: hasError
                ? AppColors.bordeauxProfond.withValues(alpha: 0.5)
                : AppColors.laitonLisere(opacity: 0.3),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color:
                hasError ? AppColors.bordeauxProfond : AppColors.laitonBrosse,
            width: 1.2,
          ),
        ),
        suffixIcon: IconButton(
          icon: Icon(
            obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
            color: AppColors.encre.withValues(alpha: 0.45),
            size: 20,
          ),
          onPressed: toggleObscure,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Widgets locaux
// ─────────────────────────────────────────────────────────────────────────────

class _ValidationRule extends StatelessWidget {
  final String label;
  final bool isValid;

  const _ValidationRule({required this.label, required this.isValid});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          transitionBuilder: (child, animation) => ScaleTransition(
            scale: animation,
            child: child,
          ),
          child: Icon(
            isValid ? Icons.check_circle_rounded : Icons.radio_button_unchecked,
            key: ValueKey(isValid),
            color: isValid
                ? AppColors.vertBouteille
                : AppColors.encre.withValues(alpha: 0.25),
            size: 16,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: AppTextStyles.bodySmall(
            color: isValid
                ? AppColors.vertBouteille
                : AppColors.encre.withValues(alpha: 0.45),
          ),
        ),
      ],
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
