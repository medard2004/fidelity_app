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
import '../../core/utils/toast_service.dart';
import '../../models/user.dart';
import '../../core/errors/app_error.dart';
import '../../core/errors/error_messages.dart';
import '../../core/errors/form_error_handler.dart';
import '../../widgets/shared/user_avatar.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> with FormErrorHandler {
  void _confirmSignOut(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
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
            onPressed: () async {
              dialogContext.pop(); // fermer la modale
              try {
                await ref.read(authProvider.notifier).signOut();
              } catch (_) {
                // Ignore API errors, local state is already cleared.
              } finally {
                if (context.mounted) {
                  context.go('/auth');
                }
              }
            },
            child: const Text('Se déconnecter'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final user = authState.user;
    final cardsAsync = ref.watch(walletProvider);
    final cards = cardsAsync.valueOrNull ?? [];
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
            // ── En-tête Statique ─────────────────────────────────────────
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

            Divider(
              height: 1,
              color: AppColors.encre.withValues(alpha: 0.06),
            ),

            // ── Contenu Défilant ──────────────────────────────────────────
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                children: [
                  // ── Carte Avatar + Identité ────────────────────────────
                  GestureDetector(
                    onTap: () => context.push('/personal-info'),
                    child: BrassBorderedContainer(
                      backgroundColor: AppColors.porcelaine,
                      radius: AppRadius.card,
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          UserAvatar(
                            fullName: user.fullName,
                            photoUrl: user.photoUrl,
                            localImage: authState.localAvatar,
                            radius: 32,
                            isLoading: false,
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
                                    color:
                                        AppColors.encre.withValues(alpha: 0.65),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  user.memberSince,
                                  style: AppTextStyles.bodySmall(
                                    color:
                                        AppColors.encre.withValues(alpha: 0.5),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.chevron_right_rounded,
                            color: AppColors.encre.withValues(alpha: 0.3),
                            size: 24,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ── Statistiques rapides ────────────────────────────────
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

                  // ── Bannière anniversaire ──────────────────────────────
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

                  // ── Section Parrainage ──────────────────────────────────
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
                            ToastService.showSuccess(
                                'Code parrainage copié dans le presse-papier !');
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

                  // ── Préférences de notification ─────────────────────────
                  _SectionHeader(title: 'PRÉFÉRENCES DE NOTIFICATION'),
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

                  const SizedBox(height: 20),


                  const SizedBox(height: 28),

                  // ── Bouton Déconnexion ──────────────────────────────────
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
