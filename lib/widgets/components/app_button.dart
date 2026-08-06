import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_motion.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_radius.dart';

enum AppButtonVariant { primary, secondary, outline, ghost, destructive }

/// Bouton unique de l'app — remplace tous les `ElevatedButton` ad-hoc.
/// Un seul composant, 5 variantes, un seul comportement de press (scale +
/// fondu, voir [AppMotion]), un état de chargement intégré.
class AppButton extends StatefulWidget {
  final String label;
  final VoidCallback? onTap;
  final IconData? icon;
  final Widget? leading;
  final AppButtonVariant variant;
  final bool fullWidth;
  final bool loading;
  final double height;

  const AppButton({
    super.key,
    required this.label,
    required this.onTap,
    this.icon,
    this.leading,
    this.variant = AppButtonVariant.primary,
    this.fullWidth = true,
    this.loading = false,
    this.height = 52,
  });

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton> {
  bool _pressed = false;

  bool get _enabled => widget.onTap != null && !widget.loading;

  ({Color bg, Color fg, Color? border}) _colorsFor(AppButtonVariant variant) {
    if (!_enabled) {
      return (
        bg: variant == AppButtonVariant.outline ||
                variant == AppButtonVariant.ghost
            ? Colors.transparent
            : AppColors.surfaceMuted,
        fg: AppColors.inkMuted(opacity: 0.35),
        border: variant == AppButtonVariant.outline ? AppColors.border : null,
      );
    }
    switch (variant) {
      case AppButtonVariant.primary:
        return (bg: AppColors.primary, fg: Colors.white, border: null);
      case AppButtonVariant.secondary:
        return (
          bg: AppColors.primaryTint,
          fg: AppColors.primaryDark,
          border: null
        );
      case AppButtonVariant.outline:
        return (
          bg: Colors.transparent,
          fg: AppColors.ink,
          border: AppColors.border
        );
      case AppButtonVariant.ghost:
        return (bg: Colors.transparent, fg: AppColors.ink, border: null);
      case AppButtonVariant.destructive:
        return (bg: AppColors.errorTint, fg: AppColors.error, border: null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = _colorsFor(widget.variant);

    return GestureDetector(
      onTapDown: _enabled ? (_) => setState(() => _pressed = true) : null,
      onTapUp: _enabled ? (_) => setState(() => _pressed = false) : null,
      onTapCancel: _enabled ? () => setState(() => _pressed = false) : null,
      onTap: _enabled ? widget.onTap : null,
      behavior: HitTestBehavior.opaque,
      child: AnimatedScale(
        scale: _pressed ? AppMotion.buttonPressScale : 1.0,
        duration: AppMotion.pressDuration,
        curve: AppMotion.pressCurve,
        child: AnimatedOpacity(
          opacity: _pressed ? 0.85 : 1.0,
          duration: AppMotion.pressDuration,
          curve: AppMotion.pressCurve,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: widget.fullWidth ? double.infinity : null,
            height: widget.height,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: c.bg,
              borderRadius: BorderRadius.circular(AppRadius.button),
              border: c.border != null ? Border.all(color: c.border!) : null,
            ),
            child: Row(
              mainAxisSize:
                  widget.fullWidth ? MainAxisSize.max : MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (widget.loading) ...[
                  SizedBox(
                    width: 17,
                    height: 17,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: c.fg,
                    ),
                  ),
                  const SizedBox(width: 10),
                ] else if (widget.leading != null || widget.icon != null) ...[
                  widget.leading ?? Icon(widget.icon, size: 18, color: c.fg),
                  const SizedBox(width: 8),
                ],
                Flexible(
                  child: Text(
                    widget.label,
                    style: AppTextStyles.label(color: c.fg),
                    overflow: TextOverflow.ellipsis,
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
