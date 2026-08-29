import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:uuid/uuid.dart';

import '../../../core/constants/colors.dart';
import '../../../core/constants/spacing.dart';
import '../../../core/constants/typography.dart';
import '../../../core/providers/database_provider.dart';
import '../../../core/router/app_router.dart';
import '../../../core/widgets/aura_widgets.dart';
import '../../../database/app_database.dart';
import '../../../platform/channels.dart';

class ShareReceiverScreen extends ConsumerStatefulWidget {
  const ShareReceiverScreen({super.key});

  @override
  ConsumerState<ShareReceiverScreen> createState() => _ShareReceiverScreenState();
}

class _ShareReceiverScreenState extends ConsumerState<ShareReceiverScreen> {
  static const _shareChannel = MethodChannel(AuraChannels.shareMethod);
  final _contentController = TextEditingController();
  final _titleController = TextEditingController();
  bool _isLoading = true;
  bool _isSaving = false;
  String _shareType = 'text';

  @override
  void initState() {
    super.initState();
    _fetchSharePayload();
  }

  Future<void> _fetchSharePayload() async {
    try {
      final payload = await _shareChannel.invokeMethod<Map<dynamic, dynamic>>('getInitialSharePayload');
      if (payload != null) {
        final text = payload['text'] as String? ?? '';
        final subject = payload['subject'] as String? ?? '';
        _titleController.text = subject.isNotEmpty ? subject : 'Shared Content';
        _contentController.text = text;
        if (text.startsWith('http://') || text.startsWith('https://')) {
          _shareType = 'link';
        }
      }
    } catch (_) {
      // Fallback
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.6),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(AuraSpacing.lg),
            child: GlassmorphicContainer(
              borderRadius: AuraRadius.xl,
              padding: const EdgeInsets.all(AuraSpacing.lg),
              child: _isLoading
                  ? const SizedBox(
                      height: 120,
                      child: Center(child: CircularProgressIndicator()),
                    )
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(_shareType == 'link' ? LucideIcons.link : LucideIcons.share2, size: 16, color: accent),
                            const SizedBox(width: 8),
                            Text('RECEIVED VIA SHARE',
                                style: AuraTypography.caption.copyWith(color: accent, fontWeight: FontWeight.w800, letterSpacing: 1.0)),
                            const Spacer(),
                            IconButton(
                              icon: const Icon(LucideIcons.x, size: 18, color: AuraColors.textMuted),
                              onPressed: () => context.go(Routes.home),
                            ),
                          ],
                        ),
                        const SizedBox(height: AuraSpacing.md),

                        TextField(
                          controller: _titleController,
                          style: AuraTypography.cardTitle.copyWith(color: AuraColors.textPrimary),
                          decoration: InputDecoration(
                            labelText: 'Title',
                            labelStyle: const TextStyle(color: AuraColors.textMuted),
                            filled: true,
                            fillColor: AuraColors.bgSubtle,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(AuraRadius.sm), borderSide: const BorderSide(color: AuraColors.border)),
                          ),
                        ),
                        const SizedBox(height: AuraSpacing.sm),

                        TextField(
                          controller: _contentController,
                          style: AuraTypography.bodySmall.copyWith(color: AuraColors.textPrimary),
                          maxLines: 4,
                          decoration: InputDecoration(
                            labelText: 'Content',
                            labelStyle: const TextStyle(color: AuraColors.textMuted),
                            filled: true,
                            fillColor: AuraColors.bgSubtle,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(AuraRadius.sm), borderSide: const BorderSide(color: AuraColors.border)),
                          ),
                        ),
                        const SizedBox(height: AuraSpacing.lg),

                        Row(
                          children: [
                            Expanded(
                              child: AuraButton(
                                label: 'SAVE AS NOTE',
                                variant: AuraButtonVariant.secondary,
                                isLoading: _isSaving,
                                onPressed: _saveAsNote,
                              ),
                            ),
                            const SizedBox(width: AuraSpacing.sm),
                            Expanded(
                              child: AuraButton(
                                label: 'SAVE AS TASK',
                                isLoading: _isSaving,
                                onPressed: _saveAsTask,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _saveAsNote() async {
    setState(() => _isSaving = true);
    final dao = ref.read(itemDaoProvider);
    await dao.insertItem(ItemsCompanion.insert(
      id: const Uuid().v4(),
      title: _titleController.text.trim().isNotEmpty ? _titleController.text.trim() : 'Shared Note',
      notes: drift.Value(_contentController.text.trim()),
      kind: const drift.Value('note'),
      category: const drift.Value('reminder'),
      createdAt: DateTime.now().millisecondsSinceEpoch,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
    ));
    if (mounted) context.go(Routes.notes);
  }

  Future<void> _saveAsTask() async {
    setState(() => _isSaving = true);
    final dao = ref.read(itemDaoProvider);
    await dao.insertItem(ItemsCompanion.insert(
      id: const Uuid().v4(),
      title: _titleController.text.trim().isNotEmpty ? _titleController.text.trim() : 'Shared Task',
      notes: drift.Value(_contentController.text.trim()),
      category: const drift.Value('task'),
      status: const drift.Value('pending'),
      createdAt: DateTime.now().millisecondsSinceEpoch,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
    ));
    if (mounted) context.go(Routes.home);
  }
}
