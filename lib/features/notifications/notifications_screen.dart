import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../l10n/gen/app_localizations.dart';
import '../../models/app_notification.dart';
import '../../providers/app_providers.dart';
import '../../providers/settings_provider.dart';
import '../../widgets/components/components.dart';
import '../../widgets/shared/app_detail_bar.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  IconData _iconFor(NotificationKind k) {
    switch (k) {
      case NotificationKind.reward:
        return LucideIcons.gift;
      case NotificationKind.stamp:
        return LucideIcons.circle;
      case NotificationKind.points:
        return LucideIcons.star;
      case NotificationKind.cashback:
        return LucideIcons.piggyBank;
      case NotificationKind.vip:
        return LucideIcons.gem;
      case NotificationKind.referral:
        return LucideIcons.users;
      case NotificationKind.system:
        return LucideIcons.info;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(themeModeProvider);
    final t = AppLocalizations.of(context)!;
    final notifications = ref.watch(notificationsProvider);

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppDetailBar(
        title: t.notificationsTitle,
        trailing: TextButton(
          onPressed: () =>
              ref.read(notificationsProvider.notifier).markAllRead(),
          child: Text(t.notificationsMarkAllRead,
              style: AppTextStyles.bodySmall(color: AppColors.primary)),
        ),
      ),
      body: notifications.isEmpty
          ? _EmptyNotifications(t: t)
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
                    Divider(color: AppColors.border, height: 1),
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
                      child:
                          const Icon(LucideIcons.trash2, color: Colors.white),
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
                        decoration: BoxDecoration(
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
  final AppLocalizations t;
  const _EmptyNotifications({required this.t});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: EmptyState(
        icon: LucideIcons.bell,
        title: t.notificationsEmptyTitle,
        message: t.notificationsEmptyMessage,
      ),
    );
  }
}
