import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../platform/speech_channel.dart';
import '../../domain/entities/capture_state.dart';

final speechChannelProvider = Provider<SpeechChannel>((ref) {
  final channel = SpeechChannel();
  ref.onDispose(channel.dispose);
  return channel;
});

final captureProvider = StateNotifierProvider<CaptureNotifier, CaptureState>((ref) {
  final speechChannel = ref.watch(speechChannelProvider);
  return CaptureNotifier(speechChannel);
});

class CaptureNotifier extends StateNotifier<CaptureState> {

  CaptureNotifier(this._speechChannel) : super(const CaptureState());
  final SpeechChannel _speechChannel;

  StreamSubscription<String>? _transcriptSub;
  StreamSubscription<double>? _audioLevelSub;
  StreamSubscription<String>? _stateSub;
  StreamSubscription<String>? _errorSub;

  Timer? _silenceTimer;

  /// Start voice capture flow.
  Future<void> startCapture() async {
    state = const CaptureState(status: CaptureStatus.starting);

    // Cancel existing subscriptions
    await _cancelSubscriptions();

    // Subscribe to STT streams
    _transcriptSub = _speechChannel.partialTranscriptStream.listen(_onPartialTranscript);
    _audioLevelSub = _speechChannel.audioLevelStream.listen(_onAudioLevel);
    _stateSub = _speechChannel.speechStateStream.listen(_onSpeechState);
    _errorSub = _speechChannel.errorStream.listen(_onError);

    final success = await _speechChannel.startListening();
    if (success) {
      state = state.copyWith(status: CaptureStatus.listening);
      _resetSilenceTimer();
    } else {
      state = state.copyWith(
        status: CaptureStatus.error,
        errorMessage: 'Microphone or Speech Recognizer unavailable',
      );
    }
  }

  void _onPartialTranscript(String text) {
    if (text.isEmpty) return;

    // Detect lightweight context hint
    final contextHint = _detectContextHint(text);

    state = state.copyWith(
      transcript: text,
      detectedContext: contextHint,
    );

    _resetSilenceTimer();
  }

  void _onAudioLevel(double level) {
    state = state.copyWith(audioLevel: level);
  }

  void _onSpeechState(String speechState) {
    if (speechState == 'autoStopped') {
      if (state.status == CaptureStatus.listening) {
        stopAndProcess();
      }
    }
  }

  void _onError(String errorMsg) {
    state = state.copyWith(
      status: CaptureStatus.error,
      errorMessage: errorMsg,
    );
  }

  void _resetSilenceTimer() {
    _silenceTimer?.cancel();
    // Auto-stop after 1.5 seconds of silence if transcript is present
    _silenceTimer = Timer(const Duration(milliseconds: 1500), () {
      if (state.status == CaptureStatus.listening && state.transcript.trim().isNotEmpty) {
        stopAndProcess();
      }
    });
  }

  /// Stop listening and transition to AI processing state.
  Future<void> stopAndProcess() async {
    _silenceTimer?.cancel();
    await _speechChannel.stopListening();

    if (state.transcript.trim().isEmpty) {
      state = state.copyWith(
        status: CaptureStatus.error,
        errorMessage: "No speech detected. Try speaking clearly or type manually.",
      );
      return;
    }

    state = state.copyWith(status: CaptureStatus.processing);
  }

  /// Switch to manual text input mode fallback.
  Future<void> switchToTextInput() async {
    _silenceTimer?.cancel();
    await _speechChannel.stopListening();
    state = state.copyWith(status: CaptureStatus.textInput);
  }

  /// Update transcript manually (when typing).
  void updateTypedTranscript(String text) {
    final contextHint = _detectContextHint(text);
    state = state.copyWith(
      transcript: text,
      detectedContext: contextHint,
    );
  }

  /// Submit typed transcript for processing.
  void submitTypedTranscript() {
    if (state.transcript.trim().isEmpty) return;
    state = state.copyWith(status: CaptureStatus.processing);
  }

  /// Cancel capture flow and reset to idle.
  Future<void> cancelCapture() async {
    _silenceTimer?.cancel();
    await _speechChannel.cancelListening();
    await _cancelSubscriptions();
    state = const CaptureState(status: CaptureStatus.idle);
  }

  Future<void> _cancelSubscriptions() async {
    await _transcriptSub?.cancel();
    await _audioLevelSub?.cancel();
    await _stateSub?.cancel();
    await _errorSub?.cancel();
  }

  String? _detectContextHint(String text) {
    final lower = text.toLowerCase();
    if (lower.contains('assignment') || lower.contains('exam') || lower.contains('quiz') || lower.contains('lab')) {
      return 'Academics · VIT';
    } else if (lower.contains('meeting') || lower.contains('standup') || lower.contains('internship') || lower.contains('work')) {
      return 'Internship · Career';
    } else if (lower.contains('iit') || lower.contains('gate') || lower.contains('math') || lower.contains('physics')) {
      return 'IIT Prep · Studies';
    } else if (lower.contains('gym') || lower.contains('run') || lower.contains('workout') || lower.contains('health')) {
      return 'Fitness · Personal';
    }
    return null;
  }

  @override
  void dispose() {
    _silenceTimer?.cancel();
    _cancelSubscriptions();
    super.dispose();
  }
}
