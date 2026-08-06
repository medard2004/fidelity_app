import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_radius.dart';
import '../../l10n/gen/app_localizations.dart';
import '../../widgets/components/components.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  List<OnboardingSlideData> _slides(AppLocalizations t) => [
        OnboardingSlideData(
          title: t.onboardingSlide1Title,
          subtitle: t.onboardingSlide1Subtitle,
          visualBuilder: (context, active) => _WalletVisual(active: active),
        ),
        OnboardingSlideData(
          title: t.onboardingSlide2Title,
          subtitle: t.onboardingSlide2Subtitle,
          visualBuilder: (context, active) => _RewardsVisual(active: active),
        ),
        OnboardingSlideData(
          title: t.onboardingSlide3Title,
          subtitle: t.onboardingSlide3Subtitle,
          visualBuilder: (context, active) => _ReferralVisual(active: active),
        ),
      ];

  void _onPageChanged(int index) {
    setState(() {
      _currentPage = index;
    });
  }

  void _onNext(int slideCount) {
    if (_currentPage < slideCount - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    } else {
      context.go('/auth');
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final slides = _slides(t);
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '0${_currentPage + 1} / 0${slides.length}',
                    style: AppTextStyles.monoMedium(
                        color: AppColors.inkMuted(opacity: 0.5)),
                  ),
                  TextButton(
                    onPressed: () => context.go('/auth'),
                    child: Text(t.onboardingSkip,
                        style: AppTextStyles.bodyMedium(
                            color: AppColors.inkMuted(opacity: 0.6))),
                  ),
                ],
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                itemCount: slides.length,
                itemBuilder: (context, index) {
                  final slide = slides[index];
                  final active = _currentPage == index;
                  return _OnboardingSlide(slide: slide, active: active);
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(28.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      slides.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        height: 6,
                        width: _currentPage == index ? 24 : 6,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? AppColors.primary
                              : AppColors.surfaceMuted,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: AppButton(
                      key: ValueKey(_currentPage == slides.length - 1),
                      label: _currentPage == slides.length - 1
                          ? t.onboardingStart
                          : t.onboardingContinue,
                      onTap: () => _onNext(slides.length),
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

class OnboardingSlideData {
  final String title;
  final String subtitle;
  final Widget Function(BuildContext context, bool active) visualBuilder;

  OnboardingSlideData({
    required this.title,
    required this.subtitle,
    required this.visualBuilder,
  });
}

class _OnboardingSlide extends StatelessWidget {
  final OnboardingSlideData slide;
  final bool active;

  const _OnboardingSlide({required this.slide, required this.active});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Center(
              child: TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeOutBack,
                tween: Tween(begin: 0.9, end: active ? 1.0 : 0.9),
                builder: (context, scale, child) {
                  return Transform.scale(scale: scale, child: child);
                },
                child: slide.visualBuilder(context, active),
              ),
            ),
          ),
          const SizedBox(height: 32),
          AnimatedOpacity(
            duration: const Duration(milliseconds: 400),
            opacity: active ? 1.0 : 0.0,
            child: Text(
              slide.title,
              style: AppTextStyles.displayLarge(),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 12),
          AnimatedOpacity(
            duration: const Duration(milliseconds: 500),
            opacity: active ? 1.0 : 0.0,
            child: Text(
              slide.subtitle,
              style: AppTextStyles.bodyMedium(
                  color: AppColors.inkMuted(opacity: 0.7)),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

/// Visuel 1 : pile de cartes superposées.
class _WalletVisual extends StatelessWidget {
  final bool active;
  const _WalletVisual({required this.active});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: SizedBox(
          height: 300,
          width: 300,
          child: Stack(
            alignment: Alignment.center,
            children: [
              AnimatedPositioned(
                duration: const Duration(milliseconds: 700),
                curve: Curves.easeOutBack,
                left: active ? 45 : 70,
                top: active ? 40 : 50,
                child: Transform.rotate(
                  angle: active ? -0.1 : -0.04,
                  child: GradientCardSurface(
                    color: AppColors.liningPlum,
                    width: 220,
                    height: 135,
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Le Palais',
                            style:
                                AppTextStyles.titleMedium(color: Colors.white)
                                    .copyWith(fontSize: 14)),
                        const Icon(LucideIcons.star,
                            size: 18, color: Colors.white70),
                      ],
                    ),
                  ),
                ),
              ),
              AnimatedPositioned(
                duration: const Duration(milliseconds: 700),
                curve: Curves.easeOutBack,
                right: active ? 40 : 65,
                bottom: active ? 40 : 50,
                child: Transform.rotate(
                  angle: active ? 0.05 : 0.0,
                  child: GradientCardSurface(
                    color: AppColors.liningIndigo,
                    width: 230,
                    height: 145,
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                'Chez Awa',
                                style: AppTextStyles.titleMedium(
                                        color: Colors.white)
                                    .copyWith(fontSize: 16),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(LucideIcons.qrCode,
                                color: Colors.white70, size: 20),
                          ],
                        ),
                        Row(
                          children: List.generate(
                            5,
                            (index) => Container(
                              margin: const EdgeInsets.only(right: 6),
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: index < 3
                                    ? Colors.white
                                    : Colors.white.withValues(alpha: 0.25),
                              ),
                            ),
                          ),
                        ),
                        Text('3 / 8 TAMPONS',
                            style:
                                AppTextStyles.monoSmall(color: Colors.white70)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Visuel 2 : carte à tampons.
class _RewardsVisual extends StatelessWidget {
  final bool active;
  const _RewardsVisual({required this.active});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: SizedBox(
          height: 300,
          width: 300,
          child: Center(
            child: AppCard(
              elevated: true,
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SectionEyebrow('Carte de fidélité'),
                  const SizedBox(height: 4),
                  Text('Chez Awa', style: AppTextStyles.displayMedium()),
                  const SizedBox(height: 20),
                  Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children:
                            List.generate(4, (index) => _buildStamp(index)),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children:
                            List.generate(4, (index) => _buildStamp(index + 4)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primaryTint,
                      borderRadius: BorderRadius.circular(AppRadius.chip),
                    ),
                    child: Text(
                      'Offre : 1 plat offert après 8 tampons',
                      style:
                          AppTextStyles.bodySmall(color: AppColors.primaryDark),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStamp(int index) {
    final stamped = index < 5;
    return AnimatedContainer(
      duration: Duration(milliseconds: 300 + (index * 70)),
      curve: Curves.easeOutBack,
      margin: const EdgeInsets.symmetric(horizontal: 6),
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: stamped && active ? AppColors.primary : Colors.transparent,
        border: Border.all(
          color: stamped ? AppColors.primary : AppColors.border,
          width: stamped ? 1.5 : 1,
        ),
      ),
      child: Center(
        child: stamped
            ? const Icon(LucideIcons.check, color: Colors.white, size: 16)
            : Text('${index + 1}',
                style: AppTextStyles.monoSmall(
                    color: AppColors.inkMuted(opacity: 0.35))),
      ),
    );
  }
}

/// Visuel 3 : carton d'invitation / parrainage.
class _ReferralVisual extends StatelessWidget {
  final bool active;
  const _ReferralVisual({required this.active});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: SizedBox(
          height: 300,
          width: 300,
          child: Center(
            child: SizedBox(
              width: 280,
              child: AppCard(
                elevated: true,
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SectionEyebrow("Carton d'invitation"),
                    const SizedBox(height: 12),
                    Text(
                      'Partagez votre privilège :',
                      style: AppTextStyles.bodySmall(
                          color: AppColors.inkMuted(opacity: 0.8)),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 16),
                      decoration: BoxDecoration(
                        color: AppColors.primaryTint,
                        borderRadius: BorderRadius.circular(AppRadius.chip),
                      ),
                      child: Center(
                        child: Text('AURA-7590',
                            style: AppTextStyles.monoLarge(
                                color: AppColors.primaryDark)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(LucideIcons.copy,
                            size: 14, color: AppColors.primary),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            "Copier l'invitation",
                            style:
                                AppTextStyles.label(color: AppColors.primary),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
