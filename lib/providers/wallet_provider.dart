import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/mock_data.dart';
import '../models/loyalty_card.dart';

class WalletNotifier extends AsyncNotifier<List<LoyaltyCard>> {
  @override
  FutureOr<List<LoyaltyCard>> build() {
    return MockData.cards;
  }

  LoyaltyCard? byId(String id) {
    final currentCards = state.valueOrNull;
    if (currentCards == null) return null;
    try {
      return currentCards.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Simule l'ajout d'une carte après un scan QR (onboarding).
  Future<void> joinRestaurant(LoyaltyCard card) async {
    final currentCards = state.valueOrNull ?? [];
    state = AsyncValue.data([card, ...currentCards]);
  }

  void reorder(int oldIndex, int newIndex) {
    final currentCards = state.valueOrNull;
    if (currentCards == null) return;

    if (oldIndex < 0 || oldIndex >= currentCards.length) return;
    if (newIndex < 0 || newIndex >= currentCards.length) return;
    if (oldIndex == newIndex) return;

    final list = List<LoyaltyCard>.from(currentCards);
    final item = list.removeAt(oldIndex);
    list.insert(newIndex, item);
    state = AsyncValue.data(list);
  }

  void addStamp(String cardId) {
    final currentCards = state.valueOrNull;
    if (currentCards == null) return;

    state = AsyncValue.data([
      for (final c in currentCards)
        if (c.id == cardId && c.mechanic == LoyaltyMechanic.stamps)
          LoyaltyCard(
            id: c.id,
            restaurantName: c.restaurantName,
            restaurantCategory: c.restaurantCategory,
            mechanic: c.mechanic,
            liningColor: c.liningColor,
            stampsCurrent: (c.stampsCurrent + 1).clamp(0, c.stampsGoal),
            stampsGoal: c.stampsGoal,
            fallbackId: c.fallbackId,
            welcomeOffer: c.welcomeOffer,
          )
        else
          c,
    ]);
  }
}

final walletProvider = AsyncNotifierProvider<WalletNotifier, List<LoyaltyCard>>(
  () => WalletNotifier(),
);

final selectedCardProvider = StateProvider<String?>((ref) => null);
