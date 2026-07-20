import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class QrScanScreen extends StatefulWidget {
  const QrScanScreen({super.key});

  @override
  State<QrScanScreen> createState() => _QrScanScreenState();
}

class _QrScanScreenState extends State<QrScanScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) context.go('/onboarding/join');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.encre,
      body: Stack(
        alignment: Alignment.center,
        children: [
          // Simulation d'un flux caméra sobre.
          Container(color: AppColors.encre),
          Container(
            width: 240,
            height: 240,
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.laitonBrosse, width: 1.4),
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          Positioned(
            bottom: 90,
            child: Text(
              'Recherche d\'un QR code…',
              style: AppTextStyles.bodyMedium(color: AppColors.porcelaine.withOpacity(0.85)),
            ),
          ),
          Positioned(
            top: 56,
            left: 20,
            child: IconButton(
              onPressed: () => context.go('/wallet'),
              icon: const Icon(Icons.close, color: AppColors.porcelaine),
            ),
          ),
        ],
      ),
    );
  }
}
