// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get navWallet => 'Wallet';

  @override
  String get navRewards => 'Rewards';

  @override
  String get navReferral => 'Referral';

  @override
  String get navProfile => 'Profile';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonSave => 'Save';

  @override
  String get commonClose => 'Close';

  @override
  String get commonBack => 'Back';

  @override
  String get commonCopy => 'Copy';

  @override
  String get commonEdit => 'Edit';

  @override
  String get commonDone => 'Done';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsAppearance => 'Appearance';

  @override
  String get settingsThemeLight => 'Light';

  @override
  String get settingsThemeDark => 'Dark';

  @override
  String get settingsThemeSystem => 'System';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsLanguageFrench => 'Français';

  @override
  String get settingsLanguageEnglish => 'English';

  @override
  String get settingsAccount => 'Account';

  @override
  String get settingsNotifications => 'Notifications';

  @override
  String get settingsNotificationsSubtitle => 'Manage alerts per establishment';

  @override
  String get settingsSignOut => 'Sign out';

  @override
  String get settingsSignOutConfirmTitle => 'Sign out';

  @override
  String get settingsSignOutConfirmMessage =>
      'Are you sure you want to sign out of your Carte account?';

  @override
  String get profileTitle => 'Profile';

  @override
  String get profileEditProfile => 'Edit profile';

  @override
  String profileMemberSince(String date) {
    return 'Member since $date';
  }

  @override
  String get profileCards => 'Cards';

  @override
  String get profileOffers => 'Offers';

  @override
  String get profileReferrals => 'Referrals';

  @override
  String get profileNotConnectedTitle => 'You\'re not signed in';

  @override
  String get profileNotConnectedMessage => 'Sign in to access your profile.';

  @override
  String get profileSignIn => 'Sign in';

  @override
  String get profileSettings => 'Settings';

  @override
  String get profileSettingsSubtitle => 'Appearance, language, notifications';

  @override
  String get profileReferralCode => 'Your invite code';

  @override
  String get profileReferralCodeCopied => 'Referral code copied to clipboard!';

  @override
  String get profileBirthdayBannerTitle => 'Happy birthday month!';

  @override
  String get profileBirthdayBannerMessage =>
      'Exclusive treats await you at your restaurants.';

  @override
  String get editProfileTitle => 'Edit profile';

  @override
  String get editProfileFullName => 'Full name';

  @override
  String get editProfileFullNameHint => 'First Last';

  @override
  String get editProfileFullNameError => 'Please enter your full name';

  @override
  String get editProfilePhone => 'Phone number';

  @override
  String get editProfileBirthDate => 'Date of birth';

  @override
  String get editProfileEmail => 'Email';

  @override
  String get editProfileEmailHint => 'you@email.com';

  @override
  String get editProfileSaveSuccess => 'Profile updated successfully!';

  @override
  String get referralTitle => 'Referral';

  @override
  String get referralSubtitle =>
      'Recommend your favorite restaurants and earn points.';

  @override
  String get referralEmptyTitle => 'No card to refer';

  @override
  String get referralEmptyMessage =>
      'Join at least one establishment to recommend it to your friends.';

  @override
  String get referralPointsLabel => 'Referral points';

  @override
  String referralPointsEarned(int count) {
    return '$count points earned';
  }

  @override
  String referralSharesToNext(int count) {
    return '$count shares to go';
  }

  @override
  String get referralChoosePartner => 'Choose partner';

  @override
  String get referralRecipientHint => 'Phone or name';

  @override
  String get referralSendButton => 'Send invitation';

  @override
  String referralSendButtonWithCount(int count) {
    return 'Send invitation ($count)';
  }

  @override
  String get referralDuplicateRecipient =>
      'This recipient is already in your list.';

  @override
  String get referralNoRecipient =>
      'Please add at least one recipient before sending.';

  @override
  String referralSentSuccess(int count) {
    return '$count invitation(s) sent!';
  }

  @override
  String get referralHistoryTitle => 'Share history';

  @override
  String get referralHistoryEmpty => 'No shares yet.';

  @override
  String get referralMessageLabel => 'Your message';

  @override
  String get referralRecipientsLabel => 'Recipients';

  @override
  String get notificationsTitle => 'Notifications';

  @override
  String get notificationsMarkAllRead => 'Mark all read';

  @override
  String get notificationsEmptyTitle => 'No notifications';

  @override
  String get notificationsEmptyMessage =>
      'You\'ll be notified here about your stamps, rewards and VIP status.';

  @override
  String get commonConfirm => 'Confirm';

  @override
  String get commonHistory => 'History';

  @override
  String get commonCountdownPrefix => 'D-';

  @override
  String get cardStampsLabel => 'STAMPS';

  @override
  String get cardPointsLabel => 'BALANCE';

  @override
  String get cardPointsSuffix => 'PTS';

  @override
  String get cardCashbackLabel => 'CASHBACK';

  @override
  String get cardCashbackSuffix => 'FCFA';

  @override
  String get cardVipMaxTier => 'Top tier reached';

  @override
  String cardVipNextTier(int count) {
    return 'Platinum in $count visits';
  }

  @override
  String get rewardsTitle => 'Rewards';

  @override
  String get rewardsEmptyActiveTitle => 'No perk available';

  @override
  String get rewardsEmptyActiveMessage => 'Check back soon for new offers.';

  @override
  String get rewardsToUnlock => 'To unlock';

  @override
  String get rewardsAllUnlockedTitle => 'Everything unlocked';

  @override
  String get rewardsAllUnlockedMessage => 'No locked reward at the moment.';

  @override
  String get rewardsHistoryEmptyTitle => 'No history';

  @override
  String get rewardsHistoryEmptyMessage =>
      'Your used rewards will appear here.';

  @override
  String get rewardsRedeemConfirmTitle => 'Use this reward?';

  @override
  String rewardsRedeemConfirmMessage(String title) {
    return '\"$title\" will be marked as used and removed from your active perks. Show this screen to the establishment before confirming.';
  }

  @override
  String get rewardsRedeemSuccess => 'Reward marked as used';

  @override
  String get rewardsUseButton => 'Use';

  @override
  String get walletGreetingMorning => 'GOOD MORNING';

  @override
  String get walletGreetingAfternoon => 'GOOD AFTERNOON';

  @override
  String get walletGreetingEvening => 'GOOD EVENING';

  @override
  String get walletFallbackName => 'there';

  @override
  String get walletSearchSemanticLabel => 'Search a card';

  @override
  String get walletSearchHint => 'Search a card or a merchant';

  @override
  String get walletSearchNoResultsTitle => 'No card found';

  @override
  String get walletSearchNoResultsMessage => 'Try another name or merchant.';

  @override
  String get walletEmptyTitle => 'No card yet';

  @override
  String get walletEmptyMessage =>
      'Scan your first QR code to start your collection.';

  @override
  String get walletScanButton => 'Scan a QR code';

  @override
  String get cardDetailNotFound => 'Card not found';

  @override
  String get cardDetailTitle => 'Your card';

  @override
  String get cardDetailExportTooltip => 'Export / Share';

  @override
  String get cardDetailDefaultOfferRestaurant => 'Offer';

  @override
  String get cardDetailDefaultOfferTitle => 'Reward coming soon';

  @override
  String get cardDetailDefaultOfferMessage =>
      'Keep earning to unlock your next perk.';

  @override
  String get cardDetailExportSheetTitle => 'Export';

  @override
  String get cardDetailSaveTitle => 'Save the card';

  @override
  String get cardDetailSaveSubtitle => 'Keep it in your app Wallet';

  @override
  String get cardDetailDownloadTitle => 'Download the card';

  @override
  String get cardDetailDownloadSubtitle =>
      'Save an HD visual to your gallery (Pass format)';

  @override
  String get cardDetailShareTitle => 'Share the card';

  @override
  String get cardDetailShareSubtitle =>
      'Generate and send a clean version to a friend';

  @override
  String get cardDetailFullScreen => 'Full screen';

  @override
  String get cardDetailIdCopied => 'ID copied';

  @override
  String get cardDetailQrInstructions => 'Show this QR code at checkout';

  @override
  String cardDetailVisitsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count VISITS',
      one: '$count VISIT',
    );
    return '$_temp0';
  }

  @override
  String get rewardStatusReady => 'READY';

  @override
  String get rewardStatusLocked => 'LOCKED';

  @override
  String get rewardStatusUsed => 'USED';

  @override
  String get historyStampEntry => '+1 stamp · Checkout visit';

  @override
  String historyPointsEntry(int points) {
    return '+$points points · Checkout visit';
  }

  @override
  String historyCashbackEntry(int amount) {
    return '+$amount FCFA · Checkout visit';
  }

  @override
  String get historyVisitEntry => 'Visit recorded';

  @override
  String get historySignupEntry => 'Joined the card';

  @override
  String get exportFailedRetry => 'Export failed: please try again.';

  @override
  String exportShareSubject(String name) {
    return 'My $name card — Carte';
  }

  @override
  String exportShareText(String name) {
    return 'Check out $name on Carte!';
  }

  @override
  String exportDownloadReady(String id) {
    return 'HD image of card $id ready — choose \"Save image\".';
  }

  @override
  String exportShareSuccess(String name) {
    return '$name card visual shared.';
  }

  @override
  String exportSaveReady(String name) {
    return '\"$name\" card ready to be saved.';
  }

  @override
  String get exportFailedGeneric => 'Export failed: an error occurred.';

  @override
  String get commonPhoneLabel => 'Phone number';

  @override
  String get commonOptional => 'Optional';

  @override
  String get authLoginTitle => 'Sign in';

  @override
  String get authContinueGoogle => 'Continue with Google';

  @override
  String get authContinueApple => 'Continue with Apple';

  @override
  String get authNoAccountPrefix => 'Not a member yet? ';

  @override
  String get authSignUpLink => 'Sign up';

  @override
  String get authSignupTitle => 'Create an account';

  @override
  String get authBirthDateError => 'Please select your date of birth';

  @override
  String get authPhoneRequiredError => 'Please enter your phone number';

  @override
  String get authSignupButton => 'Sign up';

  @override
  String get authSignupGoogle => 'Sign up with Google';

  @override
  String get authSignupApple => 'Sign up with Apple';

  @override
  String get authHasAccountPrefix => 'Already a member? ';

  @override
  String get otpContextLogin => 'Sign in';

  @override
  String get otpContextSignup => 'Sign up';

  @override
  String get otpContextSocial => 'Verification';

  @override
  String get otpTitle => 'Verification';

  @override
  String otpSentMessage(String phone) {
    return 'A 6-digit code was sent to\n$phone';
  }

  @override
  String otpResendCountdown(String seconds) {
    return 'Resend code in 00:$seconds';
  }

  @override
  String get otpResendButton => 'Resend code';

  @override
  String completeProfileWelcomeNamed(String name) {
    return 'Welcome, $name!\nYour account has been created.';
  }

  @override
  String get completeProfileWelcomeAnon =>
      'Welcome!\nYour account has been created.';

  @override
  String get completeProfileTitle => 'Complete your profile';

  @override
  String get completeProfileSubmit => 'Go to the app';

  @override
  String get completeProfileSkip => 'Skip this step';

  @override
  String get completeSocialProfileTitle => 'Complete your profile';

  @override
  String get onboardingSlide1Title => 'All your cards,\none wallet';

  @override
  String get onboardingSlide1Subtitle =>
      'Bring your favorite loyalty cards together in one seamless, frictionless experience.';

  @override
  String get onboardingSlide2Title => 'Perks on\nevery visit';

  @override
  String get onboardingSlide2Subtitle =>
      'Earn stamps and points automatically, and unlock exclusive perks at your favorite spots.';

  @override
  String get onboardingSlide3Title => 'Share,\nearn together';

  @override
  String get onboardingSlide3Subtitle =>
      'Invite your friends with your personal code and earn referral points.';

  @override
  String get onboardingSkip => 'Skip';

  @override
  String get onboardingStart => 'Get started';

  @override
  String get onboardingContinue => 'Continue';

  @override
  String get commonValidate => 'Confirm';

  @override
  String get qrManualEntryLabel => 'Enter the code manually';

  @override
  String get qrScanTitle => 'SCAN A QR CODE';

  @override
  String get qrToggleFlash => 'Toggle flash';

  @override
  String get qrPlaceInFrame => 'Place the restaurant\'s QR code in the frame.';

  @override
  String get qrManualEntryHint =>
      'The code is printed below the QR code shown by the establishment.';

  @override
  String get qrManualEntryPlaceholder => 'E.g. JARDIN-2024';

  @override
  String get qrCameraUnavailableTitle => 'Camera unavailable';

  @override
  String get qrCameraUnavailableMessage =>
      'Allow camera access in settings, or enter the code manually.';

  @override
  String get joinOfferDetail => 'Earn 10 stamps for a free full meal.';

  @override
  String get joinUnrecognizedTitle => 'Code not recognized';

  @override
  String joinUnrecognizedMessage(String code) {
    return '\"$code\" doesn\'t match any Carte partner establishment at the moment.';
  }

  @override
  String get joinRetryScan => 'Try scanning again';

  @override
  String get joinBackToWallet => 'Back to Wallet';

  @override
  String get joinEyebrow => 'Join';

  @override
  String get joinWelcomeOfferEyebrow => 'Welcome offer';

  @override
  String get joinButton => 'Join the program';

  @override
  String get joinCardCreatedTitle => 'Card created!';

  @override
  String get phonePickerTitle => 'Select a dial code';

  @override
  String get phonePickerSearchHint => 'Search a country or dial code...';
}
