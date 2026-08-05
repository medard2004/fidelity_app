import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_shadows.dart';
import '../../models/user.dart';
import '../../providers/app_providers.dart';
import '../../providers/wallet_provider.dart';
import '../../widgets/components/components.dart';
import '../../widgets/shared/phone_input_with_country_picker.dart';

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

  void _confirmSignOut(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Déconnexion', style: AppTextStyles.titleMedium().copyWith(fontSize: 18)),
        content: Text(
          'Êtes-vous sûr de vouloir vous déconnecter de votre compte Carte ?',
          style: AppTextStyles.bodyMedium(color: AppColors.inkMuted(opacity: 0.7)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Annuler',
                style: AppTextStyles.bodyMedium(color: AppColors.inkMuted(opacity: 0.6))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(minimumSize: const Size(0, 40)),
            onPressed: () {
              Navigator.pop(context);
              ref.read(authProvider.notifier).signOut();
              context.go('/auth');
            },
            child: const Text('Se déconnecter'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;
    final cards = ref.watch(walletProvider);
    final rewards = ref.watch(rewardsProvider);
    final unreadNotifs =
        ref.watch(notificationsProvider).where((n) => !n.isRead).length;

    if (user == null) {
      return Scaffold(
        backgroundColor: AppColors.surface,
        body: Center(
          child: EmptyState(
            icon: LucideIcons.user,
            title: 'Vous n\'êtes pas connecté',
            message: 'Connectez-vous pour accéder à votre profil.',
            action: AppButton(
              label: 'Se connecter',
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
            // ── En-tête statique ─────────────────────────────────────────
            Container(
              color: AppColors.surface,
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SectionEyebrow('Espace membre'),
                      const SizedBox(height: 4),
                      Text('Profil', style: AppTextStyles.displayLarge()),
                    ],
                  ),
                  Semantics(
                    button: true,
                    label: unreadNotifs > 0
                        ? 'Notifications, $unreadNotifs non lues'
                        : 'Notifications',
                    child: GestureDetector(
                      onTap: () => context.push('/notifications'),
                      behavior: HitTestBehavior.opaque,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: AppColors.surfaceCard,
                              shape: BoxShape.circle,
                              boxShadow: AppShadows.resting,
                            ),
                            child: const Icon(
                              LucideIcons.bell,
                              color: AppColors.ink,
                              size: 20,
                            ),
                          ),
                          if (unreadNotifs > 0)
                            Positioned(
                              top: 2,
                              right: 2,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: AppColors.error,
                                  shape: BoxShape.circle,
                                ),
                                child: Text(
                                  '$unreadNotifs',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const Divider(height: 1, color: AppColors.border),

            // ── Contenu défilant ─────────────────────────────────────────
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
                                  style: AppTextStyles.displayMedium(color: Colors.white)
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
                                        : 'Membre Carte',
                                    style: AppTextStyles.titleMedium().copyWith(fontSize: 18),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    user.maskedPhoneNumber,
                                    style: AppTextStyles.monoSmall(color: AppColors.inkMuted(opacity: 0.65)),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    user.memberSince,
                                    style: AppTextStyles.bodySmall(color: AppColors.inkMuted(opacity: 0.5)),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        AppButton(
                          label: 'Modifier le profil',
                          variant: AppButtonVariant.outline,
                          icon: LucideIcons.pencil,
                          height: 46,
                          onTap: () => _openEditProfileModal(context, ref, user),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: StatTile(value: '${cards.length}', label: 'Cartes'),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: StatTile(value: '${rewards.length}', label: 'Offres'),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: StatTile(value: '${user.friendsJoined}', label: 'Filleuls'),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  if (user.isBirthdayMonth) ...[
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
                                  'Joyeux mois d\'anniversaire !',
                                  style: AppTextStyles.label(color: AppColors.primaryDark),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Des attentions exclusives vous attendent dans vos restaurants.',
                                  style: AppTextStyles.bodySmall(color: AppColors.inkMuted(opacity: 0.7)),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  const SectionEyebrow('Informations personnelles'),
                  const SizedBox(height: 8),
                  AppCard(
                    padding: EdgeInsets.zero,
                    child: Column(
                      children: [
                        _InfoRow(
                          label: 'Nom complet',
                          value: user.fullName.isNotEmpty ? user.fullName : 'Non renseigné',
                          icon: LucideIcons.user,
                        ),
                        const Divider(height: 1, color: AppColors.border),
                        _InfoRow(
                          label: 'Téléphone',
                          value: user.phoneNumber.isNotEmpty ? user.phoneNumber : 'Non renseigné',
                          icon: LucideIcons.phone,
                        ),
                        const Divider(height: 1, color: AppColors.border),
                        _InfoRow(
                          label: 'Date de naissance',
                          value: user.birthDate != null
                              ? '${user.birthDate!.day.toString().padLeft(2, '0')}/${user.birthDate!.month.toString().padLeft(2, '0')}/${user.birthDate!.year}'
                              : 'Non renseignée',
                          icon: LucideIcons.cake,
                        ),
                        const Divider(height: 1, color: AppColors.border),
                        _InfoRow(
                          label: 'Email',
                          value: (user.email != null && user.email!.isNotEmpty)
                              ? user.email!
                              : 'Non renseigné',
                          icon: LucideIcons.mail,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  const SectionEyebrow('Parrainage exclusif'),
                  const SizedBox(height: 8),
                  AppCard(
                    backgroundColor: AppColors.primaryTint,
                    bordered: false,
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Votre code invitation',
                                style: AppTextStyles.bodySmall(color: AppColors.inkMuted(opacity: 0.6)),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                user.referralCode.isNotEmpty ? user.referralCode : 'CARTE-MEMBRE',
                                style: AppTextStyles.monoMedium(color: AppColors.primaryDark)
                                    .copyWith(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Clipboard.setData(ClipboardData(text: user.referralCode));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Code parrainage copié dans le presse-papier !'),
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                const Icon(LucideIcons.copy, size: 14, color: Colors.white),
                                const SizedBox(width: 6),
                                Text('Copier', style: AppTextStyles.label(color: Colors.white)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  const SectionEyebrow('Préférences de notification'),
                  const SizedBox(height: 8),
                  AppCard(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: cards
                          .map<Widget>(
                            (card) => _NotifToggleRow(cardId: card.id, name: card.restaurantName),
                          )
                          .toList(),
                    ),
                  ),

                  const SizedBox(height: 28),

                  Center(
                    child: AppButton(
                      label: 'Se déconnecter',
                      variant: AppButtonVariant.destructive,
                      icon: LucideIcons.logOut,
                      fullWidth: false,
                      height: 44,
                      onTap: () => _confirmSignOut(context, ref),
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

  void _save(WidgetRef ref) {
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
      const SnackBar(content: Text('Profil mis à jour avec succès !')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
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
                    Text('Modifier le profil', style: AppTextStyles.displayMedium()),
                    const SizedBox(height: 20),

                    Text('Nom complet', style: AppTextStyles.label()),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _fullNameController,
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Veuillez saisir votre nom complet'
                          : null,
                      decoration: const InputDecoration(hintText: 'Prénom Nom'),
                    ),

                    const SizedBox(height: 16),

                    Text('Numéro de téléphone', style: AppTextStyles.label()),
                    const SizedBox(height: 6),
                    PhoneInputWithCountryPicker(
                      key: _phoneInputKey,
                      controller: _phoneController,
                    ),

                    const SizedBox(height: 16),

                    Text('Date de naissance', style: AppTextStyles.label()),
                    const SizedBox(height: 6),
                    AppDatePickerField(
                      value: _birthDate,
                      lastDate: DateTime.now(),
                      onChanged: (picked) => setState(() => _birthDate = picked),
                    ),

                    const SizedBox(height: 16),

                    Text('Email', style: AppTextStyles.label()),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(hintText: 'votre@email.com'),
                    ),

                    const SizedBox(height: 28),

                    AppButton(
                      label: 'Enregistrer les modifications',
                      onTap: () => _save(ref),
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

// ─────────────────────────────────────────────────────────────────────────────
// Widgets locaux
// ─────────────────────────────────────────────────────────────────────────────

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _InfoRow({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppTextStyles.bodySmall(color: AppColors.inkMuted(opacity: 0.5))),
                const SizedBox(height: 2),
                Text(value, style: AppTextStyles.bodyMedium().copyWith(fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NotifToggleRow extends ConsumerWidget {
  final String cardId;
  final String name;
  const _NotifToggleRow({required this.cardId, required this.name});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enabled =
        ref.watch(notificationPrefsProvider.select((p) => p[cardId] ?? true));
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(name, style: AppTextStyles.bodyMedium()),
          ),
          Switch(
            value: enabled,
            onChanged: (v) =>
                ref.read(notificationPrefsProvider.notifier).toggle(cardId, v),
          ),
        ],
      ),
    );
  }
}
