import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Échelle typographique — Cormorant (serif éditorial) pour les
/// titres, Inter pour le reste de l'UI, plus IBM Plex Mono en accent
/// ponctuel pour les données chiffrées (soldes, identifiants de carte,
/// code OTP).
class AppTextStyles {
  AppTextStyles._();

  // --- Display / titres — Cormorant, serif éditorial ---

  static TextStyle displayXL({Color color = AppColors.ink}) =>
      GoogleFonts.cormorant(
        fontSize: 34,
        fontWeight: FontWeight.w700,
        color: color,
        height: 1.15,
        letterSpacing: -0.2,
      );

  static TextStyle displayLarge({Color color = AppColors.ink}) =>
      GoogleFonts.cormorant(
        fontSize: 26,
        fontWeight: FontWeight.w700,
        color: color,
        height: 1.2,
        letterSpacing: -0.1,
      );

  static TextStyle displayMedium({Color color = AppColors.ink}) =>
      GoogleFonts.cormorant(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: color,
        height: 1.25,
      );

  static TextStyle titleMedium({Color color = AppColors.ink}) =>
      GoogleFonts.cormorant(
        fontSize: 17,
        fontWeight: FontWeight.w600,
        color: color,
        height: 1.3,
      );

  // --- Corps / UI — Inter, poids réguliers ---

  static TextStyle bodyLarge({Color color = AppColors.ink}) =>
      GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: color,
        height: 1.45,
      );

  static TextStyle bodyMedium({Color color = AppColors.ink}) =>
      GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: color,
        height: 1.45,
      );

  static TextStyle bodySmall({Color color = AppColors.ink}) =>
      GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: color.withValues(alpha: 0.68),
        height: 1.35,
      );

  static TextStyle label({Color color = AppColors.ink}) => GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: color,
        letterSpacing: 0.1,
      );

  /// Label mono majuscule — éléments de section, statuts, timers.
  static TextStyle eyebrow({Color color = AppColors.ink}) => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: color,
        letterSpacing: 0.8,
      );

  // --- Chiffres / données — IBM Plex Mono, tracking modéré ---

  static TextStyle monoLarge({Color color = AppColors.ink}) =>
      GoogleFonts.ibmPlexMono(
        fontSize: 26,
        fontWeight: FontWeight.w600,
        color: color,
        letterSpacing: 0.4,
        fontFeatures: const [FontFeature.tabularFigures()],
      );

  static TextStyle monoMedium({Color color = AppColors.ink}) =>
      GoogleFonts.ibmPlexMono(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: color,
        letterSpacing: 0.6,
        fontFeatures: const [FontFeature.tabularFigures()],
      );

  static TextStyle monoSmall({Color color = AppColors.ink}) =>
      GoogleFonts.ibmPlexMono(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: color.withValues(alpha: 0.75),
        letterSpacing: 0.8,
        fontFeatures: const [FontFeature.tabularFigures()],
      );
}
