import 'package:flutter/services.dart';

import 'channels.dart';

/// Dart client for communicating with the native Android overlay subsystem (`aura/overlay`).
class OverlayChannel {
  final MethodChannel _channel;

  OverlayChannel([MethodChannel? channel])
      : _channel = channel ?? const MethodChannel(AuraChannels.overlayMethod);

  /// Registers a callback listener for Orb Tap events from the native layer.
  void listenToOrbTaps(VoidCallback onOrbTap) {
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'onOrbTap') {
        onOrbTap();
      }
    });
  }

  /// Starts the floating Canvas orb foreground service.
  Future<bool> startOverlay() async {
    try {
      final res = await _channel.invokeMethod<bool>('startOverlay');
      return res ?? true;
    } catch (_) {
      return false;
    }
  }

  /// Stops the floating Canvas orb foreground service and removes the window.
  Future<bool> stopOverlay() async {
    try {
      final res = await _channel.invokeMethod<bool>('stopOverlay');
      return res ?? true;
    } catch (_) {
      return false;
    }
  }

  /// Checks if the application has been granted the `SYSTEM_ALERT_WINDOW` permission.
  Future<bool> checkOverlayPermission() async {
    try {
      final res = await _channel.invokeMethod<bool>('checkOverlayPermission');
      return res ?? false;
    } catch (_) {
      return false;
    }
  }

  /// Directs the user to Android system settings to grant overlay permission.
  Future<void> requestOverlayPermission() async {
    try {
      await _channel.invokeMethod<void>('requestOverlayPermission');
    } catch (_) {}
  }

  /// Checks whether the overlay foreground service is actively running.
  Future<bool> isOverlayRunning() async {
    try {
      final res = await _channel.invokeMethod<bool>('isOverlayRunning');
      return res ?? false;
    } catch (_) {
      return false;
    }
  }

  /// Launches native Ringtone picker for Alarms.
  Future<Map<String, String>?> pickAlarmSound({String? currentUri}) async {
    try {
      final res = await _channel.invokeMapMethod<String, String>(
        'pickAlarmSound',
        {'currentUri': currentUri ?? ''},
      );
      return res;
    } catch (_) {
      return null;
    }
  }

  /// Launches native Ringtone picker for Notifications.
  Future<Map<String, String>?> pickNotificationSound({String? currentUri}) async {
    try {
      final res = await _channel.invokeMapMethod<String, String>(
        'pickNotificationSound',
        {'currentUri': currentUri ?? ''},
      );
      return res;
    } catch (_) {
      return null;
    }
  }

  /// Clears native SharedPreferences (`aura_orb_prefs`).
  Future<void> clearNativePrefs() async {
    try {
      await _channel.invokeMethod<void>('clearNativePrefs');
    } catch (_) {}
  }

  /// Diagnostic ping returning "pong".
  Future<String> ping() async {
    try {
      final res = await _channel.invokeMethod<String>('ping');
      return res ?? 'unknown';
    } catch (_) {
      return 'error';
    }
  }
}
