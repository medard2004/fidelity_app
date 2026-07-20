import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import 'bottom_nav_bar.dart';

const _shellRoutes = ['/wallet', '/rewards', '/referral', '/profile'];

/// Coquille avec bottom tab bar. Le device frame desktop (fond porcelaine
/// assombrie) est appliqué ici pour détacher l'app du chrome du navigateur
/// sur les grands écrans.
class AppShell extends StatelessWidget {
  final Widget child;
  const AppShell({super.key, required this.child});

  int _indexForLocation(String location) {
    final i = _shellRoutes.indexWhere((r) => location.startsWith(r));
    return i == -1 ? 0 : i;
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    final currentIndex = _indexForLocation(location);
    final isWide = MediaQuery.of(context).size.width > 620;

    final scaffold = Scaffold(
      backgroundColor: AppColors.porcelaine,
      body: SafeArea(bottom: false, child: child),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: currentIndex,
        onTap: (i) => context.go(_shellRoutes[i]),
      ),
    );

    if (!isWide) return scaffold;

    // Version desktop : device frame centré sur fond porcelaine assombrie.
    return ColoredBox(
      color: AppColors.porcelaineAssombrie,
      child: Center(
        child: Container(
          width: 420,
          height: 860,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(36),
            border: Border.all(color: AppColors.encre, width: 8),
            boxShadow: [
              BoxShadow(
                color: AppColors.ombreChaude(opacity: 0.25),
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
