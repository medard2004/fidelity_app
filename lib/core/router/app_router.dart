import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/app_providers.dart';
import '../../providers/app_startup_provider.dart';
import '../../features/splash/splash_screen.dart';
import '../../features/auth/auth_screen.dart';
import '../../features/auth/otp_screen.dart';
import '../../features/auth/signup_screen.dart';
import '../../features/auth/complete_profile_screen.dart';
import '../../features/auth/complete_social_profile_screen.dart';
import '../../features/auth/create_password_screen.dart';
import '../../features/auth/forgot_password_screen.dart';
import '../../features/auth/reset_password_screen.dart';
import '../../features/onboarding/onboarding_screen.dart';
import '../../features/onboarding/qr_scan_screen.dart';
import '../../features/onboarding/join_restaurant_screen.dart';
import '../../features/wallet/wallet_dashboard_screen.dart';
import '../../features/card_detail/card_detail_screen.dart';
import '../../features/rewards/rewards_screen.dart';
import '../../features/referral/referral_screen.dart';
import '../../features/profile/profile_screen.dart';
import '../../features/profile/personal_info_screen.dart';
import '../../features/profile/edit_profile_screen.dart';
import '../../features/profile/verify_current_password_screen.dart';
import '../../features/profile/set_new_password_screen.dart';
import '../../features/notifications/notifications_screen.dart';
import '../../widgets/shared/app_shell.dart';

/// Construit un [OtpScreen] depuis les données `extra` du router.
/// `extra` peut être :
///   - `Map<String, dynamic>` : `{'phone': '...', 'context': 'login'|'signup'|'social'}`
///   - `String` : numéro brut (rétro-compatibilité)
OtpScreen _buildOtpScreen(GoRouterState state) {
  final extra = state.extra;

  String identifier = '';
  OtpContext otpContext = OtpContext.login;

  if (extra is Map<String, dynamic>) {
    identifier = extra['phone'] as String? ?? '';
    final ctx = extra['context'] as String? ?? 'login';
    otpContext = switch (ctx) {
      'signup' => OtpContext.signup,
      'social' => OtpContext.social,
      'forgotPassword' => OtpContext.forgotPassword,
      _ => OtpContext.login,
    };
  } else if (extra is String) {
    identifier = extra;
  }

  return OtpScreen(identifier: identifier, otpContext: otpContext);
}

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

class RouterNotifier extends ChangeNotifier {
  final Ref _ref;

  RouterNotifier(this._ref) {
    _ref.listen(authProvider, (_, __) => notifyListeners());
    _ref.listen(appStartupProvider, (_, __) => notifyListeners());
  }
}

final routerProvider = Provider<GoRouter>((ref) {
  final notifier = RouterNotifier(ref);

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/splash',
    refreshListenable: notifier,
    redirect: (context, state) {
      final startupState = ref.read(appStartupProvider);
      final authState = ref.read(authProvider);

      final isGoingToSplash = state.uri.path == '/splash';
      final isGoingToOnboarding = state.uri.path.startsWith('/onboarding');
      final isGoingToAuth = state.uri.path.startsWith('/auth') ||
          state.uri.path.startsWith('/login') ||
          state.uri.path.startsWith('/signup') ||
          state.uri.path.startsWith('/otp') ||
          state.uri.path.startsWith('/complete-profile') ||
          state.uri.path.startsWith('/complete-social-profile') ||
          state.uri.path.startsWith('/create-password') ||
          state.uri.path.startsWith('/forgot-password') ||
          state.uri.path.startsWith('/reset-password');

      // 1. Splash / Loading State
      if (startupState.isLoading || !startupState.hasValue) {
        return isGoingToSplash ? null : '/splash';
      }

      final hasSeenOnboarding = startupState.value?.hasSeenOnboarding ?? false;
      final isAuthenticated = authState.isAuthenticated;

      // 2. Onboarding flow
      if (!hasSeenOnboarding) {
        return isGoingToOnboarding ? null : '/onboarding';
      }

      // If they try to go to onboarding or splash after they've seen onboarding
      if (isGoingToOnboarding || isGoingToSplash) {
        return isAuthenticated ? '/wallet' : '/auth';
      }

      // 3. Auth flow
      if (!isAuthenticated) {
        // Enforce auth
        if (!isGoingToAuth) {
          return '/auth';
        }
      } else {
        // Prevent logged-in users from seeing auth screens
        if (isGoingToAuth) {
          return '/wallet';
        }
      }

      return null; // No redirect
    },
    routes: [
      // ── Splash ───────────────────────────────────────────────────────────────
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),

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

    // ── Auth : création de mot de passe ──────────────────────────────────────
    GoRoute(
      path: '/create-password',
      builder: (context, state) => const CreatePasswordScreen(),
    ),

    // ── Auth : Mot de passe oublié ───────────────────────────────────────────
    GoRoute(
      path: '/forgot-password',
      builder: (context, state) => const ForgotPasswordScreen(),
    ),
    GoRoute(
      path: '/reset-password',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>? ?? {};
        return ResetPasswordScreen(
          accountId: extra['phone'] as String? ?? '',
          token: extra['token'] as String? ?? '',
        );
      },
    ),

    // ── Profil : sous-pages ──────────────────────────────────────────────────
    GoRoute(
      path: '/personal-info',
      builder: (context, state) => const PersonalInfoScreen(),
    ),
    GoRoute(
      path: '/edit-profile',
      builder: (context, state) {
        final fieldType = (state.extra as EditFieldType?) ?? EditFieldType.fullName;
        return EditFieldScreen(fieldType: fieldType);
      },
    ),
    GoRoute(
      path: '/change-password',
      builder: (context, state) => const VerifyCurrentPasswordScreen(),
    ),
    GoRoute(
      path: '/set-new-password',
      builder: (context, state) {
        final currentPassword = state.extra as String? ?? '';
        return SetNewPasswordScreen(currentPassword: currentPassword);
      },
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
});
