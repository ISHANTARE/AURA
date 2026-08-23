import 'intent_result.dart';
import 'workspace_match_result.dart';

enum CaptureStatus {
  idle,
  starting,
  listening,
  autoStopped,
  processing,
  confirming,
  savedSuccess,
  error,
  textInput,
}

class CaptureState {
  final CaptureStatus status;
  final String transcript;
  final double audioLevel;
  final String? errorMessage;

  /// Non-fatal AI notice (e.g. "offline parser used because …").
  /// Shown in the confirmation card so degraded parsing is never silent.
  final String? aiNotice;

  /// True when [errorMessage] requires user configuration to fix
  /// (e.g. invalid API key) — UI should offer a Settings shortcut.
  final bool hardError;
  final String? detectedContext;
  final IntentResult? intentResult;
  final WorkspaceMatchResult? workspaceMatch;
  final bool isOfflineSaved;
  final bool isSaving;

  const CaptureState({
    this.status = CaptureStatus.idle,
    this.transcript = '',
    this.audioLevel = 0.0,
    this.errorMessage,
    this.aiNotice,
    this.hardError = false,
    this.detectedContext,
    this.intentResult,
    this.workspaceMatch,
    this.isOfflineSaved = false,
    this.isSaving = false,
  });

  CaptureState copyWith({
    CaptureStatus? status,
    String? transcript,
    double? audioLevel,
    String? errorMessage,
    bool clearError = false,
    String? aiNotice,
    bool clearAiNotice = false,
    bool? hardError,
    String? detectedContext,
    bool clearDetectedContext = false,
    IntentResult? intentResult,
    WorkspaceMatchResult? workspaceMatch,
    bool? isOfflineSaved,
    bool? isSaving,
  }) {
    return CaptureState(
      status: status ?? this.status,
      transcript: transcript ?? this.transcript,
      audioLevel: audioLevel ?? this.audioLevel,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      aiNotice: clearAiNotice ? null : (aiNotice ?? this.aiNotice),
      hardError: hardError ?? this.hardError,
      detectedContext: clearDetectedContext ? null : (detectedContext ?? this.detectedContext),
      intentResult: intentResult ?? this.intentResult,
      workspaceMatch: workspaceMatch ?? this.workspaceMatch,
      isOfflineSaved: isOfflineSaved ?? this.isOfflineSaved,
      isSaving: isSaving ?? this.isSaving,
    );
  }
}
