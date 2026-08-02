import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

/// Petit label majuscule au-dessus d'une section ou d'un titre
/// ("VOS PRIVILÈGES", "VOTRE CARTE"...). Un seul point d'appui pour
/// ce pattern répété à travers l'app.
class SectionEyebrow extends StatelessWidget {
  final String text;
  final Color color;

  const SectionEyebrow(this.text, {super.key, this.color = AppColors.primary});

  @override
  Widget build(BuildContext context) {
    return Text(text.toUpperCase(), style: AppTextStyles.eyebrow(color: color));
  }
}
