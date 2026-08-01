import 'dart:ui';
import 'package:flutter/material.dart';
import '../router/app_router.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../../widgets/shared/loading_dots.dart';

/// Voile de chargement plein écran premium, avec effet glassmorphism et animations.
class LoadingOverlayService {
  static OverlayEntry? _overlayEntry;
  static _LoadingOverlayWidgetState? _currentState;

  /// Affiche le voile. Si déjà affiché, met à jour le message.
  static void show({String? message}) {
    if (_overlayEntry != null) {
      _currentState?.updateMessage(message);
      return;
    }

    final overlay = rootNavigatorKey.currentState?.overlay;
    if (overlay == null) return;

    _overlayEntry = OverlayEntry(
      builder: (context) => _LoadingOverlayWidget(
        message: message,
        onStateCreated: (state) => _currentState = state,
      ),
    );
    overlay.insert(_overlayEntry!);
  }

  /// Masque le voile avec une animation fluide.
  static Future<void> hide() async {
    if (_overlayEntry == null) return;

    if (_currentState != null) {
      await _currentState?.hideAnimation();
    }
    
    _overlayEntry?.remove();
    _overlayEntry = null;
    _currentState = null;
  }
}

class _LoadingOverlayWidget extends StatefulWidget {
  final String? message;
  final ValueChanged<_LoadingOverlayWidgetState> onStateCreated;

  const _LoadingOverlayWidget({
    this.message,
    required this.onStateCreated,
  });

  @override
  State<_LoadingOverlayWidget> createState() => _LoadingOverlayWidgetState();
}

class _LoadingOverlayWidgetState extends State<_LoadingOverlayWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  String? _message;

  @override
  void initState() {
    super.initState();
    _message = widget.message;
    widget.onStateCreated(this);
    
    _controller = AnimationController(
      vsync: this, 
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    
    _controller.forward();
  }

  void updateMessage(String? newMessage) {
    if (mounted && _message != newMessage) {
      setState(() {
        _message = newMessage;
      });
    }
  }

  Future<void> hideAnimation() async {
    if (mounted) {
      await _controller.reverse();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Material(
          color: Colors.transparent,
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12.0, sigmaY: 12.0),
            child: Container(
              color: AppColors.porcelaine.withValues(alpha: 0.5),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(28),
                      decoration: BoxDecoration(
                        color: AppColors.saugePale.withValues(alpha: 0.85),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.encre.withValues(alpha: 0.06),
                            blurRadius: 24,
                            spreadRadius: 8,
                          ),
                        ],
                        border: Border.all(
                          color: AppColors.laitonLisere(opacity: 0.2),
                          width: 1,
                        ),
                      ),
                      child: const LoadingDots(color: AppColors.vertBouteille, dotSize: 10),
                    ),
                    if (_message != null) ...[
                      const SizedBox(height: 32),
                      Text(
                        _message!,
                        style: AppTextStyles.bodyMedium(
                          color: AppColors.encre.withValues(alpha: 0.85),
                        ).copyWith(
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
