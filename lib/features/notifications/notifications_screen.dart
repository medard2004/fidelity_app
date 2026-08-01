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
            onPressed: () =>
                ref.read(notificationsProvider.notifier).markAllRead(),
            child: Text('Tout marquer lu',
                style: AppTextStyles.bodySmall(color: AppColors.vertBouteille)),
          ),
        ],
      ),
      body: notifications.isEmpty
          ? const _EmptyNotifications()
          : RefreshIndicator(
              color: AppColors.laitonBrosse,
              backgroundColor: AppColors.porcelaine,
              onRefresh: () =>
                  Future.delayed(const Duration(milliseconds: 700)),
              child: ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                itemCount: notifications.length,
                separatorBuilder: (_, __) =>
                    const Divider(color: AppColors.saugePale, height: 1),
                itemBuilder: (context, i) {
                  final n = notifications[i];
                  return Dismissible(
                    key: ValueKey(n.id),
                    direction: DismissDirection.endToStart,
                    onDismissed: (_) =>
                        ref.read(notificationsProvider.notifier).remove(n.id),
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      color: AppColors.bordeauxProfond.withValues(alpha: 0.85),
                      child: const Icon(Icons.delete_outline,
                          color: AppColors.porcelaine),
                    ),
                    child: ListTile(
                      onTap: () => ref
                          .read(notificationsProvider.notifier)
                          .markRead(n.id),
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(_iconFor(n.kind),
                          color: AppColors.laitonBrosse, size: 20),
                      title: Text(n.restaurantName,
                          style: AppTextStyles.bodySmall(
                              color: AppColors.encre.withValues(alpha: 0.5))),
                      subtitle: Text(
                        n.message,
                        style: AppTextStyles.bodyMedium(
                          color: n.isRead
                              ? AppColors.encre.withValues(alpha: 0.6)
                              : AppColors.encre,
                        ),
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(n.relativeTime,
                              style: AppTextStyles.monoSmall()),
                          if (!n.isRead) ...[
                            const SizedBox(height: 6),
                            Container(
                              width: 7,
                              height: 7,
                              decoration: const BoxDecoration(
                                color: AppColors.laitonBrosse,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}

class _EmptyNotifications extends StatelessWidget {
  const _EmptyNotifications();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.notifications_none_rounded,
                size: 40, color: AppColors.laitonBrosse),
            const SizedBox(height: 16),
            Text('Aucune notification', style: AppTextStyles.displayMedium()),
            const SizedBox(height: 8),
            Text(
              'Vous serez prévenu ici de vos tampons, récompenses et statuts VIP.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium(
                  color: AppColors.encre.withValues(alpha: 0.6)),
            ),
          ],
        ),
      ),
    );
  }
}
