import '../../api/core/api_exceptions.dart';
import 'app_error.dart';
import 'error_messages.dart';

/// Traduit toute erreur technique (API, réseau, plugin social) en messages
/// compréhensibles issus de [ErrorMessages].
///
/// Principe de sûreté : **aucun texte d'origine serveur n'est jamais réaffiché
/// tel quel.** Le message brut sert uniquement à *reconnaître* le problème par
/// détection de motif ; ce qui s'affiche vient toujours du catalogue. Si un cas
/// n'est pas reconnu, on retombe sur un message générique du catalogue plutôt
/// que de risquer une fuite technique.
class ErrorTranslator {
  ErrorTranslator._();

  /// Point d'entrée unique.
  static AppError translate(Object? error, {required ErrorContext context}) {
    if (error is ValidationException) {
      return _fromValidation(error, context);
    }
    if (error is UnauthorizedException) {
      return AppError.general(_unauthorizedMessage(context));
    }
    if (error is NetworkException) {
      return const AppError.general(ErrorMessages.noInternet);
    }
    if (error is ServerException) {
      return _fromServer(error, context);
    }
    return _fromUnknown(error, context);
  }

  // ── 422 : erreurs de validation, champ par champ ───────────────────────────

  static AppError _fromValidation(ValidationException e, ErrorContext context) {
    // 429 déguisé en erreur de champ (limitation de tentatives côté backend).
    if (e.statusCode == 429) {
      return const AppError.general(ErrorMessages.tooManyAttempts);
    }

    final fields = <String, String>{};
    for (final entry in e.fieldErrors.entries) {
      final raw = entry.value.isNotEmpty ? entry.value.first : '';
      final translated = _translateField(entry.key, raw, context);
      if (translated != null) fields[entry.key] = translated;
    }

    if (fields.isEmpty) {
      return AppError.general(_fallbackMessage(context));
    }

    // Un rejet anti-fraude ou une limitation ne se rattache pas utilement à un
    // champ : on le remonte en Toast, plus visible.
    final phoneMsg = fields['phone'];
    if (phoneMsg == ErrorMessages.phoneRisky && fields.length == 1) {
      return const AppError.general(ErrorMessages.phoneRisky);
    }

    return AppError.fields(fields);
  }

  /// Reconnaît le problème à partir du message brut, puis retourne le message
  /// du catalogue correspondant au champ concerné.
  static String? _translateField(
    String field,
    String rawMessage,
    ErrorContext context,
  ) {
    final raw = _normalize(rawMessage);

    // Motifs transverses, du plus spécifique au plus général.
    if (_has(raw, ['risque de securite', 'security risk'])) {
      return ErrorMessages.phoneRisky;
    }
    if (_has(raw, ['trop de tentatives', 'too many attempts', 'throttle'])) {
      return ErrorMessages.tooManyAttempts;
    }
    if (_has(
        raw, ['deja utilise', 'deja associe', 'already been taken', 'taken'])) {
      return _takenMessage(field);
    }
    if (_has(raw, ['ne correspondent pas', 'confirmation', 'confirmed'])) {
      return ErrorMessages.passwordMismatch;
    }
    if (_has(raw, ['au moins 8', 'at least 8', 'min'])) {
      return ErrorMessages.passwordTooShort;
    }
    if (_has(raw, ['obligatoire', 'required', 'est requis'])) {
      return _requiredMessage(field);
    }
    if (_has(raw, ['expire', 'expired'])) {
      return field == 'otp'
          ? ErrorMessages.otpExpired
          : ErrorMessages.resetSessionExpired;
    }
    if (_has(
        raw, ['incorrect', 'invalide', 'invalid', 'pas valide', 'format'])) {
      return _invalidMessage(field);
    }
    if (_has(raw, ['exists', 'existe pas', 'not found', 'introuvable'])) {
      return field == 'referral_code'
          ? ErrorMessages.referralCodeInvalid
          : _invalidMessage(field);
    }

    // Motif non reconnu : message du catalogue propre au champ, jamais le brut.
    return _invalidMessage(field);
  }

  static String _takenMessage(String field) {
    switch (field) {
      case 'phone':
        return ErrorMessages.phoneTaken;
      case 'email':
        return ErrorMessages.emailTaken;
      default:
        return ErrorMessages.fieldInvalid;
    }
  }

  static String _requiredMessage(String field) {
    switch (field) {
      case 'birthdate':
        return ErrorMessages.birthdateRequired;
      default:
        return ErrorMessages.fieldRequired;
    }
  }

  static String _invalidMessage(String field) {
    switch (field) {
      case 'phone':
        return ErrorMessages.phoneInvalid;
      case 'email':
        return ErrorMessages.emailInvalid;
      case 'password':
      case 'password_confirmation':
        return ErrorMessages.passwordTooShort;
      case 'current_password':
        return ErrorMessages.passwordIncorrect;
      case 'first_name':
      case 'last_name':
      case 'name':
        return ErrorMessages.nameInvalid;
      case 'birthdate':
        return ErrorMessages.birthdateInvalid;
      case 'referral_code':
        return ErrorMessages.referralCodeInvalid;
      case 'otp':
        return ErrorMessages.otpFieldInvalid;
      default:
        return ErrorMessages.fieldInvalid;
    }
  }

  // ── 401 ────────────────────────────────────────────────────────────────────

  static String _unauthorizedMessage(ErrorContext context) {
    switch (context) {
      case ErrorContext.login:
        return ErrorMessages.loginInvalidCredentials;
      case ErrorContext.socialLogin:
        return ErrorMessages.socialAccountNotFound;
      case ErrorContext.verifyPassword:
      case ErrorContext.changePassword:
        return ErrorMessages.passwordCurrentIncorrect;
      default:
        return ErrorMessages.sessionExpired;
    }
  }

  // ── Autres réponses serveur ────────────────────────────────────────────────

  static AppError _fromServer(ServerException e, ErrorContext context) {
    final status = e.statusCode ?? 0;
    final raw = _normalize(e.message);

    if (status == 429 || _has(raw, ['trop de tentatives', 'too many'])) {
      return const AppError.general(ErrorMessages.tooManyAttempts);
    }
    if (status == 401 || status == 403) {
      return AppError.general(_unauthorizedMessage(context));
    }

    // Compte inexistant : formulé selon l'écran.
    if (_has(raw, ['not found', 'introuvable', 'existe pas', 'aucun compte'])) {
      switch (context) {
        case ErrorContext.login:
          return const AppError.general(ErrorMessages.loginAccountNotFound);
        case ErrorContext.forgotPassword:
          return const AppError.general(ErrorMessages.forgotAccountNotFound);
        default:
          return AppError.general(_fallbackMessage(context));
      }
    }
    if (_has(raw, ['identifiants', 'credentials'])) {
      return const AppError.general(ErrorMessages.loginInvalidCredentials);
    }
    if (_has(raw, ['expire', 'expired'])) {
      switch (context) {
        case ErrorContext.verifyOtp:
          return const AppError.general(ErrorMessages.otpExpired);
        case ErrorContext.resetPassword:
          return const AppError.general(ErrorMessages.resetSessionExpired);
        default:
          return const AppError.general(ErrorMessages.sessionExpired);
      }
    }
    if (_has(raw, ['mot de passe est incorrect', 'mot de passe actuel'])) {
      return const AppError.general(ErrorMessages.passwordCurrentIncorrect);
    }
    if (status >= 500) {
      return const AppError.general(ErrorMessages.serverError);
    }

    return AppError.general(_fallbackMessage(context));
  }

  // ── Erreurs hors API (plugins sociaux, exceptions Dart) ────────────────────

  static AppError _fromUnknown(Object? error, ErrorContext context) {
    final raw = _normalize(error?.toString() ?? '');

    if (_has(raw,
        ['socket', 'connection refused', 'network', 'failed host lookup'])) {
      return const AppError.general(ErrorMessages.serverUnreachable);
    }
    if (_has(raw, ['timeout', 'timed out'])) {
      return const AppError.general(ErrorMessages.serverUnreachable);
    }
    return AppError.general(_fallbackMessage(context));
  }

  /// Message de repli, toujours formulé selon l'écran en cours.
  static String _fallbackMessage(ErrorContext context) {
    switch (context) {
      case ErrorContext.login:
        return ErrorMessages.loginFailed;
      case ErrorContext.socialLogin:
        return ErrorMessages.loginFailed;
      case ErrorContext.signup:
        return ErrorMessages.signupFailed;
      case ErrorContext.forgotPassword:
        return ErrorMessages.forgotSendFailed;
      case ErrorContext.verifyOtp:
        return ErrorMessages.otpInvalid;
      case ErrorContext.resetPassword:
        return ErrorMessages.resetFailed;
      case ErrorContext.completeProfile:
        return ErrorMessages.profileCompleteFailed;
      case ErrorContext.updateProfile:
        return ErrorMessages.profileSaveFailed;
      case ErrorContext.verifyPassword:
      case ErrorContext.changePassword:
        return ErrorMessages.passwordChangeFailed;
    }
  }

  /// Vrai si l'annulation vient de l'utilisateur (fermeture de la feuille
  /// Google/Apple) : ce n'est pas une erreur, on n'affiche rien.
  static bool isUserCancellation(Object? error) {
    final raw = _normalize(error?.toString() ?? '');
    return _has(raw, [
      'cancel',
      'canceled',
      'cancelled',
      'sign_in_canceled',
      'annule',
      'aborted',
    ]);
  }

  // ── Utilitaires de détection ───────────────────────────────────────────────

  static bool _has(String haystack, List<String> needles) =>
      needles.any(haystack.contains);

  /// Minuscules + suppression des accents, pour que la détection fonctionne
  /// quelle que soit la casse ou l'accentuation du message reçu.
  static String _normalize(String input) {
    var s = input.toLowerCase();
    const accents = {
      'à': 'a',
      'â': 'a',
      'ä': 'a',
      'é': 'e',
      'è': 'e',
      'ê': 'e',
      'ë': 'e',
      'î': 'i',
      'ï': 'i',
      'ô': 'o',
      'ö': 'o',
      'ù': 'u',
      'û': 'u',
      'ü': 'u',
      'ç': 'c',
    };
    accents.forEach((k, v) => s = s.replaceAll(k, v));
    return s;
  }
}
