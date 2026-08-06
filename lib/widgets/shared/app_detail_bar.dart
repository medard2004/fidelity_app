import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../core/theme/app_colors.dart';
import '../components/app_tap_scale.dart';
import '../components/section_eyebrow.dart';

/// Barre standard des écrans secondaires atteints par push (détail de
/// carte, notifications, OTP...) : bouton retour, titre centré au format
/// eyebrow, action optionnelle à droite. S'appuie sur [AppBar] pour
/// hériter gratuitement de la gestion de la zone sûre et du thème
/// global (fond, élévation) — seuls le titre, l'action et le retour
/// varient d'un écran à l'autre. Pendant du [AppSectionHeader] pour les
/// pages qui ne sont pas des racines d'onglet.
class AppDetailBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Widget? trailing;
  final VoidCallback? onBack;

  const AppDetailBar({
    super.key,
    required this.title,
    this.trailing,
    this.onBack,
  });

  @override
  Size get preferredSize => const Size.fromHeight(52);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      toolbarHeight: preferredSize.height,
      centerTitle: true,
      leadingWidth: 44,
      leading: Center(
        child: AppTapScale(
          onTap: onBack ?? () => context.pop(),
          child: Icon(LucideIcons.arrowLeft, color: AppColors.ink, size: 20),
        ),
      ),
      title: SectionEyebrow(title),
      actions: trailing == null
          ? null
          : [
              Padding(
                padding: const EdgeInsets.only(right: 14),
                child: trailing,
              ),
            ],
    );
  }
}
