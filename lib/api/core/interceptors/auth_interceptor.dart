import 'package:dio/dio.dart';
import '../../storage/token_storage.dart';

class AuthInterceptor extends Interceptor {
  final TokenStorage tokenStorage;

  AuthInterceptor(this.tokenStorage);

  @override
  void onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await tokenStorage.getToken();

    // Si le token existe, l'ajouter à l'en-tête Authorization
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    // Demander une réponse JSON au serveur Laravel
    options.headers['Accept'] = 'application/json';

    super.onRequest(options, handler);
  }
}
