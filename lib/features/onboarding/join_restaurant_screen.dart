import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_radius.dart';
import '../../models/loyalty_card.dart';
import '../../providers/wallet_provider.dart';

class JoinRestaurantScreen extends ConsumerStatefulWidget {
  const JoinRestaurantScreen({super.key});

  @override
  ConsumerState<JoinRestaurantScreen> createState() =>
      _JoinRestaurantScreenState();
}

class _JoinRestaurantScreenState extends ConsumerState<JoinRestaurantScreen>
    with SingleTickerProviderStateMixin {
  bool _joining = false;

  // ── Carte démo : Le Comptoir (reproduit fidèlement la maquette) ──────────
  static const _demoCard = LoyaltyCard(
    id: 'card_new_demo',
    restaurantName: 'Le Comptoir',
    restaurantCategory: 'Bistrot de quartier · Cocody',
    mechanic: LoyaltyMechanic.stamps,
    liningColor: Color(0xFF607B6E), // vert sauge foncé — fond dégradé haut
    stampsCurrent: 1,
    stampsGoal: 8,
    fallbackId: 'AWA-90031',
    welcomeOffer: 'Un dessert offert à votre 3e visite',
  );

  // Détail de l'offre affiché sous l'offre principale.
  static const _offerDetail = 'Cumulez 10 tampons pour un menu entier offert.';

  Future<void> _join() async {
    setState(() => _joining = true);
    await Future.delayed(const Duration(milliseconds: 800));
    await ref.read(walletProvider.notifier).joinRestaurant(_demoCard);
    if (mounted) context.go('/wallet');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 600),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        transitionBuilder: (child, animation) => FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.06),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        ),
        child: _joining
            ? _CardRevealScreen(key: const ValueKey('reveal'), card: _demoCard)
            : _JoinScreen(
                key: const ValueKey('join'),
                card: _demoCard,
                offerDetail: _offerDetail,
                onJoin: _join,
              ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Écran principal : rejoindre
// ─────────────────────────────────────────────────────────────────────────────

class _JoinScreen extends StatefulWidget {
  final LoyaltyCard card;
  final String offerDetail;
  final VoidCallback onJoin;

  const _JoinScreen({
    super.key,
    required this.card,
    required this.offerDetail,
    required this.onJoin,
  });

  @override
  State<_JoinScreen> createState() => _JoinScreenState();
}

class _JoinScreenState extends State<_JoinScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();

    _fade = CurvedAnimation(parent: _ctrl, curve: const Interval(0, 0.7, curve: Curves.easeOut));
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Dégradé haut sauge → bas porcelaine (comme la maquette).
    const topColor = Color(0xFF607B6E);
    const bottomColor = Color(0xFFEBE8DC);

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: [0.0, 0.42, 1.0],
          colors: [topColor, Color(0xFFCDD4CE), bottomColor],
        ),
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header avec bouton retour ──────────────────────────────────
            Padding(
              padding: const EdgeInsets.only(left: 8, top: 4),
              child: IconButton(
                onPressed: () => context.go('/wallet'),
                icon: const Icon(Icons.arrow_back,
                    color: AppColors.encre, size: 22),
              ),
            ),

            // ── En-tête établissement ──────────────────────────────────────
            FadeTransition(
              opacity: _fade,
              child: SlideTransition(
                position: _slide,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      // Label "REJOINDRE" laiton
                      Text(
                        'REJOINDRE',
                        style: AppTextStyles.monoSmall(
                          color: AppColors.laitonBrosse,
                        ).copyWith(letterSpacing: 2.5),
                      ),
                      const SizedBox(height: 10),
                      // Nom du restaurant — grand serif
                      Text(
                        widget.card.restaurantName,
                        style: AppTextStyles.displayXL(color: AppColors.encre)
                            .copyWith(height: 1.05),
                      ),
                      const SizedBox(height: 6),
                      // Catégorie · Quartier
                      Text(
                        widget.card.restaurantCategory,
                        style: AppTextStyles.bodyMedium(
                          color: AppColors.encre.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 36),

            // ── Carte offre de bienvenue ───────────────────────────────────
            FadeTransition(
              opacity: CurvedAnimation(
                parent: _ctrl,
                curve: const Interval(0.2, 1.0, curve: Curves.easeOut),
              ),
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.12),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: _ctrl,
                  curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic),
                )),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(22, 20, 22, 22),
                    decoration: BoxDecoration(
                      color: AppColors.porcelaine,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.laitonBrosse.withOpacity(0.35),
                        width: 1.0,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.encre.withOpacity(0.06),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Label "OFFRE DE BIENVENUE"
                        Text(
                          'OFFRE DE BIENVENUE',
                          style: AppTextStyles.monoSmall(
                            color: AppColors.laitonBrosse,
                          ).copyWith(
                            letterSpacing: 2.2,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 14),
                        // Titre de l'offre — serif élégant
                        Text(
                          widget.card.welcomeOffer,
                          style: AppTextStyles.displayMedium(color: AppColors.encre)
                              .copyWith(height: 1.2),
                        ),
                        const SizedBox(height: 10),
                        // Détail / sous-titre
                        Text(
                          widget.offerDetail,
                          style: AppTextStyles.bodyMedium(
                            color: AppColors.encre.withOpacity(0.65),
                          ).copyWith(height: 1.5),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            const Spacer(),

            // ── CTA "Rejoindre le programme" ───────────────────────────────
            FadeTransition(
              opacity: CurvedAnimation(
                parent: _ctrl,
                curve: const Interval(0.4, 1.0, curve: Curves.easeOut),
              ),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
                child: _JoinButton(onTap: widget.onJoin),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Bouton "Rejoindre le programme" — pill vert bouteille, grande hauteur
// ─────────────────────────────────────────────────────────────────────────────

class _JoinButton extends StatefulWidget {
  final VoidCallback onTap;
  const _JoinButton({required this.onTap});

  @override
  State<_JoinButton> createState() => _JoinButtonState();
}

class _JoinButtonState extends State<_JoinButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _pressed ? 0.975 : 1.0,
        duration: const Duration(milliseconds: 110),
        curve: Curves.easeOut,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 19),
          decoration: BoxDecoration(
            color: AppColors.vertBouteille,
            borderRadius: BorderRadius.circular(50), // pill
          ),
          child: Center(
            child: Text(
              'Rejoindre le programme',
              style: AppTextStyles.bodyLarge(color: AppColors.porcelaine)
                  .copyWith(fontWeight: FontWeight.w500, letterSpacing: 0.2),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Écran de confirmation — carte révélée avec animation spring douce
// ─────────────────────────────────────────────────────────────────────────────

class _CardRevealScreen extends StatefulWidget {
  final LoyaltyCard card;
  const _CardRevealScreen({super.key, required this.card});

  @override
  State<_CardRevealScreen> createState() => _CardRevealScreenState();
}

class _CardRevealScreenState extends State<_CardRevealScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 750),
    )..forward();

    _scale = Tween<double>(begin: 0.88, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut),
    );
    _fade = CurvedAnimation(parent: _ctrl, curve: const Interval(0, 0.5, curve: Curves.easeOut));
    _slide = Tween<Offset>(begin: const Offset(0, 0.15), end: Offset.zero)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.porcelaine,
      child: SafeArea(
        child: Center(
          child: FadeTransition(
            opacity: _fade,
            child: SlideTransition(
              position: _slide,
              child: ScaleTransition(
                scale: _scale,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Carte révélée
                      Container(
                        height: 200,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: widget.card.liningColor,
                          borderRadius: BorderRadius.circular(AppRadius.card),
                          border: Border.all(
                            color: AppColors.laitonBrosse.withOpacity(0.5),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.encre.withOpacity(0.15),
                              blurRadius: 30,
                              offset: const Offset(0, 12),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.check_circle_outline,
                                  color: AppColors.porcelaine, size: 34),
                              const SizedBox(height: 10),
                              Text(
                                'Carte créée !',
                                style: AppTextStyles.displayMedium(
                                    color: AppColors.porcelaine),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                widget.card.restaurantName,
                                style: AppTextStyles.bodyMedium(
                                  color: AppColors.porcelaine.withOpacity(0.75),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
