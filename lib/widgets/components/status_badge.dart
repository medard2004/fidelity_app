import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_radius.dart';

enum StatusTone { neutral, primary, success, warning, error }

({Color bg, Color fg}) _toneColors(StatusTone tone) {
  switch (tone) {
    case StatusTone.neutral:
      return (bg: AppColors.surfaceMuted, fg: AppColors.inkMuted(opacity: 0.8));
    case StatusTone.primary:
      return (bg: AppColors.primaryTint, fg: AppColors.primaryDark);
    case StatusTone.success:
      return (bg: AppColors.successTint, fg: AppColors.success);
    case StatusTone.warning:
      return (bg: AppColors.warningTint, fg: AppColors.warning);
    case StatusTone.error:
      return (bg: AppColors.errorTint, fg: AppColors.error);
  }
}

/// Pastille de statut non-interactive (récompense verrouillée, expiration,
/// résultat anti-fraude...). Remplace les couleurs Material brutes
/// (`Colors.green.shade*` etc.) et les puces dupliquées par écran.
class StatusBadge extends StatelessWidget {
  final String label;
  final StatusTone tone;
  final IconData? icon;

  const StatusBadge({
    super.key,
    required this.label,
    this.tone = StatusTone.neutral,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final c = _toneColors(tone);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: c.bg,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: c.fg),
            const SizedBox(width: 4),
          ],
          Text(label, style: AppTextStyles.label(color: c.fg).copyWith(fontSize: 11)),
        ],
      ),
    );
  }
}

/// Puce sélectionnable (sélecteur de restaurant, destinataires...).
/// Un seul composant pour les deux styles de chip trouvés dupliqués
/// dans l'app (sélection simple vs. chip avec suppression).
class SelectableChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback? onTap;
  final VoidCallback? onDeleted;

  const SelectableChip({
    super.key,
    required this.label,
    this.selected = false,
    this.onTap,
    this.onDeleted,
  });

  @override
  Widget build(BuildContext context) {
    final bg = selected ? AppColors.primary : AppColors.surfaceCard;
    final fg = selected ? Colors.white : AppColors.ink;
    final border = selected ? AppColors.primary : AppColors.border;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(AppRadius.pill),
          border: Border.all(color: border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label, style: AppTextStyles.label(color: fg)),
            if (onDeleted != null) ...[
              const SizedBox(width: 6),
              GestureDetector(
                onTap: onDeleted,
                child: Icon(Icons.close_rounded, size: 14, color: fg),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
