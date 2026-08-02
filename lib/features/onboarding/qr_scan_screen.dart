import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../widgets/components/components.dart';

/// Écran de scan QR — caméra réelle (mobile_scanner) sous un cadre net et
/// neutre, avec repli de saisie manuelle si la caméra est indisponible.
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
  late final MobileScannerController _cameraController;

  bool _handled = false;

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

    _cameraController = MobileScannerController(
      detectionSpeed: DetectionSpeed.noDuplicates,
    );
  }

  @override
  void dispose() {
    _scanController.dispose();
    _pulseController.dispose();
    _cameraController.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_handled || capture.barcodes.isEmpty) return;
    final value = capture.barcodes.first.rawValue;
    if (value == null || value.trim().isEmpty) return;
    _handled = true;
    HapticFeedback.mediumImpact();
    _cameraController.stop();
    context.go('/onboarding/join', extra: {'code': value});
  }

  Future<void> _openManualEntry() async {
    final controller = TextEditingController();
    final code = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 8,
          bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Saisir le code manuellement', style: AppTextStyles.displayMedium()),
            const SizedBox(height: 6),
            Text(
              'Le code figure sous le QR affiché par l\'établissement.',
              style: AppTextStyles.bodyMedium(color: AppColors.inkMuted(opacity: 0.6)),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              autofocus: true,
              textCapitalization: TextCapitalization.characters,
              decoration: const InputDecoration(hintText: 'Ex. JARDIN-2024'),
              onSubmitted: (v) => Navigator.pop(sheetContext, v),
            ),
            const SizedBox(height: 16),
            AppButton(
              label: 'Valider',
              onTap: () => Navigator.pop(sheetContext, controller.text),
            ),
          ],
        ),
      ),
    );

    if (code != null && code.trim().isNotEmpty && mounted) {
      _handled = true;
      context.go('/onboarding/join', extra: {'code': code});
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final frameW = size.width * 0.76;
    final frameH = frameW;

    return Scaffold(
      backgroundColor: AppColors.ink,
      body: Stack(
        children: [
          // ── Flux caméra réel ────────────────────────────────────────────
          Positioned.fill(
            child: MobileScanner(
              controller: _cameraController,
              onDetect: _onDetect,
              errorBuilder: (context, error) =>
                  _CameraUnavailable(onManualEntry: _openManualEntry),
            ),
          ),
          // Voile sombre pour garder l'overlay lisible sur l'image caméra.
          Positioned.fill(
            child: IgnorePointer(
              child: Container(color: Colors.black.withValues(alpha: 0.32)),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  child: Row(
                    children: [
                      Semantics(
                        button: true,
                        label: 'Retour',
                        child: GestureDetector(
                          onTap: () => context.go('/wallet'),
                          behavior: HitTestBehavior.opaque,
                          child: const SizedBox(
                            width: 44,
                            height: 44,
                            child: Icon(Icons.arrow_back_rounded, color: Colors.white, size: 22),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Center(
                          child: Text(
                            'SCANNER UN QR',
                            style: AppTextStyles.eyebrow(color: Colors.white.withValues(alpha: 0.85)),
                          ),
                        ),
                      ),
                      Semantics(
                        button: true,
                        label: 'Activer ou désactiver le flash',
                        child: GestureDetector(
                          onTap: () => _cameraController.toggleTorch(),
                          behavior: HitTestBehavior.opaque,
                          child: const SizedBox(
                            width: 44,
                            height: 44,
                            child: Icon(Icons.flash_on_outlined, color: Colors.white, size: 20),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(flex: 2),

                // ── Cadre QR animé ────────────────────────────────────────
                AnimatedBuilder(
                  animation: _pulseAnim,
                  builder: (context, child) {
                    return Transform.scale(scale: _pulseAnim.value, child: child);
                  },
                  child: SizedBox(
                    width: frameW,
                    height: frameH,
                    child: Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.04),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.5), width: 1.2),
                          ),
                        ),

                        ..._buildCorners(frameW, frameH),

                        AnimatedBuilder(
                          animation: _scanAnim,
                          builder: (context, _) {
                            final top = 16.0 + (frameH - 32) * _scanAnim.value;
                            return Positioned(
                              left: 20,
                              right: 20,
                              top: top,
                              child: Container(
                                height: 2,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.transparent,
                                      AppColors.primary.withValues(alpha: 0.9),
                                      AppColors.primary,
                                      AppColors.primary.withValues(alpha: 0.9),
                                      Colors.transparent,
                                    ],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.primary.withValues(alpha: 0.5),
                                      blurRadius: 8,
                                      spreadRadius: 1,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 36),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    'Placez le QR du restaurant dans le cadre.',
                    style: AppTextStyles.bodyMedium(color: Colors.white.withValues(alpha: 0.8)),
                    textAlign: TextAlign.center,
                  ),
                ),

                const SizedBox(height: 18),

                Semantics(
                  button: true,
                  label: 'Saisir le code manuellement',
                  child: TextButton(
                    onPressed: _openManualEntry,
                    style: TextButton.styleFrom(minimumSize: const Size(0, 44)),
                    child: Text('Saisir le code manuellement', style: AppTextStyles.label(color: Colors.white)),
                  ),
                ),

                const Spacer(flex: 3),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Génère 4 coins d'angle positionnés aux coins du cadre.
  List<Widget> _buildCorners(double w, double h) {
    const len = 22.0;
    const thick = 2.5;
    const r = 24.0;
    const color = Colors.white;

    return [
      const Positioned(left: 0, top: 0, child: _Corner(len: len, thick: thick, r: r, color: color, flipX: false, flipY: false)),
      const Positioned(right: 0, top: 0, child: _Corner(len: len, thick: thick, r: r, color: color, flipX: true, flipY: false)),
      const Positioned(left: 0, bottom: 0, child: _Corner(len: len, thick: thick, r: r, color: color, flipX: false, flipY: true)),
      const Positioned(right: 0, bottom: 0, child: _Corner(len: len, thick: thick, r: r, color: color, flipX: true, flipY: true)),
    ];
  }
}

/// Repli affiché quand la caméra est inaccessible (permission refusée,
/// matériel absent, plateforme non supportée).
class _CameraUnavailable extends StatelessWidget {
  final VoidCallback onManualEntry;
  const _CameraUnavailable({required this.onManualEntry});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.ink,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.no_photography_outlined, size: 40, color: Colors.white70),
              const SizedBox(height: 16),
              Text('Caméra indisponible', style: AppTextStyles.displayMedium(color: Colors.white)),
              const SizedBox(height: 8),
              Text(
                'Autorisez l\'accès à la caméra dans les réglages, ou saisissez le code manuellement.',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium(color: Colors.white.withValues(alpha: 0.7)),
              ),
              const SizedBox(height: 20),
              AppButton(label: 'Saisir le code manuellement', onTap: onManualEntry),
            ],
          ),
        ),
      ),
    );
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
          painter: _CornerPainter(len: len, thick: thick, r: r, color: color),
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
      ..arcToPoint(Offset(r, 0), radius: Radius.circular(r), clockwise: true)
      ..lineTo(len + r, 0);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_CornerPainter old) => false;
}
