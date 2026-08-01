import 'dart:io';
import 'package:dio/dio.dart';
import '../core/api_client.dart';
import '../core/api_exceptions.dart';

class AuthService {
  final ApiClient _apiClient;

  AuthService(this._apiClient);

  /// Convertit toute erreur Dio en exception typée du domaine.
  ///
  /// Les messages conservés ici restent techniques : ils servent uniquement à
  /// la reconnaissance de motif par `ErrorTranslator`, qui produit le texte
  /// réellement affiché. Aucun écran ne doit afficher ces messages tels quels.
  Never _throwFromDio(DioException e) {
    final status = e.response?.statusCode;
    final data = e.response?.data;

    // Erreurs de validation : on remonte le sac d'erreurs par champ intact.
    if (status == 422 || status == 429) {
      throw ValidationException.fromResponse(data, statusCode: status);
    }

    if (status == 401) {
      throw UnauthorizedException(_backendMessage(data) ?? 'unauthorized');
    }

    if (status != null) {
      throw ServerException(
        _backendMessage(data) ?? e.message ?? 'server error',
        statusCode: status,
      );
    }

    // Pas de réponse HTTP : problème réseau (coupure, DNS, délai dépassé).
    throw NetworkException(e.message ?? 'network error');
  }

  String? _backendMessage(dynamic data) {
    if (data is Map && data['message'] != null)
      return data['message'].toString();
    return null;
  }

  /// Exécute [request] en normalisant toutes les erreurs.
  Future<T> _guard<T>(Future<T> Function() request) async {
    try {
      return await request();
    } on DioException catch (e) {
      _throwFromDio(e);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw NetworkException(e.toString());
    }
  }

  Future<Map<String, dynamic>> login(String phone, String password) =>
      _guard(() async {
        final response = await _apiClient.dio.post('/auth/login', data: {
          'phone': phone,
          'password': password,
        });
        return response.data as Map<String, dynamic>;
      });

  Future<Map<String, dynamic>> register(Map<String, dynamic> data) =>
      _guard(() async {
        final response =
            await _apiClient.dio.post('/auth/register', data: data);
        return response.data as Map<String, dynamic>;
      });

  Future<Map<String, dynamic>> socialLogin(
    String provider,
    String idToken, {
    String action = 'login',
  }) =>
      _guard(() async {
        final response = await _apiClient.dio.post('/auth/social', data: {
          'provider': provider,
          'id_token': idToken,
          'action': action,
        });
        return response.data as Map<String, dynamic>;
      });

  Future<Map<String, dynamic>> completeSocialProfile(
          Map<String, dynamic> data) =>
      _guard(() async {
        final response = await _apiClient.dio
            .post('/auth/social/complete-profile', data: data);
        return response.data as Map<String, dynamic>;
      });

  Future<Map<String, dynamic>> validateRegisterStep1(
          Map<String, dynamic> data) =>
      _guard(() async {
        final response = await _apiClient.dio
            .post('/auth/validate-register-step1', data: data);
        return response.data as Map<String, dynamic>;
      });

  Future<Map<String, dynamic>> getMe() => _guard(() async {
        final response = await _apiClient.dio.get('/auth/me');
        return response.data as Map<String, dynamic>;
      });

  Future<void> logout() async {
    try {
      await _apiClient.dio.post('/auth/logout');
    } on DioException catch (e) {
      // Déjà déconnecté côté serveur : rien à signaler à l'utilisateur.
      if (e.response?.statusCode != 401) {
        _throwFromDio(e);
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw NetworkException(e.toString());
    }
  }

  /// Construit la clé de payload appropriée pour un identifiant.
  /// Si l'identifiant contient '@', c'est un email ; sinon un téléphone.
  Map<String, String> _identifierPayload(String identifier) {
    if (identifier.contains('@')) {
      return {'email': identifier};
    }
    return {'phone': identifier};
  }

  Future<Map<String, dynamic>> forgotPassword(String identifier) =>
      _guard(() async {
        final response = await _apiClient.dio
            .post('/auth/forgot-password', data: _identifierPayload(identifier));
        return response.data as Map<String, dynamic>;
      });

  Future<Map<String, dynamic>> verifyResetOtp(
          String identifier, String otp) =>
      _guard(() async {
        final response = await _apiClient.dio.post('/auth/verify-otp', data: {
          ..._identifierPayload(identifier),
          'otp': otp,
        });
        return response.data as Map<String, dynamic>;
      });

  Future<Map<String, dynamic>> resetPassword(
    String identifier,
    String resetToken,
    String password,
  ) =>
      _guard(() async {
        final response =
            await _apiClient.dio.post('/auth/reset-password', data: {
          ..._identifierPayload(identifier),
          'reset_token': resetToken,
          'password': password,
          'password_confirmation': password,
        });
        return response.data as Map<String, dynamic>;
      });

  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> data) =>
      _guard(() async {
        final response = await _apiClient.dio.put('/auth/profile', data: data);
        return response.data as Map<String, dynamic>;
      });

  Future<Map<String, dynamic>> uploadAvatar(File file) => _guard(() async {
        final formData = FormData.fromMap({
          'avatar': await MultipartFile.fromFile(file.path, filename: 'avatar.jpg'),
        });
        final response =
            await _apiClient.dio.post('/auth/profile/avatar', data: formData);
        return response.data as Map<String, dynamic>;
      });

  Future<Map<String, dynamic>> deleteAvatar() => _guard(() async {
        final response = await _apiClient.dio.delete('/auth/profile/avatar');
        return response.data as Map<String, dynamic>;
      });

  Future<Map<String, dynamic>> verifyPassword(String currentPassword) =>
      _guard(() async {
        final response =
            await _apiClient.dio.post('/auth/verify-password', data: {
          'current_password': currentPassword,
        });
        return response.data as Map<String, dynamic>;
      });

  Future<Map<String, dynamic>> changePassword(
    String currentPassword,
    String newPassword,
  ) =>
      _guard(() async {
        final response =
            await _apiClient.dio.put('/auth/change-password', data: {
          'current_password': currentPassword,
          'password': newPassword,
          'password_confirmation': newPassword,
        });
        return response.data as Map<String, dynamic>;
      });
}
