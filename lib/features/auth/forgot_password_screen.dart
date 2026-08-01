import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../widgets/shared/invitation_button.dart';
import '../../widgets/shared/phone_input_with_country_picker.dart';
import '../../widgets/shared/phone_confirmation_dialog.dart';
import '../../providers/app_providers.dart';
import '../../core/errors/app_error.dart';
import '../../core/errors/error_messages.dart';
import '../../core/errors/form_error_handler.dart';
import '../../widgets/shared/loading_overlay.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen>
    with FormErrorHandler {
  final _formKey = GlobalKey<FormState>();
  final _phoneInputKey = GlobalKey<PhoneInputWithCountryPickerState>();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();

  bool _useEmail = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (isBusy) return;

    // Un champ vide est signalé sous le champ plutôt que par un retour muet.
    clearAllFieldErrors();
    if (!(_formKey.currentState?.validate() ?? false)) return;

    String identifier = '';
    if (_useEmail) {
      identifier = _emailController.text.trim();
    } else {
      final raw = _phoneController.text.trim();
      identifier = _phoneInputKey.currentState?.fullPhoneNumber ?? raw;
    }

    if (!_useEmail) {
      final confirmed = await PhoneConfirmationDialog.show(
        context,
        phoneNumber: identifier,
      );
      if (!confirmed || !mounted) return;
    }

    try {
      final success = await runLoading(
        context,
        () => ref.read(authProvider.notifier).forgotPassword(identifier),
        message: 'Envoi en cours…',
      );
      if (!mounted || success == null) return;

      if (success) {
        showSuccessToast(ErrorMessages.forgotCodeSent);
        context.push('/otp', extra: {
          'phone': identifier,
          'context': 'forgotPassword',
        });
      } else {
        // Compte inexistant → sous le champ ; panne d'envoi → Toast.
        handleError(
          ref.read(authProvider).lastError,
          context: ErrorContext.forgotPassword,
          formKey: _formKey,
        );
      }
    } catch (e) {
      if (mounted) {
        handleError(
          e,
          context: ErrorContext.forgotPassword,
          formKey: _formKey,
        );
      }
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
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Mot de passe oublié', style: titleStyle),
                const SizedBox(height: 16),
                Text(
                  'Entrez votre ${_useEmail ? "adresse email" : "numéro de téléphone"} pour recevoir un code de réinitialisation.',
                  style: AppTextStyles.bodyMedium(
                    color: AppColors.encre.withValues(alpha: 0.65),
                  ),
                ),
                const SizedBox(height: 32),
                if (_useEmail) ...[
                  Text('Adresse email', style: AppTextStyles.label()),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    style: AppTextStyles.bodyMedium(),
                    onChanged: (_) => clearFieldError('email'),
                    validator: fieldValidator(
                      'email',
                      requiredMessage: ErrorMessages.fieldRequired,
                      extra: (v) => v.contains('@') && v.contains('.')
                          ? null
                          : ErrorMessages.emailInvalid,
                    ),
                    decoration: InputDecoration(
                      hintText: 'jean.dupont@example.com',
                      hintStyle: AppTextStyles.bodyMedium(
                        color: AppColors.encre.withValues(alpha: 0.35),
                      ),
                      filled: true,
                      fillColor: AppColors.saugePale.withValues(alpha: 0.4),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 15),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                            color: AppColors.laitonLisere(opacity: 0.3)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                            color: AppColors.laitonLisere(opacity: 0.3)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                          color: AppColors.laitonBrosse,
                          width: 1.2,
                        ),
                      ),
                    ),
                  ),
                ] else ...[
                  Text('Numéro de téléphone', style: AppTextStyles.label()),
                  const SizedBox(height: 8),
                  PhoneInputWithCountryPicker(
                    key: _phoneInputKey,
                    controller: _phoneController,
                    validator: fieldValidator(
                      'phone',
                      requiredMessage: ErrorMessages.fieldRequired,
                    ),
                  ),
                ],
                const SizedBox(height: 48),
                Consumer(
                  builder: (context, ref, child) {
                    return InvitationButton(
                      label: 'Envoyer le code',
                      filled: true,
                      onTap: _submit,
                    );
                  },
                ),
                const SizedBox(height: 24),
                Center(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _useEmail = !_useEmail;
                      });
                    },
                    child: Text(
                      _useEmail
                          ? 'Utiliser mon numéro de téléphone'
                          : 'Utiliser mon adresse email',
                      style: AppTextStyles.bodyMedium(
                        color: AppColors.laitonBrosse,
                      ).copyWith(
                        fontWeight: FontWeight.w600,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
