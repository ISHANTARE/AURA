import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/spacing.dart';
import '../../../../core/constants/typography.dart';
import '../../domain/entities/capture_state.dart';
import '../providers/capture_provider.dart';
import 'confirmation_box.dart';
import 'waveform_widget.dart';

/// Compact bottom overlay modal (~35% height) for voice capture.
/// Matches UX wireframe `02_voice_capture.md` exactly.
class VoiceCaptureOverlay extends ConsumerStatefulWidget {
  const VoiceCaptureOverlay({super.key});

  /// Helper to dismiss/close the overlay cleanly regardless of whether
  /// it is presented inside a modal bottom sheet or in FloatingCaptureOverlayScreen Activity.
  static void closeOverlay(BuildContext context) {
    final routeName = ModalRoute.of(context)?.settings.name;
    if (routeName == '/capture-overlay' || !Navigator.of(context).canPop()) {
      SystemNavigator.pop();
    } else {
      Navigator.of(context).pop();
      if (ModalRoute.of(context)?.settings.name == '/capture-overlay') {
        SystemNavigator.pop();
      }
    }
  }

  /// Helper to display this modal overlay sheet.
  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.4), // Scrim
      builder: (context) => const VoiceCaptureOverlay(),
    );
  }

  @override
  ConsumerState<VoiceCaptureOverlay> createState() => _VoiceCaptureOverlayState();
}

class _VoiceCaptureOverlayState extends ConsumerState<VoiceCaptureOverlay>
    with SingleTickerProviderStateMixin {
  late final TextEditingController _textController;
  late final AnimationController _pulseController;
  late final Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _glowAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Auto-start capture on overlay launch
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(captureProvider.notifier).startCapture();
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final captureState = ref.watch(captureProvider);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return AnimatedPadding(
      duration: const Duration(milliseconds: 150),
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: AuraColors.bgCard,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border(
            top: BorderSide(
              color: captureState.status == CaptureStatus.error
                  ? AuraColors.accentRed
                  : AuraColors.border,
              width: 1,
            ),
          ),
        ),
        padding: const EdgeInsets.fromLTRB(AuraSpacing.md, AuraSpacing.sm, AuraSpacing.md, AuraSpacing.sm),
        child: SafeArea(
          top: false,
          child: Builder(
            builder: (context) {
              if (captureState.status == CaptureStatus.confirming) {
                return ConfirmationBox(state: captureState);
              }

              if (captureState.status == CaptureStatus.savedSuccess) {
                return Padding(
                  padding: const EdgeInsets.all(AuraSpacing.lg),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: const BoxDecoration(
                          color: AuraColors.accentGreen,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(LucideIcons.check, size: 28, color: Colors.black),
                      ),
                      const SizedBox(height: AuraSpacing.sm),
                      Text(
                        captureState.isOfflineSaved
                            ? 'Saved as Offline Draft'
                            : 'Task Created Successfully',
                        style: AuraTypography.cardTitle,
                      ),
                      const SizedBox(height: AuraSpacing.xs),
                      Text(
                        captureState.isOfflineSaved
                            ? 'Will process automatically when online.'
                            : 'Saved to your database and workspace.',
                        style: AuraTypography.body,
                      ),
                      const SizedBox(height: AuraSpacing.md),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(140, 44),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          ref.read(captureProvider.notifier).reset();
                          VoiceCaptureOverlay.closeOverlay(context);
                        },
                        child: const Text('DONE', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                );
              }

              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── Top Row (Mini Orb + Label + Waveform + Close) ────────────
                  _buildTopRow(captureState),

                  const SizedBox(height: AuraSpacing.md),

                  // ── Middle Section (Transcript or Processing or Text Input) ──
                  _buildMiddleSection(captureState),

                  const SizedBox(height: AuraSpacing.md),

                  // ── Bottom Action Bar ──────────────────────────────────────────
                  _buildBottomActionBar(captureState),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildTopRow(CaptureState state) {
    return Row(
      children: [
        // Mini Orb with glow
        AnimatedBuilder(
          animation: _pulseController,
          builder: (context, child) {
            return Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).colorScheme.primary
                        .withValues(alpha: _glowAnimation.value * 0.5),
                    blurRadius: 16,
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  'A',
                  style: AuraTypography.orbLabel.copyWith(
                    fontSize: 14,
                    color: Colors.white,
                  ),
                ),
              ),
            );
          },
        ),

        const SizedBox(width: AuraSpacing.sm),

        // Status Label
        Expanded(
          child: Row(
            children: [
              Text(
                _getStatusLabel(state.status),
                style: AuraTypography.label.copyWith(
                  color: (state.status == CaptureStatus.error)
                      ? AuraColors.accentRed
                      : Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(width: AuraSpacing.sm),
              if (state.status == CaptureStatus.listening)
                WaveformWidget(audioLevel: state.audioLevel),
            ],
          ),
        ),

        // Cancel (✕) button
        GestureDetector(
          onTap: () async {
            HapticFeedback.lightImpact();
            await ref.read(captureProvider.notifier).cancelCapture();
            if (mounted) {
              VoiceCaptureOverlay.closeOverlay(context);
            }
          },
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AuraColors.bgElevated,
              shape: BoxShape.circle,
              border: Border.all(color: AuraColors.border, width: 1),
            ),
            child: const Icon(
              Icons.close,
              color: AuraColors.textSecondary,
              size: 16,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMiddleSection(CaptureState state) {
    if (state.status == CaptureStatus.textInput) {
      return Container(
        decoration: BoxDecoration(
          color: AuraColors.bgElevated,
          border: Border.all(color: AuraColors.border, width: 2),
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: AuraSpacing.sm),
        child: TextField(
          controller: _textController,
          autofocus: true,
          style: AuraTypography.bodyPrimary,
          onChanged: (val) {
            ref.read(captureProvider.notifier).updateTypedTranscript(val);
          },
          onSubmitted: (_) {
            ref.read(captureProvider.notifier).submitTypedTranscript();
          },
          decoration: InputDecoration(
            hintText: 'Type what you want to capture...',
            hintStyle: AuraTypography.body,
            border: InputBorder.none,
          ),
        ),
      );
    }

    if (state.status == CaptureStatus.processing) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: AuraSpacing.md),
        alignment: Alignment.center,
        child: Column(
          children: [
            const CircularProgressIndicator(
              strokeWidth: 3,
            ),
            const SizedBox(height: AuraSpacing.sm),
            Text(
              'Thinking...',
              style: AuraTypography.bodyPrimary.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            if (state.transcript.isNotEmpty) ...[
              const SizedBox(height: AuraSpacing.xs),
              Text(
                '"${state.transcript}"',
                style: AuraTypography.body.copyWith(fontStyle: FontStyle.italic),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      );
    }

    if (state.status == CaptureStatus.error) {
      return Container(
        padding: const EdgeInsets.all(AuraSpacing.sm),
        decoration: BoxDecoration(
          color: AuraColors.accentRed.withValues(alpha: 0.1),
          border: Border.all(color: AuraColors.accentRed, width: 1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          state.errorMessage ?? 'An error occurred during voice capture',
          style: AuraTypography.bodyPrimary.copyWith(color: AuraColors.accentRed),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Live Transcript
        ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 48, maxHeight: 90),
          child: SingleChildScrollView(
            child: Text(
              state.transcript.isEmpty
                  ? 'Listening... speak now'
                  : '"${state.transcript}"',
              style: state.transcript.isEmpty
                  ? AuraTypography.body
                  : AuraTypography.bodyPrimary.copyWith(
                      fontStyle: FontStyle.italic,
                    ),
            ),
          ),
        ),

        if (state.detectedContext != null) ...[
          const SizedBox(height: AuraSpacing.xs),
          Text(
            'Detecting context: ${state.detectedContext}',
            style: AuraTypography.label.copyWith(
              color: AuraColors.textSecondary,
              fontSize: 12,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildBottomActionBar(CaptureState state) {
    if (state.status == CaptureStatus.error) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextButton(
            style: TextButton.styleFrom(
              minimumSize: const Size(0, 44),
              padding: const EdgeInsets.symmetric(horizontal: 12),
            ),
            onPressed: () {
              ref.read(captureProvider.notifier).switchToTextInput();
            },
            child: Text(
              'Type Manually',
              style: AuraTypography.label.copyWith(color: AuraColors.textSecondary),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
              minimumSize: const Size(0, 44),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              ref.read(captureProvider.notifier).startCapture();
            },
            child: const Text('Try Again', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // "Type instead" link — constrained to left side
        if (state.status != CaptureStatus.textInput &&
            state.status != CaptureStatus.processing)
          GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              ref.read(captureProvider.notifier).switchToTextInput();
            },
            child: Text(
              'Type instead',
              style: AuraTypography.label.copyWith(
                color: AuraColors.textSecondary,
                decoration: TextDecoration.underline,
              ),
            ),
          )
        else
          const SizedBox.shrink(),

        // CTA Button — intrinsic size, right-aligned
        SizedBox(
          height: 44,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
              elevation: 2,
              minimumSize: const Size(0, 44),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: (state.status == CaptureStatus.processing)
                ? null
                : () {
                    HapticFeedback.mediumImpact();
                    if (state.status == CaptureStatus.textInput) {
                      ref.read(captureProvider.notifier).submitTypedTranscript();
                    } else {
                      ref.read(captureProvider.notifier).stopAndProcess();
                    }
                  },
            child: Text(
              state.status == CaptureStatus.textInput ? 'SUBMIT →' : 'STOP & PROCESS →',
              style: AuraTypography.label.copyWith(
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _getStatusLabel(CaptureStatus status) {
    switch (status) {
      case CaptureStatus.starting:
        return 'STARTING...';
      case CaptureStatus.listening:
        return 'LISTENING...';
      case CaptureStatus.autoStopped:
        return 'STOPPING...';
      case CaptureStatus.processing:
        return 'PROCESSING...';
      case CaptureStatus.confirming:
        return 'CONFIRMING...';
      case CaptureStatus.savedSuccess:
        return 'SAVED!';
      case CaptureStatus.error:
        return 'ERROR';
      case CaptureStatus.textInput:
        return 'TYPE INPUT';
      case CaptureStatus.idle:
        return 'IDLE';
    }
  }
}
