# Système de chargement global — Auth (phase 1)

Date : 2026-08-01
Statut : approuvé

## Problème

Le mixin `FormErrorHandler` expose déjà `isBusy` (garde anti-double-soumission) sur
tous les écrans auth, mais aucun retour visuel n'y est associé — le commentaire du
code le dit explicitement : *"Aucun indicateur de chargement n'y est associé."*
Même chose côté démarrage : `SplashScreen` est *"volontairement muet"* pendant la
résolution de `appStartupProvider`. L'utilisateur tape, rien ne bouge visuellement,
l'app paraît lente ou bloquée.

Objectif : un système de chargement centralisé, réutilisable, au design cohérent
avec l'identité "Édition Porcelaine" (jamais de blanc/noir pur, animations discrètes,
pas de spinner Material générique). Portée actuelle : écrans auth uniquement.
Extension au reste de l'app dans une itération suivante (hors scope de ce spec).

## Composants

### 1. `LoadingDots` (`lib/widgets/shared/loading_dots.dart`)

Le seul motif visuel de chargement de l'app. 3 points, opacité respirante en
cascade (léger déphasage entre points, boucle continue). Props : `color`
(défaut `AppColors.encre`), `size`. Pas de dépendance à un contexte particulier —
utilisable inline (bouton) ou centré (overlay/écran plein).

### 2. `InvitationButton` — extension

Nouveau prop `loading: bool = false` sur `InvitationButton` (`lib/widgets/shared/invitation_button.dart`).
Quand `true` :
- le label est remplacé par `LoadingDots` (couleur adaptée à `filled` : `porcelaine`
  sur fond `vertBouteille`, `encre` sinon), taille adaptée à la hauteur du bouton ;
- `onTap` est forcé à `null` en interne, quelle que soit la valeur passée par
  l'appelant — un seul point de vérité, plus besoin d'écrire `isBusy ? null : _handler`
  dans chaque écran (mais ça reste sans effet de le laisser, donc pas de migration
  cassante) ;
- largeur/hauteur du bouton ne bougent pas (pas de saut de layout entre état
  normal et chargement).

### 3. `LoadingOverlayService` (`lib/core/utils/loading_overlay_service.dart`)

Jumeau de `ToastService` (même mécanisme : `OverlayEntry` statique inséré via
`rootNavigatorKey.currentState?.overlay`, pas de `BuildContext` à faire voyager).

```dart
LoadingOverlayService.show({String? message});
LoadingOverlayService.hide();
```

Rendu : voile `AppColors.porcelaine` semi-opaque (~0.85) plein écran,
`LoadingDots` centrés (couleur `encre`), message optionnel en dessous
(`AppTextStyles.bodyMedium`). `IgnorePointer` inversé : contrairement à
`GrainOverlay`/`WaxSealUnlockOverlay` (purement décoratifs, jamais interactifs),
celui-ci bloque volontairement toute interaction en dessous — c'est son rôle.

`show()` est idempotent : un appel pendant qu'une entry existe déjà la remplace
plutôt que d'empiler. `hide()` sans entry active ne fait rien.

Réservé aux moments sans bouton porteur d'état :
- retours Google/Apple Sign-In (l'app quitte le focus vers le natif/webview ;
  le spinner du bouton seul, invisible pendant ce temps, ne suffit pas à
  rassurer au retour) ;
- `SplashScreen` peut soit appeler le service, soit intégrer `LoadingDots`
  directement dans son `Scaffold` (plus simple puisqu'il possède déjà l'écran
  seul) — voir Intégration.

## Intégration

| Fichier | Changement |
|---|---|
| `lib/widgets/shared/loading_dots.dart` | nouveau — le widget |
| `lib/widgets/shared/invitation_button.dart` | + prop `loading` |
| `lib/core/utils/loading_overlay_service.dart` | nouveau — service |
| `lib/features/auth/auth_screen.dart` | `loading: isBusy` sur les 3 CTA ; `LoadingOverlayService.show()/hide()` autour de `_continueWithGoogle`/`_continueWithApple` |
| `lib/features/auth/signup_screen.dart` | idem (submit + 2 CTA sociaux) |
| `lib/features/auth/otp_screen.dart` | `loading: isBusy` sur CTA submit |
| `lib/features/auth/forgot_password_screen.dart` | idem |
| `lib/features/auth/create_password_screen.dart` | idem |
| `lib/features/auth/reset_password_screen.dart` | idem |
| `lib/features/auth/complete_profile_screen.dart` | idem |
| `lib/features/auth/complete_social_profile_screen.dart` | idem |
| `lib/features/splash/splash_screen.dart` | remplace le body muet par `LoadingDots` centrés (mettre à jour le commentaire obsolète) |

## Gestion d'erreur / edge cases

- `LoadingOverlayService.hide()` toujours appelé en `finally` autour des flux
  sociaux (même pattern que `runGuarded` pour `isBusy`) — jamais de voile
  bloqué même si `SocialAuthService` lève.
- Double `show()` consécutif : remplace, n'empile pas d'entries.
- Navigation pendant overlay actif (ex. retour arrière rapide) : `hide()` doit
  être sûr même si `rootNavigatorKey.currentState?.overlay` a changé d'état —
  vérifier nullité avant `remove()`, comme `ToastService.hideCurrent()` le
  fait déjà.

## Tests

Pas de suite de tests widget existante sur les écrans auth actuels (à
confirmer en phase d'implémentation) — le plan d'implémentation décidera du
niveau de couverture (tests widget pour `LoadingDots`/`InvitationButton.loading`
au minimum ; `LoadingOverlayService` difficile à tester unitairement de par
sa nature statique/Overlay, vérification manuelle acceptable).

## Hors scope

Extension du système à la navigation, aux appels réseau hors auth (wallet,
rewards, profile...), et à un éventuel état de chargement par route dans le
router — prévu pour une itération future, non traité ici.
