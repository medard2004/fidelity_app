/// Catalogue unique des messages présentés à l'utilisateur.
///
/// Toute formulation visible pour les parcours liés au compte vit ici : c'est
/// ce qui garantit l'harmonisation. Aucun écran ne doit écrire un message en
/// dur ; il pioche dans ce catalogue.
///
/// Règles de rédaction respectées ici :
///   * pas de terme technique, de code d'erreur ni de nom de champ API ;
///   * on dit ce qui s'est passé, et quoi faire quand l'utilisateur peut agir ;
///   * vouvoiement, phrase complète, ponctuation finale.
class ErrorMessages {
  ErrorMessages._();

  // ── Erreurs générales (Toast) ──────────────────────────────────────────────

  static const noInternet =
      "Vous semblez hors ligne. Vérifiez votre connexion, puis réessayez.";
  static const serverUnreachable =
      "Nous n'arrivons pas à joindre nos serveurs. Réessayez dans quelques instants.";
  static const serverError =
      "Le service est momentanément indisponible. Réessayez dans quelques instants.";
  static const unexpected = "Une erreur est survenue. Réessayez.";
  static const tooManyAttempts =
      "Trop de tentatives. Patientez quelques instants avant de réessayer.";
  static const sessionExpired =
      "Votre session a expiré. Reconnectez-vous pour continuer.";
  static const missingRequiredFields =
      "Veuillez renseigner tous les champs obligatoires.";

  // ── Connexion ──────────────────────────────────────────────────────────────

  static const loginInvalidCredentials =
      "Numéro de téléphone ou mot de passe incorrect.";
  static const loginAccountNotFound = "Ce compte n'existe pas encore.";
  static const loginFailed =
      "Impossible de vous connecter pour le moment. Réessayez.";
  static const loginSuccess = "Vous êtes connecté.";

  // ── Connexion sociale ──────────────────────────────────────────────────────

  static const socialCancelled = "Connexion annulée.";
  static const socialFailedGoogle =
      "Impossible de vous connecter avec Google. Réessayez.";
  static const socialFailedApple =
      "Impossible de vous connecter avec Apple. Réessayez.";
  static const socialAccountNotFound =
      "Aucun compte n'est associé à ce profil. Créez d'abord un compte.";

  // ── Inscription ────────────────────────────────────────────────────────────

  static const signupPhoneTaken =
      "Ce numéro de téléphone est déjà associé à un compte.";
  static const signupEmailTaken = "Cette adresse e-mail est déjà utilisée.";
  static const signupFailed =
      "Impossible de créer votre compte pour le moment. Réessayez.";
  static const signupSuccess = "Votre compte a bien été créé.";

  // ── Mot de passe oublié / réinitialisation ─────────────────────────────────

  static const forgotAccountNotFound =
      "Aucun compte n'est associé à ce numéro de téléphone.";
  static const forgotCodeSent =
      "Un code de réinitialisation vient d'être envoyé.";
  static const forgotSendFailed =
      "Impossible d'envoyer le code. Réessayez dans quelques instants.";
  static const otpInvalid = "Ce code est incorrect. Vérifiez-le et réessayez.";
  static const otpExpired =
      "Ce code a expiré. Demandez-en un nouveau pour continuer.";
  static const resetSessionExpired =
      "Votre demande a expiré. Recommencez la réinitialisation.";
  static const resetFailed =
      "Impossible de réinitialiser votre mot de passe. Réessayez.";
  static const resetSuccess = "Votre mot de passe a bien été modifié.";

  // ── Profil (complétion et modification) ────────────────────────────────────

  static const profileSaveFailed =
      "Impossible d'enregistrer les modifications. Réessayez.";
  static const profileSaveSuccess =
      "Les informations ont bien été enregistrées.";
  static const profileCompleteFailed =
      "Impossible d'enregistrer votre profil. Réessayez.";
  static const passwordCurrentIncorrect =
      "Le mot de passe actuel est incorrect.";
  static const passwordChangeSuccess = "Votre mot de passe a bien été modifié.";
  static const passwordChangeFailed =
      "Impossible de modifier votre mot de passe. Réessayez.";

  // ── Erreurs de champ (affichées sous le champ) ─────────────────────────────

  static const fieldRequired = "Veuillez renseigner ce champ.";
  static const phoneInvalid = "Le numéro de téléphone n'est pas valide.";
  static const phoneTaken =
      "Ce numéro de téléphone est déjà associé à un compte.";
  static const phoneRisky =
      "Ce numéro ne peut pas être utilisé. Essayez-en un autre.";
  static const emailInvalid = "L'adresse e-mail n'est pas valide.";
  static const emailTaken = "Cette adresse e-mail est déjà utilisée.";
  static const passwordTooShort =
      "Le mot de passe doit contenir au moins 8 caractères.";
  static const passwordMismatch =
      "Les deux mots de passe ne correspondent pas.";
  static const passwordNeedsUppercase =
      "Le mot de passe doit contenir au moins une majuscule.";
  static const passwordNeedsDigit =
      "Le mot de passe doit contenir au moins un chiffre.";
  static const passwordMustDiffer =
      "Le nouveau mot de passe doit être différent de l'actuel.";
  static const passwordIncorrect = "Mot de passe incorrect.";
  static const nameInvalid = "Ce nom n'est pas valide.";
  static const birthdateInvalid = "Cette date de naissance n'est pas valide.";
  static const birthdateRequired = "Veuillez indiquer votre date de naissance.";
  static const referralCodeInvalid = "Ce code de parrainage n'existe pas.";
  static const otpFieldInvalid = "Ce code n'est pas valide.";
  static const fieldInvalid = "Cette information n'est pas valide.";
}
