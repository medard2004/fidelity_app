import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

/// Un overlay de chargement élégant et cohérent avec le design "Édition Porcelaine".
///
/// Usage simple :
/// ```dart
/// LoadingOverlay.show(context, message: 'Connexion en cours…');
/// // ... await une opération ...
/// LoadingOverlay.hide();
/// ```
class LoadingOverlay {
  static OverlayEntry? _entry;
  static bool _isShowing = false;

  /// Vrai tant que l'overlay est affiché — utile pour désactiver un bouton
  /// pendant qu'une opération (ex. Google/Apple Sign-In) est en cours.
  static bool get isShowing => _isShowing;

  /// Affiche l'overlay de chargement.
  static void show(BuildContext context, {String message = 'Chargement…'}) {
    // Éviter les doublons
    if (_isShowing) hide();

    _entry = OverlayEntry(
      builder: (_) => _LoadingOverlayWidget(message: message),
    );

    Overlay.of(context, rootOverlay: true).insert(_entry!);
    _isShowing = true;
  }

  /// Masque l'overlay de chargement.
  static void hide() {
    _entry?.remove();
    _entry = null;
    _isShowing = false;
  }

  /// Exécute [action] sous l'overlay, avec deux garanties :
  ///   - l'overlay disparaît toujours à la fin, même si [action] lève une
  ///     exception (aucun "chargement" ne peut rester bloqué à l'écran) ;
  ///   - l'overlay reste visible au moins [minVisibleDuration], pour éviter
  ///     un flash désagréable quand la réponse arrive très vite.
  ///
  /// Ne gère pas la ré-entrance : c'est à l'appelant de désactiver son bouton
  /// pendant l'opération (voir `FormErrorHandler.runLoading`), car un simple
  /// flag statique ici ne donnerait aucun retour visuel sur le bouton tapé.
  static Future<T> run<T>(
    BuildContext context,
    Future<T> Function() action, {
    String message = 'Chargement…',
    Duration minVisibleDuration = const Duration(milliseconds: 450),
  }) async {
    final stopwatch = Stopwatch()..start();
    show(context, message: message);
    try {
      return await action();
    } finally {
      final remaining = minVisibleDuration - stopwatch.elapsed;
      if (remaining > Duration.zero) {
        await Future.delayed(remaining);
      }
      hide();
    }
  }
}

class _LoadingOverlayWidget extends StatefulWidget {
  final String message;
  const _LoadingOverlayWidget({required this.message});

  @override
  State<_LoadingOverlayWidget> createState() => _LoadingOverlayWidgetState();
}

class _LoadingOverlayWidgetState extends State<_LoadingOverlayWidget>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _pulseController;
  late AnimationController _spinController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    // Fade-in du fond
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );

    // Pulsation douce de la pastille centrale
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );
    _pulseAnimation = Tween<double>(begin: 0.92, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _pulseController.repeat(reverse: true);

    // Rotation de l'arc
    _spinController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _spinController.repeat();

    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _pulseController.dispose();
    _spinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // AbsorbPointer est indispensable : un Container/Material peint mais sans
    // détecteur de gestes ne bloque PAS le hit-test Flutter — sans lui, un tap
    // pendant le chargement traverse jusqu'au bouton en dessous et relance
    // l'action (ex. une seconde connexion Google en parallèle pendant la
    // latence du picker natif).
    return AbsorbPointer(
      absorbing: true,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Material(
          color: Colors.transparent,
          child: Container(
            color: AppColors.porcelaine.withValues(alpha: 0.88),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ── Spinner élégant ──────────────────────────────────────
                  ScaleTransition(
                    scale: _pulseAnimation,
                    child: SizedBox(
                      width: 64,
                      height: 64,
                      child: AnimatedBuilder(
                        animation: _spinController,
                        builder: (context, child) {
                          return CustomPaint(
                            painter: _ArcPainter(
                              progress: _spinController.value,
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // ── Message ─────────────────────────────────────────────
                  Text(
                    widget.message,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodyMedium(
                      color: AppColors.encre.withValues(alpha: 0.7),
                    ).copyWith(fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Peint un arc laiton rotatif — simple, premium, pas de dépendance.
class _ArcPainter extends CustomPainter {
  final double progress;
  _ArcPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 3;

    // Cercle guide léger
    final guidePaint = Paint()
      ..color = AppColors.saugePale
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, guidePaint);

    // Arc principal laiton
    final arcPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..shader = SweepGradient(
        startAngle: 0,
        endAngle: pi * 2,
        colors: [
          AppColors.laitonBrosse.withValues(alpha: 0.0),
          AppColors.laitonBrosse.withValues(alpha: 0.9),
          AppColors.vertBouteille.withValues(alpha: 0.6),
        ],
        stops: const [0.0, 0.6, 1.0],
        transform: GradientRotation(progress * pi * 2),
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    const sweepAngle = pi * 1.2;
    final startAngle = progress * pi * 2;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      arcPaint,
    );

    // Point lumineux à l'extrémité de l'arc
    final dotAngle = startAngle + sweepAngle;
    final dotCenter = Offset(
      center.dx + radius * cos(dotAngle),
      center.dy + radius * sin(dotAngle),
    );
    final dotPaint = Paint()
      ..color = AppColors.laitonBrosse
      ..style = PaintingStyle.fill;
    canvas.drawCircle(dotCenter, 3.5, dotPaint);
  }

  @override
  bool shouldRepaint(_ArcPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
