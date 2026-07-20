import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';
import 'app_radius.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get light {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.porcelaine,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.vertBouteille,
        brightness: Brightness.light,
        primary: AppColors.vertBouteille,
        secondary: AppColors.laitonBrosse,
        surface: AppColors.porcelaine,
        error: AppColors.bordeauxProfond,
      ),
    );

    return base.copyWith(
      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.transparent,
      dividerColor: AppColors.saugePale,
      textTheme: base.textTheme.copyWith(
        headlineLarge: AppTextStyles.displayXL(),
        headlineMedium: AppTextStyles.displayLarge(),
        headlineSmall: AppTextStyles.displayMedium(),
        bodyLarge: AppTextStyles.bodyLarge(),
        bodyMedium: AppTextStyles.bodyMedium(),
        bodySmall: AppTextStyles.bodySmall(),
        labelLarge: AppTextStyles.label(),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.porcelaine,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: const IconThemeData(color: AppColors.encre),
        titleTextStyle: AppTextStyles.displayMedium(),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.saugePale.withOpacity(0.5),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.input),
          borderSide: BorderSide(color: AppColors.laitonLisere(opacity: 0.25)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.input),
          borderSide: BorderSide(color: AppColors.laitonLisere(opacity: 0.25)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.input),
          borderSide: BorderSide(color: AppColors.laitonLisere(opacity: 1)),
        ),
        hintStyle: AppTextStyles.bodyMedium(color: AppColors.encre.withOpacity(0.4)),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }
}
