import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/mock_data.dart';
import '../models/reward.dart';
import '../models/app_notification.dart';
import '../models/user.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Récompenses
// ─────────────────────────────────────────────────────────────────────────────

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

// ─────────────────────────────────────────────────────────────────────────────
// Notifications
// ─────────────────────────────────────────────────────────────────────────────

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

// ─────────────────────────────────────────────────────────────────────────────
// Données en cours de saisie pendant l'inscription (flow temporaire)
// ─────────────────────────────────────────────────────────────────────────────

/// Données collectées en cours d'inscription, portées entre les écrans.
class SignupFlowData {
  final String fullName;
  final int? age;
  final String phone;
  final AuthProvider provider;
  final DateTime? birthDate;

  const SignupFlowData({
    this.fullName = '',
    this.age,
    this.phone = '',
    this.provider = AuthProvider.phone,
    this.birthDate,
  });

  SignupFlowData copyWith({
    String? fullName,
    int? age,
    String? phone,
    AuthProvider? provider,
    DateTime? birthDate,
  }) =>
      SignupFlowData(
        fullName: fullName ?? this.fullName,
        age: age ?? this.age,
        phone: phone ?? this.phone,
        provider: provider ?? this.provider,
        birthDate: birthDate ?? this.birthDate,
      );
}

class SignupFlowNotifier extends StateNotifier<SignupFlowData> {
  SignupFlowNotifier() : super(const SignupFlowData());

  void startPhoneSignup({
    required String fullName,
    required String phone,
    DateTime? birthDate,
    int? age,
  }) {
    final calculatedAge = age ??
        (birthDate != null ? (DateTime.now().difference(birthDate).inDays ~/ 365) : null);
    state = SignupFlowData(
      fullName: fullName,
      age: calculatedAge,
      phone: phone,
      birthDate: birthDate,
      provider: AuthProvider.phone,
    );
  }

  void startSocialSignup({required AuthProvider provider}) {
    state = SignupFlowData(provider: provider);
  }

  void setSocialDetails({
    required String fullName,
    required String phone,
    DateTime? birthDate,
  }) {
    state = state.copyWith(
      fullName: fullName,
      phone: phone,
      birthDate: birthDate,
    );
  }

  void reset() => state = const SignupFlowData();
}

final signupFlowProvider =
    StateNotifierProvider<SignupFlowNotifier, SignupFlowData>(
  (ref) => SignupFlowNotifier(),
);

// ─────────────────────────────────────────────────────────────────────────────
// Utilisateur / Auth
// ─────────────────────────────────────────────────────────────────────────────

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

  // ── Connexion par téléphone (OTP validé) ──────────────────────────────────

  /// Connexion classique : crée la session avec le numéro de téléphone.
  void completeLogin({String phone = ''}) {
    state = AuthState(
      isAuthenticated: true,
      user: MockData.user.copyWith(phoneNumber: phone.isNotEmpty ? phone : null),
    );
  }

  /// Rétro-compatibilité : utilisé par OtpScreen en mode connexion simple.
  void completeOtp() => completeLogin();

  // ── Inscription par téléphone ──────────────────────────────────────────────

  /// Crée le compte après validation OTP lors d'une inscription par téléphone.
  void completeSignupOtp(SignupFlowData flow) {
    state = AuthState(
      isAuthenticated: true,
      user: AppUser(
        id: 'u_${DateTime.now().millisecondsSinceEpoch}',
        fullName: flow.fullName,
        phoneNumber: flow.phone,
        birthDate: flow.birthDate,
        age: flow.age,
        joinDate: DateTime.now(),
        referralCode: _generateReferralCode(flow.fullName),
        authProvider: AuthProvider.phone,
        profileCompleted: false,
      ),
    );
  }

  // ── Connexion/Inscription sociale ──────────────────────────────────────────

  /// Connexion sociale (Google/Apple) — crée une session partielle,
  /// le profil doit être complété avant d'accéder au wallet.
  void completeSocialLogin(AuthProvider provider) {
    state = AuthState(
      isAuthenticated: true,
      user: AppUser(
        id: 'u_social_${DateTime.now().millisecondsSinceEpoch}',
        fullName: '',
        phoneNumber: '',
        joinDate: DateTime.now(),
        referralCode: '',
        authProvider: provider,
        profileCompleted: false,
      ),
    );
  }

  // ── Complétion du profil ───────────────────────────────────────────────────

  /// Complète le profil post-inscription téléphone (Ville + Quartier + Email).
  void completeProfile({
    String? city,
    String? neighborhood,
    String? email,
  }) {
    if (state.user == null) return;
    state = state.copyWith(
      user: state.user!.copyWith(
        city: city,
        neighborhood: neighborhood,
        email: email,
        profileCompleted: true,
      ),
    );
  }

  /// Complète le profil post-connexion sociale (Nom + Téléphone + Birthdate + Ville + …).
  void completeSocialProfile({
    required String fullName,
    required String phone,
    DateTime? birthDate,
    String? city,
    String? neighborhood,
    String? email,
  }) {
    if (state.user == null) return;
    final code = _generateReferralCode(fullName);
    state = state.copyWith(
      user: state.user!.copyWith(
        fullName: fullName,
        phoneNumber: phone,
        birthDate: birthDate,
        city: city,
        neighborhood: neighborhood,
        email: email,
        profileCompleted: true,
      ).copyWith(
        // referralCode ne peut pas être changé via copyWith standard ; on le sette ici via reconstruction.
      ),
    );
    // Reconstruire avec le referralCode si vide.
    if (state.user!.referralCode.isEmpty) {
      state = state.copyWith(
        user: AppUser(
          id: state.user!.id,
          fullName: fullName,
          phoneNumber: phone,
          birthDate: birthDate,
          joinDate: state.user!.joinDate,
          city: city,
          neighborhood: neighborhood,
          email: email,
          referralCode: code,
          authProvider: state.user!.authProvider,
          profileCompleted: true,
        ),
      );
    }
  }

  // ── Misc ──────────────────────────────────────────────────────────────────

  void updateProfile({String? firstName, String? email}) {
    if (state.user == null) return;
    state = state.copyWith(
      user: state.user!.copyWith(fullName: firstName, email: email),
    );
  }

  void updateFullProfile({
    String? fullName,
    String? phoneNumber,
    DateTime? birthDate,
    String? email,
  }) {
    if (state.user == null) return;
    state = state.copyWith(
      user: state.user!.copyWith(
        fullName: fullName,
        phoneNumber: phoneNumber,
        birthDate: birthDate,
        email: email,
        profileCompleted: true,
      ),
    );
  }

  void signOut() => state = const AuthState();

  // ── Helpers privés ────────────────────────────────────────────────────────

  String _generateReferralCode(String fullName) {
    final base = fullName.trim().split(' ').first.toUpperCase();
    final suffix = (DateTime.now().millisecondsSinceEpoch % 10000).toString();
    return '${base.length >= 4 ? base.substring(0, 4) : base}-$suffix';
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>(
  (ref) => AuthNotifier(),
);
