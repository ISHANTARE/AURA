import 'package:flutter/services.dart';
import 'channels.dart';

class SharedPayload {
  final String type; // 'text', 'image', 'pdf'
  final String? content;
  final String? filePath;
  final String mimeType;

  SharedPayload({
    required this.type,
    this.content,
    this.filePath,
    required this.mimeType,
  });

  factory SharedPayload.fromMap(Map<dynamic, dynamic> map) {
    return SharedPayload(
      type: map['type'] as String? ?? 'text',
      content: map['content'] as String?,
      filePath: map['filePath'] as String?,
      mimeType: map['mimeType'] as String? ?? 'text/plain',
    );
  }
}

class ShareChannel {
  final MethodChannel _channel;

  ShareChannel({MethodChannel? channel})
      : _channel = channel ?? const MethodChannel(AuraChannels.shareMethod);

  /// Fetch initial payload if app was opened via Android share target
  Future<SharedPayload?> getInitialSharePayload() async {
    try {
      final Map<dynamic, dynamic>? res =
          await _channel.invokeMethod<Map<dynamic, dynamic>>('getInitialSharePayload');
      if (res != null) {
        return SharedPayload.fromMap(res);
      }
    } on PlatformException catch (_) {
      return null;
    }
    return null;
  }
}
