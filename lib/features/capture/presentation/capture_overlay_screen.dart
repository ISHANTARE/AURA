import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/constants/colors.dart';
import '../../../core/constants/spacing.dart';
import '../../../core/constants/typography.dart';
import '../../../core/widgets/aura_widgets.dart';
import '../../../platform/speech_channel.dart';

// ── Capture State Machine ─────────────────────────────────────────────────────

enum CaptureStatus { idle, starting, listening, textInput, processing, confirming, savedSuccess, error }

class CaptureState {
  final CaptureStatus status;
  final String partialTranscript;
  final double audioLevel;
  final String? errorMessage;
  final bool isOfflineSaved;

  const CaptureState({
    this.status = CaptureStatus.idle,
    this.partialTranscript = '',
    this.audioLevel = 0.0,
    this.errorMessage,
    this.isOfflineSaved = false,
  });

  CaptureState copyWith({
    CaptureStatus? status,
    String? partialTranscript,
    double? audioLevel,
    String? errorMessage,
    bool? isOfflineSaved,
  }) =>
      CaptureState(
        status: status ?? this.status,
        partialTranscript: partialTranscript ?? this.partialTranscript,
        audioLevel: audioLevel ?? this.audioLevel,
        errorMessage: errorMessage ?? this.errorMessage,
        isOfflineSaved: isOfflineSaved ?? this.isOfflineSaved,
      );
}

class CaptureNotifier extends StateNotifier<CaptureState> {
  final SpeechChannel _speech;

  CaptureNotifier(this._speech) : super(const CaptureState());

  Future<void> startListening() async {
    state = state.copyWith(status: CaptureStatus.starting, partialTranscript: '', audioLevel: 0.0);

    final available = await _speech.isAvailable();
    if (!available) {
      state = state.copyWith(status: CaptureStatus.error, errorMessage: 'Speech recognition not available on this device.');
      return;
    }

    _speech.partialTranscriptStream.listen((t) {
      state = state.copyWith(partialTranscript: t);
    });

    _speech.audioLevelStream.listen((level) {
      state = state.copyWith(audioLevel: level);
    });

    _speech.speechStateStream.listen((s) {
      if (s == 'autoStopped') stopAndProcess();
      if (s == 'error') state = state.copyWith(status: CaptureStatus.error, errorMessage: 'Speech recognition failed.');
    });

    await _speech.startListening();
    state = state.copyWith(status: CaptureStatus.listening);
  }

  void stopAndProcess() async {
    if (state.status != CaptureStatus.listening) return;
    await _speech.stopListening();
    state = state.copyWith(status: CaptureStatus.processing);

    await Future<void>.delayed(const Duration(milliseconds: 800));
    state = state.copyWith(status: CaptureStatus.confirming);
  }

  void switchToText() => state = state.copyWith(status: CaptureStatus.textInput);

  void dismiss() => state = const CaptureState(status: CaptureStatus.idle);
}

final _speechChannelProvider = Provider((_) => SpeechChannel());
final captureProvider = StateNotifierProvider<CaptureNotifier, CaptureState>((ref) {
  return CaptureNotifier(ref.watch(_speechChannelProvider));
});

// ── Floating Capture Overlay Screen ──────────────────────────────────────────

class FloatingCaptureOverlayScreen extends ConsumerStatefulWidget {
  const FloatingCaptureOverlayScreen({super.key});

  @override
  ConsumerState<FloatingCaptureOverlayScreen> createState() => _FloatingCaptureOverlayScreenState();
}

class _FloatingCaptureOverlayScreenState extends ConsumerState<FloatingCaptureOverlayScreen> {
  final _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(captureProvider.notifier).startListening();
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(captureProvider);
    final accent = Theme.of(context).colorScheme.primary;

    return GestureDetector(
      onTap: () {
        if (state.status == CaptureStatus.listening) {
          ref.read(captureProvider.notifier).stopAndProcess();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black.withValues(alpha: 0.6),
        body: SafeArea(
          child: Stack(
            children: [
              Positioned.fill(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: GestureDetector(
                    onTap: () {},
                    child: GlassmorphicContainer(
                      borderRadius: AuraRadius.xl,
                      padding: const EdgeInsets.all(AuraSpacing.lg),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 36, height: 4,
                            margin: const EdgeInsets.only(bottom: AuraSpacing.md),
                            decoration: BoxDecoration(
                              color: AuraColors.border,
                              borderRadius: BorderRadius.circular(AuraRadius.full),
                            ),
                          ),
                          _buildStatusBody(state, accent),
                          const SizedBox(height: AuraSpacing.lg),
                          _buildActionRow(state, accent),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBody(CaptureState state, Color accent) {
    return switch (state.status) {
      CaptureStatus.starting || CaptureStatus.idle => Column(
          children: [
            _AnimatedMicOrb(audioLevel: 0, state: CaptureStatus.starting, accent: accent),
            const SizedBox(height: AuraSpacing.md),
            Text('Starting...', style: AuraTypography.body.copyWith(color: AuraColors.textSecondary)),
          ],
        ),
      CaptureStatus.listening => Column(
          children: [
            _AnimatedMicOrb(audioLevel: state.audioLevel, state: CaptureStatus.listening, accent: accent),
            const SizedBox(height: AuraSpacing.md),
            _WaveformBar(audioLevel: state.audioLevel, accent: accent),
            const SizedBox(height: AuraSpacing.md),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Text(
                state.partialTranscript.isEmpty ? 'Listening...' : state.partialTranscript,
                key: ValueKey(state.partialTranscript),
                style: AuraTypography.cardTitle.copyWith(
                  color: state.partialTranscript.isEmpty ? AuraColors.textMuted : AuraColors.textPrimary,
                ),
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      CaptureStatus.textInput => Column(
          children: [
            const Icon(LucideIcons.keyboard, size: 32, color: AuraColors.textSecondary),
            const SizedBox(height: AuraSpacing.md),
            TextField(
              controller: _textController,
              autofocus: true,
              style: AuraTypography.cardTitle.copyWith(color: AuraColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'Type your task or reminder...',
                hintStyle: AuraTypography.body.copyWith(color: AuraColors.textMuted),
                filled: true,
                fillColor: AuraColors.bgSubtle,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AuraRadius.md),
                  borderSide: const BorderSide(color: AuraColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AuraRadius.md),
                  borderSide: BorderSide(color: accent),
                ),
              ),
              maxLines: 3,
            ),
          ],
        ),
      CaptureStatus.processing => Column(
          children: [
            SizedBox(
              width: 52, height: 52,
              child: CircularProgressIndicator(color: accent, strokeWidth: 2),
            ),
            const SizedBox(height: AuraSpacing.md),
            Text('Understanding your request...', style: AuraTypography.body.copyWith(color: AuraColors.textSecondary)),
          ],
        ),
      CaptureStatus.confirming => _ConfirmationCard(
          transcript: state.partialTranscript,
          accent: accent,
          onConfirm: () => ref.read(captureProvider.notifier).dismiss(),
          onDiscard: () => ref.read(captureProvider.notifier).dismiss(),
        ),
      CaptureStatus.savedSuccess => Column(
          children: [
            Container(
              width: 56, height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AuraColors.accentGreen.withValues(alpha: 0.15),
              ),
              child: const Icon(LucideIcons.checkCircle2, size: 32, color: AuraColors.accentGreen),
            ),
            const SizedBox(height: AuraSpacing.md),
            Text(
              state.isOfflineSaved ? 'Saved to offline queue. Will sync when online.' : 'Saved successfully!',
              style: AuraTypography.body.copyWith(color: AuraColors.textPrimary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      CaptureStatus.error => Column(
          children: [
            const Icon(LucideIcons.alertCircle, size: 40, color: AuraColors.accentRed),
            const SizedBox(height: AuraSpacing.sm),
            Text(
              state.errorMessage ?? 'Something went wrong.',
              style: AuraTypography.body.copyWith(color: AuraColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
    };
  }

  Widget _buildActionRow(CaptureState state, Color accent) {
    return switch (state.status) {
      CaptureStatus.listening => Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            AuraButton(
              label: 'TYPE INSTEAD',
              variant: AuraButtonVariant.outline,
              icon: LucideIcons.keyboard,
              onPressed: () => ref.read(captureProvider.notifier).switchToText(),
            ),
            AuraButton(
              label: 'DONE',
              icon: LucideIcons.checkCheck,
              onPressed: () => ref.read(captureProvider.notifier).stopAndProcess(),
            ),
          ],
        ),
      CaptureStatus.textInput => AuraButton(
          label: 'PROCESS TEXT',
          fullWidth: true,
          onPressed: () => ref.read(captureProvider.notifier).stopAndProcess(),
        ),
      CaptureStatus.error => Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            AuraButton(
              label: 'TRY AGAIN',
              variant: AuraButtonVariant.outline,
              onPressed: () => ref.read(captureProvider.notifier).startListening(),
            ),
            AuraButton(
              label: 'TYPE',
              variant: AuraButtonVariant.secondary,
              onPressed: () => ref.read(captureProvider.notifier).switchToText(),
            ),
          ],
        ),
      _ => TextButton(
          onPressed: () => ref.read(captureProvider.notifier).dismiss(),
          child: Text('DISMISS', style: AuraTypography.label.copyWith(color: AuraColors.textMuted)),
        ),
    };
  }
}

// ── Animated Mic Orb ──────────────────────────────────────────────────────────

class _AnimatedMicOrb extends StatefulWidget {
  final double audioLevel;
  final CaptureStatus state;
  final Color accent;
  const _AnimatedMicOrb({required this.audioLevel, required this.state, required this.accent});

  @override
  State<_AnimatedMicOrb> createState() => _AnimatedMicOrbState();
}

class _AnimatedMicOrbState extends State<_AnimatedMicOrb> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 1.0, end: 1.08).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() { _controller.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final ringRadius = 28.0 + (widget.audioLevel * 24.0);

    return ScaleTransition(
      scale: _pulseAnim,
      child: SizedBox(
        width: 80,
        height: 80,
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (widget.state == CaptureStatus.listening)
              Container(
                width: ringRadius * 2,
                height: ringRadius * 2,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: widget.accent.withValues(alpha: 0.3), width: 1.5),
                ),
              ),
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.accent.withValues(alpha: 0.15),
                border: Border.all(color: widget.accent.withValues(alpha: 0.6), width: 1.5),
                boxShadow: [BoxShadow(color: widget.accent.withValues(alpha: 0.25), blurRadius: 20, spreadRadius: 4)],
              ),
              child: const Icon(LucideIcons.mic, size: 24, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Waveform Bar ──────────────────────────────────────────────────────────────

class _WaveformBar extends StatelessWidget {
  final double audioLevel;
  final Color accent;
  const _WaveformBar({required this.audioLevel, required this.accent});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(11, (i) {
        final offset = (i - 5).abs() / 5.0;
        final height = 4.0 + (audioLevel * 28.0 * (1.0 - offset * 0.7));
        return AnimatedContainer(
          duration: const Duration(milliseconds: 80),
          width: 4,
          height: height.clamp(4.0, 32.0),
          margin: const EdgeInsets.symmetric(horizontal: 2),
          decoration: BoxDecoration(
            color: accent.withValues(alpha: 0.4 + audioLevel * 0.6),
            borderRadius: BorderRadius.circular(AuraRadius.full),
          ),
        );
      }),
    );
  }
}

// ── Confirmation Card ─────────────────────────────────────────────────────────

class _ConfirmationCard extends StatefulWidget {
  final String transcript;
  final Color accent;
  final VoidCallback onConfirm;
  final VoidCallback onDiscard;

  const _ConfirmationCard({
    required this.transcript,
    required this.accent,
    required this.onConfirm,
    required this.onDiscard,
  });

  @override
  State<_ConfirmationCard> createState() => _ConfirmationCardState();
}

class _ConfirmationCardState extends State<_ConfirmationCard> {
  late TextEditingController _titleController;
  String _priority = 'medium';

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.transcript);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(LucideIcons.sparkles, size: 14, color: widget.accent),
            const SizedBox(width: 6),
            Text('AURA INTELLIGENCE',
                style: AuraTypography.caption.copyWith(
                  color: widget.accent,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.0,
                )),
          ],
        ),
        const SizedBox(height: AuraSpacing.sm),
        TextField(
          controller: _titleController,
          style: AuraTypography.cardTitle.copyWith(color: AuraColors.textPrimary),
          decoration: InputDecoration(
            labelText: 'Task Title',
            labelStyle: AuraTypography.caption.copyWith(color: AuraColors.textMuted),
            filled: true,
            fillColor: AuraColors.bgSubtle,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AuraRadius.sm),
              borderSide: const BorderSide(color: AuraColors.border),
            ),
          ),
        ),
        const SizedBox(height: AuraSpacing.sm),
        Row(
          children: [
            Text('Priority:', style: AuraTypography.caption.copyWith(color: AuraColors.textMuted)),
            const SizedBox(width: AuraSpacing.sm),
            ...['low', 'medium', 'high'].map((p) => Padding(
              padding: const EdgeInsets.only(right: 6),
              child: AuraChip(
                label: p.toUpperCase(),
                color: PriorityBadge.colorFor(p),
                selected: _priority == p,
                onTap: () => setState(() => _priority = p),
              ),
            )),
          ],
        ),
        const SizedBox(height: AuraSpacing.md),
        Row(
          children: [
            Expanded(
              child: AuraButton(
                label: 'CANCEL',
                variant: AuraButtonVariant.outline,
                onPressed: widget.onDiscard,
              ),
            ),
            const SizedBox(width: AuraSpacing.sm),
            Expanded(
              child: AuraButton(
                label: 'CONFIRM & SAVE →',
                onPressed: widget.onConfirm,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
