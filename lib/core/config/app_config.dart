/// Central configuration reader supporting `--dart-define` environment overrides.
///
/// Defaults target Google Gemini's OpenAI-compatible endpoint so a fresh build
/// works out of the box once the user supplies an API key (Settings → AI Engine).
class AppConfig {
  static const String llmApiKey = String.fromEnvironment(
    'LLM_API_KEY',
    defaultValue: '',
  );

  static const String llmBaseUrl = String.fromEnvironment(
    'LLM_BASE_URL',
    defaultValue: 'https://generativelanguage.googleapis.com/v1beta/openai/',
  );

  static const String llmModel = String.fromEnvironment(
    'LLM_MODEL',
    defaultValue: 'gemini-2.0-flash',
  );
}
