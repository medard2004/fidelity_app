import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

/// Écran de scan QR — fond encre profonde, cadre laiton, ligne de scan animée.
class QrScanScreen extends StatefulWidget {
  const QrScanScreen({super.key});

  @override
  State<QrScanScreen> createState() => _QrScanScreenState();
}

class _QrScanScreenState extends State<QrScanScreen>
    with TickerProviderStateMixin {
  late final AnimationController _scanController;
  late final AnimationController _pulseController;
  late final Animation<double> _scanAnim;
  late final Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();

    // Ligne de scan : monte et descend doucement en boucle.
    _scanController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);

    _scanAnim = CurvedAnimation(
      parent: _scanController,
      curve: Curves.easeInOut,
    );

    // Pulsation subtile du cadre : scale 1.0 → 1.015 en boucle.
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _pulseAnim = Tween<double>(begin: 1.0, end: 1.015).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Auto-navigation après 3 s (simule la détection du QR).
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) context.go('/onboarding/join');
    });
  }

  @override
  void dispose() {
    _scanController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Fond quasi-noir chaud (encre).
    const bg = Color(0xFF1A1917);
    final size = MediaQuery.of(context).size;
    final frameW = size.width * 0.76;
    final frameH = frameW * 1.08;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          children: [
            // ── AppBar ────────────────────────────────────────────────────
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => context.go('/wallet'),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      child: const Icon(
                        Icons.arrow_back,
                        color: AppColors.porcelaine,
                        size: 22,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        'SCANNER UN QR',
                        style: AppTextStyles.monoSmall(
                          color: AppColors.laitonBrosse,
                        ).copyWith(letterSpacing: 3.0),
                      ),
                    ),
                  ),
                  const SizedBox(width: 38), // équilibre la flèche
                ],
              ),
            ),

            const Spacer(flex: 2),

            // ── Cadre QR animé ────────────────────────────────────────────
            AnimatedBuilder(
              animation: _pulseAnim,
              builder: (context, child) {
                return Transform.scale(
                  scale: _pulseAnim.value,
                  child: child,
                );
              },
              child: SizedBox(
                width: frameW,
                height: frameH,
                child: Stack(
                  children: [
                    // Fond légèrement éclairé du cadre.
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.03),
                        borderRadius: BorderRadius.circular(26),
                        border: Border.all(
                          color: AppColors.laitonBrosse.withOpacity(0.7),
                          width: 1.2,
                        ),
                      ),
                    ),

                    // ── Coins d'angle laiton ──────────────────────────────
                    ..._buildCorners(frameW, frameH),

                    // ── Ligne de scan animée ──────────────────────────────
                    AnimatedBuilder(
                      animation: _scanAnim,
                      builder: (context, _) {
                        final top = 16.0 +
                            (frameH - 32) * _scanAnim.value;
                        return Positioned(
                          left: 20,
                          right: 20,
                          top: top,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Petit réticule central blanc.
                              Center(
                                child: Container(
                                  width: 18,
                                  height: 18,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.85),
                                      width: 1.2,
                                    ),
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 1),
                              // Ligne laiton avec halo.
                              Container(
                                height: 1.4,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.transparent,
                                      AppColors.laitonBrosse.withOpacity(0.9),
                                      AppColors.laitonBrosse,
                                      AppColors.laitonBrosse.withOpacity(0.9),
                                      Colors.transparent,
                                    ],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.laitonBrosse
                                          .withOpacity(0.4),
                                      blurRadius: 8,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 36),

            // ── Texte d'instruction ───────────────────────────────────────
            Text(
              'Placez le QR du restaurant dans le cadre.',
              style: AppTextStyles.bodyMedium(
                color: AppColors.porcelaine.withOpacity(0.75),
              ),
              textAlign: TextAlign.center,
            ),

            const Spacer(flex: 3),
          ],
        ),
      ),
    );
  }

  /// Génère 4 coins d'angle laiton positionnés aux coins du cadre.
  List<Widget> _buildCorners(double w, double h) {
    const len = 22.0;
    const thick = 2.0;
    const r = 26.0;
    const color = AppColors.laitonBrosse;

    return [
      // ─ Coin haut-gauche
      Positioned(
        left: 0, top: 0,
        child: _Corner(len: len, thick: thick, r: r, color: color,
            flipX: false, flipY: false),
      ),
      // ─ Coin haut-droit
      Positioned(
        right: 0, top: 0,
        child: _Corner(len: len, thick: thick, r: r, color: color,
            flipX: true, flipY: false),
      ),
      // ─ Coin bas-gauche
      Positioned(
        left: 0, bottom: 0,
        child: _Corner(len: len, thick: thick, r: r, color: color,
            flipX: false, flipY: true),
      ),
      // ─ Coin bas-droit
      Positioned(
        right: 0, bottom: 0,
        child: _Corner(len: len, thick: thick, r: r, color: color,
            flipX: true, flipY: true),
      ),
    ];
  }
}

/// Coin d'angle tracé via CustomPaint.
class _Corner extends StatelessWidget {
  final double len;
  final double thick;
  final double r;
  final Color color;
  final bool flipX;
  final bool flipY;

  const _Corner({
    required this.len,
    required this.thick,
    required this.r,
    required this.color,
    required this.flipX,
    required this.flipY,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scaleX: flipX ? -1 : 1,
      scaleY: flipY ? -1 : 1,
      child: SizedBox(
        width: len + r,
        height: len + r,
        child: CustomPaint(
          painter: _CornerPainter(
              len: len, thick: thick, r: r, color: color),
        ),
      ),
    );
  }
}

class _CornerPainter extends CustomPainter {
  final double len, thick, r;
  final Color color;

  const _CornerPainter(
      {required this.len,
      required this.thick,
      required this.r,
      required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = thick
      ..strokeCap = StrokeCap.round;

    final path = Path()
      ..moveTo(0, len)
      ..lineTo(0, r)
      ..arcToPoint(Offset(r, 0),
          radius: Radius.circular(r), clockwise: true)
      ..lineTo(len + r, 0);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_CornerPainter old) => false;
}
