import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

/// Écran de scan QR — caméra réelle (mobile_scanner) sous un cadre laiton
/// animé, avec repli de saisie manuelle si la caméra est indisponible.
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
      backgroundColor: AppColors.porcelaine,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: AppColors.encre.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Text('Saisir le code manuellement',
                style: AppTextStyles.displayMedium()),
            const SizedBox(height: 6),
            Text(
              'Le code figure sous le QR affiché par l\'établissement.',
              style: AppTextStyles.bodyMedium(
                color: AppColors.encre.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              autofocus: true,
              textCapitalization: TextCapitalization.characters,
              style: AppTextStyles.bodyMedium(),
              decoration: InputDecoration(
                hintText: 'Ex. JARDIN-2024',
                filled: true,
                fillColor: AppColors.saugePale.withValues(alpha: 0.4),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide:
                      BorderSide(color: AppColors.laitonLisere(opacity: 0.3)),
                ),
              ),
              onSubmitted: (v) => Navigator.pop(sheetContext, v),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(sheetContext, controller.text),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.vertBouteille,
                  foregroundColor: AppColors.porcelaine,
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  elevation: 0,
                ),
                child: const Text('Valider'),
              ),
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
    // Fond quasi-noir chaud (encre).
    const bg = Color(0xFF1A1917);
    final size = MediaQuery.of(context).size;
    final frameW = size.width * 0.76;
    final frameH = frameW * 1.08;

    return Scaffold(
      backgroundColor: bg,
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
          // Voile sombre pour garder l'overlay laiton lisible sur l'image caméra.
          Positioned.fill(
            child: IgnorePointer(
              child: Container(color: Colors.black.withValues(alpha: 0.28)),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // ── AppBar ────────────────────────────────────────────────
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
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
                            child: Icon(
                              Icons.arrow_back,
                              color: AppColors.porcelaine,
                              size: 22,
                            ),
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
                      Semantics(
                        button: true,
                        label: 'Activer ou désactiver le flash',
                        child: GestureDetector(
                          onTap: () => _cameraController.toggleTorch(),
                          behavior: HitTestBehavior.opaque,
                          child: const SizedBox(
                            width: 44,
                            height: 44,
                            child: Icon(
                              Icons.flash_on_outlined,
                              color: AppColors.porcelaine,
                              size: 20,
                            ),
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
                            color: Colors.white.withValues(alpha: 0.03),
                            borderRadius: BorderRadius.circular(26),
                            border: Border.all(
                              color:
                                  AppColors.laitonBrosse.withValues(alpha: 0.7),
                              width: 1.2,
                            ),
                          ),
                        ),

                        // ── Coins d'angle laiton ──────────────────────────
                        ..._buildCorners(frameW, frameH),

                        // ── Ligne de scan animée ──────────────────────────
                        AnimatedBuilder(
                          animation: _scanAnim,
                          builder: (context, _) {
                            final top = 16.0 + (frameH - 32) * _scanAnim.value;
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
                                          color: Colors.white
                                              .withValues(alpha: 0.85),
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
                                          AppColors.laitonBrosse
                                              .withValues(alpha: 0.9),
                                          AppColors.laitonBrosse,
                                          AppColors.laitonBrosse
                                              .withValues(alpha: 0.9),
                                          Colors.transparent,
                                        ],
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColors.laitonBrosse
                                              .withValues(alpha: 0.4),
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

                // ── Texte d'instruction ───────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    'Placez le QR du restaurant dans le cadre.',
                    style: AppTextStyles.bodyMedium(
                      color: AppColors.porcelaine.withValues(alpha: 0.75),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                const SizedBox(height: 18),

                Semantics(
                  button: true,
                  label: 'Saisir le code manuellement',
                  child: TextButton(
                    onPressed: _openManualEntry,
                    style: TextButton.styleFrom(
                      minimumSize: const Size(0, 44),
                    ),
                    child: Text(
                      'Saisir le code manuellement',
                      style: AppTextStyles.label(color: AppColors.laitonBrosse)
                          .copyWith(fontWeight: FontWeight.w600),
                    ),
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

  /// Génère 4 coins d'angle laiton positionnés aux coins du cadre.
  List<Widget> _buildCorners(double w, double h) {
    const len = 22.0;
    const thick = 2.0;
    const r = 26.0;
    const color = AppColors.laitonBrosse;

    return [
      // ─ Coin haut-gauche
      const Positioned(
        left: 0,
        top: 0,
        child: _Corner(
            len: len,
            thick: thick,
            r: r,
            color: color,
            flipX: false,
            flipY: false),
      ),
      // ─ Coin haut-droit
      const Positioned(
        right: 0,
        top: 0,
        child: _Corner(
            len: len,
            thick: thick,
            r: r,
            color: color,
            flipX: true,
            flipY: false),
      ),
      // ─ Coin bas-gauche
      const Positioned(
        left: 0,
        bottom: 0,
        child: _Corner(
            len: len,
            thick: thick,
            r: r,
            color: color,
            flipX: false,
            flipY: true),
      ),
      // ─ Coin bas-droit
      const Positioned(
        right: 0,
        bottom: 0,
        child: _Corner(
            len: len,
            thick: thick,
            r: r,
            color: color,
            flipX: true,
            flipY: true),
      ),
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
      color: const Color(0xFF1A1917),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.no_photography_outlined,
                  size: 40, color: AppColors.laitonBrosse),
              const SizedBox(height: 16),
              Text(
                'Caméra indisponible',
                style: AppTextStyles.displayMedium(color: AppColors.porcelaine),
              ),
              const SizedBox(height: 8),
              Text(
                'Autorisez l\'accès à la caméra dans les réglages, ou saisissez le code manuellement.',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium(
                  color: AppColors.porcelaine.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onManualEntry,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.laitonBrosse,
                    foregroundColor: AppColors.encre,
                    minimumSize: const Size.fromHeight(48),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    elevation: 0,
                  ),
                  child: const Text('Saisir le code manuellement'),
                ),
              ),
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
