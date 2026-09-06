import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

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

class _ShareReceiveScreenState extends ConsumerState<ShareReceiveScreen>
    with WidgetsBindingObserver {
  _ShareState _state = const _ShareState(status: _ShareStatus.loading);
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  StreamSubscription<void>? _shareEventSub;

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _titleController.dispose();
    _notesController.dispose();
    _shareEventSub?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Cold start: consume the persisted payload.
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadSharePayload());
    // Warm shares arriving while this screen is already open.
    _shareEventSub = ref
        .read(shareChannelProvider)
        .onShareReceived
        .listen((_) => _loadSharePayload());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _state.payload == null) {
      _loadSharePayload();
    }
  }

  Future<void> _closeScreen() async {
    try {
      await ref.read(shareChannelProvider).close();
    } catch (_) {}
    if (mounted) {
      if (context.canPop()) {
        context.pop();
      } else {
        context.go(Routes.home);
      }
    }
  }

  Future<void> _loadSharePayload({int retries = 3}) async {
    if (_state.status != _ShareStatus.loading && _state.payload == null) {
      setState(() => _state = const _ShareState(status: _ShareStatus.loading));
    }
    try {
      final shareChannel = ref.read(shareChannelProvider);
      var payload = await shareChannel.getInitialSharePayload();

      if (payload == null && retries > 0) {
        await Future.delayed(const Duration(milliseconds: 300));
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

      // 1. Permanently copy media file from cache into app documents storage
      String? permanentFilePath;
      final sourceFilePath = _state.payload?.filePath ?? _state.result?.imagePath;
      if (sourceFilePath != null && sourceFilePath.isNotEmpty) {
        try {
          final src = File(sourceFilePath);
          if (src.existsSync()) {
            final docDir = await getApplicationDocumentsDirectory();
            final mediaDir = Directory(p.join(docDir.path, 'shared_media'));
            if (!mediaDir.existsSync()) {
              await mediaDir.create(recursive: true);
            }
            final ext = p.extension(sourceFilePath);
            final filename = '${itemId}_${DateTime.now().millisecondsSinceEpoch}$ext';
            final destFile = File(p.join(mediaDir.path, filename));
            await src.copy(destFile.path);
            permanentFilePath = destFile.path;
          }
        } catch (e) {
          debugPrint('Error preserving shared media file: $e');
        }
      }

      // 2. Format notes with attachment reference if media was preserved
      final mediaAttachmentTag = permanentFilePath != null ? '\n\n[Attachment: $permanentFilePath]' : '';
      final fullNotes = notes.isNotEmpty
          ? '$notes$mediaAttachmentTag'
          : (mediaAttachmentTag.isNotEmpty ? mediaAttachmentTag.trim() : null);

      final companion = ItemsCompanion(
        id: Value(itemId),
        workspaceId: wsId,
        title: Value(title),
        notes: Value(fullNotes),
        location: Value(permanentFilePath ?? _state.result?.url),
        category: const Value('reminder'),
        kind: const Value('task'),
        status: const Value('pending'),
        createdAt: Value(nowEpoch),
        updatedAt: Value(nowEpoch),
      );

      await db.itemDao.insertItem(companion);

      // 3. Link shared_contents record to this created item
      final sharedId = _state.result?.sharedContentId;
      if (sharedId != null) {
        await SharedContentDao(db).linkToItem(
          sharedId,
          itemId,
          permanentPath: permanentFilePath,
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Item saved to AURA!')),
        );
        _closeScreen();
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
      backgroundColor: AuraColors.bgOf(context),
      appBar: AppBar(
        backgroundColor: AuraColors.bgOf(context),
        elevation: 0,
        leading: IconButton(
          icon: Icon(LucideIcons.x, color: AuraColors.textPrimaryOf(context)),
          onPressed: _closeScreen,
        ),
        title: Text(
          'SHARED TO AURA',
          style: AuraTypography.screenHeader.copyWith(
            color: AuraColors.textPrimaryOf(context),
          ),
        ),
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
    final isImage = payload.type == 'image';
    final hasFilePath = payload.filePath != null && payload.filePath!.isNotEmpty;
    final fileExists = isImage && hasFilePath && File(payload.filePath!).existsSync();

    final icon = isImage
        ? LucideIcons.image
        : (payload.content?.startsWith('http') ?? false)
            ? LucideIcons.link
            : LucideIcons.fileText;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Type Badge
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: AuraSpacing.sm, vertical: 4),
            decoration: BoxDecoration(
              color: AuraColors.accentLime.withValues(alpha: 0.1),
              border: Border.all(color: AuraColors.accentLime),
              borderRadius: BorderRadius.circular(4),
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

          // Content Preview (shows image preview if available)
          if (fileExists)
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: AuraColors.cardOf(context),
                border: Border.all(color: AuraColors.borderOf(context), width: 1.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Image.file(
                  File(payload.filePath!),
                  height: 240,
                  width: double.infinity,
                  fit: BoxFit.contain,
                ),
              ),
            )
          else
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AuraSpacing.md),
              decoration: BoxDecoration(
                color: AuraColors.cardOf(context),
                border: Border.all(color: AuraColors.borderOf(context), width: 1.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                isImage
                    ? 'Shared Image: ${payload.filePath ?? 'Ready to process'}'
                    : payload.content ?? 'No content',
                style: AuraTypography.body.copyWith(
                  color: AuraColors.textPrimaryOf(context),
                ),
                maxLines: 6,
                overflow: TextOverflow.ellipsis,
              ),
            ),

          const SizedBox(height: AuraSpacing.lg),

          Text(
            'AURA will extract the key information and create a task, reminder, or note.',
            style: AuraTypography.caption.copyWith(
              color: AuraColors.textSecondaryOf(context),
            ),
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
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
          Center(
            child: TextButton(
              onPressed: _closeScreen,
              child: Text(
                'Dismiss',
                style: AuraTypography.label.copyWith(color: AuraColors.textSecondaryOf(context)),
              ),
            ),
          ),
        ],
      ),
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
                  Text(
                    'Content Extracted!',
                    style: AuraTypography.cardTitle.copyWith(
                      color: AuraColors.textPrimaryOf(context),
                    ),
                  ),
                  Text(
                    'Review and save to your database',
                    style: AuraTypography.caption.copyWith(
                      color: AuraColors.textSecondaryOf(context),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AuraSpacing.lg),

          // Title field
          Text(
            'TITLE',
            style: AuraTypography.label.copyWith(
              color: AuraColors.accentLime,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _titleController,
            style: AuraTypography.cardTitle.copyWith(
              color: AuraColors.textPrimaryOf(context),
            ),
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
          Text(
            'EXTRACTED CONTENT / NOTES',
            style: AuraTypography.label.copyWith(
              color: AuraColors.accentLime,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _notesController,
            maxLines: 5,
            style: AuraTypography.bodyPrimary.copyWith(
              color: AuraColors.textPrimaryOf(context),
            ),
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
                  side: BorderSide(color: AuraColors.borderOf(context)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: _closeScreen,
                child: Text(
                  'DISCARD',
                  style: TextStyle(color: AuraColors.textPrimaryOf(context)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildError(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(LucideIcons.alertCircle, size: 48, color: AuraColors.accentRed),
          const SizedBox(height: AuraSpacing.md),
          Text(
            'Something went wrong',
            style: AuraTypography.cardTitle.copyWith(
              color: AuraColors.textPrimaryOf(context),
            ),
          ),
          const SizedBox(height: AuraSpacing.xs),
          Text(
            message,
            style: AuraTypography.body.copyWith(
              color: AuraColors.textSecondaryOf(context),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AuraSpacing.lg),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AuraColors.accentLime,
              foregroundColor: Colors.black,
            ),
            onPressed: _closeScreen,
            child: const Text('GO HOME'),
          ),
        ],
      ),
    );
  }
}
