import 'package:flutter/material.dart';
import '../../core/theme/app_motion.dart';

/// Enveloppe de retour tactile — réduit légèrement l'échelle et l'opacité
/// au toucher, remonte au relâchement. Harmonise le feedback de pression
/// des zones tactiles qui ne passent pas par [AppButton] (icônes rondes,
/// liens texte, éléments de la barre de navigation) sur la même durée et
/// la même courbe que le reste de l'app (voir [AppMotion]).
class AppTapScale extends StatefulWidget {
  final VoidCallback? onTap;
  final Widget child;
  final double scaleDown;
  final HitTestBehavior behavior;

  const AppTapScale({
    super.key,
    required this.onTap,
    required this.child,
    this.scaleDown = AppMotion.iconPressScale,
    this.behavior = HitTestBehavior.opaque,
  });

  @override
  State<AppTapScale> createState() => _AppTapScaleState();
}

class _AppTapScaleState extends State<AppTapScale> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed != value) setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onTap != null;
    return GestureDetector(
      behavior: widget.behavior,
      onTapDown: enabled ? (_) => _setPressed(true) : null,
      onTapUp: enabled ? (_) => _setPressed(false) : null,
      onTapCancel: enabled ? () => _setPressed(false) : null,
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _pressed ? widget.scaleDown : 1.0,
        duration: AppMotion.pressDuration,
        curve: AppMotion.pressCurve,
        child: AnimatedOpacity(
          opacity: _pressed ? 0.75 : 1.0,
          duration: AppMotion.pressDuration,
          curve: AppMotion.pressCurve,
          child: widget.child,
        ),
      ),
    );
  }
}
