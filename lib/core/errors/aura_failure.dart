/// Sealed failure hierarchy for typed error handling in AURA
sealed class AuraFailure implements Exception {
  final String message;
  final dynamic cause;

  const AuraFailure(this.message, [this.cause]);

  @override
  String toString() => '$runtimeType: $message${cause != null ? ' (Cause: $cause)' : ''}';
}

/// Database failure (Drift/SQLite read/write errors)
final class DatabaseFailure extends AuraFailure {
  const DatabaseFailure(super.message, [super.cause]);
}

/// AI Extraction failure (Gemini/OpenAI API or JSON parse errors)
final class AiExtractionFailure extends AuraFailure {
  const AiExtractionFailure(super.message, [super.cause]);
}

/// Speech Recognition failure (Android SpeechRecognizer errors)
final class SpeechRecognitionFailure extends AuraFailure {
  const SpeechRecognitionFailure(super.message, [super.cause]);
}

/// Network failure (Offline / timeout errors)
final class NetworkFailure extends AuraFailure {
  const NetworkFailure(super.message, [super.cause]);
}

/// Permission failure (Microphone, Overlay, Notification permissions denied)
final class PermissionFailure extends AuraFailure {
  const PermissionFailure(super.message, [super.cause]);
}

/// General unexpected failure
final class UnknownFailure extends AuraFailure {
  const UnknownFailure(super.message, [super.cause]);
}
