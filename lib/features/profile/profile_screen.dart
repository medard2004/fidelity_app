import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_text_styles.dart';
import '../../providers/app_providers.dart';
import '../../providers/wallet_provider.dart';
import '../../widgets/shared/brass_bordered_container.dart';
import '../../widgets/shared/invitation_button.dart';
import '../../widgets/shared/phone_input_with_country_picker.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  void _openEditProfileModal(BuildContext context, WidgetRef ref, user) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.porcelaine,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _EditProfileModal(user: user),
    );
  }

  void _confirmSignOut(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.porcelaine,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: AppColors.laitonLisere(opacity: 0.3)),
        ),
        title: Text(
          'Déconnexion',
          style: GoogleFonts.bodoniModa(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.encre,
          ),
        ),
        content: Text(
          'Êtes-vous sûr de vouloir vous déconnecter de votre compte Carte ?',
          style: AppTextStyles.bodyMedium(
            color: AppColors.encre.withValues(alpha: 0.7),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Annuler',
              style: AppTextStyles.bodyMedium(
                color: AppColors.encre.withValues(alpha: 0.6),
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.vertBouteille,
              foregroundColor: AppColors.porcelaine,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
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
    final unreadNotifs = ref.watch(notificationsProvider.notifier).unreadCount;

    if (user == null) return const SizedBox.shrink();

    final titleStyle = GoogleFonts.bodoniModa(
      fontSize: 25,
      fontWeight: FontWeight.w600,
      color: AppColors.encre,
      height: 1.1,
    );

    return Scaffold(
      backgroundColor: AppColors.porcelaine,
      body: SafeArea(
        child: Column(
          children: [
            // ── En-tête Statique (Fixe au défilement) ─────────────────────────
            Container(
              color: AppColors.porcelaine,
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ESPACE MEMBRE',
                        style: AppTextStyles.monoSmall(
                          color: AppColors.laitonBrosse,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text('Profil', style: titleStyle),
                    ],
                  ),

                  // Bouton Notification uniforme avec badge
                  GestureDetector(
                    onTap: () => context.push('/notifications'),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.porcelaine,
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                              color: AppColors.laitonLisere(opacity: 0.35),
                            ),
                          ),
                          child: const Icon(
                            Icons.notifications_none,
                            color: AppColors.encre,
                            size: 20,
                          ),
                        ),
                        if (unreadNotifs > 0)
                          Positioned(
                            top: -2,
                            right: -2,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: AppColors.bordeauxProfond,
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                '$unreadNotifs',
                                style: const TextStyle(
                                  color: AppColors.porcelaine,
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Separateur discret sous l'en-tête statique
            Divider(
              height: 1,
              color: AppColors.encre.withValues(alpha: 0.06),
            ),

            // ── Contenu Défilant ──────────────────────────────────────────────
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                children: [
                  // Carte En-tête Utilisateur (Cadre Laiton Brossé)
                  BrassBorderedContainer(
                    backgroundColor: AppColors.porcelaine,
                    radius: AppRadius.card,
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            // Avatar avec initiales
                            Container(
                              width: 64,
                              height: 64,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.vertBouteille,
                                border: Border.all(
                                  color: AppColors.laitonBrosse,
                                  width: 1.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.ombreChaude(opacity: 0.1),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Text(
                                  user.fullName.isNotEmpty
                                      ? user.fullName[0].toUpperCase()
                                      : '?',
                                  style: GoogleFonts.bodoniModa(
                                    fontSize: 26,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.porcelaine,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(width: 16),

                            // Identité
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    user.fullName.isNotEmpty
                                        ? user.fullName
                                        : 'Membre Carte',
                                    style: GoogleFonts.bodoniModa(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.encre,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    user.maskedPhoneNumber,
                                    style: AppTextStyles.monoSmall(
                                      color: AppColors.encre
                                          .withValues(alpha: 0.65),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    user.memberSince,
                                    style: AppTextStyles.bodySmall(
                                      color: AppColors.encre
                                          .withValues(alpha: 0.5),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Bouton d'action "Modifier le profil"
                        InvitationButton(
                          label: 'Modifier le profil',
                          leading: const Icon(
                            Icons.edit_outlined,
                            size: 15,
                            color: AppColors.encre,
                          ),
                          onTap: () =>
                              _openEditProfileModal(context, ref, user),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Statistiques rapides
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          label: 'Cartes',
                          value: '${cards.length}',
                          subtext: 'Actives',
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _StatCard(
                          label: 'Offres',
                          value: '${rewards.length}',
                          subtext: 'Débloquées',
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _StatCard(
                          label: 'Filleuls',
                          value: '${user.friendsJoined}',
                          subtext: 'Rejoints',
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Bannière d'anniversaire (si applicable)
                  if (user.isBirthdayMonth) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color:
                            AppColors.bordeauxProfond.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color:
                              AppColors.bordeauxProfond.withValues(alpha: 0.3),
                        ),
                      ),
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
                                  style: AppTextStyles.label().copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.bordeauxProfond,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Des attentions exclusives vous attendent dans vos restaurants.',
                                  style: AppTextStyles.bodySmall(
                                    color:
                                        AppColors.encre.withValues(alpha: 0.7),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Section Informations Personnelles
                  _SectionHeader(title: 'INFORMATIONS PERSONNELLES'),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.porcelaine,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: AppColors.laitonLisere(opacity: 0.35),
                      ),
                    ),
                    child: Column(
                      children: [
                        _InfoRow(
                          label: 'Nom complet',
                          value: user.fullName.isNotEmpty
                              ? user.fullName
                              : 'Non renseigné',
                          icon: Icons.person_outline,
                        ),
                        const _ItemDivider(),
                        _InfoRow(
                          label: 'Téléphone',
                          value: user.phoneNumber.isNotEmpty
                              ? user.phoneNumber
                              : 'Non renseigné',
                          icon: Icons.phone_outlined,
                        ),
                        const _ItemDivider(),
                        _InfoRow(
                          label: 'Date de naissance',
                          value: user.birthDate != null
                              ? '${user.birthDate!.day.toString().padLeft(2, '0')}/${user.birthDate!.month.toString().padLeft(2, '0')}/${user.birthDate!.year}'
                              : 'Non renseignée',
                          icon: Icons.cake_outlined,
                        ),
                        const _ItemDivider(),
                        _InfoRow(
                          label: 'Email',
                          value: (user.email != null && user.email!.isNotEmpty)
                              ? user.email!
                              : 'Non renseigné',
                          icon: Icons.email_outlined,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Section Parrainage
                  _SectionHeader(title: 'PARRAINAGE EXCLUSIF'),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.saugePale.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: AppColors.laitonLisere(opacity: 0.35),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Votre code invitation',
                                style: AppTextStyles.bodySmall(
                                  color: AppColors.encre.withValues(alpha: 0.6),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                user.referralCode.isNotEmpty
                                    ? user.referralCode
                                    : 'CARTE-MEMBRE',
                                style: AppTextStyles.monoMedium(
                                  color: AppColors.vertBouteille,
                                ).copyWith(
                                    fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Clipboard.setData(
                              ClipboardData(text: user.referralCode),
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    'Code parrainage copié dans le presse-papier !'),
                                behavior: SnackBarBehavior.floating,
                                duration: Duration(seconds: 2),
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: AppColors.vertBouteille,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.copy_rounded,
                                  size: 14,
                                  color: AppColors.porcelaine,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Copier',
                                  style: AppTextStyles.label(
                                    color: AppColors.porcelaine,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Section Notifications par Restaurant
                  _SectionHeader(title: 'PREFERENCES DE NOTIFICATION'),
                  const SizedBox(height: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.porcelaine,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: AppColors.laitonLisere(opacity: 0.35),
                      ),
                    ),
                    child: Column(
                      children: cards
                          .map<Widget>(
                            (card) =>
                                _NotifToggleRow(name: card.restaurantName),
                          )
                          .toList(),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Bouton Se déconnecter
                  Center(
                    child: TextButton.icon(
                      onPressed: () => _confirmSignOut(context, ref),
                      icon: Icon(
                        Icons.logout_rounded,
                        size: 16,
                        color: AppColors.bordeauxProfond.withValues(alpha: 0.8),
                      ),
                      label: Text(
                        'Se déconnecter',
                        style: AppTextStyles.bodyMedium(
                          color:
                              AppColors.bordeauxProfond.withValues(alpha: 0.9),
                        ).copyWith(fontWeight: FontWeight.w600),
                      ),
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
  final dynamic user;
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
      const SnackBar(
        content: Text('Profil mis à jour avec succès !'),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ),
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
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Form(
                key: _formKey,
                child: ListView(
                  controller: scrollController,
                  children: [
                    // Handle
                    Center(
                      child: Container(
                        width: 36,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppColors.encre.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    Text(
                      'Modifier le profil',
                      style: GoogleFonts.bodoniModa(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        color: AppColors.encre,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Nom complet
                    Text('Nom complet', style: AppTextStyles.label()),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _fullNameController,
                      style: AppTextStyles.bodyMedium(),
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Veuillez saisir votre nom complet'
                          : null,
                      decoration: InputDecoration(
                        hintText: 'Prénom Nom',
                        filled: true,
                        fillColor: AppColors.saugePale.withValues(alpha: 0.4),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                              color: AppColors.laitonLisere(opacity: 0.3)),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Téléphone
                    Text('Numéro de téléphone', style: AppTextStyles.label()),
                    const SizedBox(height: 6),
                    PhoneInputWithCountryPicker(
                      key: _phoneInputKey,
                      controller: _phoneController,
                    ),

                    const SizedBox(height: 16),

                    // Date de naissance
                    Text('Date de naissance', style: AppTextStyles.label()),
                    const SizedBox(height: 6),
                    GestureDetector(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _birthDate ?? DateTime(2000, 1, 1),
                          firstDate: DateTime(1930),
                          lastDate: DateTime.now(),
                        );
                        if (picked != null) {
                          setState(() => _birthDate = picked);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 12),
                        decoration: BoxDecoration(
                          color: AppColors.saugePale.withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: AppColors.laitonLisere(opacity: 0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                _birthDate == null
                                    ? 'Sélectionner une date'
                                    : '${_birthDate!.day.toString().padLeft(2, '0')}/${_birthDate!.month.toString().padLeft(2, '0')}/${_birthDate!.year}',
                                style: AppTextStyles.bodyMedium(
                                  color: _birthDate == null
                                      ? AppColors.encre.withValues(alpha: 0.35)
                                      : AppColors.encre,
                                ),
                              ),
                            ),
                            const Icon(
                              Icons.calendar_today_outlined,
                              size: 16,
                              color: AppColors.laitonBrosse,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Email
                    Text('Email', style: AppTextStyles.label()),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      style: AppTextStyles.bodyMedium(),
                      decoration: InputDecoration(
                        hintText: 'votre@email.com',
                        filled: true,
                        fillColor: AppColors.saugePale.withValues(alpha: 0.4),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                              color: AppColors.laitonLisere(opacity: 0.3)),
                        ),
                      ),
                    ),

                    const SizedBox(height: 28),

                    InvitationButton(
                      label: 'Enregistrer les modifications',
                      filled: true,
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

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final String subtext;

  const _StatCard({
    required this.label,
    required this.value,
    required this.subtext,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
      decoration: BoxDecoration(
        color: AppColors.porcelaine,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.laitonLisere(opacity: 0.3)),
      ),
      child: Column(
        children: [
          Text(
            label.toUpperCase(),
            style: AppTextStyles.monoSmall(color: AppColors.laitonBrosse)
                .copyWith(fontSize: 10),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.bodoniModa(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppColors.vertBouteille,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtext,
            style: AppTextStyles.bodySmall(
              color: AppColors.encre.withValues(alpha: 0.5),
            ).copyWith(fontSize: 11),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: AppTextStyles.monoSmall(
        color: AppColors.laitonBrosse,
      ).copyWith(letterSpacing: 1.2, fontWeight: FontWeight.w600),
    );
  }
}

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
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.laitonBrosse),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.bodySmall(
                    color: AppColors.encre.withValues(alpha: 0.5),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: AppTextStyles.bodyMedium(
                    color: AppColors.encre,
                  ).copyWith(fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ItemDivider extends StatelessWidget {
  const _ItemDivider();
  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      color: AppColors.encre.withValues(alpha: 0.08),
    );
  }
}

class _NotifToggleRow extends StatefulWidget {
  final String name;
  const _NotifToggleRow({required this.name});

  @override
  State<_NotifToggleRow> createState() => _NotifToggleRowState();
}

class _NotifToggleRowState extends State<_NotifToggleRow> {
  bool _enabled = true;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              widget.name,
              style: AppTextStyles.bodyMedium(color: AppColors.encre),
            ),
          ),
          Switch(
            value: _enabled,
            onChanged: (v) => setState(() => _enabled = v),
            activeThumbColor: AppColors.vertBouteille,
            inactiveThumbColor: AppColors.porcelaine,
            trackColor: WidgetStateProperty.resolveWith<Color?>((states) {
              if (states.contains(WidgetState.selected)) {
                return AppColors.vertBouteille.withValues(alpha: 0.3);
              }
              return AppColors.encre.withValues(alpha: 0.15);
            }),
          ),
        ],
      ),
    );
  }
}
