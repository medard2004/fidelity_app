import '../core/theme/app_colors.dart';
import '../models/loyalty_card.dart';
import '../models/reward.dart';
import '../models/app_notification.dart';
import '../models/user.dart';

class MockData {
  MockData._();

  static AppUser get user => AppUser(
        id: 'u1',
        fullName: 'Amina Kokou',
        phoneNumber: '+228 90 12 34 56',
        birthDate: DateTime(1996, 4, 18),
        joinDate: DateTime(2024, 3, 1),
        email: 'amina@example.com',
        referralCode: 'AMINA-2839',
        friendsInvited: 3,
        friendsJoined: 1,
        city: 'Lomé',
        neighborhood: 'Bè',
        authProvider: AuthProvider.phone,
        profileCompleted: true,
      );

  static List<LoyaltyCard> get cards => [
        const LoyaltyCard(
          id: 'card_comptoir',
          restaurantName: 'Bistrot de Quartier',
          restaurantCategory: 'BISTROT DE QUARTIER',
          mechanic: LoyaltyMechanic.stamps,
          liningColor: AppColors.liningTerracotta,
          stampsCurrent: 5,
          stampsGoal: 8,
          fallbackId: 'COM-11829',
          welcomeOffer: 'Un café offert pour votre première visite',
        ),
        const LoyaltyCard(
          id: 'card_palais',
          restaurantName: 'Le Palais',
          restaurantCategory: 'TABLE GASTRONOMIQUE',
          mechanic: LoyaltyMechanic.points,
          liningColor: AppColors.liningIndigo,
          pointsBalance: 1240,
          fallbackId: 'PAL-40217',
          welcomeOffer: '100 points offerts à l\'inscription',
        ),
        const LoyaltyCard(
          id: 'card_sunset',
          restaurantName: 'Sunset Lounge',
          restaurantCategory: 'ROOFTOP & COCKTAILS',
          mechanic: LoyaltyMechanic.cashback,
          liningColor: AppColors.liningPlum,
          cashbackBalanceFcfa: 3400,
          fallbackId: 'SUN-28392',
          welcomeOffer: '500 FCFA de cashback offerts',
        ),
        const LoyaltyCard(
          id: 'card_macbouffe',
          restaurantName: 'Mac Bouffe',
          restaurantCategory: 'CUISINE DU MONDE',
          mechanic: LoyaltyMechanic.vip,
          liningColor: AppColors.liningVip,
          vipTier: VipTier.gold,
          vipProgressToNextTier: 0.65,
          fallbackId: 'MAC-90014',
          welcomeOffer: 'Statut Gold offert dès l\'inscription',
        ),
      ];

  static List<Reward> get rewards => [
        Reward(
          id: 'rw1',
          cardId: 'card_comptoir',
          restaurantName: 'LE COMPTOIR',
          title: 'Dessert offert',
          description: 'À votre prochaine visite',
          status: RewardStatus.active,
          expiresAt: DateTime.now().add(const Duration(days: 6)),
        ),
        Reward(
          id: 'rw2',
          cardId: 'card_palais',
          restaurantName: 'LE PALAIS',
          title: 'Coupe de champagne',
          description: 'Pour deux personnes',
          status: RewardStatus.active,
          expiresAt: DateTime.now().add(const Duration(days: 21)),
        ),
        const Reward(
          id: 'rw3',
          cardId: 'card_sunset',
          restaurantName: 'SUNSET LOUNGE',
          title: 'Cocktail signature',
          description: '5 000 FCFA de cashback',
          status: RewardStatus.locked,
          lockedCondition: '5 000 FCFA de cashback',
        ),
        const Reward(
          id: 'rw4',
          cardId: 'card_macbouffe',
          restaurantName: 'MAC BOUFFE',
          title: 'Accès table Chef',
          description: 'Statut Platinum',
          status: RewardStatus.locked,
          lockedCondition: 'Statut Platinum',
        ),
        Reward(
          id: 'rw5',
          cardId: 'card_comptoir',
          restaurantName: 'Le Comptoir',
          title: 'Café offert',
          description: 'Café offert',
          status: RewardStatus.used,
          usedAt: DateTime(2026, 9, 2),
        ),
        Reward(
          id: 'rw6',
          cardId: 'card_palais',
          restaurantName: 'Le Palais',
          title: 'Amuse-bouche du chef',
          description: 'Amuse-bouche du chef',
          status: RewardStatus.used,
          usedAt: DateTime(2026, 8, 20),
        ),
      ];

  /// Établissements partenaires "découvrables" via scan QR (pas encore dans
  /// le portefeuille de l'utilisateur). En l'absence de backend, la mise en
  /// correspondance code scanné → restaurant est simulée ici.
  static const List<LoyaltyCard> joinableRestaurants = [
    LoyaltyCard(
      id: 'card_jardin_dore',
      restaurantName: 'Le Jardin Doré',
      restaurantCategory: 'BRUNCH & PÂTISSERIE',
      mechanic: LoyaltyMechanic.stamps,
      liningColor: AppColors.liningEmerald,
      stampsCurrent: 1,
      stampsGoal: 8,
      fallbackId: 'JARDIN-2024',
      welcomeOffer: 'Un dessert offert à votre 3e visite',
    ),
  ];

  /// Recherche un établissement partenaire par code scanné/saisi
  /// (insensible à la casse et aux espaces).
  static LoyaltyCard? findJoinableByCode(String rawCode) {
    final normalized = rawCode.trim().toUpperCase();
    for (final card in joinableRestaurants) {
      if (card.fallbackId.toUpperCase() == normalized) return card;
    }
    return null;
  }

  static List<AppNotification> get notifications => [
        AppNotification(
          id: 'n1',
          restaurantName: 'Bistrot de Quartier',
          kind: NotificationKind.stamp,
          message: 'Nouveau sceau ajouté à votre carte',
          timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        ),
        AppNotification(
          id: 'n2',
          restaurantName: 'Sunset Lounge',
          kind: NotificationKind.reward,
          message: 'Votre cashback s\'élève à 3 400 FCFA',
          timestamp: DateTime.now().subtract(const Duration(hours: 6)),
        ),
        AppNotification(
          id: 'n3',
          restaurantName: 'Mac Bouffe',
          kind: NotificationKind.vip,
          message: 'Plus que 3 visites avant le statut Platinum',
          timestamp: DateTime.now().subtract(const Duration(days: 1)),
          isRead: true,
        ),
        AppNotification(
          id: 'n4',
          restaurantName: 'Digital Vision',
          kind: NotificationKind.referral,
          message: 'Un ami a rejoint grâce à votre code',
          timestamp: DateTime.now().subtract(const Duration(days: 3)),
          isRead: true,
        ),
      ];
}
