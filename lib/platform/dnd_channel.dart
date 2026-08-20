import 'package:flutter/services.dart';
import 'channels.dart';

/// Platform channel bridge to query Android DND (Do Not Disturb) mode state
/// and stream real-time DND toggles.
class DndChannel {
  final MethodChannel _methodChannel;
  final EventChannel _eventChannel;

  DndChannel({
    MethodChannel? methodChannel,
    EventChannel? eventChannel,
  })  : _methodChannel = methodChannel ?? const MethodChannel(AuraChannels.dndMethod),
        _eventChannel = eventChannel ?? const EventChannel(AuraChannels.dndEvent);

  /// Check whether DND mode is currently active on device.
  Future<bool> isDndActive() async {
    try {
      final bool? isDnd = await _methodChannel.invokeMethod<bool>('isDndActive');
      return isDnd ?? false;
    } on PlatformException catch (_) {
      return false;
    }
  }

  /// Get exact Android interruption filter ID.
  Future<int> getDndFilter() async {
    try {
      final int? filter = await _methodChannel.invokeMethod<int>('getDndFilter');
      return filter ?? 1; // Default to INTERRUPTION_FILTER_ALL (1)
    } on PlatformException catch (_) {
      return 1;
    }
  }

  /// Stream emitting boolean [true] when DND turns ON, and [false] when DND turns OFF (lifted).
  Stream<bool> get dndStateStream {
    return _eventChannel
        .receiveBroadcastStream()
        .map((event) => event as bool)
        .handleError((_) => false);
  }
}
