import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

/// Diviseur "OU" entre deux modes d'action (ex. téléphone / social).
class OrDivider extends StatelessWidget {
  final String label;

  const OrDivider({super.key, this.label = 'OU'});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Divider(color: AppColors.border)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(label,
              style: AppTextStyles.eyebrow(
                  color: AppColors.inkMuted(opacity: 0.5))),
        ),
        Expanded(child: Divider(color: AppColors.border)),
      ],
    );
  }
}
