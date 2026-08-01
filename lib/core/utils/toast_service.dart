import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import '../router/app_router.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

enum ToastType { success, error, warning, info }

class ToastService {
  // We keep this for compatibility if any place still uses it, but we will use Overlay.
  static final GlobalKey<ScaffoldMessengerState> messengerKey =
      GlobalKey<ScaffoldMessengerState>();

  static OverlayEntry? _overlayEntry;
  static Timer? _timer;
  static bool _isShowing = false;

  /// Hide the current toast (if any)
  static void hideCurrent() {
    if (_isShowing && _overlayEntry != null) {
      _overlayEntry?.remove();
      _overlayEntry = null;
      _isShowing = false;
    }
    _timer?.cancel();
    _timer = null;
    
    // Fallback if using standard SnackBar somewhere
    messengerKey.currentState?.hideCurrentSnackBar();
  }

  /// Show a global toast notification using Overlay
  static void show({
    required String message,
    ToastType type = ToastType.info,
    Duration duration = const Duration(seconds: 4),
  }) {
    // Make sure we have a navigator context
    final context = rootNavigatorKey.currentContext;
    if (context == null) return;

    hideCurrent();

    final Color backgroundColor;
    final IconData iconData;
    final Color iconColor;

    switch (type) {
      case ToastType.success:
        backgroundColor = AppColors.vertBouteille.withValues(alpha: 0.85);
        iconData = Icons.check_circle_outline_rounded;
        iconColor = AppColors.porcelaine;
        break;
      case ToastType.error:
        backgroundColor = AppColors.bordeauxProfond.withValues(alpha: 0.9);
        iconData = Icons.error_outline_rounded;
        iconColor = AppColors.porcelaine;
        break;
      case ToastType.warning:
        backgroundColor = AppColors.laitonBrosse.withValues(alpha: 0.9);
        iconData = Icons.warning_amber_rounded;
        iconColor = AppColors.encre;
        break;
      case ToastType.info:
      default:
        backgroundColor = AppColors.encre.withValues(alpha: 0.85);
        iconData = Icons.info_outline_rounded;
        iconColor = AppColors.porcelaine;
        break;
    }

    final textColor = (type == ToastType.warning) ? AppColors.encre : AppColors.porcelaine;
    
    _overlayEntry = OverlayEntry(
      builder: (context) => _ToastWidget(
        message: message,
        backgroundColor: backgroundColor,
        iconData: iconData,
        iconColor: iconColor,
        textColor: textColor,
        onDismiss: hideCurrent,
      ),
    );

    final overlay = rootNavigatorKey.currentState?.overlay;
    if (overlay != null) {
      overlay.insert(_overlayEntry!);
      _isShowing = true;
      _timer = Timer(duration, hideCurrent);
    }
  }

  /// Helper for Success
  static void showSuccess(String message, {Duration duration = const Duration(seconds: 3)}) {
    show(message: message, type: ToastType.success, duration: duration);
  }

  /// Helper for Error
  static void showError(String message, {Duration duration = const Duration(seconds: 4)}) {
    show(message: message, type: ToastType.error, duration: duration);
  }

  /// Helper for Warning
  static void showWarning(String message, {Duration duration = const Duration(seconds: 3)}) {
    show(message: message, type: ToastType.warning, duration: duration);
  }

  /// Helper for Info
  static void showInfo(String message, {Duration duration = const Duration(seconds: 3)}) {
    show(message: message, type: ToastType.info, duration: duration);
  }
}

class _ToastWidget extends StatefulWidget {
  final String message;
  final Color backgroundColor;
  final IconData iconData;
  final Color iconColor;
  final Color textColor;
  final VoidCallback onDismiss;

  const _ToastWidget({
    required this.message,
    required this.backgroundColor,
    required this.iconData,
    required this.iconColor,
    required this.textColor,
    required this.onDismiss,
  });

  @override
  State<_ToastWidget> createState() => _ToastWidgetState();
}

class _ToastWidgetState extends State<_ToastWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0, -1.5),
      end: const Offset(0, 0),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    ));

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeIn,
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final statusBarHeight = MediaQuery.of(context).padding.top;
    
    return Positioned(
      top: statusBarHeight + 16,
      left: 16,
      right: 16,
      child: SafeArea(
        child: Material(
          color: Colors.transparent,
          child: SlideTransition(
            position: _offsetAnimation,
            child: FadeTransition(
              opacity: _opacityAnimation,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: widget.backgroundColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.15),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: widget.iconColor.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(widget.iconData, color: widget.iconColor, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Text(
                              widget.message,
                              style: AppTextStyles.bodyMedium(color: widget.textColor).copyWith(
                                height: 1.3,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: widget.onDismiss,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Icon(
                              Icons.close_rounded,
                              color: widget.iconColor.withValues(alpha: 0.6),
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
