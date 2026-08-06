import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_shadows.dart';
import '../components/app_tap_scale.dart';

/// Bouton de notification standard des pages racines — remplace les
/// trois variantes légèrement différentes (forme, badge) qui existaient
/// sur Wallet, Récompenses et Profil.
class NotificationBellButton extends StatelessWidget {
  final int unreadCount;

  const NotificationBellButton({super.key, required this.unreadCount});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: unreadCount > 0
          ? 'Notifications, $unreadCount non lues'
          : 'Notifications',
      child: AppTapScale(
        onTap: () => context.push('/notifications'),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 44,
              height: 44,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.surfaceCard,
                shape: BoxShape.circle,
                boxShadow: AppShadows.resting,
              ),
              child: Icon(LucideIcons.bell, color: AppColors.ink, size: 20),
            ),
            if (unreadCount > 0)
              Positioned(
                top: 2,
                right: 2,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: AppColors.error,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '$unreadCount',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
