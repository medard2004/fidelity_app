import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/mock_data.dart';
import '../models/reward.dart';
import '../models/app_notification.dart';
import '../models/user.dart';
import '../api/repositories/auth_repository.dart';
import '../api/providers/api_providers.dart';

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
  final String email;
  final AuthProvider provider;
  final DateTime? birthDate;

  const SignupFlowData({
    this.fullName = '',
    this.age,
    this.phone = '',
    this.email = '',
    this.provider = AuthProvider.phone,
    this.birthDate,
  });

  SignupFlowData copyWith({
    String? fullName,
    int? age,
    String? phone,
    String? email,
    AuthProvider? provider,
    DateTime? birthDate,
  }) =>
      SignupFlowData(
        fullName: fullName ?? this.fullName,
        age: age ?? this.age,
        phone: phone ?? this.phone,
        email: email ?? this.email,
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
        (birthDate != null
            ? (DateTime.now().difference(birthDate).inDays ~/ 365)
            : null);
    state = SignupFlowData(
      fullName: fullName,
      age: calculatedAge,
      phone: phone,
      birthDate: birthDate,
      provider: AuthProvider.phone,
    );
  }

  void startSocialSignup(
      {required AuthProvider provider,
      String fullName = '',
      String email = ''}) {
    state =
        SignupFlowData(provider: provider, fullName: fullName, email: email);
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

  /// Dernière erreur brute survenue, conservée telle quelle.
  ///
  /// Le notifier ne formule volontairement aucun message : seul l'écran connaît
  /// son contexte (une même erreur ne se dit pas pareil à la connexion et sur
  /// le profil) et sait si elle concerne un champ précis. L'écran la traduit
  /// via `FormErrorHandler.handleError`.
  final Object? lastError;

  const AuthState({
    this.isAuthenticated = false,
    this.user,
    this.lastError,
  });

  AuthState copyWith({
    bool? isAuthenticated,
    AppUser? user,
    Object? lastError,
    bool clearError = false,
  }) =>
      AuthState(
        isAuthenticated: isAuthenticated ?? this.isAuthenticated,
        user: user ?? this.user,
        lastError: clearError ? null : (lastError ?? this.lastError),
      );
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _authRepository;

  AuthNotifier(this._authRepository) : super(const AuthState());

  // ── Session ───────────────────────────────────────────────────────────────

  void setAuthenticated(AppUser user) {
    state = AuthState(
      isAuthenticated: true,
      user: user,
    );
  }

  // ── Connexion par téléphone (API) ─────────────────────────────────────────

  Future<bool> login(String phone, String password) async {
    state = state.copyWith(clearError: true);
    try {
      final user = await _authRepository.login(phone, password);
      state = AuthState(
        isAuthenticated: true,
        user: user,
      );
      return true;
    } catch (e) {
      state = state.copyWith(lastError: e);
      return false;
    }
  }

  Future<bool> validateRegisterStep1(SignupFlowData flow) async {
    state = state.copyWith(clearError: true);
    try {
      final data = {
        'first_name': flow.fullName,
        'phone': flow.phone,
        if (flow.birthDate != null)
          'birthdate': flow.birthDate!.toIso8601String().split('T')[0],
      };
      await _authRepository.validateRegisterStep1(data);
      return true;
    } catch (e) {
      state = state.copyWith(lastError: e);
      return false;
    }
  }

  // ── Inscription par téléphone (API) ────────────────────────────────────────

  Future<bool> register(SignupFlowData flow, String password) async {
    state = state.copyWith(clearError: true);
    try {
      final data = {
        'first_name': flow.fullName,
        'phone': flow.phone,
        'password': password,
        'password_confirmation': password,
        if (flow.birthDate != null)
          'birthdate': flow.birthDate!.toIso8601String().split('T')[0],
      };
      final user = await _authRepository.register(data);
      state = AuthState(
        isAuthenticated: true,
        user: user,
      );
      return true;
    } catch (e) {
      state = state.copyWith(lastError: e);
      return false;
    }
  }

  // ── Password Recovery ──────────────────────────────────────────────────────

  Future<bool> forgotPassword(String identifier) async {
    state = state.copyWith(clearError: true);
    try {
      await _authRepository.forgotPassword(identifier);
      // We don't store the message in state, the UI will show success
      return true;
    } catch (e) {
      state = state.copyWith(lastError: e);
      return false;
    }
  }

  Future<String?> verifyResetOtp(String identifier, String otp) async {
    state = state.copyWith(clearError: true);
    try {
      final token = await _authRepository.verifyResetOtp(identifier, otp);
      return token;
    } catch (e) {
      state = state.copyWith(lastError: e);
      return null;
    }
  }

  Future<bool> resetPassword(
      String identifier, String token, String password) async {
    state = state.copyWith(clearError: true);
    try {
      await _authRepository.resetPassword(identifier, token, password);
      return true;
    } catch (e) {
      state = state.copyWith(lastError: e);
      return false;
    }
  }

  // ── Connexion/Inscription sociale ──────────────────────────────────────────

  /// Connexion sociale (Google/Apple) — retourne true si la connexion est réussie.
  /// Le booléen 'needsProfileCompletion' indique si l'utilisateur doit compléter son profil.
  Future<Map<String, dynamic>> socialLogin(
      AuthProvider provider, String idToken,
      {String action = 'login'}) async {
    state = state.copyWith(clearError: true);
    try {
      final String providerString =
          provider == AuthProvider.google ? 'google' : 'apple';
      final response = await _authRepository
          .socialLogin(providerString, idToken, action: action);

      final client = response['client'] as AppUser;
      final needsCompletion = response['needs_profile_completion'] as bool;

      state = AuthState(
        isAuthenticated: true,
        user: client,
      );

      return {
        'success': true,
        'needs_profile_completion': needsCompletion,
        'client': client,
      };
    } catch (e) {
      state = state.copyWith(lastError: e);
      return {'success': false};
    }
  }

  // ── Complétion du profil ───────────────────────────────────────────────────

  /// Complète le profil post-inscription téléphone (Ville + Quartier + Email).
  void completeProfile({
    String? city,
    String? country,
    String? neighborhood,
    String? email,
  }) {
    if (state.user == null) return;
    state = state.copyWith(
      user: state.user!.copyWith(
        city: city,
        country: country,
        neighborhood: neighborhood,
        email: email,
        profileCompleted: true,
      ),
    );
  }

  /// Complète le profil post-connexion sociale (Nom + Téléphone + Birthdate + Ville + …).
  Future<bool> completeSocialProfile({
    required String fullName,
    required String phone,
    DateTime? birthDate,
    String? city,
    String? country,
    String? neighborhood,
    String? email,
  }) async {
    state = state.copyWith(clearError: true);
    try {
      final data = {
        'first_name': fullName,
        'phone': phone,
        if (birthDate != null)
          'birthdate': birthDate.toIso8601String().split('T')[0],
        if (city != null) 'city': city,
        if (country != null) 'country': country,
        if (neighborhood != null) 'neighborhood': neighborhood,
        if (email != null) 'email': email,
      };

      final user = await _authRepository.completeSocialProfile(data);
      state = AuthState(
        isAuthenticated: true,
        user: user,
      );
      return true;
    } catch (e) {
      state = state.copyWith(lastError: e);
      return false;
    }
  }

  // ── Verify / Change Password (authenticated) ──────────────────────────────

  Future<bool> verifyPassword(String currentPassword) async {
    state = state.copyWith(clearError: true);
    try {
      final valid = await _authRepository.verifyPassword(currentPassword);
      return valid;
    } catch (e) {
      state = state.copyWith(lastError: e);
      return false;
    }
  }

  Future<bool> changePassword(
      String currentPassword, String newPassword) async {
    state = state.copyWith(clearError: true);
    try {
      await _authRepository.changePassword(currentPassword, newPassword);
      return true;
    } catch (e) {
      state = state.copyWith(lastError: e);
      return false;
    }
  }

  // ── Misc ──────────────────────────────────────────────────────────────────

  void updateProfile({String? firstName, String? email}) {
    if (state.user == null) return;
    state = state.copyWith(
      user: state.user!.copyWith(fullName: firstName, email: email),
    );
  }

  Future<void> updateFullProfile({
    String? fullName,
    String? phoneNumber,
    DateTime? birthDate,
    String? email,
    String? city,
    String? country,
  }) async {
    if (state.user == null) return;

    // Snapshot avant mise à jour optimiste (pour rollback en cas d'échec).
    final previousUser = state.user!;

    // Optimistic UI update
    state = state.copyWith(
      user: state.user!.copyWith(
        fullName: fullName,
        phoneNumber: phoneNumber,
        birthDate: birthDate,
        email: email,
        city: city,
        country: country,
        profileCompleted: true,
      ),
    );

    try {
      // Séparation first_name / last_name pour l'API si fullName est fourni
      String? firstName;
      String? lastName;
      if (fullName != null) {
        final parts = fullName.trim().split(' ');
        firstName = parts.first;
        lastName = parts.skip(1).join(' ');
      }

      final data = <String, dynamic>{};
      if (firstName != null) data['first_name'] = firstName;
      if (lastName != null) data['last_name'] = lastName;
      if (phoneNumber != null) data['phone'] = phoneNumber;
      if (email != null) data['email'] = email;
      if (city != null) data['city'] = city;
      if (country != null) data['country'] = country;
      if (birthDate != null)
        data['birthdate'] = birthDate.toIso8601String().split('T')[0];

      if (data.isNotEmpty) {
        final updatedUser = await _authRepository.updateProfile(data);
        state = state.copyWith(user: updatedUser);
      }
    } catch (e) {
      // Rollback : restaurer l'état précédent pour ne pas afficher de données
      // non persistées en base.
      state = state.copyWith(user: previousUser, lastError: e);
      rethrow;
    }
  }

  Future<void> signOut() async {
    state = state.copyWith(clearError: true);
    try {
      await _authRepository.logout();
    } catch (_) {
      // Ignorer l'erreur d'API (ex: NetworkException ou 401)
      // car on force la déconnexion locale dans le finally.
    } finally {
      state = const AuthState();
    }
  }

  void clearError() {
    if (state.lastError != null) {
      state = state.copyWith(clearError: true);
    }
  }

  // ── Helpers privés ────────────────────────────────────────────────────────

  String _generateReferralCode(String fullName) {
    final base = fullName.trim().split(' ').first.toUpperCase();
    final suffix = (DateTime.now().millisecondsSinceEpoch % 10000).toString();
    return '${base.length >= 4 ? base.substring(0, 4) : base}-$suffix';
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return AuthNotifier(authRepository);
});
