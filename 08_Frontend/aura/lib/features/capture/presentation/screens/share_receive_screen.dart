import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/constants/spacing.dart';
import '../../../../core/constants/typography.dart';
import '../../../../core/providers/providers.dart';
import '../../../../core/router/app_router.dart';
import '../../../../database/daos/shared_content_dao.dart';
import '../../domain/usecases/process_shared_content_usecase.dart';
import '../../../capture/presentation/providers/capture_provider.dart';
import '../../../../platform/share_channel.dart';

/// Provider for ShareChannel instance
final shareChannelProvider = Provider<ShareChannel>((ref) => ShareChannel());

/// Provider for ProcessSharedContentUseCase
final processSharedContentUseCaseProvider =
    Provider<ProcessSharedContentUseCase>((ref) {
  final db = ref.watch(databaseProvider);
  return ProcessSharedContentUseCase(
    sharedContentDao: SharedContentDao(db),
  );
});

/// Async state for the share receive screen
enum _ShareStatus { loading, ready, processing, done, error }

class _ShareState {
  final _ShareStatus status;
  final SharedPayload? payload;
  final ProcessedShareResult? result;
  final String? errorMessage;

  const _ShareState({
    required this.status,
    this.payload,
    this.result,
    this.errorMessage,
  });
}

/// Share-to-AURA Receive Screen for v2.
/// Receives shared content (text/links/images), processes them via
/// ProcessSharedContentUseCase, and routes to VoiceCaptureOverlay
/// for intent confirmation.
class ShareReceiveScreen extends ConsumerStatefulWidget {
  const ShareReceiveScreen({super.key});

  @override
  ConsumerState<ShareReceiveScreen> createState() => _ShareReceiveScreenState();
}

class _ShareReceiveScreenState extends ConsumerState<ShareReceiveScreen> {
  _ShareState _state = const _ShareState(status: _ShareStatus.loading);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadSharePayload());
  }

  Future<void> _loadSharePayload() async {
    try {
      final shareChannel = ref.read(shareChannelProvider);
      final payload = await shareChannel.getInitialSharePayload();

      if (!mounted) return;

      if (payload == null) {
        setState(() => _state = const _ShareState(
              status: _ShareStatus.ready,
              errorMessage: 'No shared content received.',
            ));
        return;
      }

      setState(() => _state = _ShareState(
            status: _ShareStatus.ready,
            payload: payload,
          ));
    } catch (e) {
      if (mounted) {
        setState(() => _state = _ShareState(
              status: _ShareStatus.error,
              errorMessage: 'Failed to read shared content: $e',
            ));
      }
    }
  }

  Future<void> _processAndCapture() async {
    final payload = _state.payload;
    if (payload == null) return;

    setState(() => _state = _ShareState(
          status: _ShareStatus.processing,
          payload: payload,
        ));

    try {
      final useCase = ref.read(processSharedContentUseCaseProvider);
      final result = await useCase.execute(payload);

      if (!mounted) return;

      setState(() => _state = _ShareState(
            status: _ShareStatus.done,
            payload: payload,
            result: result,
          ));

      // Pre-fill the capture transcript with the extracted text
      // and route to home to show voice confirmation
      ref.read(captureProvider.notifier).updateTypedTranscript(
            '${result.title}: ${result.extractedText}'.trim(),
          );

      if (mounted) context.go(Routes.home);
    } catch (e) {
      if (mounted) {
        setState(() => _state = _ShareState(
              status: _ShareStatus.error,
              payload: payload,
              errorMessage: 'Processing failed: $e',
            ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AuraColors.bgBase,
      appBar: AppBar(
        backgroundColor: AuraColors.bgBase,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.x, color: AuraColors.textPrimary),
          onPressed: () => context.go(Routes.home),
        ),
        title: Text('SHARED TO AURA', style: AuraTypography.screenHeader),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AuraSpacing.md),
          child: _buildBody(),
        ),
      ),
    );
  }

  Widget _buildBody() {
    switch (_state.status) {
      case _ShareStatus.loading:
        return const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AuraColors.accentLime),
          ),
        );

      case _ShareStatus.error:
        return _buildError(_state.errorMessage ?? 'Unknown error');

      case _ShareStatus.processing:
        return const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                valueColor:
                    AlwaysStoppedAnimation<Color>(AuraColors.accentLime),
              ),
              SizedBox(height: AuraSpacing.md),
              Text('Processing shared content…',
                  style: TextStyle(color: AuraColors.textSecondary)),
            ],
          ),
        );

      case _ShareStatus.done:
        return _buildDone();

      case _ShareStatus.ready:
        final payload = _state.payload;
        if (payload == null) {
          return _buildError(_state.errorMessage ?? 'No content received.');
        }
        return _buildPreview(payload);
    }
  }

  Widget _buildPreview(SharedPayload payload) {
    final icon = payload.type == 'image'
        ? LucideIcons.image
        : (payload.content?.startsWith('http') ?? false)
            ? LucideIcons.link
            : LucideIcons.fileText;

    final preview = payload.type == 'image'
        ? 'Image file: ${payload.filePath ?? 'Unknown path'}'
        : payload.content ?? 'No content';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Type Badge
        Container(
          padding:
              const EdgeInsets.symmetric(horizontal: AuraSpacing.sm, vertical: 4),
          decoration: BoxDecoration(
            color: AuraColors.accentLime.withValues(alpha: 0.1),
            border: Border.all(color: AuraColors.accentLime),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 14, color: AuraColors.accentLime),
              const SizedBox(width: 6),
              Text(
                payload.type.toUpperCase(),
                style: AuraTypography.label.copyWith(color: AuraColors.accentLime),
              ),
            ],
          ),
        ),

        const SizedBox(height: AuraSpacing.md),

        // Content Preview
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AuraSpacing.md),
          decoration: BoxDecoration(
            color: AuraColors.bgCard,
            border: Border.all(color: AuraColors.border, width: 2),
            boxShadow: const [
              BoxShadow(
                  color: AuraColors.shadow, offset: Offset(4, 4), blurRadius: 0),
            ],
          ),
          child: Text(
            preview,
            style: AuraTypography.body,
            maxLines: 6,
            overflow: TextOverflow.ellipsis,
          ),
        ),

        const SizedBox(height: AuraSpacing.lg),

        Text(
          'AURA will extract the key information and create a task, reminder, or note.',
          style: AuraTypography.overline,
        ),

        const SizedBox(height: AuraSpacing.md),

        // CTA
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AuraColors.accentLime,
              foregroundColor: Colors.black,
              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
              side: const BorderSide(color: AuraColors.border, width: 2),
              elevation: 0,
            ),
            onPressed: _processAndCapture,
            child: Text(
              'CAPTURE WITH AURA →',
              style: AuraTypography.label.copyWith(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
          ),
        ),

        const SizedBox(height: AuraSpacing.sm),

        // Dismiss
        TextButton(
          onPressed: () => context.go(Routes.home),
          child: Text(
            'Dismiss',
            style: AuraTypography.label.copyWith(color: AuraColors.textSecondary),
          ),
        ),
      ],
    );
  }

  Widget _buildDone() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: const BoxDecoration(
            color: AuraColors.accentGreen,
            shape: BoxShape.circle,
          ),
          child: const Icon(LucideIcons.check, size: 36, color: Colors.black),
        ),
        const SizedBox(height: AuraSpacing.md),
        Text('Content saved!', style: AuraTypography.sectionHeader),
        const SizedBox(height: AuraSpacing.xs),
        Text(
          'Returning to home…',
          style: AuraTypography.body,
        ),
      ],
    );
  }

  Widget _buildError(String message) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(LucideIcons.alertCircle, size: 48, color: AuraColors.accentRed),
        const SizedBox(height: AuraSpacing.md),
        Text('Something went wrong', style: AuraTypography.cardTitle),
        const SizedBox(height: AuraSpacing.xs),
        Text(message, style: AuraTypography.body, textAlign: TextAlign.center),
        const SizedBox(height: AuraSpacing.lg),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AuraColors.accentLime,
            foregroundColor: Colors.black,
          ),
          onPressed: () => context.go(Routes.home),
          child: const Text('GO HOME'),
        ),
      ],
    );
  }
}
