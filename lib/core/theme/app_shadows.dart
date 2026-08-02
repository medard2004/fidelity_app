import 'package:flutter/material.dart';

/// Élévations — ombres neutres et froides (jamais teintées),
/// discrètes, à 3 niveaux seulement.
class AppShadows {
  AppShadows._();

  /// Carte au repos (liste, tuile, champ).
  static List<BoxShadow> resting = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.05),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];

  /// Élément surélevé (carte active, bouton flottant, en-tête sticky).
  static List<BoxShadow> raised = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.08),
      blurRadius: 20,
      offset: const Offset(0, 8),
    ),
  ];

  /// Modale / feuille / élément au premier plan.
  static List<BoxShadow> floating = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.14),
      blurRadius: 32,
      offset: const Offset(0, 16),
    ),
  ];
}
