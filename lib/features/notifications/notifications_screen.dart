import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/app_notification.dart';
import '../../providers/app_providers.dart';
import '../../widgets/components/components.dart';

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
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: Text('Notifications', style: AppTextStyles.displayMedium()),
        actions: [
          TextButton(
            onPressed: () =>
                ref.read(notificationsProvider.notifier).markAllRead(),
            child: Text('Tout marquer lu',
                style: AppTextStyles.bodySmall(color: AppColors.primary)),
          ),
        ],
      ),
      body: notifications.isEmpty
          ? const _EmptyNotifications()
          : RefreshIndicator(
              color: AppColors.primary,
              backgroundColor: AppColors.surfaceCard,
              onRefresh: () =>
                  Future.delayed(const Duration(milliseconds: 700)),
              child: ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                itemCount: notifications.length,
                separatorBuilder: (_, __) =>
                    const Divider(color: AppColors.border, height: 1),
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
                      color: AppColors.error,
                      child: const Icon(Icons.delete_outline,
                          color: Colors.white),
                    ),
                    child: ListTile(
                      onTap: () => ref
                          .read(notificationsProvider.notifier)
                          .markRead(n.id),
                      contentPadding: EdgeInsets.zero,
                      leading: Container(
                        width: 38,
                        height: 38,
                        alignment: Alignment.center,
                        decoration: const BoxDecoration(
                          color: AppColors.surfaceMuted,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(_iconFor(n.kind),
                            color: AppColors.primary, size: 18),
                      ),
                      title: Text(n.restaurantName,
                          style: AppTextStyles.bodySmall(
                              color: AppColors.inkMuted(opacity: 0.5))),
                      subtitle: Text(
                        n.message,
                        style: AppTextStyles.bodyMedium(
                          color: n.isRead
                              ? AppColors.inkMuted(opacity: 0.6)
                              : AppColors.ink,
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
                                color: AppColors.primary,
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
    return const Center(
      child: EmptyState(
        icon: Icons.notifications_none_rounded,
        title: 'Aucune notification',
        message:
            'Vous serez prévenu ici de vos tampons, récompenses et statuts VIP.',
      ),
    );
  }
}
