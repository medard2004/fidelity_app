import 'package:flutter/material.dart';

/// Mécanique de fidélité d'une carte.
enum LoyaltyMechanic { stamps, points, cashback, vip }

/// Palier VIP — Platinum réserve le Bordeaux profond.
enum VipTier { none, silver, gold, platinum }

class LoyaltyCard {
  final String id;
  final String restaurantName;
  final String restaurantCategory;
  final LoyaltyMechanic mechanic;

  /// Couleur de doublure désaturée empruntée à l'identité du restaurant.
  final Color liningColor;

  /// Tampons : progression actuelle / objectif.
  final int stampsCurrent;
  final int stampsGoal;

  /// Points : solde.
  final int pointsBalance;

  /// Cashback : solde en FCFA.
  final int cashbackBalanceFcfa;

  /// VIP : palier actuel.
  final VipTier vipTier;
  final double vipProgressToNextTier; // 0.0 à 1.0

  final String fallbackId; // ex. "SUN-28392"
  final String welcomeOffer;

  const LoyaltyCard({
    required this.id,
    required this.restaurantName,
    required this.restaurantCategory,
    required this.mechanic,
    required this.liningColor,
    this.stampsCurrent = 0,
    this.stampsGoal = 8,
    this.pointsBalance = 0,
    this.cashbackBalanceFcfa = 0,
    this.vipTier = VipTier.none,
    this.vipProgressToNextTier = 0,
    required this.fallbackId,
    this.welcomeOffer = '',
  });

  /// Résumé mono affiché sur la carte dans le wallet.
  String get quickStat {
    switch (mechanic) {
      case LoyaltyMechanic.stamps:
        return '$stampsCurrent / $stampsGoal SCEAUX';
      case LoyaltyMechanic.points:
        return '$pointsBalance PTS';
      case LoyaltyMechanic.cashback:
        return '$cashbackBalanceFcfa FCFA';
      case LoyaltyMechanic.vip:
        return vipTier.label.toUpperCase();
    }
  }
}

extension VipTierLabel on VipTier {
  String get label {
    switch (this) {
      case VipTier.none:
        return 'Membre';
      case VipTier.silver:
        return 'Silver';
      case VipTier.gold:
        return 'Gold';
      case VipTier.platinum:
        return 'Platinum';
    }
  }
}
