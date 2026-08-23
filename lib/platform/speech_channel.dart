import 'dart:async';
import 'package:flutter/services.dart';
import 'channels.dart';

/// Dart wrapper bridging Android SpeechRecognizer API.
class SpeechChannel {

  SpeechChannel() {
    _methodChannel.setMethodCallHandler(_handleMethodCall);
  }
  static const MethodChannel _methodChannel = MethodChannel(AuraChannels.speechMethod);
  static const EventChannel _partialChannel = EventChannel(AuraChannels.speechPartialEvent);
  static const EventChannel _audioLevelChannel = EventChannel(AuraChannels.speechAudioLevelEvent);

  final StreamController<String> _transcriptStateController = StreamController<String>.broadcast();
  final StreamController<String> _errorController = StreamController<String>.broadcast();
  final StreamController<String> _speechStateController = StreamController<String>.broadcast();

  Stream<String>? _partialStream;
  Stream<double>? _audioLevelStream;

  /// Stream of partial and final transcript string updates.
  Stream<String> get partialTranscriptStream {
    _partialStream ??= _partialChannel
        .receiveBroadcastStream()
        .map((event) => event.toString());
    return _partialStream!;
  }

  /// Stream of audio amplitude values (0.0 to 1.0) at ~60fps.
  Stream<double> get audioLevelStream {
    _audioLevelStream ??= _audioLevelChannel
        .receiveBroadcastStream()
        .map((event) => (event as num).toDouble());
    return _audioLevelStream!;
  }

  /// Stream of speech state transitions (e.g. "listening", "autoStopped").
  Stream<String> get speechStateStream => _speechStateController.stream;

  /// Stream of speech recognition errors.
  Stream<String> get errorStream => _errorController.stream;

  /// Stream of final ready transcripts.
  Stream<String> get finalTranscriptStream => _transcriptStateController.stream;

  Future<bool> _handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'onSpeechStateChanged':
        _speechStateController.add(call.arguments.toString());
        return true;
      case 'onSpeechError':
        _errorController.add(call.arguments.toString());
        return true;
      case 'onTranscriptReady':
        _transcriptStateController.add(call.arguments.toString());
        return true;
      default:
        return false;
    }
  }

  /// Check if Android SpeechRecognizer is available on device.
  Future<bool> isAvailable() async {
    try {
      final result = await _methodChannel.invokeMethod<bool>('isAvailable');
      return result ?? false;
    } on PlatformException {
      return false;
    }
  }

  /// Start speech recognition listening session.
  ///
  /// [localeId] is a BCP-47 tag (e.g. "en-US", "hi-IN"). When null the
  /// recognizer follows the device's default locale.
  Future<bool> startListening({String? localeId}) async {
    try {
      final result = await _methodChannel.invokeMethod<bool>(
        'startListening',
        localeId == null ? null : {'localeId': localeId},
      );
      return result ?? false;
    } on PlatformException catch (e) {
      _errorController.add(e.message ?? 'Failed to start listening');
      return false;
    }
  }

  /// BCP-47 tags of languages the on-device recognizer supports.
  Future<List<String>> availableLocales() async {
    try {
      final result =
          await _methodChannel.invokeMethod<List<dynamic>>('getAvailableLocales');
      return result?.cast<String>() ?? const [];
    } on PlatformException {
      return const [];
    } on MissingPluginException {
      return const [];
    }
  }

  /// Stop listening and trigger final processing.
  Future<void> stopListening() async {
    try {
      await _methodChannel.invokeMethod<void>('stopListening');
    } on PlatformException catch (_) {}
  }

  /// Cancel listening session without returning results.
  Future<void> cancelListening() async {
    try {
      await _methodChannel.invokeMethod<void>('cancelListening');
    } on PlatformException catch (_) {}
  }

  void dispose() {
    _transcriptStateController.close();
    _errorController.close();
    _speechStateController.close();
  }
}
