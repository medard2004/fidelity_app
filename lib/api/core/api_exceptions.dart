class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, {this.statusCode});

  @override
  String toString() => 'ApiException: $message (Status: $statusCode)';
}

class NetworkException extends ApiException {
  NetworkException(super.message);
}

class UnauthorizedException extends ApiException {
  UnauthorizedException(super.message, {super.statusCode = 401});
}

class ServerException extends ApiException {
  ServerException(super.message, {super.statusCode});
}

/// Erreur de validation renvoyée par l'API (HTTP 422, ou 429 sur une règle de
/// limitation attachée à un champ).
///
/// [fieldErrors] reprend le sac d'erreurs Laravel (`{champ: [messages]}`) tel
/// quel. Ce contenu est **technique et destiné à la traduction uniquement** :
/// il ne doit jamais être affiché directement. `ErrorTranslator` le convertit
/// en messages du catalogue avant tout affichage.
class ValidationException extends ApiException {
  final Map<String, List<String>> fieldErrors;

  ValidationException(
    super.message, {
    this.fieldErrors = const {},
    super.statusCode = 422,
  });

  /// Construit l'exception à partir du corps de réponse Laravel.
  factory ValidationException.fromResponse(dynamic data, {int? statusCode}) {
    final errors = <String, List<String>>{};
    String message = 'Validation failed';

    if (data is Map) {
      if (data['errors'] is Map) {
        (data['errors'] as Map).forEach((key, value) {
          if (value is List) {
            errors[key.toString()] =
                value.map((e) => e.toString()).toList(growable: false);
          } else if (value != null) {
            errors[key.toString()] = [value.toString()];
          }
        });
      }
      if (data['message'] != null) message = data['message'].toString();
    }

    return ValidationException(
      message,
      fieldErrors: errors,
      statusCode: statusCode ?? 422,
    );
  }

  bool get hasFieldErrors => fieldErrors.isNotEmpty;
}
