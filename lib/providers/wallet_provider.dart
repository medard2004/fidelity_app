import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/mock_data.dart';
import '../models/loyalty_card.dart';

class WalletNotifier extends StateNotifier<List<LoyaltyCard>> {
  WalletNotifier() : super(MockData.cards);

  LoyaltyCard? byId(String id) {
    try {
      return state.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Simule l'ajout d'une carte après un scan QR (onboarding).
  void joinRestaurant(LoyaltyCard card) {
    state = [card, ...state];
  }

  void reorder(int oldIndex, int newIndex) {
    if (oldIndex < 0 || oldIndex >= state.length) return;
    if (newIndex < 0 || newIndex >= state.length) return;
    if (oldIndex == newIndex) return;
    final list = List<LoyaltyCard>.from(state);
    final item = list.removeAt(oldIndex);
    list.insert(newIndex, item);
    state = list;
  }

  void addStamp(String cardId) {
    state = [
      for (final c in state)
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
    ];
  }
}

final walletProvider =
    StateNotifierProvider<WalletNotifier, List<LoyaltyCard>>(
  (ref) => WalletNotifier(),
);

final selectedCardProvider = StateProvider<String?>((ref) => null);
