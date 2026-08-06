import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart' show CupertinoPageTransitionsBuilder;
import 'app_colors.dart';
import 'app_text_styles.dart';
import 'app_radius.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get light => _build(Brightness.light);
  static ThemeData get dark => _build(Brightness.dark);

  /// Construit le thème pour la luminosité donnée. Bascule [AppColors]
  /// sur cette luminosité avant de lire le moindre token — sans ça,
  /// `light` et `dark` liraient tous les deux la luminosité globale
  /// courante (celle laissée par le dernier appel) et produiraient deux
  /// [ThemeData] avec les mêmes couleurs figées pour l'AppBar, les
  /// dialogues, les champs de saisie, etc.
  static ThemeData _build(Brightness brightness) {
    AppColors.setBrightness(brightness);
    final base = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: AppColors.surface,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: brightness,
        primary: AppColors.primary,
        secondary: AppColors.primaryDark,
        surface: AppColors.surface,
        error: AppColors.error,
      ),
    );

    return base.copyWith(
      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.transparent,
      dividerColor: AppColors.border,
      textTheme: base.textTheme.copyWith(
        headlineLarge: AppTextStyles.displayXL(),
        headlineMedium: AppTextStyles.displayLarge(),
        headlineSmall: AppTextStyles.displayMedium(),
        titleMedium: AppTextStyles.titleMedium(),
        bodyLarge: AppTextStyles.bodyLarge(),
        bodyMedium: AppTextStyles.bodyMedium(),
        bodySmall: AppTextStyles.bodySmall(),
        labelLarge: AppTextStyles.label(),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: AppColors.ink),
        titleTextStyle: AppTextStyles.displayMedium(),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceMuted,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.input),
          borderSide: BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.input),
          borderSide: BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.input),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.6),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.input),
          borderSide: const BorderSide(color: AppColors.error, width: 1.2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.input),
          borderSide: const BorderSide(color: AppColors.error, width: 1.6),
        ),
        hintStyle:
            AppTextStyles.bodyMedium(color: AppColors.inkMuted(opacity: 0.4)),
        errorStyle: AppTextStyles.bodySmall(color: AppColors.error).copyWith(
          color: AppColors.error,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.surfaceMuted,
          disabledForegroundColor: AppColors.inkMuted(opacity: 0.4),
          minimumSize: const Size.fromHeight(52),
          elevation: 0,
          textStyle: AppTextStyles.label(color: Colors.white),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.button),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.ink,
          minimumSize: const Size.fromHeight(52),
          side: BorderSide(color: AppColors.border),
          textStyle: AppTextStyles.label(),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.button),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: AppTextStyles.label(color: AppColors.primary),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: AppColors.surfaceCard,
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
        dragHandleColor: AppColors.border,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadius.sheet),
          ),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surfaceCard,
        surfaceTintColor: Colors.transparent,
        // En sombre, l'élévation Material seule (ombre noire sur fond déjà
        // quasi noir) ne suffit pas à détacher la boîte de dialogue de son
        // arrière-plan assombri — un hairline la définit clairement. En
        // clair, l'ombre suffit déjà, donc pas de bordure superflue.
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.card),
          side: AppColors.isDark
              ? BorderSide(color: AppColors.border)
              : BorderSide.none,
        ),
        titleTextStyle: AppTextStyles.titleMedium(),
        contentTextStyle:
            AppTextStyles.bodyMedium(color: AppColors.inkMuted(opacity: 0.8)),
      ),
      snackBarTheme: SnackBarThemeData(
        // Toast volontairement toujours sombre (texte blanc) dans les deux
        // thèmes — AppColors.inkSolid, pas AppColors.ink qui s'inverserait
        // en blanc en mode sombre et rendrait le texte illisible.
        backgroundColor: AppColors.inkSolid,
        contentTextStyle: AppTextStyles.bodyMedium(color: Colors.white),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.input),
        ),
      ),
      chipTheme: base.chipTheme.copyWith(
        backgroundColor: AppColors.surfaceMuted,
        selectedColor: AppColors.primaryTint,
        labelStyle: AppTextStyles.label(),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.pill),
          side: BorderSide(color: AppColors.border),
        ),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primary,
      ),
      // Le sélecteur de date Material 3 s'appuie par défaut sur des tons
      // dérivés algorithmiquement du seed color (surfaceContainerHigh,
      // onSurfaceVariant...) — jamais harmonisés avec nos tokens custom,
      // d'où un contraste très faible en sombre. On fixe explicitement
      // chaque rôle sur nos propres tokens (déjà sensibles au thème).
      datePickerTheme: DatePickerThemeData(
        backgroundColor: AppColors.surfaceCard,
        surfaceTintColor: Colors.transparent,
        headerBackgroundColor: AppColors.surfaceCard,
        headerForegroundColor: AppColors.ink,
        headerHeadlineStyle: AppTextStyles.displayMedium(),
        headerHelpStyle:
            AppTextStyles.label(color: AppColors.inkMuted(opacity: 0.6)),
        weekdayStyle:
            AppTextStyles.bodySmall(color: AppColors.inkMuted(opacity: 0.55)),
        dayStyle: AppTextStyles.bodyMedium(),
        yearStyle: AppTextStyles.bodyMedium(),
        dayForegroundColor: WidgetStateProperty.resolveWith((states) =>
            states.contains(WidgetState.selected)
                ? Colors.white
                : AppColors.ink),
        dayBackgroundColor: WidgetStateProperty.resolveWith((states) =>
            states.contains(WidgetState.selected)
                ? AppColors.primary
                : Colors.transparent),
        todayForegroundColor: WidgetStateProperty.resolveWith((states) =>
            states.contains(WidgetState.selected)
                ? Colors.white
                : AppColors.primary),
        todayBackgroundColor: WidgetStateProperty.resolveWith((states) =>
            states.contains(WidgetState.selected)
                ? AppColors.primary
                : Colors.transparent),
        todayBorder: const BorderSide(color: AppColors.primary, width: 1),
        yearForegroundColor: WidgetStateProperty.resolveWith((states) =>
            states.contains(WidgetState.selected)
                ? Colors.white
                : AppColors.ink),
        yearBackgroundColor: WidgetStateProperty.resolveWith((states) =>
            states.contains(WidgetState.selected)
                ? AppColors.primary
                : Colors.transparent),
        dividerColor: AppColors.border,
        confirmButtonStyle:
            TextButton.styleFrom(foregroundColor: AppColors.primary),
        cancelButtonStyle: TextButton.styleFrom(
            foregroundColor: AppColors.inkMuted(opacity: 0.6)),
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
