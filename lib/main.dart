import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/app_theme.dart';
import 'l10n/gen/app_localizations.dart';
import 'providers/settings_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('fr_FR');
  await initializeDateFormatting('en_US');
  runApp(const ProviderScope(child: CarteApp()));
}

class CarteApp extends ConsumerWidget {
  const CarteApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);

    // Chaque getter reconstruit son propre ThemeData en basculant
    // temporairement AppColors sur sa luminosité ; on fige ensuite
    // AppColors sur la luminosité réellement active pour que le reste de
    // l'arbre (qui lit AppColors.xxx directement) affiche les bonnes
    // couleurs — voir AppColors.setBrightness.
    final lightTheme = AppTheme.light;
    final darkTheme = AppTheme.dark;
    final platformBrightness = MediaQuery.platformBrightnessOf(context);
    final resolvedBrightness = switch (themeMode) {
      ThemeMode.light => Brightness.light,
      ThemeMode.dark => Brightness.dark,
      ThemeMode.system => platformBrightness,
    };
    AppColors.setBrightness(resolvedBrightness);

    return MaterialApp.router(
      title: 'Carte — Fidélité',
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: themeMode,
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: appRouter,
    );
  }
}
