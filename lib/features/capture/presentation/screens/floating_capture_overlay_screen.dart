import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/voice_capture_overlay.dart';
import '../providers/capture_provider.dart';

/// Screen displayed inside AuraCaptureActivity with transparent background.
/// Shows ONLY the voice capture overlay embedded directly at bottom of screen.
class FloatingCaptureOverlayScreen extends ConsumerStatefulWidget {
  const FloatingCaptureOverlayScreen({super.key});

  @override
  ConsumerState<FloatingCaptureOverlayScreen> createState() =>
      _FloatingCaptureOverlayScreenState();
}

class _FloatingCaptureOverlayScreenState
    extends ConsumerState<FloatingCaptureOverlayScreen> {
  static const _captureActivityChannel = MethodChannel('aura/capture_activity');

  @override
  void initState() {
    super.initState();
    _captureActivityChannel.setMethodCallHandler((call) async {
      if (call.method == 'restartCapture') {
        await ref.read(captureProvider.notifier).cancelCapture();
        if (mounted) {
          ref.read(captureProvider.notifier).startCapture();
        }
      }
      return null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Background dismiss gesture detector
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () async {
                await ref.read(captureProvider.notifier).cancelCapture();
                if (context.mounted) {
                  VoiceCaptureOverlay.closeOverlay(context);
                }
              },
              child: Container(
                color: Colors.black.withValues(alpha: 0.4),
              ),
            ),
          ),
          // Direct embedded VoiceCaptureOverlay at bottom
          const Align(
            alignment: Alignment.bottomCenter,
            child: VoiceCaptureOverlay(),
          ),
        ],
      ),
    );
  }
}

