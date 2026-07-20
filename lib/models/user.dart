class AppUser {
  final String id;
  final String firstName;
  final String phoneNumber;
  final DateTime? birthDate;
  final String? email;
  final String? photoUrl;
  final String referralCode;
  final int friendsInvited;
  final int friendsJoined;

  const AppUser({
    required this.id,
    required this.firstName,
    required this.phoneNumber,
    this.birthDate,
    this.email,
    this.photoUrl,
    required this.referralCode,
    this.friendsInvited = 0,
    this.friendsJoined = 0,
  });

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

  AppUser copyWith({
    String? firstName,
    String? email,
    String? photoUrl,
  }) {
    return AppUser(
      id: id,
      firstName: firstName ?? this.firstName,
      phoneNumber: phoneNumber,
      birthDate: birthDate,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      referralCode: referralCode,
      friendsInvited: friendsInvited,
      friendsJoined: friendsJoined,
    );
  }
}
