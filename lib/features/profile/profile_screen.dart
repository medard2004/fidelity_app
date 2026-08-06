import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../l10n/gen/app_localizations.dart';
import '../../models/user.dart';
import '../../providers/app_providers.dart';
import '../../providers/settings_provider.dart';
import '../../providers/wallet_provider.dart';
import '../../widgets/components/components.dart';
import '../../widgets/shared/app_section_header.dart';
import '../../widgets/shared/notification_bell_button.dart';
import '../../widgets/shared/phone_input_with_country_picker.dart';

/// Profil — juste l'essentiel : identité, un coup d'œil chiffré, code de
/// parrainage, et un accès unique vers Paramètres pour tout le reste
/// (apparence, langue, notifications, déconnexion). Les informations
/// détaillées (nom/téléphone/naissance/email) ne vivent qu'à un seul
/// endroit : la modale d'édition, pour ne pas les afficher deux fois.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  void _openEditProfileModal(
      BuildContext context, WidgetRef ref, AppUser user) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => _EditProfileModal(user: user),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(themeModeProvider);
    final t = AppLocalizations.of(context)!;
    final user = ref.watch(authProvider).user;
    final cards = ref.watch(walletProvider);
    final rewards = ref.watch(rewardsProvider);
    final unreadNotifs =
        ref.watch(notificationsProvider).where((n) => !n.isRead).length;
    final dateFormatLocale =
        Localizations.localeOf(context).languageCode == 'fr'
            ? 'fr_FR'
            : 'en_US';

    if (user == null) {
      return Scaffold(
        backgroundColor: AppColors.surface,
        body: Center(
          child: EmptyState(
            icon: LucideIcons.user,
            title: t.profileNotConnectedTitle,
            message: t.profileNotConnectedMessage,
            action: AppButton(
              label: t.profileSignIn,
              fullWidth: false,
              onTap: () => context.go('/auth'),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          children: [
            AppSectionHeader(
              title: t.profileTitle,
              actions: [NotificationBellButton(unreadCount: unreadNotifs)],
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                children: [
                  AppCard(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 64,
                              height: 64,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.primary,
                              ),
                              child: Center(
                                child: Text(
                                  user.fullName.isNotEmpty
                                      ? user.fullName[0].toUpperCase()
                                      : '?',
                                  style: AppTextStyles.displayMedium(
                                          color: Colors.white)
                                      .copyWith(fontSize: 26),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    user.fullName.isNotEmpty
                                        ? user.fullName
                                        : t.profileTitle,
                                    style: AppTextStyles.titleMedium()
                                        .copyWith(fontSize: 18),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    user.maskedPhoneNumber,
                                    style: AppTextStyles.monoSmall(
                                        color:
                                            AppColors.inkMuted(opacity: 0.65)),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    t.profileMemberSince(
                                        user.memberSinceDate(dateFormatLocale)),
                                    style: AppTextStyles.bodySmall(
                                        color:
                                            AppColors.inkMuted(opacity: 0.5)),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        AppButton(
                          label: t.profileEditProfile,
                          variant: AppButtonVariant.outline,
                          icon: LucideIcons.pencil,
                          height: 46,
                          onTap: () =>
                              _openEditProfileModal(context, ref, user),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: StatTile(
                            value: '${cards.length}', label: t.profileCards),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: StatTile(
                            value: '${rewards.length}', label: t.profileOffers),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: StatTile(
                            value: '${user.friendsJoined}',
                            label: t.profileReferrals),
                      ),
                    ],
                  ),
                  if (user.isBirthdayMonth) ...[
                    const SizedBox(height: 16),
                    AppCard(
                      backgroundColor: AppColors.primaryTint,
                      bordered: false,
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          const Text('🎂', style: TextStyle(fontSize: 24)),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  t.profileBirthdayBannerTitle,
                                  style: AppTextStyles.label(
                                      color: AppColors.primaryDark),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  t.profileBirthdayBannerMessage,
                                  style: AppTextStyles.bodySmall(
                                      color: AppColors.inkMuted(opacity: 0.7)),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  AppCard(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                t.profileReferralCode,
                                style: AppTextStyles.bodySmall(
                                    color: AppColors.inkMuted(opacity: 0.6)),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                user.referralCode.isNotEmpty
                                    ? user.referralCode
                                    : 'CARTE-MEMBRE',
                                style: AppTextStyles.monoMedium(
                                        color: AppColors.primaryDark)
                                    .copyWith(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15),
                              ),
                            ],
                          ),
                        ),
                        AppTapScale(
                          onTap: () {
                            Clipboard.setData(
                                ClipboardData(text: user.referralCode));
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text(t.profileReferralCodeCopied)),
                            );
                          },
                          child: Container(
                            width: 38,
                            height: 38,
                            alignment: Alignment.center,
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(LucideIcons.copy,
                                size: 15, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  AppCard(
                    onTap: () => context.push('/settings'),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: Row(
                      children: [
                        Container(
                          width: 38,
                          height: 38,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: AppColors.surfaceMuted,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(LucideIcons.settings,
                              size: 18, color: AppColors.ink),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(t.profileSettings,
                                  style: AppTextStyles.bodyMedium()
                                      .copyWith(fontWeight: FontWeight.w600)),
                              Text(
                                t.profileSettingsSubtitle,
                                style: AppTextStyles.bodySmall(
                                    color: AppColors.inkMuted(opacity: 0.55)),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        Icon(LucideIcons.chevronRight,
                            size: 18, color: AppColors.inkMuted(opacity: 0.35)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Modal d'édition du profil
// ─────────────────────────────────────────────────────────────────────────────

class _EditProfileModal extends StatefulWidget {
  final AppUser user;
  const _EditProfileModal({required this.user});

  @override
  State<_EditProfileModal> createState() => _EditProfileModalState();
}

class _EditProfileModalState extends State<_EditProfileModal> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _fullNameController;
  late GlobalKey<PhoneInputWithCountryPickerState> _phoneInputKey;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  DateTime? _birthDate;

  @override
  void initState() {
    super.initState();
    _fullNameController = TextEditingController(text: widget.user.fullName);
    _phoneInputKey = GlobalKey<PhoneInputWithCountryPickerState>();
    _phoneController = TextEditingController(
      text: widget.user.phoneNumber.replaceFirst(RegExp(r'^\+\d+\s*'), ''),
    );
    _emailController = TextEditingController(text: widget.user.email ?? '');
    _birthDate = widget.user.birthDate;
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _save(WidgetRef ref, AppLocalizations t) {
    if (!_formKey.currentState!.validate()) return;

    final fullPhone = _phoneInputKey.currentState?.fullPhoneNumber ??
        _phoneController.text.trim();

    ref.read(authProvider.notifier).updateFullProfile(
          fullName: _fullNameController.text.trim(),
          phoneNumber: fullPhone,
          birthDate: _birthDate,
          email: _emailController.text.trim().isNotEmpty
              ? _emailController.text.trim()
              : null,
        );

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(t.editProfileSaveSuccess)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final t = AppLocalizations.of(context)!;
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.8,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (context, scrollController) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Form(
                key: _formKey,
                child: ListView(
                  controller: scrollController,
                  children: [
                    Text(t.editProfileTitle,
                        style: AppTextStyles.displayMedium()),
                    const SizedBox(height: 20),
                    Text(t.editProfileFullName, style: AppTextStyles.label()),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _fullNameController,
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? t.editProfileFullNameError
                          : null,
                      decoration:
                          InputDecoration(hintText: t.editProfileFullNameHint),
                    ),
                    const SizedBox(height: 16),
                    Text(t.editProfilePhone, style: AppTextStyles.label()),
                    const SizedBox(height: 6),
                    PhoneInputWithCountryPicker(
                      key: _phoneInputKey,
                      controller: _phoneController,
                    ),
                    const SizedBox(height: 16),
                    Text(t.editProfileBirthDate, style: AppTextStyles.label()),
                    const SizedBox(height: 6),
                    AppDatePickerField(
                      value: _birthDate,
                      lastDate: DateTime.now(),
                      onChanged: (picked) =>
                          setState(() => _birthDate = picked),
                    ),
                    const SizedBox(height: 16),
                    Text(t.editProfileEmail, style: AppTextStyles.label()),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration:
                          InputDecoration(hintText: t.editProfileEmailHint),
                    ),
                    const SizedBox(height: 28),
                    AppButton(
                      label: t.commonSave,
                      onTap: () => _save(ref, t),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
