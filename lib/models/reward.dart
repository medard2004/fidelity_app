enum RewardStatus { active, locked, used }

class Reward {
  final String id;
  final String cardId;
  final String restaurantName;
  final String title;
  final String description;
  final RewardStatus status;

  /// Condition restante si verrouillée, ex. "Encore 3 sceaux".
  final String? lockedCondition;

  /// Date d'expiration si la récompense est à durée limitée.
  final DateTime? expiresAt;

  final DateTime? usedAt;

  const Reward({
    required this.id,
    required this.cardId,
    required this.restaurantName,
    required this.title,
    required this.description,
    required this.status,
    this.lockedCondition,
    this.expiresAt,
    this.usedAt,
  });

  bool get isExpiringSoon =>
      expiresAt != null && expiresAt!.difference(DateTime.now()).inHours < 48;
}
