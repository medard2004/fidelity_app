import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/router/app_route_observer.dart';
import '../../../models/loyalty_card.dart';
import '../../../providers/wallet_provider.dart';
import 'loyalty_card_widget.dart';

/// Empilement façon Apple Wallet : les cartes se chevauchent
/// verticalement (~70px visibles par carte, assez pour ne jamais
/// tronquer le titre de l'enseigne), légèrement en éventail.
///
/// Supporte le glisser-déposer interactif (drag & drop) avec physique
/// de ressort (Spring), effet de parallaxe tridimensionnelle, inclinaison
/// dynamique au déplacement et retours haptiques.
class LoyaltyCardStack extends ConsumerStatefulWidget {
  final List<LoyaltyCard> cards;
  final ValueChanged<LoyaltyCard> onCardTap;
  final double cardHeight;
  final double peekOffset;

  const LoyaltyCardStack({
    super.key,
    required this.cards,
    required this.onCardTap,
    this.cardHeight = 148,
    this.peekOffset = 70,
  });

  @override
  ConsumerState<LoyaltyCardStack> createState() => _LoyaltyCardStackState();
}

class _LoyaltyCardStackState extends ConsumerState<LoyaltyCardStack>
    with TickerProviderStateMixin
    implements RouteAware {
  late AnimationController _springController;

  /// Anime l'apparition en cascade des cartes au premier affichage de la
  /// pile — chaque carte démarre [_staggerMs] après la précédente et anime
  /// sa propre entrée sur [_singleCardMs].
  late final AnimationController _revealController;

  /// Anime un léger "réveil" de la pile (sans le décalage en cascade)
  /// quand on revient sur le Wallet après avoir fermé le détail d'une
  /// carte — voir [didPopNext]. Démarre déjà résolue (valeur 1.0 = aucun
  /// effet) pour ne jamais affecter le tout premier affichage.
  late final AnimationController _returnPulseController;

  static const _singleCardMs = 650;
  static const _staggerMs = 220;

  bool _routeSubscribed = false;

  int? _draggedIndex;
  int? _hoverIndex;
  int? _pressedIndex;

  late Offset _initialTouchGlobal;
  double _initialTop = 0.0;
  double _currentTop = 0.0;
  double _tiltAngle = 0.0;
  bool _isDragging = false;

  /// Incrémenté à chaque nouveau drag : permet à `_runSpringAnimation` de
  /// détecter qu'un nouveau geste a démarré pendant qu'une animation de
  /// retour précédente se terminait encore, et d'ignorer ce callback périmé.
  int _dragSession = 0;

  @override
  void initState() {
    super.initState();
    _springController = AnimationController.unbounded(vsync: this);
    _springController.addListener(() {
      setState(() {
        _currentTop = _springController.value;
      });
    });
    final total = widget.cards.length;
    final totalRevealMs =
        _singleCardMs + _staggerMs * (total > 0 ? total - 1 : 0);
    _revealController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: totalRevealMs),
    )..forward();
    _returnPulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
      value: 1.0,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (!_routeSubscribed && route is PageRoute<void>) {
      routeObserver.subscribe(this, route);
      _routeSubscribed = true;
    }
  }

  @override
  void dispose() {
    if (_routeSubscribed) routeObserver.unsubscribe(this);
    _springController.dispose();
    _revealController.dispose();
    _returnPulseController.dispose();
    super.dispose();
  }

  @override
  void didPush() {}

  @override
  void didPushNext() {}

  @override
  void didPop() {}

  /// Retour sur le Wallet après fermeture du détail d'une carte — un
  /// souffle léger plutôt qu'un réaffichage figé, sans reproduire toute
  /// l'ouverture en cascade du premier affichage.
  @override
  void didPopNext() {
    _returnPulseController.forward(from: 0.0);
  }

  void _runSpringAnimation(double targetTop) {
    // Capture la session et les indices maintenant : si un nouveau drag
    // démarre avant que cette animation ne se termine, `stop()` complètera
    // quand même ce `.then` (Flutter complète le future même en cas
    // d'annulation), donc on doit comparer la session au lieu de relire
    // les champs d'instance qui auraient déjà été réécrits par le nouveau drag.
    final session = _dragSession;
    final oldIdx = _draggedIndex;
    final newIdx = _hoverIndex;

    const spring = SpringDescription(
      mass: 1.0,
      stiffness: 220.0, // Ressort ferme et réactif
      damping: 20.0, // Amortissement pour éviter les rebonds infinis
    );
    final simulation = SpringSimulation(
      spring,
      _currentTop,
      targetTop,
      0.0,
    );
    _springController.animateWith(simulation).then((_) {
      if (!mounted || session != _dragSession) return;
      if (oldIdx != null && newIdx != null) {
        if (oldIdx != newIdx) {
          ref.read(walletProvider.notifier).reorder(oldIdx, newIdx);
        }
        setState(() {
          _draggedIndex = null;
          _hoverIndex = null;
          _isDragging = false;
          _tiltAngle = 0.0;
        });
        HapticFeedback.mediumImpact();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final total = widget.cards.length;
    final stackHeight = widget.cardHeight + widget.peekOffset * (total - 1);

    return SizedBox(
      height: stackHeight,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          for (int i = 0; i < total; i++)
            _buildStackCard(i, total, stackHeight),
        ],
      ),
    );
  }

  Widget _buildStackCard(int index, int total, double stackHeight) {
    final card = widget.cards[index];
    final isThisDragged = index == _draggedIndex;

    // Position verticale cible de la carte
    double targetTop = widget.peekOffset * index;
    if (_isDragging && _draggedIndex != null && _hoverIndex != null) {
      final dragIdx = _draggedIndex!;
      final hoverIdx = _hoverIndex!;
      if (index != dragIdx) {
        if (dragIdx < hoverIdx) {
          if (index > dragIdx && index <= hoverIdx) {
            targetTop = widget.peekOffset * (index - 1);
          }
        } else if (dragIdx > hoverIdx) {
          if (index >= hoverIdx && index < dragIdx) {
            targetTop = widget.peekOffset * (index + 1);
          }
        }
      }
    }

    final topPos = isThisDragged ? _currentTop : targetTop;
    final isPressed = _pressedIndex == index && !_isDragging;

    // Facteurs d'échelle et profondeur visuelle
    double scaleFactor = 1.0;
    double opacityFactor = 1.0;
    double elevation = 0.0;

    if (_isDragging) {
      if (isThisDragged) {
        scaleFactor = 1.06; // Légère surélévation
        elevation = 20.0; // Ombre marquée de profondeur
      } else {
        scaleFactor = 0.97; // Recul en arrière-plan
        opacityFactor = 0.88; // Transparence pour focus sur la carte active
        elevation = 2.0;
      }
    } else if (isPressed) {
      scaleFactor = 0.965; // Léger tassement au toucher, avant l'ouverture
    }

    final rotationAngle = isThisDragged
        ? _tiltAngle
        : ((index.isEven ? -1 : 1) * 0.0122); // Inclinaison alternée de base

    // Apparition en cascade : la carte `index` démarre `index * 150ms`
    // après la précédente et anime sa propre entrée sur 420ms, le tout
    // exprimé en fraction de la durée totale du contrôleur.
    final totalRevealMs = _revealController.duration!.inMilliseconds;
    final startMs = _staggerMs * index;
    final revealStart = (startMs / totalRevealMs).clamp(0.0, 1.0);
    final revealEnd =
        ((startMs + _singleCardMs) / totalRevealMs).clamp(0.0, 1.0);
    final revealAnim = CurvedAnimation(
      parent: _revealController,
      curve: Interval(revealStart, revealEnd, curve: Curves.easeOutCubic),
    );
    final pulseAnim = CurvedAnimation(
      parent: _returnPulseController,
      curve: Curves.easeOut,
    );

    return AnimatedPositioned(
      key: ValueKey(card.id),
      duration:
          isThisDragged ? Duration.zero : const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
      top: topPos,
      left: 0,
      right: 0,
      child: AnimatedBuilder(
        animation: Listenable.merge([revealAnim, pulseAnim]),
        builder: (context, child) {
          final t = revealAnim.value;
          // Pulse de retour : au repos (p=1) aucun effet ; démarré depuis 0
          // par `didPopNext`, il ramène doucement la carte à son état
          // plein — un souffle, pas une nouvelle ouverture.
          final p = pulseAnim.value;
          final opacity = t.clamp(0.0, 1.0) * (0.92 + 0.08 * p);
          final scale = (0.95 + 0.05 * t) * (0.985 + 0.015 * p);
          // Bascule 3D : la carte part inclinée vers l'arrière (comme posée
          // à plat) et se redresse en montant, avec un très léger écho de
          // la même inclinaison au pulse de retour.
          final tilt = (1 - t) * -0.62 + (1 - p) * -0.09;
          final matrix = Matrix4.identity()
            ..setEntry(3, 2, 0.0016)
            ..translateByDouble(0.0, (1 - t) * 46, 0.0, 1.0)
            ..rotateX(tilt)
            ..scaleByDouble(scale, scale, 1.0, 1.0);
          return Opacity(
            opacity: opacity.clamp(0.0, 1.0),
            child: Transform(
              alignment: Alignment.center,
              transform: matrix,
              child: child,
            ),
          );
        },
        child: AnimatedScale(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          scale: scaleFactor,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            opacity: opacityFactor,
            child: Transform.rotate(
              angle: rotationAngle,
              alignment: Alignment.center,
              child: GestureDetector(
                onTap: () {
                  if (!_isDragging) widget.onCardTap(card);
                },
                onTapDown: (_) {
                  if (!_isDragging) setState(() => _pressedIndex = index);
                },
                onTapUp: (_) {
                  if (_pressedIndex == index) {
                    setState(() => _pressedIndex = null);
                  }
                },
                onTapCancel: () {
                  if (_pressedIndex == index) {
                    setState(() => _pressedIndex = null);
                  }
                },
                onLongPressStart: (details) {
                  if (_isDragging) return;
                  HapticFeedback.lightImpact();
                  _springController
                      .stop(); // Interrompt toute animation en cours
                  setState(() {
                    _dragSession++;
                    _draggedIndex = index;
                    _hoverIndex = index;
                    _isDragging = true;
                    _pressedIndex = null;
                    _initialTouchGlobal = details.globalPosition;
                    _initialTop = widget.peekOffset * index;
                    _currentTop = _initialTop;
                    _tiltAngle = 0.0;
                  });
                },
                onLongPressMoveUpdate: (details) {
                  if (!_isDragging || _draggedIndex != index) return;
                  final deltaY =
                      details.globalPosition.dy - _initialTouchGlobal.dy;
                  final deltaX =
                      details.globalPosition.dx - _initialTouchGlobal.dx;

                  final maxTop = widget.peekOffset * (total - 1);

                  setState(() {
                    _currentTop =
                        (_initialTop + deltaY).clamp(-20.0, maxTop + 30.0);
                    _tiltAngle = (deltaX * 0.0004).clamp(-0.06, 0.06);

                    // Calcul du nouvel index de survol
                    int newHover = (_currentTop + widget.peekOffset / 2) ~/
                        widget.peekOffset;
                    newHover = newHover.clamp(0, total - 1);

                    if (newHover != _hoverIndex) {
                      _hoverIndex = newHover;
                      HapticFeedback
                          .selectionClick(); // Retour haptique de survol
                    }
                  });
                },
                onLongPressEnd: (details) {
                  if (!_isDragging || _draggedIndex != index) return;
                  final targetTop = _hoverIndex! * widget.peekOffset;
                  _runSpringAnimation(targetTop);
                },
                child: Hero(
                  tag: 'card_${card.id}',
                  child: Material(
                    elevation: elevation,
                    borderRadius: BorderRadius.circular(20),
                    shadowColor: Colors.black.withValues(alpha: 0.35),
                    color: Colors.transparent,
                    child: LoyaltyCardWidget(
                        card: card, height: widget.cardHeight),
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
