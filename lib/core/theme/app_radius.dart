/// Rayons d'arrondi — généreux et cohérents, dans l'esprit
/// Wallet/Revolut/Stripe (jamais des coins pointus, jamais un
/// arrondi disparate d'un composant à l'autre).
class AppRadius {
  AppRadius._();

  static const double chip = 8;
  static const double input = 12;
  static const double button = 12;
  static const double card = 20;
  static const double sheet = 28;
  static const double pill = 999;
}

/// Espacements — échelle constante utilisée partout dans l'app.
class AppSpacing {
  AppSpacing._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;
}
