import 'dart:async';

import 'package:flutter/material.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/constants/spacing.dart';
import '../../../../core/constants/typography.dart';
import '../../../../core/providers/providers.dart';
import '../../../../core/router/app_router.dart';
import '../../../../database/daos/shared_content_dao.dart';
import '../../domain/usecases/process_shared_content_usecase.dart';
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
/// ProcessSharedContentUseCase (OCR / link read), and saves the extracted
/// content as a shared item after user review.
class ShareReceiveScreen extends ConsumerStatefulWidget {
  const ShareReceiveScreen({super.key});

  @override
  ConsumerState<ShareReceiveScreen> createState() => _ShareReceiveScreenState();
}

class _ShareReceiveScreenState extends ConsumerState<ShareReceiveScreen> {
  _ShareState _state = const _ShareState(status: _ShareStatus.loading);
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  StreamSubscription<void>? _shareEventSub;

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    _shareEventSub?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // Cold start: consume the persisted payload file.
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadSharePayload());
    // Warm shares arriving while this screen is already open.
    _shareEventSub = ref
        .read(shareChannelProvider)
        .onShareReceived
        .listen((_) => _loadSharePayload());
  }

  Future<void> _loadSharePayload({int retries = 2}) async {
    try {
      final shareChannel = ref.read(shareChannelProvider);
      var payload = await shareChannel.getInitialSharePayload();

      if (payload == null && retries > 0) {
        await Future.delayed(const Duration(milliseconds: 350));
        return _loadSharePayload(retries: retries - 1);
      }

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

      _titleController.text = result.title;
      _notesController.text = result.extractedText;

      setState(() => _state = _ShareState(
            status: _ShareStatus.done,
            payload: payload,
            result: result,
          ));
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

  Future<void> _saveSharedItem() async {
    final title = _titleController.text.trim();
    final notes = _notesController.text.trim();

    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a title')),
      );
      return;
    }

    try {
      final db = ref.read(databaseProvider);
      // FK-safe: never write a dangling workspace reference. On fresh
      // installs with no workspaces, leave it null instead of crashing.
      final workspaces = await db.workspaceDao.getAll();
      final wsId = workspaces.isNotEmpty ? Value(workspaces.first.id) : const Value<String?>(null);
      const uuid = Uuid();
      final nowEpoch = DateTime.now().millisecondsSinceEpoch;
      final itemId = uuid.v4();

      final companion = ItemsCompanion(
        id: Value(itemId),
        workspaceId: wsId,
        title: Value(title),
        notes: Value(notes.isNotEmpty ? notes : null),
        location: Value(_state.result?.url),
        category: const Value('shared'),
        kind: const Value('shared'),
        status: const Value('pending'),
        createdAt: Value(nowEpoch),
        updatedAt: Value(nowEpoch),
      );

      await db.itemDao.insertItem(companion);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Item saved to AURA!')),
        );
        context.go(Routes.home);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save item: $e')),
        );
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
            color: AuraColors.cardOf(context),
            border: Border.all(color: AuraColors.borderOf(context), width: 2),
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
              side: BorderSide(color: AuraColors.borderOf(context), width: 2),
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
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: AuraColors.accentGreen,
                  shape: BoxShape.circle,
                ),
                child: const Icon(LucideIcons.check, size: 24, color: Colors.black),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Content Extracted!', style: AuraTypography.cardTitle),
                  Text('Review and save to your database', style: AuraTypography.caption),
                ],
              ),
            ],
          ),
          const SizedBox(height: AuraSpacing.lg),

          // Title field
          Text('TITLE', style: AuraTypography.label.copyWith(color: AuraColors.accentLime, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          TextField(
            controller: _titleController,
            style: AuraTypography.cardTitle,
            decoration: InputDecoration(
              filled: true,
              fillColor: AuraColors.cardOf(context),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AuraColors.borderOf(context)),
              ),
            ),
          ),

          const SizedBox(height: AuraSpacing.md),

          // Extracted text / Notes field
          Text('EXTRACTED CONTENT / NOTES', style: AuraTypography.label.copyWith(color: AuraColors.accentLime, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          TextField(
            controller: _notesController,
            maxLines: 5,
            style: AuraTypography.bodyPrimary,
            decoration: InputDecoration(
              filled: true,
              fillColor: AuraColors.cardOf(context),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AuraColors.borderOf(context)),
              ),
            ),
          ),

          const SizedBox(height: AuraSpacing.xl),

          // Action Buttons: SAVE vs DISCARD
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AuraColors.accentLime,
                    foregroundColor: Colors.black,
                    minimumSize: const Size(0, 48),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  icon: const Icon(LucideIcons.save, size: 18, color: Colors.black),
                  label: const Text('SAVE TO AURA', style: TextStyle(fontWeight: FontWeight.bold)),
                  onPressed: _saveSharedItem,
                ),
              ),
              const SizedBox(width: 12),
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(0, 48),
                  side: const BorderSide(color: AuraColors.border),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () => context.go(Routes.home),
                child: const Text('DISCARD'),
              ),
            ],
          ),
        ],
      ),
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
