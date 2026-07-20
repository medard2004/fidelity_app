import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/app_notification.dart';
import '../../providers/app_providers.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  IconData _iconFor(NotificationKind k) {
    switch (k) {
      case NotificationKind.reward:
        return Icons.card_giftcard_outlined;
      case NotificationKind.stamp:
        return Icons.circle_outlined;
      case NotificationKind.points:
        return Icons.star_outline;
      case NotificationKind.cashback:
        return Icons.savings_outlined;
      case NotificationKind.vip:
        return Icons.diamond_outlined;
      case NotificationKind.referral:
        return Icons.people_outline;
      case NotificationKind.system:
        return Icons.info_outline;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifications = ref.watch(notificationsProvider);

    return Scaffold(
      backgroundColor: AppColors.porcelaine,
      appBar: AppBar(
        title: Text('Notifications', style: AppTextStyles.displayMedium()),
        actions: [
          TextButton(
            onPressed: () => ref.read(notificationsProvider.notifier).markAllRead(),
            child: Text('Tout marquer lu',
                style: AppTextStyles.bodySmall(color: AppColors.vertBouteille)),
          ),
        ],
      ),
      body: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        itemCount: notifications.length,
        separatorBuilder: (_, __) => Divider(color: AppColors.saugePale, height: 1),
        itemBuilder: (context, i) {
          final n = notifications[i];
          return ListTile(
            onTap: () => ref.read(notificationsProvider.notifier).markRead(n.id),
            contentPadding: EdgeInsets.zero,
            leading: Icon(_iconFor(n.kind), color: AppColors.laitonBrosse, size: 20),
            title: Text(n.restaurantName,
                style: AppTextStyles.bodySmall(color: AppColors.encre.withOpacity(0.5))),
            subtitle: Text(
              n.message,
              style: AppTextStyles.bodyMedium(
                color: n.isRead ? AppColors.encre.withOpacity(0.6) : AppColors.encre,
              ),
            ),
            trailing: Text(n.relativeTime, style: AppTextStyles.monoSmall()),
          );
        },
      ),
    );
  }
}
