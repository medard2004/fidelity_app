import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../providers/app_providers.dart';
import '../../widgets/shared/user_avatar.dart';
import '../../models/user.dart';
import '../../core/utils/toast_service.dart';
import '../../core/errors/app_error.dart';
import '../../core/errors/error_messages.dart';
import '../../core/errors/form_error_handler.dart';
import 'edit_profile_screen.dart'; // Pour EditFieldType

class PersonalInfoScreen extends ConsumerStatefulWidget {
  const PersonalInfoScreen({super.key});

  @override
  ConsumerState<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends ConsumerState<PersonalInfoScreen>
    with FormErrorHandler {
  Future<void> _showAvatarOptions(AppUser user) {
    final hasPhoto = user.photoUrl != null && user.photoUrl!.isNotEmpty;

    return showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.porcelaine,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 48,
              height: 5,
              decoration: BoxDecoration(
                color: AppColors.encre.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined,
                  color: AppColors.encre),
              title:
                  Text('Prendre une photo', style: AppTextStyles.bodyMedium()),
              onTap: () {
                Navigator.pop(sheetContext);
                _pickAndUploadAvatar(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined,
                  color: AppColors.encre),
              title: Text('Choisir dans la galerie',
                  style: AppTextStyles.bodyMedium()),
              onTap: () {
                Navigator.pop(sheetContext);
                _pickAndUploadAvatar(ImageSource.gallery);
              },
            ),
            if (hasPhoto)
              ListTile(
                leading: const Icon(Icons.delete_outline,
                    color: AppColors.bordeauxProfond),
                title: Text(
                  'Supprimer la photo',
                  style: AppTextStyles.bodyMedium(
                      color: AppColors.bordeauxProfond),
                ),
                onTap: () {
                  Navigator.pop(sheetContext);
                  _removeAvatar();
                },
              ),
            ListTile(
              title: Center(
                child: Text(
                  'Annuler',
                  style: AppTextStyles.bodyMedium(
                      color: AppColors.encre.withValues(alpha: 0.5)),
                ),
              ),
              onTap: () => Navigator.pop(sheetContext),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  /// Affiche une boîte de dialogue expliquant pourquoi l'accès est refusé
  /// et invitant l'utilisateur à ouvrir les paramètres de l'application.
  void _showPermissionDeniedDialog(String source) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.porcelaine,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Accès refusé',
          style: AppTextStyles.bodyLarge().copyWith(fontWeight: FontWeight.w700),
        ),
        content: Text(
          'L\'accès à la $source a été refusé. '
          'Pour changer votre photo de profil, autorisez l\'accès dans les paramètres de votre appareil.',
          style: AppTextStyles.bodyMedium(
            color: AppColors.encre.withValues(alpha: 0.75),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'Annuler',
              style: AppTextStyles.bodyMedium(color: AppColors.laitonBrosse),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              // Ouvrir les paramètres de l'app via un lien deep link Android/iOS
              // si l'utilisateur a un package app_settings; sinon on informe juste.
              ToastService.showError(
                'Ouvrez Paramètres › Applications › [App] › Autorisations pour activer la $source.',
              );
            },
            child: Text(
              'Paramètres',
              style: AppTextStyles.bodyMedium(
                color: AppColors.vertBouteille,
              ).copyWith(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickAndUploadAvatar(ImageSource source) async {
    XFile? picked;
    try {
      picked = await ImagePicker().pickImage(source: source, imageQuality: 90);
    } on PlatformException catch (e) {
      if (!mounted) return;
      final isDenied = e.code == 'camera_access_denied' ||
          e.code == 'photo_access_denied' ||
          e.code == 'camera_access_restricted';
      if (isDenied) {
        _showPermissionDeniedDialog(
          source == ImageSource.camera ? 'caméra' : 'galerie',
        );
      } else {
        ToastService.showError('Impossible d\'ouvrir ${source == ImageSource.camera ? 'la caméra' : 'la galerie'}.');
      }
      return;
    }
    if (picked == null || !mounted) return;

    final CroppedFile? cropped = await ImageCropper().cropImage(
      sourcePath: picked.path,
      aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
      maxWidth: 1024,
      maxHeight: 1024,
      compressFormat: ImageCompressFormat.jpg,
      compressQuality: 85,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Recadrer la photo',
          toolbarColor: AppColors.porcelaine,
          toolbarWidgetColor: AppColors.encre,
          initAspectRatio: CropAspectRatioPreset.square,
          lockAspectRatio: true,
        ),
        IOSUiSettings(
          title: 'Recadrer la photo',
          aspectRatioLockEnabled: true,
        ),
      ],
    );
    if (cropped == null || !mounted) return;

    final croppedFile = File(cropped.path);

    try {
      await runGuarded(
        () => ref.read(authProvider.notifier).updateAvatar(croppedFile),
      );
      if (mounted) showSuccessToast(ErrorMessages.avatarUpdateSuccess);
    } catch (e) {
      if (mounted) handleError(e, context: ErrorContext.updateAvatar);
    }
  }

  Future<void> _removeAvatar() async {
    try {
      await runGuarded(() => ref.read(authProvider.notifier).removeAvatar());
      if (mounted) showSuccessToast(ErrorMessages.avatarRemoveSuccess);
    } catch (e) {
      if (mounted) handleError(e, context: ErrorContext.updateAvatar);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final user = authState.user;
    final localAvatar = authState.localAvatar;

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
                GestureDetector(
                  onTap: isBusy ? null : () => _showAvatarOptions(user),
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      UserAvatar(
                        fullName: user.fullName,
                        photoUrl: user.photoUrl,
                        localImage: localAvatar,
                        radius: 44,
                        isLoading: isBusy,
                      ),
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppColors.vertBouteille,
                          shape: BoxShape.circle,
                          border:
                              Border.all(color: AppColors.porcelaine, width: 2),
                        ),
                        child: const Icon(
                          Icons.camera_alt_rounded,
                          size: 16,
                          color: AppColors.porcelaine,
                        ),
                      ),
                    ],
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
                  onTap: () => context.push('/edit-profile/${EditFieldType.fullName.name}'),
                ),
                _divider(),
                _EditableInfoTile(
                  icon: Icons.phone_outlined,
                  label: 'Téléphone',
                  value: user.phoneNumber.isNotEmpty
                      ? user.phoneNumber
                      : 'Non renseigné',
                  onTap: () =>
                      context.push('/edit-profile/${EditFieldType.phone.name}'),
                ),
                _divider(),
                _EditableInfoTile(
                  icon: Icons.cake_outlined,
                  label: 'Date de naissance',
                  value: user.birthDate != null
                      ? '${user.birthDate!.day.toString().padLeft(2, '0')}/${user.birthDate!.month.toString().padLeft(2, '0')}/${user.birthDate!.year}'
                      : 'Non renseignée',
                  onTap: () => context.push('/edit-profile/${EditFieldType.birthDate.name}'),
                ),
                _divider(),
                _EditableInfoTile(
                  icon: Icons.email_outlined,
                  label: 'Email',
                  value: (user.email != null && user.email!.isNotEmpty)
                      ? user.email!
                      : 'Non renseigné',
                  onTap: () =>
                      context.push('/edit-profile/${EditFieldType.email.name}'),
                ),
                _divider(),
                _EditableInfoTile(
                  icon: Icons.public_outlined,
                  label: 'Pays',
                  value: (user.country != null && user.country!.isNotEmpty)
                      ? user.country!
                      : 'Non renseigné',
                  onTap: () => context.push('/edit-profile/${EditFieldType.country.name}'),
                ),
                _divider(),
                _EditableInfoTile(
                  icon: Icons.location_city_outlined,
                  label: 'Ville',
                  value: (user.city != null && user.city!.isNotEmpty)
                      ? user.city!
                      : 'Non renseignée',
                  onTap: () =>
                      context.push('/edit-profile/${EditFieldType.city.name}'),
                ),
              ],
            ),
          ),

          if (!user.isSocialUser) ...[
            const SizedBox(height: 28),
            Text(
              'Sécurité',
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
                    icon: Icons.lock_outline_rounded,
                    label: 'Modifier le mot de passe',
                    value: '••••••••',
                    onTap: () => context.push('/change-password'),
                  ),
                ],
              ),
            ),
          ],
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
