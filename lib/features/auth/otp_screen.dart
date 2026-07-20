import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../providers/app_providers.dart';
import '../../widgets/shared/otp_input_row.dart';

class OtpScreen extends ConsumerStatefulWidget {
  final String phoneNumber;
  const OtpScreen({super.key, required this.phoneNumber});

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
    ref.read(authProvider.notifier).completeOtp();
    context.go('/onboarding/scan');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.porcelaine,
      appBar: AppBar(leading: BackButton(color: AppColors.encre)),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Vérification', style: AppTextStyles.displayXL()),
            const SizedBox(height: 8),
            Text(
              'Un code à 6 chiffres a été envoyé au\n${widget.phoneNumber.isEmpty ? "+228 •• •• •• ••" : widget.phoneNumber}',
              style: AppTextStyles.bodyMedium(color: AppColors.encre.withOpacity(0.65)),
            ),
            const SizedBox(height: 44),
            OtpInputRow(onCompleted: _onCompleted),
            const SizedBox(height: 32),
            Center(
              child: _secondsLeft > 0
                  ? Text(
                      'Renvoyer le code dans 00:${_secondsLeft.toString().padLeft(2, '0')}',
                      style: AppTextStyles.monoSmall(),
                    )
                  : TextButton(
                      onPressed: _startCountdown,
                      child: Text('Renvoyer le code',
                          style: AppTextStyles.bodyMedium(color: AppColors.vertBouteille)),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
