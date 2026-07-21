import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_radius.dart';
import '../../widgets/shared/brass_bordered_container.dart';
import '../../widgets/shared/invitation_button.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingSlideData> _slides = [
    OnboardingSlideData(
      title: "L'Écrin de vos Cartes",
      subtitle: "Rassemblez toutes vos cartes de fidélité dans un seul portefeuille minimaliste et élégant.",
      visualBuilder: (context, active) => _WalletVisual(active: active),
    ),
    OnboardingSlideData(
      title: "Privilèges Uniques",
      subtitle: "Gagnez des tampons à chaque visite et obtenez des avantages exclusifs chez vos restaurateurs favoris.",
      visualBuilder: (context, active) => _RewardsVisual(active: active),
    ),
    OnboardingSlideData(
      title: "Partager l'Élégance",
      subtitle: "Invitez vos proches et débloquez des avantages exceptionnels grâce à votre code de parrainage exclusif.",
      visualBuilder: (context, active) => _ReferralVisual(active: active),
    ),
  ];

  void _onPageChanged(int index) {
    setState(() {
      _currentPage = index;
    });
  }

  void _onNext() {
    if (_currentPage < _slides.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    } else {
      context.go('/signup');
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.porcelaine,
      body: SafeArea(
        child: Column(
          children: [
            // Header with Skip Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Page number indicator in IBM Plex Mono (e.g., 01/03)
                  Text(
                    "0${_currentPage + 1} / 0${_slides.length}",
                    style: AppTextStyles.monoMedium(
                      color: AppColors.encre.withOpacity(0.5),
                    ),
                  ),
                  TextButton(
                    onPressed: () => context.go('/signup'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.encre.withOpacity(0.6),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                    child: Text(
                      "Passer",
                      style: AppTextStyles.bodyMedium(
                        color: AppColors.encre.withOpacity(0.6),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // PageView content
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                itemCount: _slides.length,
                itemBuilder: (context, index) {
                  final slide = _slides[index];
                  final active = _currentPage == index;
                  return _OnboardingSlide(
                    slide: slide,
                    active: active,
                  );
                },
              ),
            ),

            // Bottom Navigation Area
            Padding(
              padding: const EdgeInsets.all(28.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Smooth Dots Indicator
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _slides.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        height: 6,
                        width: _currentPage == index ? 24 : 6,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? AppColors.vertBouteille
                              : AppColors.saugePale,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Call to Action (Next / Get Started)
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: InvitationButton(
                      key: ValueKey(_currentPage == _slides.length - 1),
                      label: _currentPage == _slides.length - 1
                          ? "Commencer l'expérience"
                          : "Continuer",
                      filled: true,
                      onTap: _onNext,
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

  const _OnboardingSlide({
    required this.slide,
    required this.active,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Visual Container with smooth scale transition
          Expanded(
            child: Center(
              child: TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeOutBack,
                tween: Tween(begin: 0.9, end: active ? 1.0 : 0.9),
                builder: (context, scale, child) {
                  return Transform.scale(
                    scale: scale,
                    child: child,
                  );
                },
                child: slide.visualBuilder(context, active),
              ),
            ),
          ),
          const SizedBox(height: 32),

          // Title with Bodoni Moda
          AnimatedOpacity(
            duration: const Duration(milliseconds: 400),
            opacity: active ? 1.0 : 0.0,
            child: Text(
              slide.title,
              style: AppTextStyles.displayLarge(),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 16),

          // Subtitle with Public Sans
          AnimatedOpacity(
            duration: const Duration(milliseconds: 500),
            opacity: active ? 0.75 : 0.0,
            child: Text(
              slide.subtitle,
              style: AppTextStyles.bodyMedium(color: AppColors.encre),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

/// Visual 1: Elegant Stacked Loyalty Cards
class _WalletVisual extends StatelessWidget {
  final bool active;
  const _WalletVisual({required this.active});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: SizedBox(
          height: 320,
          width: 320,
          child: Stack(
            alignment: Alignment.center,
            children: [
          // Rear Card (Bordeaux)
          AnimatedPositioned(
            duration: const Duration(milliseconds: 700),
            curve: Curves.easeOutBack,
            left: active ? 45 : 70,
            top: active ? 40 : 50,
            child: Transform.rotate(
              angle: active ? -0.12 : -0.05,
              child: Container(
                width: 220,
                height: 135,
                decoration: BoxDecoration(
                  color: AppColors.bordeauxProfond,
                  borderRadius: BorderRadius.circular(AppRadius.card),
                  border: Border.all(
                    color: AppColors.laitonLisere(opacity: 0.4),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.ombreChaude(opacity: 0.15),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Le Palais",
                      style: GoogleFonts.bodoniModa(
                        color: AppColors.porcelaine,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.laitonBrosse, width: 1),
                          ),
                          child: const Center(
                            child: Icon(Icons.star_border, size: 10, color: AppColors.laitonBrosse),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Front Card (Vert Bouteille)
          AnimatedPositioned(
            duration: const Duration(milliseconds: 700),
            curve: Curves.easeOutBack,
            right: active ? 40 : 65,
            bottom: active ? 40 : 50,
            child: Transform.rotate(
              angle: active ? 0.06 : 0.0,
              child: Container(
                width: 230,
                height: 145,
                decoration: BoxDecoration(
                  color: AppColors.vertBouteille,
                  borderRadius: BorderRadius.circular(AppRadius.card),
                  border: Border.all(
                    color: AppColors.laitonLisere(opacity: 0.65),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.ombreChaude(opacity: 0.22),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
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
                            "Chez Awa",
                            style: GoogleFonts.bodoniModa(
                              color: AppColors.porcelaine,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.qr_code,
                          color: AppColors.laitonBrosse,
                          size: 20,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Stamps dots representation
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
                                ? AppColors.laitonBrosse
                                : AppColors.porcelaine.withOpacity(0.2),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            "N° 8903-AWA",
                            style: AppTextStyles.monoSmall(color: AppColors.porcelaine),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "3 / 8 Tampons",
                          style: AppTextStyles.monoSmall(color: AppColors.laitonBrosse),
                        ),
                      ],
                    ),
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

/// Visual 2: Elegant Stamp Grid Card
class _RewardsVisual extends StatelessWidget {
  final bool active;
  const _RewardsVisual({required this.active});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: SizedBox(
          height: 320,
          width: 320,
          child: Center(
            child: BrassBorderedContainer(
              backgroundColor: AppColors.porcelaine,
              radius: AppRadius.card,
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
              Text(
                "CARTE DE FIDÉLITÉ",
                style: AppTextStyles.monoSmall(color: AppColors.laitonBrosse),
              ),
              const SizedBox(height: 4),
              Text(
                "Chez Awa",
                style: AppTextStyles.displayMedium(),
              ),
              const SizedBox(height: 20),

              // 2 x 4 Stamps grid representation
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(4, (index) => _buildStamp(index)),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(4, (index) => _buildStamp(index + 4)),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.saugePale.withOpacity(0.35),
                  borderRadius: BorderRadius.circular(AppRadius.chip),
                  border: Border.all(
                    color: AppColors.laitonLisere(opacity: 0.25),
                  ),
                ),
                child: Text(
                  "Offre : 1 plat offert après 8 tampons",
                  style: AppTextStyles.bodySmall(color: AppColors.encre),
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
    // 5 stamps are marked (indexes 0 to 4)
    final stamped = index < 5;
    return AnimatedContainer(
      duration: Duration(milliseconds: 300 + (index * 70)),
      curve: Curves.easeOutBack,
      margin: const EdgeInsets.symmetric(horizontal: 6),
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: stamped && active ? AppColors.vertBouteille : Colors.transparent,
        border: Border.all(
          color: stamped ? AppColors.vertBouteille : AppColors.laitonLisere(opacity: 0.45),
          width: stamped ? 1.5 : 1,
          style: stamped ? BorderStyle.solid : BorderStyle.solid,
        ),
      ),
      child: Center(
        child: stamped
            ? const Icon(
                Icons.check,
                color: AppColors.laitonBrosse,
                size: 16,
              )
            : Text(
                "${index + 1}",
                style: AppTextStyles.monoSmall(
                  color: AppColors.encre.withOpacity(0.35),
                ),
              ),
      ),
    );
  }
}

/// Visual 3: Elegant Invitation / Referral Card
class _ReferralVisual extends StatelessWidget {
  final bool active;
  const _ReferralVisual({required this.active});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: SizedBox(
          height: 320,
          width: 320,
          child: Center(
            child: Container(
              width: 280,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
            color: AppColors.porcelaine,
            borderRadius: BorderRadius.circular(AppRadius.card),
            border: Border.all(
              color: AppColors.laitonBrosse,
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.ombreChaude(opacity: 0.12),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Double brass line accent
              Container(
                height: 1,
                width: 40,
                color: AppColors.laitonBrosse,
              ),
              const SizedBox(height: 10),
              Text(
                "CARTON D'INVITATION",
                style: GoogleFonts.bodoniModa(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.encre,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                "Partagez votre privilège :",
                style: AppTextStyles.bodySmall(color: AppColors.encre.withOpacity(0.8)),
              ),
              const SizedBox(height: 10),
              // Referral code display block
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  color: AppColors.saugePale.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(AppRadius.chip),
                  border: Border.all(
                    color: AppColors.laitonLisere(opacity: 0.3),
                  ),
                ),
                child: Center(
                  child: Text(
                    "AURA-7590",
                    style: AppTextStyles.monoLarge(color: AppColors.vertBouteille),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Simulated link button
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.copy_rounded, size: 14, color: AppColors.laitonBrosse),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      "Copier l'invitation",
                      style: AppTextStyles.label(color: AppColors.laitonBrosse),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // Double brass line accent
              Container(
                height: 1,
                width: 40,
                color: AppColors.laitonBrosse,
              ),
            ],
          ),
        ),
      ),
    ),
    ),
    );
  }
}
