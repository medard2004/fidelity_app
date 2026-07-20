import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// Animation de déblocage d'une récompense : un fin trait de laiton
/// qui dessine un contour autour de la carte, une seule fois.
/// Pas de confettis, pas de paillettes.
class WaxSealUnlockOverlay extends StatefulWidget {
  final Widget child;
  final bool play;
  final VoidCallback? onCompleted;

  const WaxSealUnlockOverlay({
    super.key,
    required this.child,
    required this.play,
    this.onCompleted,
  });

  @override
  State<WaxSealUnlockOverlay> createState() => _WaxSealUnlockOverlayState();
}

class _WaxSealUnlockOverlayState extends State<WaxSealUnlockOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    if (widget.play) _controller.forward();
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) widget.onCompleted?.call();
    });
  }

  @override
  void didUpdateWidget(covariant WaxSealUnlockOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.play && !oldWidget.play) {
      _controller
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (widget.play)
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, _) {
                  return CustomPaint(
                    painter: _SealPainter(progress: _controller.value),
                  );
                },
              ),
            ),
          ),
      ],
    );
  }
}

class _SealPainter extends CustomPainter {
  final double progress;
  _SealPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      const Radius.circular(17),
    );
    final path = Path()..addRRect(rrect);
    final metrics = path.computeMetrics().first;
    final extract = metrics.extractPath(0, metrics.length * progress);

    final paint = Paint()
      ..color = AppColors.laitonBrosse
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(extract, paint);
  }

  @override
  bool shouldRepaint(covariant _SealPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
