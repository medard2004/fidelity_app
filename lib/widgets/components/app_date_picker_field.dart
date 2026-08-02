import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_radius.dart';

/// Champ de sélection de date — remplace les 4 implémentations
/// quasi-identiques dupliquées à travers les écrans d'authentification
/// et le profil. Reprend la même décoration que les champs de texte
/// (via `InputDecorationTheme`) pour rester visuellement identique.
class AppDatePickerField extends StatelessWidget {
  final DateTime? value;
  final void Function(DateTime) onChanged;
  final String? Function(DateTime?)? validator;
  final String hintText;
  final String helpText;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final DateTime? initialPickerDate;

  const AppDatePickerField({
    super.key,
    required this.value,
    required this.onChanged,
    this.validator,
    this.hintText = 'Sélectionner une date',
    this.helpText = 'Date de naissance',
    this.firstDate,
    this.lastDate,
    this.initialPickerDate,
  });

  @override
  Widget build(BuildContext context) {
    return FormField<DateTime>(
      initialValue: value,
      validator: validator,
      builder: (state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate:
                      value ?? initialPickerDate ?? DateTime(2000, 1, 1),
                  firstDate: firstDate ?? DateTime(1930),
                  lastDate: lastDate ??
                      DateTime.now().subtract(const Duration(days: 365 * 16)),
                  helpText: helpText,
                  builder: (context, child) => Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: const ColorScheme.light(
                        primary: AppColors.primary,
                        onPrimary: Colors.white,
                        surface: AppColors.surfaceCard,
                      ),
                    ),
                    child: child!,
                  ),
                );
                if (picked != null) {
                  onChanged(picked);
                  state.didChange(picked);
                }
              },
              child: Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: AppColors.surfaceMuted,
                  borderRadius: BorderRadius.circular(AppRadius.input),
                  border: Border.all(
                    color: state.hasError ? AppColors.error : AppColors.border,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        value == null
                            ? hintText
                            : '${value!.day.toString().padLeft(2, '0')}/'
                                '${value!.month.toString().padLeft(2, '0')}/'
                                '${value!.year}',
                        style: AppTextStyles.bodyMedium(
                          color: value == null
                              ? AppColors.inkMuted(opacity: 0.4)
                              : AppColors.ink,
                        ),
                      ),
                    ),
                    const Icon(Icons.calendar_today_outlined,
                        size: 16, color: AppColors.primary),
                  ],
                ),
              ),
            ),
            if (state.hasError)
              Padding(
                padding: const EdgeInsets.only(top: 6, left: 4),
                child: Text(
                  state.errorText!,
                  style: AppTextStyles.bodySmall(color: AppColors.error)
                      .copyWith(color: AppColors.error),
                ),
              ),
          ],
        );
      },
    );
  }
}
