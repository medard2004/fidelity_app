import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../l10n/gen/app_localizations.dart';
import '../../providers/app_providers.dart';
import '../../providers/settings_provider.dart';
import '../../providers/wallet_provider.dart';
import '../../widgets/components/components.dart';
import '../../widgets/shared/app_detail_bar.dart';

/// Paramètres — apparence (clair/sombre/système), langue, notifications
/// par établissement et déconnexion. Regroupe ce qui encombrait
/// auparavant l'écran Profil pour lui laisser une lecture directe.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  void _confirmSignOut(
      BuildContext context, WidgetRef ref, AppLocalizations t) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(t.settingsSignOutConfirmTitle,
            style: AppTextStyles.titleMedium().copyWith(fontSize: 18)),
        content: Text(
          t.settingsSignOutConfirmMessage,
          style:
              AppTextStyles.bodyMedium(color: AppColors.inkMuted(opacity: 0.7)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(t.commonCancel,
                style: AppTextStyles.bodyMedium(
                    color: AppColors.inkMuted(opacity: 0.6))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(minimumSize: const Size(0, 40)),
            onPressed: () {
              Navigator.pop(context);
              ref.read(authProvider.notifier).signOut();
              context.go('/auth');
            },
            child: Text(t.settingsSignOut),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context)!;
    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);
    final cards = ref.watch(walletProvider);

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppDetailBar(title: t.settingsTitle),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        children: [
          SectionEyebrow(t.settingsAppearance),
          const SizedBox(height: 8),
          AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                _OptionRow(
                  icon: LucideIcons.sun,
                  label: t.settingsThemeLight,
                  selected: themeMode == ThemeMode.light,
                  onTap: () => ref
                      .read(themeModeProvider.notifier)
                      .setThemeMode(ThemeMode.light),
                ),
                Divider(height: 1, color: AppColors.border),
                _OptionRow(
                  icon: LucideIcons.moon,
                  label: t.settingsThemeDark,
                  selected: themeMode == ThemeMode.dark,
                  onTap: () => ref
                      .read(themeModeProvider.notifier)
                      .setThemeMode(ThemeMode.dark),
                ),
                Divider(height: 1, color: AppColors.border),
                _OptionRow(
                  icon: LucideIcons.monitor,
                  label: t.settingsThemeSystem,
                  selected: themeMode == ThemeMode.system,
                  onTap: () => ref
                      .read(themeModeProvider.notifier)
                      .setThemeMode(ThemeMode.system),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          SectionEyebrow(t.settingsLanguage),
          const SizedBox(height: 8),
          AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                _OptionRow(
                  icon: LucideIcons.languages,
                  label: t.settingsLanguageFrench,
                  selected: locale.languageCode == 'fr',
                  onTap: () => ref
                      .read(localeProvider.notifier)
                      .setLocale(const Locale('fr')),
                ),
                Divider(height: 1, color: AppColors.border),
                _OptionRow(
                  icon: LucideIcons.languages,
                  label: t.settingsLanguageEnglish,
                  selected: locale.languageCode == 'en',
                  onTap: () => ref
                      .read(localeProvider.notifier)
                      .setLocale(const Locale('en')),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          SectionEyebrow(t.settingsNotifications),
          const SizedBox(height: 8),
          AppCard(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                for (int i = 0; i < cards.length; i++) ...[
                  if (i > 0) Divider(height: 1, color: AppColors.border),
                  _NotifToggleRow(
                    cardId: cards[i].id,
                    name: cards[i].restaurantName,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 28),
          Center(
            child: AppButton(
              label: t.settingsSignOut,
              variant: AppButtonVariant.destructive,
              icon: LucideIcons.logOut,
              fullWidth: false,
              height: 44,
              onTap: () => _confirmSignOut(context, ref, t),
            ),
          ),
        ],
      ),
    );
  }
}

class _OptionRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _OptionRow({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppTapScale(
      onTap: onTap,
      scaleDown: 0.99,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 18, color: AppColors.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(label, style: AppTextStyles.bodyMedium()),
            ),
            if (selected)
              const Icon(LucideIcons.check, size: 18, color: AppColors.primary),
          ],
        ),
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
