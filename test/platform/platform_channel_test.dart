import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:aura/platform/channels.dart';
import 'package:aura/platform/overlay_channel.dart';
import 'package:aura/platform/speech_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Platform Channel Constants Contract', () {
    test('AuraChannels constants match specification', () {
      expect(AuraChannels.overlayMethod, 'aura/overlay');
      expect(AuraChannels.speechMethod, 'aura/speech');
      expect(AuraChannels.speechPartialEvent, 'aura/speech/partial');
      expect(AuraChannels.speechAudioLevelEvent, 'aura/speech/audioLevel');
      expect(AuraChannels.speechStateEvent, 'aura/speech/speechState');
      expect(AuraChannels.speechErrorEvent, 'aura/speech/speechError');
      expect(AuraChannels.shareMethod, 'aura/share');
      expect(AuraChannels.dndMethod, 'com.aura.aura/dnd');
      expect(AuraChannels.dndEvents, 'com.aura.aura/dnd_events');
    });
  });

  group('OverlayChannel Mocked MethodChannel Tests', () {
    late List<MethodCall> calls;
    late OverlayChannel overlayChannel;

    setUp(() {
      calls = [];
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
        const MethodChannel(AuraChannels.overlayMethod),
        (MethodCall methodCall) async {
          calls.add(methodCall);
          switch (methodCall.method) {
            case 'ping':
              return 'pong';
            case 'startOverlay':
              return true;
            case 'stopOverlay':
              return true;
            case 'isOverlayRunning':
              return true;
            case 'checkOverlayPermission':
              return true;
            case 'pickAlarmSound':
              return {'title': 'Gentle Breeze', 'uri': 'content://media/internal/audio/media/12'};
            default:
              return null;
          }
        },
      );
      overlayChannel = OverlayChannel();
    });

    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
        const MethodChannel(AuraChannels.overlayMethod),
        null,
      );
    });

    test('ping returns pong from native layer', () async {
      final res = await overlayChannel.ping();
      expect(res, 'pong');
      expect(calls.single.method, 'ping');
    });

    test('startOverlay invokes native startOverlay', () async {
      final res = await overlayChannel.startOverlay();
      expect(res, true);
      expect(calls.single.method, 'startOverlay');
    });

    test('stopOverlay invokes native stopOverlay', () async {
      final res = await overlayChannel.stopOverlay();
      expect(res, true);
      expect(calls.single.method, 'stopOverlay');
    });

    test('checkOverlayPermission returns boolean', () async {
      final res = await overlayChannel.checkOverlayPermission();
      expect(res, true);
      expect(calls.single.method, 'checkOverlayPermission');
    });

    test('isOverlayRunning returns boolean', () async {
      final res = await overlayChannel.isOverlayRunning();
      expect(res, true);
      expect(calls.single.method, 'isOverlayRunning');
    });

    test('pickAlarmSound returns sound title and uri', () async {
      final res = await overlayChannel.pickAlarmSound();
      expect(res, isNotNull);
      expect(res!['title'], 'Gentle Breeze');
      expect(res['uri'], 'content://media/internal/audio/media/12');
    });
  });

  group('SpeechChannel Mocked MethodChannel Tests', () {
    late List<MethodCall> calls;
    late SpeechChannel speechChannel;

    setUp(() {
      calls = [];
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
        const MethodChannel(AuraChannels.speechMethod),
        (MethodCall methodCall) async {
          calls.add(methodCall);
          switch (methodCall.method) {
            case 'startListening':
              return true;
            case 'stopListening':
              return true;
            case 'cancelListening':
              return true;
            case 'isAvailable':
              return true;
            default:
              return null;
          }
        },
      );
      speechChannel = SpeechChannel();
    });

    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
        const MethodChannel(AuraChannels.speechMethod),
        null,
      );
    });

    test('startListening sends localeId to native', () async {
      final res = await speechChannel.startListening(localeId: 'en_US');
      expect(res, true);
      expect(calls.single.method, 'startListening');
      expect(calls.single.arguments['localeId'], 'en_US');
    });

    test('stopListening calls stopListening', () async {
      final res = await speechChannel.stopListening();
      expect(res, true);
      expect(calls.single.method, 'stopListening');
    });

    test('cancelListening calls cancelListening', () async {
      final res = await speechChannel.cancelListening();
      expect(res, true);
      expect(calls.single.method, 'cancelListening');
    });

    test('isAvailable returns true', () async {
      final res = await speechChannel.isAvailable();
      expect(res, true);
      expect(calls.single.method, 'isAvailable');
    });
  });
}
