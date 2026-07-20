/// Coins arrondis mesurés — plus proches d'une carte bancaire réelle
/// que d'un bouton d'app mobile lambda.
class AppRadius {
  AppRadius._();

  static const double card = 17; // 16–18px
  static const double button = 12;
  static const double chip = 10;
  static const double input = 10;
  static const double sheet = 24;
}

/// Espacements — beaucoup de respiration, on n'a pas peur du vide.
class AppSpacing {
  AppSpacing._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;
}
