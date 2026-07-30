import '../services/auth_service.dart';
import '../storage/token_storage.dart';

class AuthRepository {
  final AuthService _authService;
  final TokenStorage _tokenStorage;

  AuthRepository(this._authService, this._tokenStorage);

  Future<void> login(String email, String password) async {
    final response = await _authService.login(email, password);
    
    // Assurez-vous que la clé 'token' correspond à la structure JSON renvoyée par votre backend Laravel.
    final token = response['token']; 
    
    if (token != null) {
      await _tokenStorage.saveToken(token);
    }
  }

  Future<void> logout() async {
    // Appelez ici la route de déconnexion du backend si nécessaire
    // await _authService.logout();
    await _tokenStorage.deleteToken();
  }

  Future<bool> isLoggedIn() async {
    final token = await _tokenStorage.getToken();
    return token != null;
  }
}
