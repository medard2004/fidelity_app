import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_radius.dart';

/// Tuile de statistique compacte — profil (cartes/offres/filleuls),
/// progression parrainage. Un seul composant pour ce pattern répété.
class StatTile extends StatelessWidget {
  final String value;
  final String label;
  final IconData? icon;

  const StatTile(
      {super.key, required this.value, required this.label, this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(AppRadius.card - 4),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 18, color: AppColors.primary),
            const SizedBox(height: 6),
          ],
          Text(value, style: AppTextStyles.monoLarge().copyWith(fontSize: 20)),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodySmall(
                color: AppColors.inkMuted(opacity: 0.6)),
          ),
        ],
      ),
    );
  }
}
