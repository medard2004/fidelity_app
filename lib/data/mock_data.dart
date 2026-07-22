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
        firstName: 'Amina',
        phoneNumber: '+228 90 12 34 56',
        birthDate: DateTime(1996, 4, 18),
        email: 'amina@example.com',
        referralCode: 'AMINA-2839',
        friendsInvited: 3,
        friendsJoined: 1,
      );

  static List<LoyaltyCard> get cards => [
        const LoyaltyCard(
          id: 'card_comptoir',
          restaurantName: 'Bistrot de Quartier',
          restaurantCategory: 'BISTROT DE QUARTIER',
          mechanic: LoyaltyMechanic.stamps,
          liningColor: Color(0xFFEAE5D9),
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
          liningColor: Color(0xFFE3E0CE),
          pointsBalance: 1240,
          fallbackId: 'PAL-40217',
          welcomeOffer: '100 points offerts à l\'inscription',
        ),
        const LoyaltyCard(
          id: 'card_sunset',
          restaurantName: 'Sunset Lounge',
          restaurantCategory: 'ROOFTOP & COCKTAILS',
          mechanic: LoyaltyMechanic.cashback,
          liningColor: Color(0xFF1E3B2F),
          cashbackBalanceFcfa: 3400,
          fallbackId: 'SUN-28392',
          welcomeOffer: '500 FCFA de cashback offerts',
        ),
        const LoyaltyCard(
          id: 'card_macbouffe',
          restaurantName: 'Mac Bouffe',
          restaurantCategory: 'CUISINE DU MONDE',
          mechanic: LoyaltyMechanic.vip,
          liningColor: Color(0xFF421A1E),
          vipTier: VipTier.gold,
          vipProgressToNextTier: 0.65,
          fallbackId: 'MAC-90014',
          welcomeOffer: 'Statut Gold offert dès l\'inscription',
        ),
      ];

  static List<Reward> get rewards => [
        Reward(
          id: 'rw1',
          cardId: 'card_sunset',
          restaurantName: 'Sunset Lounge',
          title: 'Cocktail signature',
          description: 'Le Sunset Old Fashioned',
          status: RewardStatus.locked,
          lockedCondition: '5 000 FCFA de cashback',
        ),
        Reward(
          id: 'rw2',
          cardId: 'card_palais',
          restaurantName: 'Le Palais',
          title: 'Coupe de champagne',
          description: 'Pour deux personnes',
          status: RewardStatus.active,
          expiresAt: DateTime.now().add(const Duration(days: 21)),
        ),
        Reward(
          id: 'rw3',
          cardId: 'card_macbouffe',
          restaurantName: 'Mac Bouffe',
          title: 'Accès table Chef',
          description: 'Menu dégustation privé',
          status: RewardStatus.locked,
          lockedCondition: 'Statut Platinum',
        ),
        Reward(
          id: 'rw4',
          cardId: 'card_comptoir',
          restaurantName: 'Bistrot de Quartier',
          title: 'Café gourmand',
          description: 'Au choix avec votre dessert',
          status: RewardStatus.active,
          expiresAt: DateTime.now().add(const Duration(days: 7)),
        ),
      ];

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
