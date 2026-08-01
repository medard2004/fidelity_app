import 'package:intl/intl.dart';

/// Méthode d'authentification utilisée lors de l'inscription.
enum AuthProvider { phone, google, apple }

class AppUser {
  final String id;
  final String fullName;
  final String phoneNumber;
  final int? age;
  final DateTime? birthDate;
  final DateTime joinDate;
  final String? email;
  final String? photoUrl;
  final String referralCode;
  final int friendsInvited;
  final int friendsJoined;
  final String? city;
  final String? neighborhood;
  final AuthProvider authProvider;
  final bool profileCompleted;

  const AppUser({
    required this.id,
    required this.fullName,
    required this.phoneNumber,
    this.age,
    this.birthDate,
    required this.joinDate,
    this.email,
    this.photoUrl,
    required this.referralCode,
    this.friendsInvited = 0,
    this.friendsJoined = 0,
    this.city,
    this.neighborhood,
    this.authProvider = AuthProvider.phone,
    this.profileCompleted = false,
  });

  /// Rétro-compatibilité : expose `firstName` comme premier prénom (avant le premier espace).
  String get firstName {
    final parts = fullName.trim().split(' ');
    return parts.isNotEmpty ? parts.first : fullName;
  }

  /// Numéro masqué partiellement pour l'écran Profil, ex. "+228 •• •• 45 12".
  String get maskedPhoneNumber {
    if (phoneNumber.length < 4) return phoneNumber;
    final visibleEnd = phoneNumber.substring(phoneNumber.length - 4);
    final prefix = phoneNumber.substring(0, phoneNumber.length - 8 > 0 ? 4 : 0);
    return '$prefix •• •• $visibleEnd';
  }

  /// Vrai si l'anniversaire tombe dans le mois en cours (bloc anniversaire).
  bool get isBirthdayMonth {
    if (birthDate == null) return false;
    return birthDate!.month == DateTime.now().month;
  }

  /// Vrai si cet utilisateur s'est connecté via un fournisseur social.
  bool get isSocialUser =>
      authProvider == AuthProvider.google || authProvider == AuthProvider.apple;

  /// Texte de membre depuis la date d'inscription.
  String get memberSince {
    const locale = 'fr_FR';
    return 'Depuis ${DateFormat('MMMM yyyy', locale).format(joinDate)}';
  }

  AppUser copyWith({
    String? fullName,
    String? firstName,
    String? phoneNumber,
    int? age,
    DateTime? birthDate,
    DateTime? joinDate,
    String? email,
    String? photoUrl,
    String? city,
    String? neighborhood,
    AuthProvider? authProvider,
    bool? profileCompleted,
  }) {
    return AppUser(
      id: id,
      // Si `fullName` est fourni, on le prend directement.
      // Si seulement `firstName` est fourni (compatibilité), on substitue.
      fullName: fullName ??
          (firstName != null
              ? '$firstName ${this.fullName.split(' ').skip(1).join(' ')}'
                  .trim()
              : this.fullName),
      phoneNumber: phoneNumber ?? this.phoneNumber,
      age: age ?? this.age,
      birthDate: birthDate ?? this.birthDate,
      joinDate: joinDate ?? this.joinDate,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      referralCode: referralCode,
      friendsInvited: friendsInvited,
      friendsJoined: friendsJoined,
      city: city ?? this.city,
      neighborhood: neighborhood ?? this.neighborhood,
      authProvider: authProvider ?? this.authProvider,
      profileCompleted: profileCompleted ?? this.profileCompleted,
    );
  }
}
