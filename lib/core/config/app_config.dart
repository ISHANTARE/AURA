/// Central configuration reader supporting `--dart-define` environment overrides.
class AppConfig {
  static const String llmApiKey = String.fromEnvironment(
    'LLM_API_KEY',
    defaultValue: '',
  );

  static const String llmBaseUrl = String.fromEnvironment(
    'LLM_BASE_URL',
    defaultValue: 'https://integrate.api.nvidia.com/v1',
  );

  static const String llmModel = String.fromEnvironment(
    'LLM_MODEL',
    defaultValue: 'meta/llama-3.3-70b-instruct',
  );
}
