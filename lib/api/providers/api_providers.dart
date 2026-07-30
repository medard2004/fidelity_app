import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/api_client.dart';
import '../storage/token_storage.dart';
import '../services/auth_service.dart';
import '../repositories/auth_repository.dart';

// --- STORAGE ---
final tokenStorageProvider = Provider<TokenStorage>((ref) {
  return TokenStorage();
});

// --- CORE ---
final apiClientProvider = Provider<ApiClient>((ref) {
  final tokenStorage = ref.watch(tokenStorageProvider);
  return ApiClient(tokenStorage: tokenStorage);
});

// --- SERVICES ---
final authServiceProvider = Provider<AuthService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return AuthService(apiClient);
});

// --- REPOSITORIES ---
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final authService = ref.watch(authServiceProvider);
  final tokenStorage = ref.watch(tokenStorageProvider);
  return AuthRepository(authService, tokenStorage);
});
