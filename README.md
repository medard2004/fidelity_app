# Carte — App Client Fidélité Multi-Restaurants (Édition Porcelaine)

Application Flutter mobile-first pour le module client de la plateforme
de fidélité multi-restaurants, basée sur la direction artistique
"Édition Porcelaine".

## Stack technique

- **Flutter 3.x / Dart 3.x**
- **flutter_riverpod** — gestion d'état (StateNotifierProvider)
- **go_router** — navigation déclarative, shell avec bottom tab bar
- **google_fonts** — Bodoni Moda (display), Public Sans (corps), IBM Plex Mono (données)
- Données 100% mockées en mémoire (`lib/data/mock_data.dart`), prêtes pour un futur branchement API

## Lancer le projet

Ce projet contient uniquement le code Dart (`lib/`) et le `pubspec.yaml`.
Les dossiers de plateforme (android/, ios/, etc.) n'ont pas été générés
dans cet environnement (pas de SDK Flutter disponible ici). Pour démarrer :

```bash
flutter create . --project-name carte_app --org com.digitalvision
flutter pub get
flutter run
```

La première commande régénère les dossiers `android/`, `ios/`, `web/`, etc.
sans toucher au code déjà présent dans `lib/`.

## Structure

```
lib/
  core/
    theme/        → design tokens : couleurs, typographie, radius, ThemeData
    router/        → GoRouter (auth, onboarding, shell + bottom nav, détail carte)
  models/           → AppUser, LoyaltyCard, Reward, AppNotification
  data/             → mock_data.dart (4-5 cartes de démonstration)
  providers/        → Riverpod : wallet, rewards, notifications, auth
  widgets/shared/    → composants réutilisables (boutons, QR plate, OTP, nav bar, grain, sceau laiton)
  features/
    auth/            → inscription, connexion, OTP
    onboarding/       → scan QR (mock), rejoindre un restaurant
    wallet/           → dashboard, pile de cartes empilées
    card_detail/      → écran plein écran d'une carte + progression + récompenses
    rewards/          → toutes les récompenses, tous restaurants
    referral/         → parrainage
    profile/          → profil, anniversaire, notifications par restaurant
    notifications/    → centre de notifications
```

## Design tokens

Toutes les couleurs et typographies vivent dans `lib/core/theme/` — jamais
de valeur codée en dur dans les widgets d'écran. Voir `app_colors.dart`
pour la palette à 6 teintes (Porcelaine, Encre, Vert bouteille, Laiton
brossé, Sauge pâle, Bordeaux profond).

## Points d'attention pour la suite

- Le QR code et le scanner caméra sont actuellement des **mocks visuels**
  (`BrassQrPlate` / `QrScanScreen`). Brancher `mobile_scanner` et
  `qr_flutter` pour la version production.
- L'authentification OTP est simulée (tout code à 6 chiffres valide la connexion).
- Les animations respectent `prefers-reduced-motion` côté web/desktop ;
  pour mobile natif, ajouter un contrôle sur `MediaQuery.disableAnimations`
  si nécessaire.
- Prévoir la connexion à une API pour remplacer `MockData` et les
  `StateNotifier` par des appels réseau (repository pattern recommandé).
