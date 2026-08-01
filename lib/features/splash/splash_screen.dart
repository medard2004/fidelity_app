import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/shared/loading_dots.dart';

/// Écran d'attente pendant la résolution de l'état de démarrage
/// (`appStartupProvider`).
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.porcelaine,
      body: Center(child: LoadingDots(dotSize: 8)),
    );
  }
}
