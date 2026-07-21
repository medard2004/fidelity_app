import 'package:flutter/material.dart';
import '../../../models/loyalty_card.dart';
import 'loyalty_card_widget.dart';

/// Empilement façon Apple Wallet : les cartes se chevauchent
/// verticalement (~64px visibles par carte), légèrement en éventail
/// avec une rotation alternée de 1 à 2 degrés — comme des cartes de
/// visite précieuses posées à la main plutôt qu'un alignement parfait.
class LoyaltyCardStack extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final total = cards.length;
    final stackHeight = cardHeight + peekOffset * (total - 1);

    return SizedBox(
      height: stackHeight,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          for (int i = 0; i < cards.length; i++)
            Positioned(
              top: peekOffset * i,
              left: 0,
              right: 0,
              child: Transform.rotate(
                angle: (i.isEven ? -1 : 1) * 0.0122, // ~0.7°, alterné
                child: GestureDetector(
                  onTap: () => onCardTap(cards[i]),
                  child: Hero(
                    tag: 'card_${cards[i].id}',
                    child: LoyaltyCardWidget(card: cards[i], height: cardHeight),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
