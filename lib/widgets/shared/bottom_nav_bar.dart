import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_radius.dart';

class NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  const NavItem(this.icon, this.activeIcon, this.label);
}

const _navItems = [
  NavItem(Icons.wallet_outlined, Icons.wallet_rounded, 'Wallet'),
  NavItem(
      Icons.card_giftcard_outlined, Icons.card_giftcard_rounded, 'Récompenses'),
  NavItem(Icons.people_outline, Icons.people_rounded, 'Parrainage'),
  NavItem(Icons.person_outline, Icons.person_rounded, 'Profil'),
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
    return Container(
      decoration: const BoxDecoration(
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
        children: List.generate(_navItems.length, (i) {
          final item = _navItems[i];
          final active = i == currentIndex;
          final color = active ? AppColors.primary : AppColors.inkMuted(opacity: 0.45);
          return Expanded(
            child: GestureDetector(
              onTap: () => onTap(i),
              behavior: HitTestBehavior.opaque,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
                    decoration: BoxDecoration(
                      color: active ? AppColors.primaryTint : Colors.transparent,
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                    ),
                    child: Icon(active ? item.activeIcon : item.icon,
                        size: 22, color: color),
                  ),
                  const SizedBox(height: 4),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(item.label, style: AppTextStyles.bodySmall(color: color)),
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
