enum CaptureStatus {
  idle,
  starting,
  listening,
  autoStopped,
  processing,
  confirming,
  error,
  textInput,
}

class CaptureState {

  const CaptureState({
    this.status = CaptureStatus.idle,
    this.transcript = '',
    this.audioLevel = 0.0,
    this.errorMessage,
    this.detectedContext,
  });
  final CaptureStatus status;
  final String transcript;
  final double audioLevel;
  final String? errorMessage;
  final String? detectedContext;

  CaptureState copyWith({
    CaptureStatus? status,
    String? transcript,
    double? audioLevel,
    String? errorMessage,
    String? detectedContext,
  }) {
    return CaptureState(
      status: status ?? this.status,
      transcript: transcript ?? this.transcript,
      audioLevel: audioLevel ?? this.audioLevel,
      errorMessage: errorMessage ?? this.errorMessage,
      detectedContext: detectedContext ?? this.detectedContext,
    );
  }
}
