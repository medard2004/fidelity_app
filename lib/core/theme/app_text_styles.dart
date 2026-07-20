import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Trois rôles typographiques stricts. Un écran n'en mélange jamais
/// plus de 3 à la fois : display / body / mono.
class AppTextStyles {
  AppTextStyles._();

  // --- Display : Bodoni Moda — serif à fort contraste, éditoriale ---

  static TextStyle displayXL({Color color = AppColors.encre}) =>
      GoogleFonts.bodoniModa(
        fontSize: 40,
        fontWeight: FontWeight.w600,
        color: color,
        height: 1.05,
        letterSpacing: -0.5,
      );

  static TextStyle displayLarge({Color color = AppColors.encre}) =>
      GoogleFonts.bodoniModa(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        color: color,
        height: 1.1,
      );

  static TextStyle displayMedium({Color color = AppColors.encre}) =>
      GoogleFonts.bodoniModa(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: color,
        height: 1.15,
      );

  /// Effet "gravure" — majuscules, tracking resserré.
  static TextStyle displayEngraved({Color color = AppColors.encre}) =>
      GoogleFonts.bodoniModa(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: color,
        letterSpacing: -0.3,
      );

  // --- Corps / UI : Public Sans — sobre, jamais expressive ---

  static TextStyle bodyLarge({Color color = AppColors.encre}) =>
      GoogleFonts.publicSans(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: color,
        height: 1.4,
      );

  static TextStyle bodyMedium({Color color = AppColors.encre}) =>
      GoogleFonts.publicSans(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: color,
        height: 1.4,
      );

  static TextStyle bodySmall({Color color = AppColors.encre}) =>
      GoogleFonts.publicSans(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: color.withOpacity(0.7),
        height: 1.3,
      );

  static TextStyle label({Color color = AppColors.encre}) =>
      GoogleFonts.publicSans(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: color,
        letterSpacing: 0.2,
      );

  // --- Chiffres / données : IBM Plex Mono — petites capitales, tracking large ---

  static TextStyle monoLarge({Color color = AppColors.encre}) =>
      GoogleFonts.ibmPlexMono(
        fontSize: 24,
        fontWeight: FontWeight.w500,
        color: color,
        letterSpacing: 1.2,
        fontFeatures: const [FontFeature.tabularFigures()],
      );

  static TextStyle monoMedium({Color color = AppColors.encre}) =>
      GoogleFonts.ibmPlexMono(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: color,
        letterSpacing: 1.4,
        fontFeatures: const [FontFeature.tabularFigures()],
      );

  static TextStyle monoSmall({Color color = AppColors.encre}) =>
      GoogleFonts.ibmPlexMono(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: color.withOpacity(0.75),
        letterSpacing: 1.6,
        fontFeatures: const [FontFeature.tabularFigures()],
      );
}
