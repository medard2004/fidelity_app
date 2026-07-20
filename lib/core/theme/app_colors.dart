import 'package:flutter/material.dart';

/// Palette "Édition Porcelaine" — 6 teintes nommées.
/// À respecter au pixel près : jamais de blanc pur, jamais de noir pur,
/// jamais de gris froid pour les ombres.
class AppColors {
  AppColors._();

  /// Fond principal — blanc cassé chaud, jamais un blanc pur.
  static const Color porcelaine = Color(0xFFF6F3EC);

  /// Texte principal — quasi-noir chaud.
  static const Color encre = Color(0xFF1B1A17);

  /// Accent primaire — CTA, statuts actifs, QR actif.
  static const Color vertBouteille = Color(0xFF223D31);

  /// Accent secondaire — métal mat, jamais brillant.
  static const Color laitonBrosse = Color(0xFF9C7A3C);

  /// Surface d'élévation — cartes secondaires, séparations douces.
  static const Color saugePale = Color(0xFFE4E1D6);

  /// Rare — statut VIP Platinum, accents d'urgence.
  static const Color bordeauxProfond = Color(0xFF5B2A2E);

  // --- Dérivés d'usage (toujours issus des 6 teintes ci-dessus) ---

  /// Liseré laiton à faible opacité pour les bordures fines (1px).
  static Color laitonLisere({double opacity = 0.55}) =>
      laitonBrosse.withOpacity(opacity);

  /// Ombre portée chaude — jamais un gris froid.
  static Color ombreChaude({double opacity = 0.14}) =>
      encre.withOpacity(opacity);

  /// Fond du desktop / device frame — porcelaine légèrement assombrie.
  static const Color porcelaineAssombrie = Color(0xFFEAE6DA);

  /// Doublures désaturées par établissement (exemples de démonstration).
  static const Color doublureComptoir = Color(0xFF2E3B33); // vert profond feutré
  static const Color doublurePalais = Color(0xFFEDEADF); // reste porcelaine/sauge
  static const Color doublureSunset = Color(0xFF1D3A2C); // vert bouteille soutenu
  static const Color doublureMacBouffe = Color(0xFF3A2C24); // brun feutré
}
