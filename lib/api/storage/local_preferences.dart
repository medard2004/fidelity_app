import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LocalPreferences {
  static const _secureStorage = FlutterSecureStorage();
  static const String _onboardingKey = 'has_seen_onboarding';

  Future<void> setHasSeenOnboarding(bool value) async {
    await _secureStorage.write(key: _onboardingKey, value: value.toString());
  }

  Future<bool> hasSeenOnboarding() async {
    final value = await _secureStorage.read(key: _onboardingKey);
    return value == 'true';
  }
}

final localPreferencesProvider = Provider<LocalPreferences>((ref) {
  return LocalPreferences();
});
