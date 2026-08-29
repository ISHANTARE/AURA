import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Application-level configuration with 4-tier resolution hierarchy.
///
/// Resolution order (highest to lowest priority):
/// 1. User setting stored in [SharedPreferences]
/// 2. Dart compile-time `--dart-define` flag
/// 3. Environment variable override
/// 4. Hardcoded fallback default
class AppConfig {
  // SharedPreferences keys
  static const _prefLlmBaseUrl = 'PREF_LLM_BASE_URL';
  static const _prefLlmModel = 'PREF_LLM_MODEL';

  // Compile-time defines (set via --dart-define=LLM_BASE_URL=...)
  static const _defineBaseUrl = String.fromEnvironment('LLM_BASE_URL', defaultValue: '');
  static const _defineModel = String.fromEnvironment('LLM_MODEL', defaultValue: '');

  // Hardcoded defaults
  static const _defaultBaseUrl =
      'https://generativelanguage.googleapis.com/v1beta/openai/';
  static const _defaultModel = 'gemini-2.0-flash';

  final SharedPreferences _prefs;

  const AppConfig._(this._prefs);

  /// Creates an [AppConfig] instance backed by the provided [SharedPreferences].
  static Future<AppConfig> load() async {
    final prefs = await SharedPreferences.getInstance();
    return AppConfig._(prefs);
  }

  /// Resolves the LLM base URL through the 4-tier hierarchy.
  String get llmBaseUrl {
    final userPref = _prefs.getString(_prefLlmBaseUrl);
    if (userPref != null && userPref.isNotEmpty) return userPref;
    if (_defineBaseUrl.isNotEmpty) return _defineBaseUrl;
    return _defaultBaseUrl;
  }

  /// Resolves the LLM model name through the 4-tier hierarchy.
  String get llmModel {
    final userPref = _prefs.getString(_prefLlmModel);
    if (userPref != null && userPref.isNotEmpty) return userPref;
    if (_defineModel.isNotEmpty) return _defineModel;
    return _defaultModel;
  }

  /// Persists a user-selected LLM base URL override.
  Future<void> setLlmBaseUrl(String url) async {
    if (url.isEmpty) {
      await _prefs.remove(_prefLlmBaseUrl);
    } else {
      await _prefs.setString(_prefLlmBaseUrl, url);
    }
  }

  /// Persists a user-selected LLM model override.
  Future<void> setLlmModel(String model) async {
    if (model.isEmpty) {
      await _prefs.remove(_prefLlmModel);
    } else {
      await _prefs.setString(_prefLlmModel, model);
    }
  }

  /// Clears all user overrides, reverting to compile-time or default values.
  Future<void> resetToDefaults() async {
    await _prefs.remove(_prefLlmBaseUrl);
    await _prefs.remove(_prefLlmModel);
  }

  @override
  String toString() {
    if (kDebugMode) {
      return 'AppConfig(llmBaseUrl: $llmBaseUrl, llmModel: $llmModel)';
    }
    return 'AppConfig(llmModel: $llmModel)';
  }
}
