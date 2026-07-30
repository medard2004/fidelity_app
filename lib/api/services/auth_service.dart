import 'package:dio/dio.dart';
import '../core/api_client.dart';
import '../core/api_exceptions.dart';

class AuthService {
  final ApiClient _apiClient;

  AuthService(this._apiClient);

  /// Exemple de méthode de connexion avec email et mot de passe
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _apiClient.dio.post('/login', data: {
        'email': email,
        'password': password,
      });
      return response.data;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw UnauthorizedException('Identifiants incorrects');
      } else if (e.response?.statusCode == 422) {
        // Erreurs de validation de Laravel
        throw ServerException('Erreur de validation des données', statusCode: 422);
      }
      throw ServerException(e.message ?? 'Erreur serveur inconnue', statusCode: e.response?.statusCode);
    } catch (e) {
      throw NetworkException(e.toString());
    }
  }

  // Autres méthodes : register, forgotPassword, etc.
}
