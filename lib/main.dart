import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/toast_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Erreur d\'initialisation Firebase: $e');
  }

  await initializeDateFormatting('fr_FR');
  runApp(const ProviderScope(child: CarteApp()));
}

class CarteApp extends ConsumerWidget {
  const CarteApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      title: 'Carte — Fidélité',
      debugShowCheckedModeBanner: false,
      scaffoldMessengerKey: ToastService.messengerKey,
      theme: AppTheme.light,
      routerConfig: router,
    );
  }
}
