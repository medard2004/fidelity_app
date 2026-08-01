import 'package:flutter/widgets.dart';
import '../utils/toast_service.dart';
import 'app_error.dart';
import 'error_translator.dart';
import '../utils/loading_overlay_service.dart';

/// Aiguillage unique des erreurs pour les écrans à formulaire.
///
/// Se greffe sur n'importe quel `State` (y compris `ConsumerState`) et applique
/// la règle d'affichage du projet :
///   1. erreur de champ  → sous le champ concerné ;
///   2. erreur générale  → Toast d'erreur ;
///   3. succès           → Toast de confirmation.
///
/// Utilisation type :
/// ```dart
/// class _MonEcranState extends ConsumerState<MonEcran> with FormErrorHandler {
///   final _formKey = GlobalKey<FormState>();
///
///   TextFormField(
///     validator: fieldValidator('phone', required: true),
///     onChanged: (_) => clearFieldError('phone'),
///   )
///
///   try {
///     ...
///     showSuccessToast(ErrorMessages.profileSaveSuccess);
///   } catch (e) {
///     handleError(e, context: ErrorContext.updateProfile, formKey: _formKey);
///   }
/// }
/// ```
mixin FormErrorHandler<T extends StatefulWidget> on State<T> {
  final Map<String, String> _fieldErrors = {};
  bool _busy = false;

  /// Vrai pendant qu'une opération lancée par [runGuarded] est en cours.
  ///
  /// Sert uniquement à désactiver le bouton correspondant (`onTap: isBusy ?
  /// null : _handler`) : la latence native de Google/Apple Sign-In laisse
  /// largement le temps à un utilisateur impatient de taper deux fois, ce qui
  /// lancerait deux connexions concurrentes sans cette protection. Aucun
  /// indicateur de chargement n'y est associé.
  bool get isBusy => _busy;

  /// Message d'erreur serveur en attente d'affichage pour [field].
  String? fieldError(String field) => _fieldErrors[field];

  /// Efface l'erreur d'un champ — à appeler dès que l'utilisateur le corrige,
  /// sinon le message resterait affiché alors que la saisie a changé.
  void clearFieldError(String field) {
    if (_fieldErrors.remove(field) != null && mounted) {
      setState(() {});
    }
  }

  void clearAllFieldErrors() {
    if (_fieldErrors.isNotEmpty && mounted) {
      setState(_fieldErrors.clear);
    }
  }

  /// Traduit [error] puis l'affiche par le bon canal.
  ///
  /// [formKey] permet de relancer la validation du formulaire pour que les
  /// erreurs serveur apparaissent immédiatement sous les champs.
  /// Retourne l'[AppError] traduite, si l'écran doit réagir plus finement.
  AppError handleError(
    Object? error, {
    required ErrorContext context,
    GlobalKey<FormState>? formKey,
    bool silentOnCancel = true,
  }) {
    if (silentOnCancel && ErrorTranslator.isUserCancellation(error)) {
      return const AppError();
    }

    final appError = ErrorTranslator.translate(error, context: context);

    if (appError.hasFieldErrors) {
      _fieldErrors
        ..clear()
        ..addAll(appError.fieldErrors);
      if (mounted) setState(() {});
      // Déclenche l'affichage des messages sous les champs.
      formKey?.currentState?.validate();
    }

    if (appError.hasGeneralMessage) {
      ToastService.showError(appError.generalMessage!);
    }

    return appError;
  }

  /// Exécute [action] avec protection contre les doubles soumissions.
  ///
  /// N'affiche rien : le seul effet observable est [isBusy], qui sert à
  /// désactiver le bouton déclencheur le temps de l'appel.
  ///
  /// [isBusy] repasse toujours à `false` à la fin, même en cas d'exception
  /// (le bouton ne peut pas rester désactivé indéfiniment).
  ///
  /// L'appelant reste responsable de vérifier `isBusy` avant d'invoquer cette
  /// méthode (typiquement via `onTap: isBusy ? null : _handler`) plutôt que de
  /// compter sur le no-op silencieux du garde ci-dessous.
  Future<R?> runGuarded<R>(
    Future<R> Function() action, {
    bool useOverlay = false,
    String? loadingMessage,
  }) async {
    if (_busy) return null;
    if (mounted) setState(() => _busy = true);
    
    if (useOverlay) {
      LoadingOverlayService.show(message: loadingMessage);
    }
    
    try {
      return await action();
    } finally {
      if (useOverlay) {
        await LoadingOverlayService.hide();
      }
      if (mounted) setState(() => _busy = false);
    }
  }

  /// Toast de confirmation. Passe par le mixin pour que tous les écrans
  /// utilisent le même canal.
  void showSuccessToast(String message) => ToastService.showSuccess(message);

  /// Toast d'erreur pour un cas décidé localement (validation purement client
  /// qui ne se rattache à aucun champ).
  void showErrorToast(String message) => ToastService.showError(message);

  /// Validateur prêt à l'emploi combinant la validation locale et l'erreur
  /// serveur éventuelle pour ce champ.
  ///
  /// [requiredMessage] non nul rend le champ obligatoire ; [extra] permet
  /// d'ajouter une règle métier (longueur, correspondance…).
  FormFieldValidator<String> fieldValidator(
    String field, {
    String? requiredMessage,
    String? Function(String value)? extra,
  }) {
    return (value) {
      final v = value?.trim() ?? '';
      if (requiredMessage != null && v.isEmpty) return requiredMessage;
      if (extra != null && v.isNotEmpty) {
        final local = extra(v);
        if (local != null) return local;
      }
      return _fieldErrors[field];
    };
  }
}
