import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class NavItem {
  final IconData icon;
  final String label;
  const NavItem(this.icon, this.label);
}

const _navItems = [
  NavItem(Icons.wallet_outlined, 'Wallet'),
  NavItem(Icons.card_giftcard_outlined, 'Récompenses'),
  NavItem(Icons.diamond_outlined, 'Parrainage'),
  NavItem(Icons.person_outline, 'Profil'),
];

/// Bottom tab bar porcelaine, liseré laiton supérieur fin,
/// icônes en trait fin, onglet actif souligné d'un point laiton.
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
      decoration: BoxDecoration(
        color: AppColors.porcelaine,
        border: Border(
          top:
              BorderSide(color: AppColors.laitonLisere(opacity: 0.3), width: 1),
        ),
      ),
      padding: EdgeInsets.only(
        top: 10,
        bottom: MediaQuery.of(context).padding.bottom + 8,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(_navItems.length, (i) {
          final item = _navItems[i];
          final active = i == currentIndex;
          final color =
              active ? AppColors.encre : AppColors.encre.withOpacity(0.4);
          return GestureDetector(
            onTap: () => onTap(i),
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(item.icon, size: 23, color: color),
                  const SizedBox(height: 4),
                  Text(item.label,
                      style: AppTextStyles.bodySmall(color: color)),
                  const SizedBox(height: 4),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 4,
                    height: 4,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color:
                          active ? AppColors.laitonBrosse : Colors.transparent,
                    ),
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
