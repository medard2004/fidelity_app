// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get navWallet => 'Wallet';

  @override
  String get navRewards => 'Récompenses';

  @override
  String get navReferral => 'Parrainage';

  @override
  String get navProfile => 'Profil';

  @override
  String get commonCancel => 'Annuler';

  @override
  String get commonSave => 'Enregistrer';

  @override
  String get commonClose => 'Fermer';

  @override
  String get commonBack => 'Retour';

  @override
  String get commonCopy => 'Copier';

  @override
  String get commonEdit => 'Modifier';

  @override
  String get commonDone => 'Terminé';

  @override
  String get settingsTitle => 'Paramètres';

  @override
  String get settingsAppearance => 'Apparence';

  @override
  String get settingsThemeLight => 'Clair';

  @override
  String get settingsThemeDark => 'Sombre';

  @override
  String get settingsThemeSystem => 'Système';

  @override
  String get settingsLanguage => 'Langue';

  @override
  String get settingsLanguageFrench => 'Français';

  @override
  String get settingsLanguageEnglish => 'English';

  @override
  String get settingsAccount => 'Compte';

  @override
  String get settingsNotifications => 'Notifications';

  @override
  String get settingsNotificationsSubtitle =>
      'Gérer les alertes par établissement';

  @override
  String get settingsSignOut => 'Se déconnecter';

  @override
  String get settingsSignOutConfirmTitle => 'Déconnexion';

  @override
  String get settingsSignOutConfirmMessage =>
      'Êtes-vous sûr de vouloir vous déconnecter de votre compte Carte ?';

  @override
  String get profileTitle => 'Profil';

  @override
  String get profileEditProfile => 'Modifier le profil';

  @override
  String profileMemberSince(String date) {
    return 'Membre depuis $date';
  }

  @override
  String get profileCards => 'Cartes';

  @override
  String get profileOffers => 'Offres';

  @override
  String get profileReferrals => 'Filleuls';

  @override
  String get profileNotConnectedTitle => 'Vous n\'êtes pas connecté';

  @override
  String get profileNotConnectedMessage =>
      'Connectez-vous pour accéder à votre profil.';

  @override
  String get profileSignIn => 'Se connecter';

  @override
  String get profileSettings => 'Paramètres';

  @override
  String get profileSettingsSubtitle => 'Apparence, langue, notifications';

  @override
  String get profileReferralCode => 'Votre code invitation';

  @override
  String get profileReferralCodeCopied =>
      'Code parrainage copié dans le presse-papier !';

  @override
  String get profileBirthdayBannerTitle => 'Joyeux mois d\'anniversaire !';

  @override
  String get profileBirthdayBannerMessage =>
      'Des attentions exclusives vous attendent dans vos restaurants.';

  @override
  String get editProfileTitle => 'Modifier le profil';

  @override
  String get editProfileFullName => 'Nom complet';

  @override
  String get editProfileFullNameHint => 'Prénom Nom';

  @override
  String get editProfileFullNameError => 'Veuillez saisir votre nom complet';

  @override
  String get editProfilePhone => 'Numéro de téléphone';

  @override
  String get editProfileBirthDate => 'Date de naissance';

  @override
  String get editProfileEmail => 'Email';

  @override
  String get editProfileEmailHint => 'votre@email.com';

  @override
  String get editProfileSaveSuccess => 'Profil mis à jour avec succès !';

  @override
  String get referralTitle => 'Parrainage';

  @override
  String get referralSubtitle =>
      'Recommandez vos restaurants favoris et cumulez des points.';

  @override
  String get referralEmptyTitle => 'Aucune carte à parrainer';

  @override
  String get referralEmptyMessage =>
      'Rejoignez au moins un établissement pour pouvoir le recommander à vos proches.';

  @override
  String get referralPointsLabel => 'Points de parrainage';

  @override
  String referralPointsEarned(int count) {
    return '$count points cumulés';
  }

  @override
  String referralSharesToNext(int count) {
    return 'Encore $count partages';
  }

  @override
  String get referralChoosePartner => 'Choisir le partenaire';

  @override
  String get referralRecipientHint => 'Téléphone ou nom';

  @override
  String get referralSendButton => 'Envoyer l\'invitation';

  @override
  String referralSendButtonWithCount(int count) {
    return 'Envoyer l\'invitation ($count)';
  }

  @override
  String get referralDuplicateRecipient =>
      'Ce destinataire est déjà dans votre liste d\'envoi.';

  @override
  String get referralNoRecipient =>
      'Veuillez ajouter au moins un destinataire avant d\'envoyer.';

  @override
  String referralSentSuccess(int count) {
    return '$count invitation(s) envoyée(s) !';
  }

  @override
  String get referralHistoryTitle => 'Historique des partages';

  @override
  String get referralHistoryEmpty => 'Aucun partage effectué pour le moment.';

  @override
  String get referralMessageLabel => 'Votre message';

  @override
  String get referralRecipientsLabel => 'Destinataires';

  @override
  String get notificationsTitle => 'Notifications';

  @override
  String get notificationsMarkAllRead => 'Tout marquer lu';

  @override
  String get notificationsEmptyTitle => 'Aucune notification';

  @override
  String get notificationsEmptyMessage =>
      'Vous serez prévenu ici de vos tampons, récompenses et statuts VIP.';

  @override
  String get commonConfirm => 'Confirmer';

  @override
  String get commonHistory => 'Historique';

  @override
  String get commonCountdownPrefix => 'J-';

  @override
  String get cardStampsLabel => 'TAMPONS';

  @override
  String get cardPointsLabel => 'SOLDE';

  @override
  String get cardPointsSuffix => 'PTS';

  @override
  String get cardCashbackLabel => 'CASHBACK';

  @override
  String get cardCashbackSuffix => 'FCFA';

  @override
  String get cardVipMaxTier => 'Palier maximum atteint';

  @override
  String cardVipNextTier(int count) {
    return 'Platinum dans $count visites';
  }

  @override
  String get rewardsTitle => 'Récompenses';

  @override
  String get rewardsEmptyActiveTitle => 'Aucun privilège disponible';

  @override
  String get rewardsEmptyActiveMessage =>
      'Revenez bientôt pour de nouvelles offres.';

  @override
  String get rewardsToUnlock => 'À débloquer';

  @override
  String get rewardsAllUnlockedTitle => 'Tout est débloqué';

  @override
  String get rewardsAllUnlockedMessage =>
      'Aucune récompense verrouillée pour le moment.';

  @override
  String get rewardsHistoryEmptyTitle => 'Aucun historique';

  @override
  String get rewardsHistoryEmptyMessage =>
      'Vos récompenses utilisées apparaîtront ici.';

  @override
  String get rewardsRedeemConfirmTitle => 'Utiliser cette récompense ?';

  @override
  String rewardsRedeemConfirmMessage(String title) {
    return '« $title » sera marquée comme utilisée et retirée de vos privilèges actifs. Présentez cet écran à l\'enseigne avant de confirmer.';
  }

  @override
  String get rewardsRedeemSuccess => 'Récompense marquée comme utilisée';

  @override
  String get rewardsUseButton => 'Utiliser';

  @override
  String get walletGreetingMorning => 'BONJOUR';

  @override
  String get walletGreetingAfternoon => 'BON APRÈS-MIDI';

  @override
  String get walletGreetingEvening => 'BONSOIR';

  @override
  String get walletFallbackName => 'vous';

  @override
  String get walletSearchSemanticLabel => 'Rechercher une carte';

  @override
  String get walletSearchHint => 'Rechercher une carte ou une enseigne';

  @override
  String get walletSearchNoResultsTitle => 'Aucune carte trouvée';

  @override
  String get walletSearchNoResultsMessage =>
      'Essayez un autre nom ou une autre enseigne.';

  @override
  String get walletEmptyTitle => 'Aucune carte pour l\'instant';

  @override
  String get walletEmptyMessage =>
      'Scannez votre premier QR pour commencer votre collection.';

  @override
  String get walletScanButton => 'Scanner un QR code';

  @override
  String get cardDetailNotFound => 'Carte introuvable';

  @override
  String get cardDetailTitle => 'Votre carte';

  @override
  String get cardDetailExportTooltip => 'Exporter / Partager';

  @override
  String get cardDetailDefaultOfferRestaurant => 'Offre';

  @override
  String get cardDetailDefaultOfferTitle => 'Récompense à venir';

  @override
  String get cardDetailDefaultOfferMessage =>
      'Continuez à cumuler pour débloquer votre prochain privilège.';

  @override
  String get cardDetailExportSheetTitle => 'Exportation';

  @override
  String get cardDetailSaveTitle => 'Enregistrer la carte';

  @override
  String get cardDetailSaveSubtitle =>
      'Conserver dans votre Portefeuille d\'application';

  @override
  String get cardDetailDownloadTitle => 'Télécharger la carte';

  @override
  String get cardDetailDownloadSubtitle =>
      'Enregistrer un visuel HD dans votre galerie (Pass format)';

  @override
  String get cardDetailShareTitle => 'Partager la carte';

  @override
  String get cardDetailShareSubtitle =>
      'Générer et envoyer une version propre à un proche';

  @override
  String get cardDetailFullScreen => 'Plein écran';

  @override
  String get cardDetailIdCopied => 'Identifiant copié';

  @override
  String get cardDetailQrInstructions =>
      'Présentez ce QR Code lors de votre passage en caisse';

  @override
  String cardDetailVisitsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count VISITES',
      one: '$count VISITE',
    );
    return '$_temp0';
  }

  @override
  String get rewardStatusReady => 'PRÊT';

  @override
  String get rewardStatusLocked => 'VERROUILLÉ';

  @override
  String get rewardStatusUsed => 'UTILISÉ';

  @override
  String get historyStampEntry => '+1 tampon · Passage en caisse';

  @override
  String historyPointsEntry(int points) {
    return '+$points points · Passage en caisse';
  }

  @override
  String historyCashbackEntry(int amount) {
    return '+$amount FCFA · Passage en caisse';
  }

  @override
  String get historyVisitEntry => 'Visite comptabilisée';

  @override
  String get historySignupEntry => 'Inscription à la carte';

  @override
  String get exportFailedRetry => 'Échec de l\'export : réessayez.';

  @override
  String exportShareSubject(String name) {
    return 'Ma carte $name — Carte';
  }

  @override
  String exportShareText(String name) {
    return 'Découvre $name sur Carte !';
  }

  @override
  String exportDownloadReady(String id) {
    return 'Image HD de la carte $id prête — choisissez « Enregistrer l\'image ».';
  }

  @override
  String exportShareSuccess(String name) {
    return 'Visuel de la carte $name partagé.';
  }

  @override
  String exportSaveReady(String name) {
    return 'Carte « $name » prête à être enregistrée.';
  }

  @override
  String get exportFailedGeneric =>
      'Échec de l\'export : une erreur est survenue.';

  @override
  String get commonPhoneLabel => 'Numéro de téléphone';

  @override
  String get commonOptional => 'Optionnel';

  @override
  String get authLoginTitle => 'Connexion';

  @override
  String get authContinueGoogle => 'Continuer avec Google';

  @override
  String get authContinueApple => 'Continuer avec Apple';

  @override
  String get authNoAccountPrefix => 'Pas encore membre ? ';

  @override
  String get authSignUpLink => 'S\'inscrire';

  @override
  String get authSignupTitle => 'Créer un compte';

  @override
  String get authBirthDateError =>
      'Veuillez sélectionner votre date de naissance';

  @override
  String get authPhoneRequiredError =>
      'Veuillez saisir votre numéro de téléphone';

  @override
  String get authSignupButton => 'S\'inscrire';

  @override
  String get authSignupGoogle => 'S\'inscrire avec Google';

  @override
  String get authSignupApple => 'S\'inscrire avec Apple';

  @override
  String get authHasAccountPrefix => 'Déjà membre ? ';

  @override
  String get otpContextLogin => 'Connexion';

  @override
  String get otpContextSignup => 'Inscription';

  @override
  String get otpContextSocial => 'Vérification';

  @override
  String get otpTitle => 'Vérification';

  @override
  String otpSentMessage(String phone) {
    return 'Un code à 6 chiffres a été envoyé au\n$phone';
  }

  @override
  String otpResendCountdown(String seconds) {
    return 'Renvoyer le code dans 00:$seconds';
  }

  @override
  String get otpResendButton => 'Renvoyer le code';

  @override
  String completeProfileWelcomeNamed(String name) {
    return 'Bienvenue, $name !\nVotre compte a été créé.';
  }

  @override
  String get completeProfileWelcomeAnon =>
      'Bienvenue !\nVotre compte a été créé.';

  @override
  String get completeProfileTitle => 'Complétez votre profil';

  @override
  String get completeProfileSubmit => 'Accéder à l\'application';

  @override
  String get completeProfileSkip => 'Passer cette étape';

  @override
  String get completeSocialProfileTitle => 'Compléter le profil';

  @override
  String get onboardingSlide1Title =>
      'Toutes vos cartes,\nun seul portefeuille';

  @override
  String get onboardingSlide1Subtitle =>
      'Rassemblez vos cartes de fidélité préférées dans une expérience unique, rapide et sans friction.';

  @override
  String get onboardingSlide2Title => 'Des privilèges\nà chaque visite';

  @override
  String get onboardingSlide2Subtitle =>
      'Cumulez tampons et points automatiquement, et débloquez des avantages exclusifs chez vos enseignes favorites.';

  @override
  String get onboardingSlide3Title => 'Partagez,\ngagnez ensemble';

  @override
  String get onboardingSlide3Subtitle =>
      'Invitez vos proches avec votre code personnel et cumulez des points de parrainage.';

  @override
  String get onboardingSkip => 'Passer';

  @override
  String get onboardingStart => 'Commencer l\'expérience';

  @override
  String get onboardingContinue => 'Continuer';

  @override
  String get commonValidate => 'Valider';

  @override
  String get qrManualEntryLabel => 'Saisir le code manuellement';

  @override
  String get qrScanTitle => 'SCANNER UN QR';

  @override
  String get qrToggleFlash => 'Activer ou désactiver le flash';

  @override
  String get qrPlaceInFrame => 'Placez le QR du restaurant dans le cadre.';

  @override
  String get qrManualEntryHint =>
      'Le code figure sous le QR affiché par l\'établissement.';

  @override
  String get qrManualEntryPlaceholder => 'Ex. JARDIN-2024';

  @override
  String get qrCameraUnavailableTitle => 'Caméra indisponible';

  @override
  String get qrCameraUnavailableMessage =>
      'Autorisez l\'accès à la caméra dans les réglages, ou saisissez le code manuellement.';

  @override
  String get joinOfferDetail =>
      'Cumulez 10 tampons pour un menu entier offert.';

  @override
  String get joinUnrecognizedTitle => 'Code non reconnu';

  @override
  String joinUnrecognizedMessage(String code) {
    return '« $code » ne correspond à aucun établissement partenaire de Carte pour le moment.';
  }

  @override
  String get joinRetryScan => 'Réessayer un scan';

  @override
  String get joinBackToWallet => 'Retour au portefeuille';

  @override
  String get joinEyebrow => 'Rejoindre';

  @override
  String get joinWelcomeOfferEyebrow => 'Offre de bienvenue';

  @override
  String get joinButton => 'Rejoindre le programme';

  @override
  String get joinCardCreatedTitle => 'Carte créée !';

  @override
  String get phonePickerTitle => 'Sélectionnez un indicatif';

  @override
  String get phonePickerSearchHint => 'Rechercher un pays ou un indicatif...';
}
