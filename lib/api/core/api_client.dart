import 'package:dio/dio.dart';
import '../config/api_constants.dart';
import 'interceptors/auth_interceptor.dart';
import '../storage/token_storage.dart';

class ApiClient {
  late final Dio _dio;

  ApiClient({required TokenStorage tokenStorage}) {
    _dio = Dio(BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(milliseconds: ApiConstants.connectTimeout),
      receiveTimeout: const Duration(milliseconds: ApiConstants.receiveTimeout),
      responseType: ResponseType.json,
    ));

    // Ajout des intercepteurs
    _dio.interceptors.addAll([
      AuthInterceptor(tokenStorage),
      // Affiche les logs dans la console pendant le développement
      LogInterceptor(
        request: true,
        requestHeader: true,
        requestBody: true,
        responseHeader: true,
        responseBody: true,
        error: true,
      ),
    ]);
  }

  Dio get dio => _dio;
}
