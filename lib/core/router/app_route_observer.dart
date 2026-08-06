import 'package:flutter/material.dart';

/// Observateur de routes partagé — permet aux écrans de la coquille de
/// détecter leur retour au premier plan (ex: après la fermeture du détail
/// d'une carte) via [RouteAware.didPopNext], pour rejouer une animation
/// d'entrée légère plutôt qu'un simple réaffichage figé.
final routeObserver = RouteObserver<PageRoute<void>>();
