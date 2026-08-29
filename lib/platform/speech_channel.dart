import 'package:flutter/services.dart';

import 'channels.dart';

/// Dart client for communicating with Android's native SpeechRecognizer and live audio streams.
class SpeechChannel {
  final MethodChannel _methodChannel;
  final EventChannel _partialChannel;
  final EventChannel _audioLevelChannel;
  final EventChannel _stateChannel;
  final EventChannel _errorChannel;

  SpeechChannel({
    MethodChannel? methodChannel,
    EventChannel? partialChannel,
    EventChannel? audioLevelChannel,
    EventChannel? stateChannel,
    EventChannel? errorChannel,
  })  : _methodChannel = methodChannel ?? const MethodChannel(AuraChannels.speechMethod),
        _partialChannel = partialChannel ?? const EventChannel(AuraChannels.speechPartialEvent),
        _audioLevelChannel = audioLevelChannel ?? const EventChannel(AuraChannels.speechAudioLevelEvent),
        _stateChannel = stateChannel ?? const EventChannel(AuraChannels.speechStateEvent),
        _errorChannel = errorChannel ?? const EventChannel(AuraChannels.speechErrorEvent);

  /// Starts listening for speech using Android SpeechRecognizer.
  Future<bool> startListening({String? localeId}) async {
    try {
      final res = await _methodChannel.invokeMethod<bool>(
        'startListening',
        {'localeId': localeId},
      );
      return res ?? true;
    } catch (_) {
      return false;
    }
  }

  /// Stops speech recognition gracefully and waits for final results.
  Future<bool> stopListening() async {
    try {
      final res = await _methodChannel.invokeMethod<bool>('stopListening');
      return res ?? true;
    } catch (_) {
      return false;
    }
  }

  /// Aborts speech recognition immediately without delivering results.
  Future<bool> cancelListening() async {
    try {
      final res = await _methodChannel.invokeMethod<bool>('cancelListening');
      return res ?? true;
    } catch (_) {
      return false;
    }
  }

  /// Verifies if speech recognition service is available on device.
  Future<bool> isAvailable() async {
    try {
      final res = await _methodChannel.invokeMethod<bool>('isAvailable');
      return res ?? false;
    } catch (_) {
      return false;
    }
  }

  /// Live stream of partial speech transcripts as words are recognized in real time.
  Stream<String> get partialTranscriptStream {
    return _partialChannel.receiveBroadcastStream().map((event) => event.toString());
  }

  /// Live stream of normalized RMS audio power level in `[0.0, 1.0]` range.
  Stream<double> get audioLevelStream {
    return _audioLevelChannel.receiveBroadcastStream().map((event) {
      if (event is num) return event.toDouble();
      return 0.0;
    });
  }

  /// Live stream of speech lifecycle state transitions (`ready`, `listening`, `processing`, `autoStopped`, `error`).
  Stream<String> get speechStateStream {
    return _stateChannel.receiveBroadcastStream().map((event) => event.toString());
  }

  /// Live stream of error messages from speech recognition failure.
  Stream<String> get speechErrorStream {
    return _errorChannel.receiveBroadcastStream().map((event) => event.toString());
  }
}
