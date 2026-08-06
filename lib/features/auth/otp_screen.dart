import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../l10n/gen/app_localizations.dart';
import '../../providers/app_providers.dart';
import '../../providers/settings_provider.dart';
import '../../widgets/shared/app_detail_bar.dart';
import '../../widgets/shared/otp_input_row.dart';

/// Contexte d'utilisation de l'OTP, transmis via `extra` du router.
/// - `login`        → connexion classique, redirige vers /wallet
/// - `signup`       → inscription téléphone, redirige vers /complete-profile
/// - `social`       → vérification du numéro lors du profil social,
///                    redirige vers /wallet (le profil est déjà saisi)
enum OtpContext { login, signup, social }

class OtpScreen extends ConsumerStatefulWidget {
  final String phoneNumber;
  final OtpContext otpContext;

  const OtpScreen({
    super.key,
    required this.phoneNumber,
    this.otpContext = OtpContext.login,
  });

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
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

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _onCompleted(String code) {
    switch (widget.otpContext) {
      case OtpContext.login:
        ref
            .read(authProvider.notifier)
            .completeLogin(phone: widget.phoneNumber);
        context.go('/wallet');

      case OtpContext.signup:
        final flow = ref.read(signupFlowProvider);
        ref.read(authProvider.notifier).completeSignupOtp(flow);
        context.go('/complete-profile');

      case OtpContext.social:
        // Le profil social est déjà entièrement saisi dans CompleteSocialProfileScreen.
        // On arrive ici après la vérif du téléphone → on termine l'enregistrement.
        final flow = ref.read(signupFlowProvider);
        ref.read(authProvider.notifier).completeSocialProfile(
              fullName: flow.fullName,
              phone: flow.phone,
              birthDate: flow.birthDate,
            );
        context.go('/wallet');
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(themeModeProvider);
    final t = AppLocalizations.of(context)!;
    final contextLabel = switch (widget.otpContext) {
      OtpContext.login => t.otpContextLogin,
      OtpContext.signup => t.otpContextSignup,
      OtpContext.social => t.otpContextSocial,
    };

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppDetailBar(title: contextLabel),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 32),
            Text(t.otpTitle, style: AppTextStyles.displayXL()),
            const SizedBox(height: 8),
            Text(
              t.otpSentMessage(widget.phoneNumber.isEmpty
                  ? '+228 •• •• •• ••'
                  : widget.phoneNumber),
              style: AppTextStyles.bodyMedium(
                  color: AppColors.inkMuted(opacity: 0.65)),
            ),
            const SizedBox(height: 44),
            OtpInputRow(onCompleted: _onCompleted),
            const SizedBox(height: 32),
            Center(
              child: _secondsLeft > 0
                  ? Text(
                      t.otpResendCountdown(
                          _secondsLeft.toString().padLeft(2, '0')),
                      style: AppTextStyles.monoSmall(),
                    )
                  : TextButton(
                      onPressed: _startCountdown,
                      child: Text(t.otpResendButton,
                          style: AppTextStyles.bodyMedium(
                              color: AppColors.primary)),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
