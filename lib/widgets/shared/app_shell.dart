import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/router/tab_transition_direction.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/settings_provider.dart';
import 'bottom_nav_bar.dart';

const _shellRoutes = ['/wallet', '/rewards', '/referral', '/profile'];

/// Coquille avec bottom tab bar. Le device frame desktop (fond neutre
/// assombri) est appliqué ici pour détacher l'app du chrome du navigateur
/// sur les grands écrans.
class AppShell extends ConsumerWidget {
  final Widget child;
  const AppShell({super.key, required this.child});

  int _indexForLocation(String location) {
    final i = _shellRoutes.indexWhere((r) => location.startsWith(r));
    return i == -1 ? 0 : i;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // AppColors est un flag global lu directement (pas via Theme.of), donc
    // rien ne force naturellement ce widget à se reconstruire quand le
    // thème change ailleurs dans l'app (ex. depuis l'écran Paramètres,
    // plusieurs niveaux de navigation plus loin). On observe explicitement
    // le thème pour garantir une mise à jour immédiate de la bottom bar.
    ref.watch(themeModeProvider);
    final location = GoRouterState.of(context).uri.toString();
    final currentIndex = _indexForLocation(location);
    final isWide = MediaQuery.of(context).size.width > 620;

    final scaffold = Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(bottom: false, child: child),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: currentIndex,
        onTap: (i) {
          tabSlideDirection = i >= currentIndex ? 1 : -1;
          context.go(_shellRoutes[i]);
        },
      ),
    );

    if (!isWide) return scaffold;

    // Version desktop : device frame centré sur fond neutre.
    return ColoredBox(
      color: AppColors.surfaceDesktopFrame,
      child: Center(
        child: Container(
          width: 420,
          height: 860,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(36),
            border: Border.all(color: AppColors.inkSolid, width: 8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.22),
                blurRadius: 40,
                offset: const Offset(0, 20),
              ),
            ],
          ),
          child: scaffold,
        ),
      ),
    );
  }
}
