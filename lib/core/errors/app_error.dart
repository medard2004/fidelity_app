/// Résultat normalisé d'une erreur, prêt à être affiché à l'utilisateur.
///
/// Toute erreur (backend, réseau, validation) est traduite en [AppError] par
/// `ErrorTranslator`. Deux canaux d'affichage, jamais les deux pour la même
/// cause :
///   * [fieldErrors]  → message affiché sous le champ concerné ;
///   * [generalMessage] → message affiché en Toast.
class AppError {
  /// Nom du champ (côté API : `phone`, `password`, `first_name`…) → message
  /// utilisateur déjà traduit.
  final Map<String, String> fieldErrors;

  /// Message général à présenter en Toast, `null` si tout est imputable à des
  /// champs précis.
  final String? generalMessage;

  const AppError({
    this.fieldErrors = const {},
    this.generalMessage,
  });

  const AppError.general(String message)
      : fieldErrors = const {},
        generalMessage = message;

  const AppError.fields(Map<String, String> errors)
      : fieldErrors = errors,
        generalMessage = null;

  bool get hasFieldErrors => fieldErrors.isNotEmpty;
  bool get hasGeneralMessage => generalMessage != null;
}

/// Contexte d'appel : un même code d'erreur ne se formule pas pareil selon
/// l'écran (un 401 à la connexion n'est pas un 401 sur le profil).
enum ErrorContext {
  login,
  socialLogin,
  signup,
  forgotPassword,
  verifyOtp,
  resetPassword,
  completeProfile,
  updateProfile,
  updateAvatar,
  verifyPassword,
  changePassword,
}
