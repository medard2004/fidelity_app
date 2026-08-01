import 'package:flutter/material.dart';
import '../../models/loyalty_card.dart';
import '../../core/utils/toast_service.dart';

class CardExportService {
  /// Simule l'exportation et le partage d'une carte.
  /// En réalité, on génèrerait une image Uint8List via RepaintBoundary puis on utiliserait `share_plus`.
  static void exportAndShareCard(BuildContext context, LoyaltyCard card, String action) {
    String message = '';
    if (action == 'save') {
      message = 'Carte "${card.restaurantName}" enregistrée dans vos favoris !';
    } else if (action == 'download') {
      message = 'Image HD de la carte ${card.fallbackId} téléchargée dans votre galerie !';
    } else if (action == 'share') {
      message = 'Visuel de la carte ${card.restaurantName} préparé pour le partage !';
    }

    if (context.mounted) {
      ToastService.showSuccess(message);
    }
  }
}
