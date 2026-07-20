enum NotificationKind { reward, stamp, points, cashback, vip, referral, system }

class AppNotification {
  final String id;
  final String restaurantName;
  final NotificationKind kind;
  final String message;
  final DateTime timestamp;
  final bool isRead;

  const AppNotification({
    required this.id,
    required this.restaurantName,
    required this.kind,
    required this.message,
    required this.timestamp,
    this.isRead = false,
  });

  /// Horodatage relatif, ex. "il y a 2h".
  String get relativeTime {
    final diff = DateTime.now().difference(timestamp);
    if (diff.inMinutes < 1) return "à l'instant";
    if (diff.inMinutes < 60) return 'il y a ${diff.inMinutes}min';
    if (diff.inHours < 24) return 'il y a ${diff.inHours}h';
    return 'il y a ${diff.inDays}j';
  }

  AppNotification copyWith({bool? isRead}) => AppNotification(
        id: id,
        restaurantName: restaurantName,
        kind: kind,
        message: message,
        timestamp: timestamp,
        isRead: isRead ?? this.isRead,
      );
}
