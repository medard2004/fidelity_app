import 'package:flutter/material.dart';

/// Un wrapper PopScope qui, si le clavier est ouvert, intercepte l'appui sur le 
/// bouton "Retour" pour fermer uniquement le clavier au lieu de quitter la page.
class KeyboardDismissPopScope extends StatelessWidget {
  final Widget child;
  final bool canPop;

  const KeyboardDismissPopScope({
    super.key,
    required this.child,
    this.canPop = true,
  });

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
        } else if (canPop) {
          // Sinon, on recule manuellement dans la navigation si autorisé.
          Navigator.of(context).pop();
        }
      },
      child: child,
    );
  }
}
