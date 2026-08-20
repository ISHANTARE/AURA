/// Central configuration reader supporting `--dart-define` environment overrides.
class AppConfig {
  static const String llmApiKey = String.fromEnvironment(
    'LLM_API_KEY',
    defaultValue: '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',
  );

  static const String llmBaseUrl = String.fromEnvironment(
    'LLM_BASE_URL',
    defaultValue: 'https://integrate.api.nvidia.com/v1',
  );

  static const String llmModel = String.fromEnvironment(
    'LLM_MODEL',
    defaultValue: 'meta/llama-3.1-8b-instruct',
  );
}
