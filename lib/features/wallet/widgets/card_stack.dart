import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/loyalty_card.dart';
import '../../../providers/wallet_provider.dart';
import 'loyalty_card_widget.dart';

/// Empilement façon Apple Wallet : les cartes se chevauchent
/// verticalement (~64px visibles par carte), légèrement en éventail.
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
    this.cardHeight = 190,
    this.peekOffset = 64,
  });

  @override
  ConsumerState<LoyaltyCardStack> createState() => _LoyaltyCardStackState();
}

class _LoyaltyCardStackState extends ConsumerState<LoyaltyCardStack>
    with SingleTickerProviderStateMixin {
  late AnimationController _springController;

  int? _draggedIndex;
  int? _hoverIndex;

  late Offset _initialTouchGlobal;
  double _initialTop = 0.0;
  double _currentTop = 0.0;
  double _tiltAngle = 0.0;
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    _springController = AnimationController.unbounded(vsync: this);
    _springController.addListener(() {
      setState(() {
        _currentTop = _springController.value;
      });
    });
  }

  @override
  void dispose() {
    _springController.dispose();
    super.dispose();
  }

  void _runSpringAnimation(double targetTop) {
    final spring = SpringDescription(
      mass: 1.0,
      stiffness: 220.0, // Ressort ferme et réactif
      damping: 20.0,    // Amortissement pour éviter les rebonds infinis
    );
    final simulation = SpringSimulation(
      spring,
      _currentTop,
      targetTop,
      0.0,
    );
    _springController.animateWith(simulation).then((_) {
      if (_draggedIndex != null && _hoverIndex != null) {
        final oldIdx = _draggedIndex!;
        final newIdx = _hoverIndex!;
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

    // Facteurs d'échelle et profondeur visuelle
    double scaleFactor = 1.0;
    double opacityFactor = 1.0;
    double elevation = 0.0;

    if (_isDragging) {
      if (isThisDragged) {
        scaleFactor = 1.06;   // Légère surélévation
        elevation = 20.0;     // Ombre marquée de profondeur
      } else {
        scaleFactor = 0.97;   // Recul en arrière-plan
        opacityFactor = 0.88; // Transparence pour focus sur la carte active
        elevation = 2.0;
      }
    }

    final rotationAngle = isThisDragged
        ? _tiltAngle
        : ((index.isEven ? -1 : 1) * 0.0122); // Inclinaison alternée de base

    return AnimatedPositioned(
      key: ValueKey(card.id),
      duration: isThisDragged ? Duration.zero : const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
      top: topPos,
      left: 0,
      right: 0,
      child: AnimatedScale(
        duration: const Duration(milliseconds: 220),
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
              onLongPressStart: (details) {
                if (_isDragging) return;
                HapticFeedback.lightImpact();
                _springController.stop(); // Interrompt toute animation en cours
                setState(() {
                  _draggedIndex = index;
                  _hoverIndex = index;
                  _isDragging = true;
                  _initialTouchGlobal = details.globalPosition;
                  _initialTop = widget.peekOffset * index;
                  _currentTop = _initialTop;
                  _tiltAngle = 0.0;
                });
              },
              onLongPressMoveUpdate: (details) {
                if (!_isDragging || _draggedIndex != index) return;
                final deltaY = details.globalPosition.dy - _initialTouchGlobal.dy;
                final deltaX = details.globalPosition.dx - _initialTouchGlobal.dx;

                final maxTop = widget.peekOffset * (total - 1);

                setState(() {
                  _currentTop = (_initialTop + deltaY).clamp(-20.0, maxTop + 30.0);
                  _tiltAngle = (deltaX * 0.0004).clamp(-0.06, 0.06);

                  // Calcul du nouvel index de survol
                  int newHover = (_currentTop + widget.peekOffset / 2) ~/ widget.peekOffset;
                  newHover = newHover.clamp(0, total - 1);

                  if (newHover != _hoverIndex) {
                    _hoverIndex = newHover;
                    HapticFeedback.selectionClick(); // Retour haptique de survol
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
                  shadowColor: Colors.black.withOpacity(0.35),
                  color: Colors.transparent,
                  child: LoyaltyCardWidget(card: card, height: widget.cardHeight),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
