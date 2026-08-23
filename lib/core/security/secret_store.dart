import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Encrypted storage for user secrets (API keys), backed by
/// flutter_secure_storage (Android Keystore / encrypted SharedPreferences).
///
/// Migrates the legacy plaintext `LLM_API_KEY` SharedPreferences entry once,
/// guarded by the `secure_migration_v1` flag, so existing installs keep working.
class SecretStore {
  static const FlutterSecureStorage _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  static const String _apiKeyKey = 'aura.llm.api_key';
  static const String _legacyPrefsKey = 'LLM_API_KEY';
  static const String _migrationGuard = 'secure_migration_v1';

  /// Read the LLM API key. Falls back to (and lazily migrates) the legacy
  /// plaintext SharedPreferences value when the secure entry is empty.
  Future<String> readApiKey() async {
    try {
      final secure = await _storage.read(key: _apiKeyKey);
      if (secure != null && secure.isNotEmpty) return secure;
    } catch (_) {
      // Secure storage unavailable (rare OEM failure / tests) — fall through
      // to prefs so capture keeps working; never crash the pipeline here.
    }

    final prefs = await SharedPreferences.getInstance();
    final legacy = prefs.getString(_legacyPrefsKey) ?? '';
    if (legacy.isNotEmpty) {
      await writeApiKey(legacy);
      return legacy;
    }
    return '';
  }

  Future<void> writeApiKey(String value) async {
    try {
      if (value.isEmpty) {
        await _storage.delete(key: _apiKeyKey);
      } else {
        await _storage.write(key: _apiKeyKey, value: value);
      }
    } catch (_) {
      // Persist to prefs as last resort so the key is not silently lost.
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_legacyPrefsKey, value);
      return;
    }
    // Key now lives in secure storage — scrub the plaintext copy.
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey(_legacyPrefsKey)) {
      await prefs.remove(_legacyPrefsKey);
    }
    await prefs.setBool(_migrationGuard, true);
  }

  /// One-time explicit migration for app startup. Idempotent.
  Future<void> migrateLegacyKey() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(_migrationGuard) ?? false) return;

    final legacy = prefs.getString(_legacyPrefsKey);
    if (legacy == null || legacy.isEmpty) {
      await prefs.setBool(_migrationGuard, true);
      return;
    }

    String? secure;
    try {
      secure = await _storage.read(key: _apiKeyKey);
    } catch (_) {
      secure = null;
    }
    if (secure == null || secure.isEmpty) {
      try {
        await _storage.write(key: _apiKeyKey, value: legacy);
      } catch (_) {
        return; // Keep plaintext fallback; retry next launch.
      }
    }
    await prefs.remove(_legacyPrefsKey);
    await prefs.setBool(_migrationGuard, true);
  }
}
