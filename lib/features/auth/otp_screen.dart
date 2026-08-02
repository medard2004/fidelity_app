import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../providers/app_providers.dart';
import '../../widgets/shared/otp_input_row.dart';
import '../../core/errors/app_error.dart';
import '../../core/errors/form_error_handler.dart';
import '../../core/utils/loading_overlay_service.dart';
import '../../widgets/shared/keyboard_dismiss_pop_scope.dart';

/// Contexte d'utilisation de l'OTP, transmis via `extra` du router.
/// - `login`        → connexion classique, redirige vers /wallet
/// - `signup`       → inscription téléphone, redirige vers /complete-profile
/// - `social`       → vérification du numéro lors du profil social,
///                    redirige vers /wallet (le profil est déjà saisi)
enum OtpContext { login, signup, social, forgotPassword }

class OtpScreen extends ConsumerStatefulWidget {
  /// L'identifiant de l'utilisateur (téléphone ou email).
  final String identifier;
  final OtpContext otpContext;
  final bool isAuthReset;

  const OtpScreen({
    super.key,
    required this.identifier,
    this.otpContext = OtpContext.login,
    this.isAuthReset = false,
  });

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> with FormErrorHandler {
  final GlobalKey<OtpInputRowState> _otpKey = GlobalKey<OtpInputRowState>();
  int _secondsLeft = 30;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  void _startCountdown() {
    _secondsLeft = 30;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_secondsLeft == 0) {
        t.cancel();
      } else {
        setState(() => _secondsLeft--);
      }
    });
  }

  Future<void> _resendCode() async {
    if (isBusy) return;

    try {
      if (widget.otpContext == OtpContext.forgotPassword) {
        final success = await runGuarded(
          () => ref.read(authProvider.notifier).forgotPassword(widget.identifier),
          useOverlay: true,
          loadingMessage: 'Renvoi du code...',
        );
        if (mounted && (success ?? false)) {
          showSuccessToast('Le code a été renvoyé.');
          _startCountdown();
          _otpKey.currentState?.clear();
        } else if (mounted) {
          handleError(ref.read(authProvider).lastError, context: ErrorContext.forgotPassword);
        }
      } else {
        // Pour les autres contextes non encore implémentés,
        // on se contente de relancer le compteur visuellement.
        _startCountdown();
        _otpKey.currentState?.clear();
      }
    } catch (e) {
      if (mounted) handleError(e, context: ErrorContext.forgotPassword);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _onCompleted(String code) async {
    // Le widget OTP peut redéclencher onCompleted (ex. correction rapide du
    // dernier chiffre) : sans ce garde, une seconde vérification partirait
    // pendant que la première tourne encore.
    if (isBusy) return;

    switch (widget.otpContext) {
      case OtpContext.login:
        context.go('/wallet');

      case OtpContext.signup:
        context.go('/complete-profile');

      case OtpContext.social:
        try {
          final flow = ref.read(signupFlowProvider);
          await runGuarded(
            () => ref.read(authProvider.notifier).completeSocialProfile(
                  fullName: flow.fullName,
                  phone: flow.phone,
                  birthDate: flow.birthDate,
                ),
            useOverlay: true,
            loadingMessage: 'Validation...',
          );
          if (mounted) context.go('/wallet');
        } catch (e) {
          if (mounted) handleError(e, context: ErrorContext.completeProfile);
        }

      case OtpContext.forgotPassword:
        try {
          final resetToken = await runGuarded(
            () => ref.read(authProvider.notifier).verifyResetOtp(
                  widget.identifier,
                  code,
                ),
            useOverlay: true,
            loadingMessage: 'Vérification du code...',
          );

          if (resetToken != null && mounted) {
            context.push('/reset-password', extra: {
              'phone': widget.identifier,
              'token': resetToken,
              'isAuthReset': widget.isAuthReset,
            });
          } else if (mounted) {
            // Le code saisi occupe tout l'écran : le retour passe par un Toast.
            handleError(
              ref.read(authProvider).lastError,
              context: ErrorContext.verifyOtp,
            );
            _otpKey.currentState?.clear();
          }
        } catch (e) {
          if (mounted) {
            handleError(e, context: ErrorContext.verifyOtp);
            _otpKey.currentState?.clear();
          }
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    final contextLabel = switch (widget.otpContext) {
      OtpContext.login => 'Connexion',
      OtpContext.signup => 'Inscription',
      OtpContext.social => 'Vérification',
      OtpContext.forgotPassword => 'Récupération',
    };

    return KeyboardDismissPopScope(
      child: Scaffold(
        backgroundColor: AppColors.porcelaine,
      appBar: AppBar(
        backgroundColor: AppColors.porcelaine,
        elevation: 0,
        leading: BackButton(color: AppColors.encre),
        title: Text(
          contextLabel.toUpperCase(),
          style:
              AppTextStyles.monoSmall(color: AppColors.laitonBrosse).copyWith(
            letterSpacing: 2.5,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 32),
            Text('Vérification', style: AppTextStyles.displayXL()),
            const SizedBox(height: 8),
            Text(
              'Un code à 6 chiffres a été envoyé '
              '${widget.identifier.contains('@') ? 'à' : 'au'}\n'
              '${widget.identifier.isEmpty ? "+228 •• •• •• ••" : widget.identifier}',
              style: AppTextStyles.bodyMedium(
                color: AppColors.encre.withValues(alpha: 0.65),
              ),
            ),
            const SizedBox(height: 44),
            OtpInputRow(
              key: _otpKey,
              onCompleted: _onCompleted,
            ),
            const Spacer(),
            Center(
              child: TextButton(
                onPressed: _secondsLeft > 0 ? null : _resendCode,
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.laitonBrosse,
                  disabledForegroundColor:
                      AppColors.encre.withValues(alpha: 0.3),
                ),
                child: Text(
                  _secondsLeft > 0
                      ? 'Renvoyer le code dans 00:${_secondsLeft.toString().padLeft(2, '0')}'
                      : 'Renvoyer le code',
                  style: AppTextStyles.bodyMedium().copyWith(
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.underline,
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
