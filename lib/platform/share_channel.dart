import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'channels.dart';

class SharedPayload {
  final String type; // 'text', 'image', 'video', 'audio', 'pdf', 'file'
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
      type: (map['type'] as String?) ?? 'text',
      content: (map['content'] ?? map['text']) as String?,
      filePath: (map['filePath'] ?? map['localPath'] ?? map['path'] ?? map['uri']) as String?,
      mimeType: (map['mimeType'] as String?) ?? 'text/plain',
    );
  }
}

class ShareChannel {
  final MethodChannel _channel;

  /// Fired when a share lands while the /share engine is already warm
  /// (native pushes `onShareReceived` from onNewIntent or the copy thread).
  final StreamController<void> _shareReceivedController =
      StreamController<void>.broadcast();

  bool _handlerRegistered = false;

  ShareChannel({MethodChannel? channel})
      : _channel = channel ?? const MethodChannel(AuraChannels.shareMethod);

  Stream<void> get onShareReceived {
    if (!_handlerRegistered) {
      _handlerRegistered = true;
      _channel.setMethodCallHandler((call) async {
        if (call.method == 'onShareReceived') {
          _shareReceivedController.add(null);
        }
        return null;
      });
    }
    return _shareReceivedController.stream;
  }

  /// Fetch the pending share payload (single-consume on the native side).
  Future<SharedPayload?> getInitialSharePayload() async {
    try {
      final dynamic raw =
          await _channel.invokeMethod<dynamic>('getInitialSharePayload');
      if (raw == null) return null;
      if (raw is Map) {
        return SharedPayload.fromMap(raw);
      } else if (raw is String && raw.isNotEmpty) {
        final decoded = jsonDecode(raw);
        if (decoded is Map) {
          return SharedPayload.fromMap(decoded);
        }
      }
    } on PlatformException catch (_) {
      return null;
    }
    return null;
  }
}
