import 'package:flutter/material.dart';

/// Design system "Carte" — palette neutre et technique,
/// inspirée d'Apple Wallet / Revolut / Stripe / Monzo.
/// Fonds neutres froids, un seul accent de marque, tokens sémantiques
/// explicites pour succès / avertissement / erreur.
///
/// Les tokens neutres (texte, fonds, bordures) sont sensibles au mode
/// sombre via [setBrightness] — appelé une fois par [CarteApp] à chaque
/// changement de thème, avant reconstruction de l'arbre. Ça évite de
/// propager `Theme.of(context)` dans les dizaines de fichiers qui
/// référencent `AppColors.xxx` directement. L'accent de marque et les
/// couleurs sémantiques restent identiques dans les deux modes — assez
/// saturées pour rester lisibles sur fond clair comme sombre.
class AppColors {
  AppColors._();

  static Brightness _brightness = Brightness.light;

  static void setBrightness(Brightness brightness) => _brightness = brightness;

  static bool get isDark => _brightness == Brightness.dark;

  // --- Neutres ---------------------------------------------------------

  static const Color _inkLight = Color(0xFF14151A);
  static const Color _inkDark = Color(0xFFF2F2F5);

  /// Texte principal — quasi-noir froid en clair, quasi-blanc en sombre.
  static Color get ink => isDark ? _inkDark : _inkLight;

  /// Texte secondaire — dérivé de [ink], jamais une nouvelle teinte.
  static Color inkMuted({double opacity = 0.6}) =>
      ink.withValues(alpha: opacity);

  static const Color _surfaceLight = Color(0xFFF7F7F9);
  static const Color _surfaceDark = Color(0xFF0E0F12);

  /// Fond principal de l'app — gris très clair en clair, quasi-noir en
  /// sombre ; jamais un blanc/noir pur.
  static Color get surface => isDark ? _surfaceDark : _surfaceLight;

  static const Color _surfaceCardLight = Color(0xFFFFFFFF);
  static const Color _surfaceCardDark = Color(0xFF1B1C21);

  /// Surface élevée — cartes, feuilles, modales.
  static Color get surfaceCard => isDark ? _surfaceCardDark : _surfaceCardLight;

  static const Color _surfaceMutedLight = Color(0xFFEEEFF2);
  static const Color _surfaceMutedDark = Color(0xFF25262C);

  /// Fill discret — inputs, chips, fonds de section.
  static Color get surfaceMuted =>
      isDark ? _surfaceMutedDark : _surfaceMutedLight;

  static const Color _borderLight = Color(0xFFE4E5EA);
  static const Color _borderDark = Color(0xFF34353C);

  /// Bordure fine (hairline).
  static Color get border => isDark ? _borderDark : _borderLight;

  // --- Accent de marque --------------------------------------------------

  /// Accent primaire — CTA, éléments actifs, liens.
  static const Color primary = Color(0xFF4F46E5);

  /// État pressé/actif de [primary].
  static const Color primaryDark = Color(0xFF4338CA);

  /// Fond teinté léger pour badges/sélections sur [primary] — pastel en
  /// clair, remplacé par un fond assombri de même teinte en sombre (un
  /// pastel clair resterait un pavé blanc criard sur fond sombre).
  static const Color _primaryTintLight = Color(0xFFEEF0FF);
  static const Color _primaryTintDark = Color(0xFF23244A);
  static Color get primaryTint => isDark ? _primaryTintDark : _primaryTintLight;

  // --- Sémantique ---------------------------------------------------------

  static const Color success = Color(0xFF16A34A);
  static const Color _successTintLight = Color(0xFFECFDF3);
  static const Color _successTintDark = Color(0xFF15291F);
  static Color get successTint => isDark ? _successTintDark : _successTintLight;

  static const Color warning = Color(0xFFD97706);
  static const Color _warningTintLight = Color(0xFFFFF7ED);
  static const Color _warningTintDark = Color(0xFF2E2313);
  static Color get warningTint => isDark ? _warningTintDark : _warningTintLight;

  static const Color error = Color(0xFFDC2626);
  static const Color _errorTintLight = Color(0xFFFEF2F2);
  static const Color _errorTintDark = Color(0xFF2E1A1A);
  static Color get errorTint => isDark ? _errorTintDark : _errorTintLight;

  // --- Doublures des cartes de fidélité (identité par établissement) ------

  static const Color liningCharcoal = Color(0xFF1C1D22);
  static const Color liningIndigo = Color(0xFF3730A3);
  static const Color liningEmerald = Color(0xFF0F766E);
  static const Color liningTerracotta = Color(0xFFB45309);
  static const Color liningPlum = Color(0xFF6D28D9);
  static const Color liningNavy = Color(0xFF1E3A5F);

  /// Traitement VIP — graphite sobre, jamais un métallique criard.
  static const Color liningVip = Color(0xFF23252B);

  /// Fond du device frame desktop (au-delà de 620px de large).
  static const Color surfaceDesktopFrame = Color(0xFFE7E8ED);

  /// Dégradé premium dérivé d'une couleur de doublure — même teinte
  /// d'identité par établissement, enrichie en lumière (haut-gauche) et
  /// en profondeur (bas-droite) plutôt qu'un aplat. 5 points avec des
  /// écarts de luminosité modérés entre chacun (au lieu de 2 paliers
  /// francs) pour une transition très progressive, sans bande visible.
  /// Un seul calcul, réutilisé par toutes les cartes de fidélité et
  /// leurs aperçus.
  static LinearGradient cardGradient(Color base) {
    final hsl = HSLColor.fromColor(base);
    Color at(double deltaLightness, double deltaSaturation) => hsl
        .withLightness((hsl.lightness + deltaLightness).clamp(0.0, 1.0))
        .withSaturation((hsl.saturation + deltaSaturation).clamp(0.0, 1.0))
        .toColor();

    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        at(0.14, 0.05),
        at(0.06, 0.02),
        base,
        at(-0.06, 0.0),
        at(-0.12, -0.02),
      ],
      stops: const [0.0, 0.25, 0.5, 0.75, 1.0],
    );
  }
}
