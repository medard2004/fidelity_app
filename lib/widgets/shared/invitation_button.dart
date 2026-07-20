import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_radius.dart';

/// Bouton "carton d'invitation" : fond porcelaine, liseré laiton fin,
/// scale subtil (0.98) au tap, jamais de rebond visible.
class InvitationButton extends StatefulWidget {
  final String label;
  final VoidCallback onTap;
  final IconData? icon;
  final bool filled; // vert bouteille plein — réservé au CTA principal
  final bool fullWidth;

  const InvitationButton({
    super.key,
    required this.label,
    required this.onTap,
    this.icon,
    this.filled = false,
    this.fullWidth = true,
  });

  @override
  State<InvitationButton> createState() => _InvitationButtonState();
}

class _InvitationButtonState extends State<InvitationButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final bg = widget.filled ? AppColors.vertBouteille : AppColors.porcelaine;
    final fg = widget.filled ? AppColors.porcelaine : AppColors.encre;

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _pressed ? 0.98 : 1.0,
        duration: const Duration(milliseconds: 90),
        curve: Curves.easeOut,
        child: Container(
          width: widget.fullWidth ? double.infinity : null,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(AppRadius.button),
            border: widget.filled
                ? null
                : Border.all(color: AppColors.laitonLisere(opacity: 0.55)),
          ),
          child: Row(
            mainAxisSize: widget.fullWidth ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.icon != null) ...[
                Icon(widget.icon, size: 17, color: fg),
                const SizedBox(width: 8),
              ],
              Text(widget.label, style: AppTextStyles.label(color: fg)),
            ],
          ),
        ),
      ),
    );
  }
}

/// Bouton discret, texte seul (ex. Déconnexion).
class DiscreetTextButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final Color color;

  const DiscreetTextButton({
    super.key,
    required this.label,
    required this.onTap,
    this.color = AppColors.encre,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(foregroundColor: color.withOpacity(0.6)),
      child: Text(label, style: AppTextStyles.bodyMedium(color: color.withOpacity(0.6))),
    );
  }
}
