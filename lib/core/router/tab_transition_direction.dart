/// Direction du dernier changement d'onglet de la bottom nav bar
/// (1 = vers la droite, -1 = vers la gauche) — renseignée par
/// [AppShell] juste avant la navigation, lue par la transition de page
/// pour orienter le léger slide horizontal dans le même sens que le
/// déplacement du doigt sur la barre d'onglets.
int tabSlideDirection = 1;
