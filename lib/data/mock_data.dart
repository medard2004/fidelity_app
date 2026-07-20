import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../models/loyalty_card.dart';
import '../models/reward.dart';
import '../models/app_notification.dart';
import '../models/user.dart';

class MockData {
  MockData._();

  static AppUser get user => AppUser(
        id: 'u1',
        firstName: 'Kokou',
        phoneNumber: '+228 90 12 34 56',
        birthDate: DateTime(1994, DateTime.now().month, 12),
        email: null,
        referralCode: 'KOKOU-2846',
        friendsInvited: 3,
        friendsJoined: 1,
      );

  static List<LoyaltyCard> get cards => [
        const LoyaltyCard(
          id: 'card_comptoir',
          restaurantName: 'Le Comptoir',
          restaurantCategory: 'Brasserie',
          mechanic: LoyaltyMechanic.stamps,
          liningColor: AppColors.doublureComptoir,
          stampsCurrent: 5,
          stampsGoal: 8,
          fallbackId: 'CMP-10422',
          welcomeOffer: 'Un café offert pour votre première visite',
        ),
        const LoyaltyCard(
          id: 'card_palais',
          restaurantName: 'Le Palais',
          restaurantCategory: 'Restaurant',
          mechanic: LoyaltyMechanic.points,
          liningColor: AppColors.doublurePalais,
          pointsBalance: 1240,
          fallbackId: 'PAL-77310',
          welcomeOffer: '100 points offerts à l\'inscription',
        ),
        const LoyaltyCard(
          id: 'card_sunset',
          restaurantName: 'Sunset Lounge',
          restaurantCategory: 'Lounge',
          mechanic: LoyaltyMechanic.cashback,
          liningColor: AppColors.doublureSunset,
          cashbackBalanceFcfa: 3400,
          fallbackId: 'SUN-28392',
          welcomeOffer: '500 FCFA de cashback offerts',
        ),
        LoyaltyCard(
          id: 'card_macbouffe',
          restaurantName: 'Mac Bouffe',
          restaurantCategory: 'Restaurant',
          mechanic: LoyaltyMechanic.vip,
          liningColor: AppColors.doublureMacBouffe,
          vipTier: VipTier.gold,
          vipProgressToNextTier: 0.62,
          fallbackId: 'MCB-50187',
          welcomeOffer: 'Statut Silver offert dès l\'inscription',
        ),
      ];

  static List<Reward> get rewards => [
        Reward(
          id: 'rw1',
          cardId: 'card_comptoir',
          restaurantName: 'Le Comptoir',
          title: 'Un café offert',
          description: 'Valable sur toute boisson chaude en salle.',
          status: RewardStatus.active,
          expiresAt: DateTime.now().add(const Duration(hours: 30)),
        ),
        Reward(
          id: 'rw2',
          cardId: 'card_sunset',
          restaurantName: 'Sunset Lounge',
          title: 'Cocktail signature offert',
          description: 'À partir de 3 400 FCFA de cashback cumulé.',
          status: RewardStatus.active,
        ),
        const Reward(
          id: 'rw3',
          cardId: 'card_comptoir',
          restaurantName: 'Le Comptoir',
          title: 'Dessert du jour offert',
          description: 'Débloqué au 8ème sceau.',
          status: RewardStatus.locked,
          lockedCondition: 'Encore 3 sceaux',
        ),
        Reward(
          id: 'rw4',
          cardId: 'card_palais',
          restaurantName: 'Le Palais',
          title: 'Entrée offerte',
          description: 'Utilisée le mois dernier.',
          status: RewardStatus.used,
          usedAt: DateTime.now().subtract(const Duration(days: 21)),
        ),
      ];

  static List<AppNotification> get notifications => [
        AppNotification(
          id: 'n1',
          restaurantName: 'Le Comptoir',
          kind: NotificationKind.stamp,
          message: 'Nouveau sceau ajouté à votre carte',
          timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        ),
        AppNotification(
          id: 'n2',
          restaurantName: 'Sunset Lounge',
          kind: NotificationKind.reward,
          message: 'Votre récompense est prête',
          timestamp: DateTime.now().subtract(const Duration(hours: 6)),
        ),
        AppNotification(
          id: 'n3',
          restaurantName: 'Mac Bouffe',
          kind: NotificationKind.vip,
          message: 'Vous approchez du palier Platinum',
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
