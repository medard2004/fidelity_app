import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../providers/app_providers.dart';
import 'edit_profile_screen.dart'; // Pour EditFieldType

class PersonalInfoScreen extends ConsumerWidget {
  const PersonalInfoScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;
    if (user == null) return const SizedBox.shrink();

    return Scaffold(
      backgroundColor: AppColors.porcelaine,
      appBar: AppBar(
        backgroundColor: AppColors.porcelaine,
        elevation: 0,
        leading: const BackButton(color: AppColors.encre),
        title: Text(
          'INFORMATIONS',
          style: AppTextStyles.monoSmall(color: AppColors.laitonBrosse)
              .copyWith(letterSpacing: 2.5, fontWeight: FontWeight.w500),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          // ── En-tête visuel ────────────────────────────────────────────
          Center(
            child: Column(
              children: [
                Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.vertBouteille,
                    border: Border.all(
                      color: AppColors.laitonBrosse,
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.ombreChaude(opacity: 0.12),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      user.fullName.isNotEmpty
                          ? user.fullName[0].toUpperCase()
                          : '?',
                      style: GoogleFonts.bodoniModa(
                        fontSize: 36,
                        fontWeight: FontWeight.w600,
                        color: AppColors.porcelaine,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  user.fullName.isNotEmpty ? user.fullName : 'Membre Carte',
                  style: GoogleFonts.bodoniModa(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: AppColors.encre,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user.memberSince,
                  style: AppTextStyles.bodySmall(
                    color: AppColors.encre.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),

          // ── Carte d'informations (Cliquables) ─────────────────────────
          Text(
            'Informations personnelles',
            style: AppTextStyles.monoSmall(
              color: AppColors.laitonBrosse,
            ).copyWith(letterSpacing: 1.2, fontWeight: FontWeight.w600),
          ),
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
                _EditableInfoTile(
                  icon: Icons.person_outline,
                  label: 'Nom complet',
                  value: user.fullName.isNotEmpty
                      ? user.fullName
                      : 'Non renseigné',
                  onTap: () => context.push('/edit-profile',
                      extra: EditFieldType.fullName),
                ),
                _divider(),
                _EditableInfoTile(
                  icon: Icons.phone_outlined,
                  label: 'Téléphone',
                  value: user.phoneNumber.isNotEmpty
                      ? user.phoneNumber
                      : 'Non renseigné',
                  onTap: () =>
                      context.push('/edit-profile', extra: EditFieldType.phone),
                ),
                _divider(),
                _EditableInfoTile(
                  icon: Icons.cake_outlined,
                  label: 'Date de naissance',
                  value: user.birthDate != null
                      ? '${user.birthDate!.day.toString().padLeft(2, '0')}/${user.birthDate!.month.toString().padLeft(2, '0')}/${user.birthDate!.year}'
                      : 'Non renseignée',
                  onTap: () => context.push('/edit-profile',
                      extra: EditFieldType.birthDate),
                ),
                _divider(),
                _EditableInfoTile(
                  icon: Icons.email_outlined,
                  label: 'Email',
                  value: (user.email != null && user.email!.isNotEmpty)
                      ? user.email!
                      : 'Non renseigné',
                  onTap: () =>
                      context.push('/edit-profile', extra: EditFieldType.email),
                ),
                _divider(),
                _EditableInfoTile(
                  icon: Icons.public_outlined,
                  label: 'Pays',
                  value: (user.country != null && user.country!.isNotEmpty)
                      ? user.country!
                      : 'Non renseigné',
                  onTap: () => context.push('/edit-profile',
                      extra: EditFieldType.country),
                ),
                _divider(),
                _EditableInfoTile(
                  icon: Icons.location_city_outlined,
                  label: 'Ville',
                  value: (user.city != null && user.city!.isNotEmpty)
                      ? user.city!
                      : 'Non renseignée',
                  onTap: () =>
                      context.push('/edit-profile', extra: EditFieldType.city),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() {
    return Divider(
      height: 1,
      color: AppColors.encre.withValues(alpha: 0.08),
    );
  }
}

class _EditableInfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;

  const _EditableInfoTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isEmpty = value == 'Non renseigné' || value == 'Non renseignée';
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14), // Pour correspondre au container
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.saugePale.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 18, color: AppColors.laitonBrosse),
            ),
            const SizedBox(width: 14),
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
                      color: isEmpty
                          ? AppColors.encre.withValues(alpha: 0.35)
                          : AppColors.encre,
                    ).copyWith(fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: AppColors.encre.withValues(alpha: 0.3),
            ),
          ],
        ),
      ),
    );
  }
}
