import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_motion.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_radius.dart';
import '../../l10n/gen/app_localizations.dart';
import '../components/app_tap_scale.dart';

class NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  const NavItem(this.icon, this.activeIcon, this.label);
}

List<NavItem> _navItems(AppLocalizations t) => [
      NavItem(LucideIcons.wallet, LucideIcons.wallet, t.navWallet),
      NavItem(LucideIcons.gift, LucideIcons.gift, t.navRewards),
      NavItem(LucideIcons.users, LucideIcons.users, t.navReferral),
      NavItem(LucideIcons.user, LucideIcons.user, t.navProfile),
    ];

/// Bottom tab bar — fond blanc, bordure hairline supérieure, indicateur
/// actif en pastille pleine (pattern Revolut/Stripe) plutôt qu'un point.
class AppBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const AppBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final navItems = _navItems(AppLocalizations.of(context)!);
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        border: Border(top: BorderSide(color: AppColors.border, width: 1)),
      ),
      padding: EdgeInsets.only(
        top: 10,
        bottom: MediaQuery.of(context).padding.bottom + 8,
        left: 12,
        right: 12,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(navItems.length, (i) {
          final item = navItems[i];
          final active = i == currentIndex;
          final color =
              active ? AppColors.primary : AppColors.inkMuted(opacity: 0.45);
          return Expanded(
            child: AppTapScale(
              onTap: () => onTap(i),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedContainer(
                    duration: AppMotion.pressDuration,
                    curve: AppMotion.pressCurve,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
                    decoration: BoxDecoration(
                      color:
                          active ? AppColors.primaryTint : Colors.transparent,
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                    ),
                    child: AnimatedScale(
                      duration: AppMotion.pressDuration,
                      curve: AppMotion.pressCurve,
                      scale: active ? 1.08 : 1.0,
                      child: Icon(active ? item.activeIcon : item.icon,
                          size: 22, color: color),
                    ),
                  ),
                  const SizedBox(height: 4),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(item.label,
                        style: AppTextStyles.bodySmall(color: color)),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
