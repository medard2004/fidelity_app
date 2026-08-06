import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Élévations — ombres neutres et froides (jamais teintées),
/// discrètes, à 3 niveaux seulement.
///
/// Sensibles au mode sombre : un fond quasi noir absorbe une ombre noire
/// à faible alpha (calibrée pour un fond clair) — elle devient invisible.
/// On remonte l'alpha en sombre pour garder un vrai effet d'élévation.
class AppShadows {
  AppShadows._();

  /// Carte au repos (liste, tuile, champ).
  static List<BoxShadow> get resting => [
        BoxShadow(
          color: Colors.black.withValues(alpha: AppColors.isDark ? 0.32 : 0.05),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ];

  /// Élément surélevé (carte active, bouton flottant, en-tête sticky).
  static List<BoxShadow> get raised => [
        BoxShadow(
          color: Colors.black.withValues(alpha: AppColors.isDark ? 0.4 : 0.08),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ];

  /// Modale / feuille / élément au premier plan.
  static List<BoxShadow> get floating => [
        BoxShadow(
          color: Colors.black.withValues(alpha: AppColors.isDark ? 0.5 : 0.14),
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
  ///
  /// En sombre, le fond est déjà quasi noir : un halo aussi large et
  /// prononcé qu'en clair déborde loin au-delà de la carte et lit comme
  /// une tache colorée floue plutôt qu'une ombre — visible même derrière
  /// d'autres éléments (ex. sous une boîte de dialogue). On réduit alpha
  /// **et** taille (blur/offset) du halo, et on renforce le contact noir
  /// pour que la carte reste ancrée, pas "flottante".
  static List<BoxShadow> card(Color tint) {
    final dark = AppColors.isDark;
    return [
      // Contact — ancre la carte au sol.
      BoxShadow(
        color: Colors.black.withValues(alpha: dark ? 0.5 : 0.08),
        blurRadius: 6,
        offset: const Offset(0, 2),
      ),
      // Halo teinté médian — la profondeur colorée caractéristique.
      BoxShadow(
        color: tint.withValues(alpha: dark ? 0.12 : 0.24),
        blurRadius: dark ? 12 : 20,
        offset: Offset(0, dark ? 5 : 10),
      ),
      // Halo teinté large — diffusion douce jusque loin sous la carte.
      BoxShadow(
        color: tint.withValues(alpha: dark ? 0.06 : 0.14),
        blurRadius: dark ? 22 : 42,
        offset: Offset(0, dark ? 10 : 22),
      ),
    ];
  }
}
