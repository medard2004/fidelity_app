import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class PhoneConfirmationDialog extends StatelessWidget {
  final String phoneNumber;

  const PhoneConfirmationDialog({
    super.key,
    required this.phoneNumber,
  });

  static Future<bool> show(
    BuildContext context, {
    required String phoneNumber,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => PhoneConfirmationDialog(
        phoneNumber: phoneNumber,
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.porcelaine,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.vertBouteille.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.phone_iphone_rounded,
                color: AppColors.vertBouteille,
                size: 32,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Confirmez votre numéro',
              style: AppTextStyles.displayMedium().copyWith(
                color: AppColors.encre,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Veuillez vérifier que ce numéro est correct. Nous l\'utiliserons pour sécuriser votre compte.',
              style: AppTextStyles.bodyMedium(
                color: AppColors.encre.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.saugePale.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.laitonLisere(opacity: 0.3)),
              ),
              child: Text(
                phoneNumber,
                style: AppTextStyles.displayMedium().copyWith(
                  color: AppColors.vertBouteille,
                  letterSpacing: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Modifier',
                      style: AppTextStyles.label().copyWith(
                        color: AppColors.encre.withValues(alpha: 0.7),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context, true);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.laitonBrosse,
                      foregroundColor: AppColors.porcelaine,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Confirmer',
                      style: AppTextStyles.label().copyWith(
                        color: AppColors.porcelaine,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
