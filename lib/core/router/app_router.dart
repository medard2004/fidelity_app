import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'app_route_observer.dart';
import 'tab_transition_direction.dart';
import '../theme/app_motion.dart';
import '../../features/auth/auth_screen.dart';
import '../../features/auth/otp_screen.dart';
import '../../features/auth/signup_screen.dart';
import '../../features/auth/complete_profile_screen.dart';
import '../../features/auth/complete_social_profile_screen.dart';
import '../../features/onboarding/onboarding_screen.dart';
import '../../features/onboarding/qr_scan_screen.dart';
import '../../features/onboarding/join_restaurant_screen.dart';
import '../../features/wallet/wallet_dashboard_screen.dart';
import '../../features/wallet/wallet_search_screen.dart';
import '../../features/card_detail/card_detail_screen.dart';
import '../../features/rewards/rewards_screen.dart';
import '../../features/referral/referral_screen.dart';
import '../../features/profile/profile_screen.dart';
import '../../features/settings/settings_screen.dart';
import '../../features/notifications/notifications_screen.dart';
import '../../widgets/shared/app_shell.dart';

/// Transition des onglets de la bottom nav bar — léger slide horizontal
/// orienté selon le sens du changement d'onglet (voir [tabSlideDirection]),
/// combiné à un fondu et un scale discret. Donne l'impression que tous
/// les onglets appartiennent au même espace plutôt que d'être des pages
/// empilées, sans jamais évoquer une navigation hiérarchique.
CustomTransitionPage<void> _tabFadePage(GoRouterState state, Widget child) {
  final direction = tabSlideDirection;
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: AppMotion.pageDuration,
    reverseTransitionDuration: AppMotion.pageReverseDuration,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curved =
          CurvedAnimation(parent: animation, curve: AppMotion.pageCurve);
      final slide = Tween<Offset>(
        begin: Offset(0.035 * direction, 0),
        end: Offset.zero,
      ).animate(curved);
      return FadeTransition(
        opacity: curved,
        child: SlideTransition(
          position: slide,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.98, end: 1.0).animate(curved),
            child: child,
          ),
        ),
      );
    },
  );
}

/// Construit un [OtpScreen] depuis les données `extra` du router.
/// `extra` peut être :
///   - `Map<String, dynamic>` : `{'phone': '...', 'context': 'login'|'signup'|'social'}`
///   - `String` : numéro brut (rétro-compatibilité)
OtpScreen _buildOtpScreen(GoRouterState state) {
  final extra = state.extra;

  String phone = '';
  OtpContext otpContext = OtpContext.login;

  if (extra is Map<String, dynamic>) {
    phone = extra['phone'] as String? ?? '';
    final ctx = extra['context'] as String? ?? 'login';
    otpContext = switch (ctx) {
      'signup' => OtpContext.signup,
      'social' => OtpContext.social,
      _ => OtpContext.login,
    };
  } else if (extra is String) {
    phone = extra;
  }

  return OtpScreen(phoneNumber: phone, otpContext: otpContext);
}

final appRouter = GoRouter(
  initialLocation: '/onboarding',
  observers: [routeObserver],
  routes: [
    // ── Onboarding ───────────────────────────────────────────────────────────
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(
      path: '/onboarding/scan',
      builder: (context, state) => const QrScanScreen(),
    ),
    GoRoute(
      path: '/onboarding/join',
      builder: (context, state) {
        final extra = state.extra;
        String? code;
        if (extra is Map<String, dynamic>) {
          code = extra['code'] as String?;
        } else if (extra is String) {
          code = extra;
        }
        return JoinRestaurantScreen(scannedCode: code);
      },
    ),

    // ── Auth : connexion ─────────────────────────────────────────────────────
    GoRoute(
      path: '/auth',
      builder: (context, state) => const AuthScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const AuthScreen(),
    ),

    // ── Auth : inscription ───────────────────────────────────────────────────
    GoRoute(
      path: '/signup',
      builder: (context, state) => const SignupScreen(),
    ),

    // ── Auth : OTP ───────────────────────────────────────────────────────────
    GoRoute(
      path: '/otp',
      builder: (context, state) => _buildOtpScreen(state),
    ),

    // ── Auth : complétion de profil post-inscription téléphone ───────────────
    GoRoute(
      path: '/complete-profile',
      builder: (context, state) => const CompleteProfileScreen(),
    ),

    // ── Auth : complétion de profil post-connexion sociale ───────────────────
    GoRoute(
      path: '/complete-social-profile',
      builder: (context, state) => const CompleteSocialProfileScreen(),
    ),

    // ── Coquille principale avec bottom tab bar ───────────────────────────────
    ShellRoute(
      builder: (context, state, child) => AppShell(child: child),
      routes: [
        GoRoute(
          path: '/wallet',
          pageBuilder: (context, state) =>
              _tabFadePage(state, const WalletDashboardScreen()),
        ),
        GoRoute(
          path: '/rewards',
          pageBuilder: (context, state) =>
              _tabFadePage(state, const RewardsScreen()),
        ),
        GoRoute(
          path: '/referral',
          pageBuilder: (context, state) =>
              _tabFadePage(state, const ReferralScreen()),
        ),
        GoRoute(
          path: '/profile',
          pageBuilder: (context, state) =>
              _tabFadePage(state, const ProfileScreen()),
        ),
      ],
    ),

    /// Détail de carte — la carte du Wallet (Hero partagé) se transforme
    /// naturellement en page plein écran : fondu + agrandissement depuis
    /// son point d'ancrage, dans l'esprit du "container transform" de
    /// Google Wallet/Google Photos, plutôt qu'un simple push.
    GoRoute(
      path: '/card/:id',
      pageBuilder: (context, state) {
        final id = state.pathParameters['id']!;
        return CustomTransitionPage<void>(
          key: state.pageKey,
          child: CardDetailScreen(cardId: id),
          transitionDuration: AppMotion.pageDuration,
          reverseTransitionDuration: AppMotion.pageReverseDuration,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final curved = CurvedAnimation(
              parent: animation,
              curve: AppMotion.pageCurve,
              reverseCurve: AppMotion.pageReverseCurve,
            );
            return FadeTransition(
              opacity: curved,
              child: ScaleTransition(
                scale: Tween<double>(begin: 0.90, end: 1.0).animate(curved),
                alignment: Alignment.center,
                child: child,
              ),
            );
          },
        );
      },
    ),

    // ── Notifications ────────────────────────────────────────────────────────
    GoRoute(
      path: '/notifications',
      builder: (context, state) => const NotificationsScreen(),
    ),

    // ── Paramètres ───────────────────────────────────────────────────────────
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
    ),

    /// Recherche du Wallet — écran dédié qui glisse depuis le bas, comme
    /// une feuille de recherche plutôt qu'une simple page poussée.
    GoRoute(
      path: '/wallet/search',
      pageBuilder: (context, state) {
        return CustomTransitionPage<void>(
          key: state.pageKey,
          child: const WalletSearchScreen(),
          transitionDuration: AppMotion.pageDuration,
          reverseTransitionDuration: AppMotion.pageReverseDuration,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final curved =
                CurvedAnimation(parent: animation, curve: AppMotion.pageCurve);
            return FadeTransition(
              opacity: curved,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.06),
                  end: Offset.zero,
                ).animate(curved),
                child: child,
              ),
            );
          },
        );
      },
    ),
  ],
);
