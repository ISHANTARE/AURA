import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'channels.dart';

class OverlayChannel {
  static const MethodChannel _channel =
      MethodChannel(AuraChannels.overlayMethod);

  /// Check if SYSTEM_ALERT_WINDOW permission is granted
  static Future<bool> isPermissionGranted() async {
    try {
      final bool granted =
          await _channel.invokeMethod('isOverlayPermissionGranted') ?? false;
      return granted;
    } on PlatformException catch (e) {
      debugPrint('[OverlayChannel] Error checking permission: $e');
      return false;
    }
  }

  /// Request SYSTEM_ALERT_WINDOW permission (opens Android System Settings page)
  static Future<void> requestPermission() async {
    try {
      await _channel.invokeMethod('requestOverlayPermission');
    } on PlatformException catch (e) {
      debugPrint('[OverlayChannel] Error requesting permission: $e');
    }
  }

  /// Start system-level floating orb overlay foreground service
  static Future<bool> startOverlay({String? colorHex}) async {
    try {
      final bool success = await _channel.invokeMethod('startOverlay', {
            if (colorHex != null) 'colorHex': colorHex,
          }) ??
          false;
      return success;
    } on PlatformException catch (e) {
      debugPrint('[OverlayChannel] Error starting overlay: $e');
      return false;
    }
  }

  /// Update the color of the active floating orb overlay
  static Future<bool> updateColor(String colorHex) async {
    try {
      final bool success = await _channel.invokeMethod('updateOverlayColor', {
            'colorHex': colorHex,
          }) ??
          false;
      return success;
    } on PlatformException catch (e) {
      debugPrint('[OverlayChannel] Error updating overlay color: $e');
      return false;
    }
  }

  /// Stop system-level floating orb overlay service
  static Future<bool> stopOverlay() async {
    try {
      final bool success =
          await _channel.invokeMethod('stopOverlay') ?? false;
      return success;
    } on PlatformException catch (e) {
      debugPrint('[OverlayChannel] Error stopping overlay: $e');
      return false;
    }
  }

  /// Check if overlay service is actively running
  static Future<bool> isRunning() async {
    try {
      final bool running =
          await _channel.invokeMethod('isOverlayRunning') ?? false;
      return running;
    } on PlatformException catch (e) {
      debugPrint('[OverlayChannel] Error checking status: $e');
      return false;
    }
  }

  /// Auto-start global orb service if permission was granted
  static Future<void> autoStartIfPermitted() async {
    try {
      final granted = await isPermissionGranted();
      if (granted) {
        final running = await isRunning();
        if (!running) {
          await startOverlay();
        }
      }
    } catch (e) {
      debugPrint('[OverlayChannel] autoStartIfPermitted error: $e');
    }
  }

  /// Set handler for callbacks from native orb tap
  static void listenToOrbTaps(VoidCallback onOrbTapped) {
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'onOrbTapped') {
        onOrbTapped();
      }
    });
  }

  /// Open system ringtone picker to select custom alarm audio on device
  static Future<Map<String, String>?> pickAlarmSound({
    String? currentUri,
    String? title,
  }) async {
    return pickSound(type: 'alarm', currentUri: currentUri, title: title);
  }

  /// Open system ringtone picker to select custom notification audio on device
  static Future<Map<String, String>?> pickNotificationSound({
    String? currentUri,
    String? title,
  }) async {
    return pickSound(type: 'notification', currentUri: currentUri, title: title);
  }

  /// Open system ringtone picker with specified sound type ('alarm' | 'notification')
  static Future<Map<String, String>?> pickSound({
    String type = 'alarm',
    String? currentUri,
    String? title,
  }) async {
    try {
      final res = await _channel.invokeMethod<Map>('pickSound', {
        'type': type,
        'currentUri': currentUri ?? '',
        'title': title,
      });
      if (res != null) {
        return Map<String, String>.from(res);
      }
    } on PlatformException catch (e) {
      debugPrint('[OverlayChannel] Error picking sound: $e');
    }
    return null;
  }

  /// Update dynamic accent color of floating orb
  static Future<void> updateOrbColor(String colorHex) async {
    try {
      await _channel.invokeMethod('updateOrbColor', {'colorHex': colorHex});
    } catch (e) {
      debugPrint('[OverlayChannel] updateOrbColor skipped: $e');
    }
  }

  /// Clear native orb preferences (position / color / dismissed flag).
  /// Part of the full Reset App Data teardown.
  static Future<void> clearNativePrefs() async {
    try {
      await _channel.invokeMethod('clearNativePrefs');
    } on PlatformException catch (e) {
      debugPrint('[OverlayChannel] Error clearing native prefs: $e');
    } on MissingPluginException catch (e) {
      debugPrint('[OverlayChannel] clearNativePrefs unavailable: $e');
    }
  }
}
