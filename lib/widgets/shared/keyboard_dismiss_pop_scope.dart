import 'package:flutter/material.dart';

/// Un wrapper PopScope qui, si le clavier est ouvert, intercepte l'appui sur le 
/// bouton "Retour" pour fermer uniquement le clavier au lieu de quitter la page.
///
/// Empêche également l'ouverture automatique du clavier à l'arrivée sur la page
/// en relâchant le focus sur le premier frame rendu.
class KeyboardDismissPopScope extends StatefulWidget {
  final Widget child;
  final bool canPop;

  const KeyboardDismissPopScope({
    super.key,
    required this.child,
    this.canPop = true,
  });

  @override
  State<KeyboardDismissPopScope> createState() =>
      _KeyboardDismissPopScopeState();
}

class _KeyboardDismissPopScopeState extends State<KeyboardDismissPopScope> {
  @override
  void initState() {
    super.initState();
    // Relâche le focus sur le premier frame pour éviter que le clavier
    // s'ouvre automatiquement à l'entrée sur la page.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) FocusScope.of(context).unfocus();
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) return;

        final bottomInset = MediaQuery.of(context).viewInsets.bottom;
        if (bottomInset > 0) {
          // Si le clavier est ouvert, on le ferme.
          FocusScope.of(context).unfocus();
        } else if (widget.canPop) {
          // Sinon, on recule manuellement dans la navigation si autorisé.
          Navigator.of(context).pop();
        }
      },
      // GestureDetector pour fermer le clavier en tapant hors d'un champ.
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        behavior: HitTestBehavior.translucent,
        child: widget.child,
      ),
    );
  }
}
