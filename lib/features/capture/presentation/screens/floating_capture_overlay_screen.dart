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
                SystemNavigator.pop();
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

