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
      detectedContext: clearDetectedContext ? null : (detectedContext ?? this.detectedContext),
      intentResult: intentResult ?? this.intentResult,
      workspaceMatch: workspaceMatch ?? this.workspaceMatch,
      isOfflineSaved: isOfflineSaved ?? this.isOfflineSaved,
      isSaving: isSaving ?? this.isSaving,
    );
  }
}
