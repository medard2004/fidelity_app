import 'package:flutter/widgets.dart';
import '../utils/toast_service.dart';
import '../../widgets/shared/loading_overlay.dart';
import 'app_error.dart';
import 'error_translator.dart';

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

  /// Vrai pendant qu'une opération sous overlay est en cours.
  ///
  /// À utiliser pour désactiver le bouton correspondant (`onTap: isBusy ? null
  /// : _handler`) : la latence native de Google/Apple Sign-In laisse largement
  /// le temps à un utilisateur impatient de taper deux fois, ce qui lancerait
  /// deux connexions concurrentes sans cette protection.
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

  /// Exécute [action] sous l'overlay de chargement, avec une double garantie :
  ///   - [isBusy] repasse toujours à `false` à la fin, même en cas d'exception
  ///     (le bouton ne peut pas rester désactivé indéfiniment) ;
  ///   - l'overlay lui-même disparaît toujours (délégué à `LoadingOverlay.run`).
  ///
  /// L'appelant reste responsable de vérifier `isBusy` avant d'invoquer cette
  /// méthode (typiquement via `onTap: isBusy ? null : _handler`), pour que le
  /// bouton donne un retour visuel immédiat plutôt qu'un no-op silencieux.
  Future<R?> runLoading<R>(
    BuildContext context,
    Future<R> Function() action, {
    required String message,
  }) async {
    if (_busy) return null;
    if (mounted) setState(() => _busy = true);
    try {
      return await LoadingOverlay.run(context, action, message: message);
    } finally {
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
