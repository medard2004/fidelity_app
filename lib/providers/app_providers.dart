import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/mock_data.dart';
import '../models/reward.dart';
import '../models/app_notification.dart';
import '../models/user.dart';

// --- Récompenses ---

class RewardsNotifier extends StateNotifier<List<Reward>> {
  RewardsNotifier() : super(MockData.rewards);

  List<Reward> get active =>
      state.where((r) => r.status == RewardStatus.active).toList();
  List<Reward> get locked =>
      state.where((r) => r.status == RewardStatus.locked).toList();
  List<Reward> get used =>
      state.where((r) => r.status == RewardStatus.used).toList();

  List<Reward> forCard(String cardId) =>
      state.where((r) => r.cardId == cardId).toList();
}

final rewardsProvider = StateNotifierProvider<RewardsNotifier, List<Reward>>(
  (ref) => RewardsNotifier(),
);

// --- Notifications ---

class NotificationsNotifier extends StateNotifier<List<AppNotification>> {
  NotificationsNotifier() : super(MockData.notifications);

  int get unreadCount => state.where((n) => !n.isRead).length;

  void markAllRead() {
    state = [for (final n in state) n.copyWith(isRead: true)];
  }

  void markRead(String id) {
    state = [
      for (final n in state)
        if (n.id == id) n.copyWith(isRead: true) else n,
    ];
  }
}

final notificationsProvider =
    StateNotifierProvider<NotificationsNotifier, List<AppNotification>>(
  (ref) => NotificationsNotifier(),
);

// --- Utilisateur / Auth ---

class AuthState {
  final bool isAuthenticated;
  final AppUser? user;
  const AuthState({this.isAuthenticated = false, this.user});

  AuthState copyWith({bool? isAuthenticated, AppUser? user}) => AuthState(
        isAuthenticated: isAuthenticated ?? this.isAuthenticated,
        user: user ?? this.user,
      );
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState());

  void completeOtp() {
    state = AuthState(isAuthenticated: true, user: MockData.user);
  }

  void updateProfile({String? firstName, String? email}) {
    if (state.user == null) return;
    state = state.copyWith(
      user: state.user!.copyWith(firstName: firstName, email: email),
    );
  }

  void signOut() {
    state = const AuthState();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>(
  (ref) => AuthNotifier(),
);
