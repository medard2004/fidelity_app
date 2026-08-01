import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:flutter/foundation.dart';

class SocialAuthService {
  static bool _googleInitialized = false;

  /// Initialise l'instance Google SignIn si besoin
  static Future<void> _ensureInitialized() async {
    if (_googleInitialized) return;
    await GoogleSignIn.instance.initialize(
      serverClientId: '423747164232-1a8off0p0fn5sjom8b7u878mf48ifuc5.apps.googleusercontent.com',
    );
    _googleInitialized = true;
  }

  /// S'authentifie avec Google puis Firebase, et retourne l'id_token Firebase pour le backend
  static Future<String?> signInWithGoogle() async {
    try {
      await _ensureInitialized();
      
      // Déconnecte l'utilisateur de Google d'abord pour forcer le choix du compte si besoin
      await GoogleSignIn.instance.signOut();
      
      // Lance le flux d'authentification natif Google
      final GoogleSignInAccount account = await GoogleSignIn.instance.authenticate(
        scopeHint: ['email', 'profile'],
      );
      
      // Récupère les tokens d'authentification Google
      final GoogleSignInAuthentication googleAuth = account.authentication;
      
      // Crée une credential pour Firebase à partir des tokens Google
      final AuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      // Authentifie l'utilisateur dans Firebase
      final UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      
      // Récupère le jeton JWT Firebase (idToken)
      // Ce jeton sera validé par le backend Laravel
      final String? firebaseIdToken = await userCredential.user?.getIdToken();

      if (firebaseIdToken == null || firebaseIdToken.isEmpty) {
        throw Exception('Impossible de récupérer le jeton Firebase après l\'authentification.');
      }

      return firebaseIdToken;
    } catch (e) {
      debugPrint('Erreur Firebase/Google Sign-In: $e');
      return null;
    }
  }

  /// S'authentifie avec Apple et retourne l'id_token pour le backend
  static Future<String?> signInWithApple() async {
    try {
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final idToken = credential.identityToken;
      if (idToken == null || idToken.isEmpty) {
        throw Exception('Impossible de récupérer le token Apple.');
      }

      return idToken;
    } catch (e) {
      rethrow;
    }
  }
}
