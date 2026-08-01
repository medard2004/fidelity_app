Améliore l’authentification **Google via Firebase** et la gestion des comptes incomplets.

### Cas à gérer

* Si un utilisateur essaie de se connecter avec un compte Google **non enregistré**, ne pas créer automatiquement le compte. Afficher une erreur claire et demander à l’utilisateur de s’inscrire.
* Si l’utilisateur s’inscrit avec Google mais **ne termine pas le formulaire de création de compte**, enregistrer son état comme **compte incomplet**.
* S’il ferme l’application avant de terminer son profil, lors de sa prochaine connexion avec le même compte Google, il doit être **automatiquement redirigé vers l’étape de complétion du compte**.
* Tant que les informations obligatoires ne sont pas complétées, **bloquer l’accès au reste de l’application**.
* Une fois le compte complété, l’utilisateur accède normalement à l’application.

### Autres cas

Gérer proprement :

* compte Google déjà inscrit → connexion normale ;
* annulation de la connexion ;
* erreur Firebase/réseau ;
* problème de session ;
* compte existant mais incomplet.

Tous les messages d’erreur et de statut doivent utiliser le système global de **Toast Notifications** déjà en place.

Ne pas casser les autres méthodes d’authentification et réutiliser l’architecture existante.
