import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../api/providers/api_providers.dart';
import '../api/storage/local_preferences.dart';
import 'app_providers.dart';

class AppStartupState {
  final bool hasSeenOnboarding;
  
  const AppStartupState({
    required this.hasSeenOnboarding,
  });
}

final appStartupProvider = FutureProvider<AppStartupState>((ref) async {
  // 1. Lire les préférences locales
  final prefs = ref.read(localPreferencesProvider);
  final hasSeenOnboarding = await prefs.hasSeenOnboarding();

  // 2. Vérifier la session (Token existant ?)
  final authRepository = ref.read(authRepositoryProvider);
  final authNotifier = ref.read(authProvider.notifier);
  
  final isLoggedIn = await authRepository.isLoggedIn();
  
  if (isLoggedIn) {
    try {
      // 3. Tenter de récupérer l'utilisateur (le backend validera le token)
      final user = await authRepository.getMe();
      // Mettre à jour l'état de l'authentification silencieusement
      authNotifier.setAuthenticated(user);
    } catch (e) {
      // Si le token est expiré ou qu'il y a une erreur réseau grave (le backend renvoie 401),
      // AuthRepository lève une exception. On nettoie alors la session.
      await authNotifier.signOut();
    }
  }

  return AppStartupState(
    hasSeenOnboarding: hasSeenOnboarding,
  );
});
