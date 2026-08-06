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

  /// Ombre teintée et douce pour les surfaces à identité colorée (cartes
  /// de fidélité) — seule exception au principe "jamais teintées"
  /// ci-dessus : sous un dégradé saturé, une ombre neutre reste plate,
  /// alors qu'un souffle de la couleur de la carte crée une vraie
  /// sensation de lumière/profondeur. Trois niveaux superposés plutôt que
  /// deux, du plus serré au plus diffus, pour un effet flottant soigné
  /// plutôt qu'une simple ombre portée.
  static List<BoxShadow> card(Color tint) => [
        // Contact — ancre la carte au sol, très discret.
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.08),
          blurRadius: 6,
          offset: const Offset(0, 2),
        ),
        // Halo teinté médian — la profondeur colorée caractéristique.
        BoxShadow(
          color: tint.withValues(alpha: 0.24),
          blurRadius: 20,
          offset: const Offset(0, 10),
        ),
        // Halo teinté large — diffusion douce jusque loin sous la carte.
        BoxShadow(
          color: tint.withValues(alpha: 0.14),
          blurRadius: 42,
          offset: const Offset(0, 22),
        ),
      ];
}
