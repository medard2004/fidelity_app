import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../models/loyalty_card.dart';
import '../../core/theme/app_colors.dart';

class CardExportService {
  /// Capture le visuel de la carte (via [boundaryKey], qui doit pointer vers
  /// un [RepaintBoundary] entourant le widget visible de la carte), l'écrit
  /// dans un fichier temporaire, puis ouvre la feuille de partage native
  /// pour l'enregistrer ou l'envoyer.
  static Future<void> exportAndShareCard(
    BuildContext context,
    LoyaltyCard card,
    String action,
    GlobalKey boundaryKey,
  ) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (c) => const Center(
        child: CircularProgressIndicator(color: AppColors.laitonBrosse),
      ),
    );

    Uint8List? bytes;
    try {
      final boundary = boundaryKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      if (boundary == null) {
        throw StateError('Visuel de la carte introuvable.');
      }
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) {
        throw StateError('Impossible de générer l\'image de la carte.');
      }
      bytes = byteData.buffer.asUint8List();
    } catch (_) {
      // bytes reste null ; géré plus bas.
    }

    if (context.mounted) Navigator.pop(context); // Ferme le loader

    if (bytes == null) {
      if (context.mounted) {
        _showSnack(context, 'Échec de l\'export : réessayez.', isError: true);
      }
      return;
    }

    try {
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/carte_${card.fallbackId}.png');
      await file.writeAsBytes(bytes);

      final result = await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path)],
          subject: 'Ma carte ${card.restaurantName} — Carte',
          text: action == 'share'
              ? 'Découvre ${card.restaurantName} sur Carte !'
              : null,
        ),
      );

      if (!context.mounted) return;

      if (result.status == ShareResultStatus.success) {
        final message = switch (action) {
          'download' =>
            'Image HD de la carte ${card.fallbackId} prête — choisissez "Enregistrer l\'image".',
          'share' => 'Visuel de la carte ${card.restaurantName} partagé.',
          _ => 'Carte "${card.restaurantName}" prête à être enregistrée.',
        };
        _showSnack(context, message);
      }
      // Feuille de partage annulée par l'utilisateur : pas de message, comportement natif standard.
    } catch (_) {
      if (context.mounted) {
        _showSnack(context, 'Échec de l\'export : une erreur est survenue.',
            isError: true);
      }
    }
  }

  static void _showSnack(BuildContext context, String message,
      {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: isError ? AppColors.bordeauxProfond : AppColors.encre,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
