import 'dart:async';
import 'package:flutter/services.dart';
import 'channels.dart';

/// Dart wrapper for controlling system-wide floating orb overlay.
class OverlayChannel {

  OverlayChannel() {
    _channel.setMethodCallHandler(_handleMethodCall);
  }
  static const MethodChannel _channel = MethodChannel(AuraChannels.overlayMethod);

  final StreamController<void> _orbTapController = StreamController<void>.broadcast();

  /// Stream emitting events when the floating orb overlay is tapped on Android.
  Stream<void> get onOrbTapped => _orbTapController.stream;

  Future<bool> _handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'onOrbTapped':
        _orbTapController.add(null);
        return true;
      default:
        return false;
    }
  }

  /// Start the floating orb foreground service.
  Future<bool> startOverlay() async {
    try {
      final result = await _channel.invokeMethod<bool>('startOverlay');
      return result ?? false;
    } on PlatformException {
      return false;
    }
  }

  /// Stop the floating orb foreground service.
  Future<bool> stopOverlay() async {
    try {
      final result = await _channel.invokeMethod<bool>('stopOverlay');
      return result ?? false;
    } on PlatformException {
      return false;
    }
  }

  /// Check if SYSTEM_ALERT_WINDOW permission is granted.
  Future<bool> isPermissionGranted() async {
    try {
      final result = await _channel.invokeMethod<bool>('isOverlayPermissionGranted');
      return result ?? false;
    } on PlatformException {
      return false;
    }
  }

  /// Request SYSTEM_ALERT_WINDOW permission from Android settings.
  Future<void> requestPermission() async {
    try {
      await _channel.invokeMethod<void>('requestOverlayPermission');
    } on PlatformException catch (_) {
      // Ignored
    }
  }

  /// Check if the overlay service is currently running.
  Future<bool> isRunning() async {
    try {
      final result = await _channel.invokeMethod<bool>('isOverlayRunning');
      return result ?? false;
    } on PlatformException {
      return false;
    }
  }

  void dispose() {
    _orbTapController.close();
  }
}
