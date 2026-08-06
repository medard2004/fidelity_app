import 'package:flutter/material.dart';

/// Constantes de mouvement partagées — garantit que toutes les transitions
/// de page et tous les retours de pression de l'app suivent la même
/// vitesse et la même courbe, pour une sensation cohérente d'un écran à
/// l'autre. N'englobe pas les animations de manipulation directe (drag &
/// drop de la pile de cartes), qui relèvent d'une physique de ressort
/// distincte et doivent rester réactives en temps réel plutôt que suivre
/// une durée de page fixe.
class AppMotion {
  AppMotion._();

  /// Transition de page standard (changement d'onglet, ouverture du détail
  /// d'une carte) — dans la fourchette 250-350ms demandée.
  static const pageDuration = Duration(milliseconds: 300);
  static const pageReverseDuration = Duration(milliseconds: 260);
  static const pageCurve = Curves.easeOutCubic;
  static const pageReverseCurve = Curves.easeInCubic;

  /// Retour de pression sur les zones tactiles (boutons, icônes, cartes).
  static const pressDuration = Duration(milliseconds: 110);
  static const pressCurve = Curves.easeOut;

  /// Échelle de pression pour les boutons pleine largeur ([AppButton]).
  static const buttonPressScale = 0.98;

  /// Échelle de pression pour les cibles tactiles compactes (icônes,
  /// onglets) — légèrement plus marquée pour rester perceptible sur une
  /// petite zone.
  static const iconPressScale = 0.90;

  /// Pas de décalage entre éléments d'une animation en cascade (pile de
  /// cartes du Wallet).
  static const staggerStep = Duration(milliseconds: 150);
}
