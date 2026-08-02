import 'package:flutter/material.dart';

/// Design system "Carte" — palette neutre et technique,
/// inspirée d'Apple Wallet / Revolut / Stripe / Monzo.
/// Fonds neutres froids, un seul accent de marque, tokens sémantiques
/// explicites pour succès / avertissement / erreur.
class AppColors {
  AppColors._();

  // --- Neutres ---------------------------------------------------------

  /// Texte principal — quasi-noir froid.
  static const Color ink = Color(0xFF14151A);

  /// Texte secondaire — dérivé de [ink], jamais une nouvelle teinte.
  static Color inkMuted({double opacity = 0.6}) => ink.withValues(alpha: opacity);

  /// Fond principal de l'app — gris très clair, jamais un blanc pur.
  static const Color surface = Color(0xFFF7F7F9);

  /// Surface élevée — cartes, feuilles, modales.
  static const Color surfaceCard = Color(0xFFFFFFFF);

  /// Fill discret — inputs, chips, fonds de section.
  static const Color surfaceMuted = Color(0xFFEEEFF2);

  /// Bordure fine (hairline).
  static const Color border = Color(0xFFE4E5EA);

  // --- Accent de marque --------------------------------------------------

  /// Accent primaire — CTA, éléments actifs, liens.
  static const Color primary = Color(0xFF4F46E5);

  /// État pressé/actif de [primary].
  static const Color primaryDark = Color(0xFF4338CA);

  /// Fond teinté léger pour badges/sélections sur [primary].
  static const Color primaryTint = Color(0xFFEEF0FF);

  // --- Sémantique ---------------------------------------------------------

  static const Color success = Color(0xFF16A34A);
  static const Color successTint = Color(0xFFECFDF3);

  static const Color warning = Color(0xFFD97706);
  static const Color warningTint = Color(0xFFFFF7ED);

  static const Color error = Color(0xFFDC2626);
  static const Color errorTint = Color(0xFFFEF2F2);

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
}
