import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Manages sensitive credentials using Android Keystore via [FlutterSecureStorage].
/// Provides migration from legacy plaintext [SharedPreferences] storage.
class SecretStore {
  static const _apiKeyKey = 'AURA_GEMINI_API_KEY';
  static const _legacyPrefsKey = 'gemini_api_key';

  final FlutterSecureStorage _storage;

  SecretStore({FlutterSecureStorage? storage})
      : _storage = storage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(
                encryptedSharedPreferences: true,
                keyCipherAlgorithm: KeyCipherAlgorithm.RSA_ECB_OAEPwithSHA_256andMGF1Padding,
                storageCipherAlgorithm: StorageCipherAlgorithm.AES_GCM_NoPadding,
              ),
            );

  /// Returns the stored API key, or `null` if not set.
  Future<String?> getApiKey() => _storage.read(key: _apiKeyKey);

  /// Stores [key] securely in Android Keystore.
  Future<void> setApiKey(String key) => _storage.write(key: _apiKeyKey, value: key);

  /// Deletes the stored API key from the Keystore.
  Future<void> deleteApiKey() => _storage.delete(key: _apiKeyKey);

  /// Migrates any legacy plaintext API key stored in [SharedPreferences] to
  /// the encrypted Keystore. Safe to call on every app launch; no-op if no
  /// legacy key is found or if a secure key already exists.
  Future<void> migrateLegacyKey() async {
    // Do not overwrite an already-migrated secure key.
    final existingSecure = await getApiKey();
    if (existingSecure != null) return;

    final prefs = await SharedPreferences.getInstance();
    final legacyKey = prefs.getString(_legacyPrefsKey);
    if (legacyKey != null && legacyKey.isNotEmpty) {
      await setApiKey(legacyKey);
      await prefs.remove(_legacyPrefsKey);
    }
  }
}
