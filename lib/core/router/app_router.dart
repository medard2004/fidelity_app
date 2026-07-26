import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/auth_screen.dart';
import '../../features/auth/otp_screen.dart';
import '../../features/auth/signup_screen.dart';
import '../../features/auth/complete_profile_screen.dart';
import '../../features/auth/complete_social_profile_screen.dart';
import '../../features/onboarding/onboarding_screen.dart';
import '../../features/onboarding/qr_scan_screen.dart';
import '../../features/onboarding/join_restaurant_screen.dart';
import '../../features/wallet/wallet_dashboard_screen.dart';
import '../../features/card_detail/card_detail_screen.dart';
import '../../features/rewards/rewards_screen.dart';
import '../../features/referral/referral_screen.dart';
import '../../features/profile/profile_screen.dart';
import '../../features/notifications/notifications_screen.dart';
import '../../widgets/shared/app_shell.dart';

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
      builder: (context, state) => const JoinRestaurantScreen(),
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
          builder: (context, state) => const WalletDashboardScreen(),
        ),
        GoRoute(
          path: '/rewards',
          builder: (context, state) => const RewardsScreen(),
        ),
        GoRoute(
          path: '/referral',
          builder: (context, state) => const ReferralScreen(),
        ),
        GoRoute(
          path: '/profile',
          builder: (context, state) => const ProfileScreen(),
        ),
      ],
    ),

    /// Détail de carte — transition signature bascule 3D + agrandissement.
    GoRoute(
      path: '/card/:id',
      pageBuilder: (context, state) {
        final id = state.pathParameters['id']!;
        return CustomTransitionPage(
          key: state.pageKey,
          child: CardDetailScreen(cardId: id),
          transitionDuration: const Duration(milliseconds: 420),
          reverseTransitionDuration: const Duration(milliseconds: 320),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final curved = CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
              reverseCurve: Curves.easeInCubic,
            );
            return AnimatedBuilder(
              animation: curved,
              child: child,
              builder: (context, child) {
                final t = curved.value;
                final perspective = Matrix4.identity()
                  ..setEntry(3, 2, 0.0009)
                  ..rotateX((1 - t) * -0.35);
                return Opacity(
                  opacity: t.clamp(0, 1),
                  child: Transform(
                    alignment: Alignment.center,
                    transform: perspective
                      ..scale(0.92 + 0.08 * t, 0.92 + 0.08 * t, 1.0),
                    child: child,
                  ),
                );
              },
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
  ],
);
