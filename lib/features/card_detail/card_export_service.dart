import 'package:flutter/material.dart';
import '../../models/loyalty_card.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/toast_service.dart';

class CardExportService {
  /// Simule l'exportation et le partage d'une carte.
  /// En réalité, on génèrerait une image Uint8List via RepaintBoundary puis on utiliserait `share_plus`.
  static Future<void> exportAndShareCard(BuildContext context, LoyaltyCard card, String action) async {
    // Montre un loader
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (c) => const Center(
        child: CircularProgressIndicator(color: AppColors.laitonBrosse),
      ),
    );

    // Simulation de la génération d'image HD
    await Future.delayed(const Duration(milliseconds: 800));
    
    // ignore: use_build_context_synchronously
    if (context.mounted) {
      Navigator.pop(context); // Fermer le loader
    }

    String message = '';
    if (action == 'save') {
      message = 'Carte "${card.restaurantName}" enregistrée dans vos favoris !';
    } else if (action == 'download') {
      message = 'Image HD de la carte ${card.fallbackId} téléchargée dans votre galerie !';
    } else if (action == 'share') {
      message = 'Visuel de la carte ${card.restaurantName} préparé pour le partage !';
    }

    // ignore: use_build_context_synchronously
    if (context.mounted) {
      ToastService.showSuccess(message);
    }
  }
}
