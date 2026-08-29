import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:uuid/uuid.dart';

import '../../../core/constants/colors.dart';
import '../../../core/constants/spacing.dart';
import '../../../core/constants/typography.dart';
import '../../../core/providers/database_provider.dart';
import '../../../core/widgets/aura_widgets.dart';
import '../../../database/app_database.dart';

// ── Providers ─────────────────────────────────────────────────────────────────

final notesListProvider = StreamProvider<List<Item>>((ref) {
  return ref.watch(itemDaoProvider).watchAllActive().map(
        (items) => items.where((i) => i.kind == 'note').toList(),
      );
});

// ── Notes Screen ──────────────────────────────────────────────────────────────

class NotesScreen extends ConsumerStatefulWidget {
  const NotesScreen({super.key});

  @override
  ConsumerState<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends ConsumerState<NotesScreen> {
  String _searchQuery = '';
  final String? _selectedWorkspaceFilter = null;

  @override
  Widget build(BuildContext context) {
    final notesAsync = ref.watch(notesListProvider);

    return Scaffold(
      backgroundColor: AuraColors.bgBase,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(AuraSpacing.md, AuraSpacing.md, AuraSpacing.md, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Notes & Knowledge', style: AuraTypography.sectionHeader.copyWith(color: AuraColors.textPrimary)),
                        Text('Voice notes, clippings & thoughts', style: AuraTypography.caption.copyWith(color: AuraColors.textMuted)),
                      ],
                    ),
                  ),
                  AuraButton(
                    label: 'NEW',
                    icon: LucideIcons.plus,
                    variant: AuraButtonVariant.outline,
                    onPressed: () => _showCreateNoteSheet(context),
                  ),
                ],
              ),
            ),

            // Search Bar
            Padding(
              padding: const EdgeInsets.all(AuraSpacing.md),
              child: BentoCard(
                padding: const EdgeInsets.symmetric(horizontal: AuraSpacing.sm, vertical: AuraSpacing.xs),
                child: Row(
                  children: [
                    const Icon(LucideIcons.search, size: 16, color: AuraColors.textMuted),
                    const SizedBox(width: AuraSpacing.sm),
                    Expanded(
                      child: TextField(
                        onChanged: (v) => setState(() => _searchQuery = v),
                        style: AuraTypography.body.copyWith(color: AuraColors.textPrimary),
                        decoration: InputDecoration(
                          hintText: 'Search notes and transcripts...',
                          hintStyle: AuraTypography.body.copyWith(color: AuraColors.textMuted),
                          border: InputBorder.none,
                          isDense: true,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Notes List
            Expanded(
              child: notesAsync.when(
                data: (notes) {
                  final filtered = notes.where((n) {
                    if (n.deletedAt != null) return false;
                    if (_selectedWorkspaceFilter != null && n.workspaceId != _selectedWorkspaceFilter) return false;
                    if (_searchQuery.isNotEmpty) {
                      final query = _searchQuery.toLowerCase();
                      final titleMatch = n.title.toLowerCase().contains(query);
                      final bodyMatch = (n.notes ?? '').toLowerCase().contains(query);
                      return titleMatch || bodyMatch;
                    }
                    return true;
                  }).toList();

                  if (filtered.isEmpty) {
                    return _EmptyNotesView(onAdd: () => _showCreateNoteSheet(context));
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: AuraSpacing.md),
                    itemCount: filtered.length,
                    itemBuilder: (ctx, index) {
                      return _NoteItemCard(note: filtered[index]);
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Error: $e', style: const TextStyle(color: AuraColors.accentRed))),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCreateNoteSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _CreateNoteSheet(),
    );
  }
}

// ── Note Item Card ────────────────────────────────────────────────────────────

class _NoteItemCard extends StatelessWidget {
  final Item note;
  const _NoteItemCard({required this.note});

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    final created = DateTime.fromMillisecondsSinceEpoch(note.createdAt);
    final dateStr = DateFormat('MMM d · hh:mm a').format(created);

    return Padding(
      padding: const EdgeInsets.only(bottom: AuraSpacing.sm),
      child: BentoCard(
        onTap: () => _showEditNoteSheet(context, note),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    note.title.isNotEmpty ? note.title : 'Untitled Note',
                    style: AuraTypography.cardTitle.copyWith(color: AuraColors.textPrimary, fontWeight: FontWeight.w700),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(dateStr, style: AuraTypography.caption.copyWith(color: AuraColors.textMuted)),
              ],
            ),
            if (note.notes != null && note.notes!.isNotEmpty) ...[
              const SizedBox(height: AuraSpacing.xs),
              Text(
                note.notes!,
                style: AuraTypography.bodySmall.copyWith(color: AuraColors.textSecondary),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            if (note.aiTranscript != null && note.aiTranscript!.isNotEmpty) ...[
              const SizedBox(height: AuraSpacing.sm),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AuraColors.bgSubtle,
                  borderRadius: BorderRadius.circular(AuraRadius.xs),
                  border: Border.all(color: AuraColors.border, width: 0.5),
                ),
                child: Row(
                  children: [
                    Icon(LucideIcons.mic, size: 12, color: accent),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        note.aiTranscript!,
                        style: AuraTypography.caption.copyWith(color: AuraColors.textMuted, fontStyle: FontStyle.italic),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showEditNoteSheet(BuildContext context, Item note) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _EditNoteSheet(note: note),
    );
  }
}

// ── Create Note Sheet ─────────────────────────────────────────────────────────

class _CreateNoteSheet extends ConsumerStatefulWidget {
  const _CreateNoteSheet();

  @override
  ConsumerState<_CreateNoteSheet> createState() => _CreateNoteSheetState();
}

class _CreateNoteSheetState extends ConsumerState<_CreateNoteSheet> {
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  bool _isSaving = false;

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      decoration: const BoxDecoration(
        color: AuraColors.bgElevated,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AuraRadius.xl)),
        border: Border(top: BorderSide(color: AuraColors.border, width: 1)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AuraSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('New Note', style: AuraTypography.cardTitle.copyWith(color: AuraColors.textPrimary, fontWeight: FontWeight.w700)),
                IconButton(icon: const Icon(LucideIcons.x, size: 18, color: AuraColors.textMuted), onPressed: () => Navigator.pop(context)),
              ],
            ),
            const SizedBox(height: AuraSpacing.sm),
            TextField(
              controller: _titleController,
              autofocus: true,
              style: AuraTypography.cardTitle.copyWith(color: AuraColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'Title (optional)',
                hintStyle: AuraTypography.body.copyWith(color: AuraColors.textMuted),
                filled: true,
                fillColor: AuraColors.bgSubtle,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(AuraRadius.sm), borderSide: const BorderSide(color: AuraColors.border)),
              ),
            ),
            const SizedBox(height: AuraSpacing.sm),
            TextField(
              controller: _bodyController,
              style: AuraTypography.body.copyWith(color: AuraColors.textPrimary),
              maxLines: 5,
              decoration: InputDecoration(
                hintText: 'Type your note...',
                hintStyle: AuraTypography.body.copyWith(color: AuraColors.textMuted),
                filled: true,
                fillColor: AuraColors.bgSubtle,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(AuraRadius.sm), borderSide: const BorderSide(color: AuraColors.border)),
              ),
            ),
            const SizedBox(height: AuraSpacing.md),
            AuraButton(
              label: 'SAVE NOTE',
              fullWidth: true,
              isLoading: _isSaving,
              onPressed: _save,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    final title = _titleController.text.trim();
    final body = _bodyController.text.trim();
    if (title.isEmpty && body.isEmpty) return;

    setState(() => _isSaving = true);
    final dao = ref.read(itemDaoProvider);
    await dao.insertItem(ItemsCompanion.insert(
      id: const Uuid().v4(),
      title: title.isNotEmpty ? title : 'Untitled Note',
      notes: drift.Value(body),
      kind: const drift.Value('note'),
      category: const drift.Value('reminder'),
      createdAt: DateTime.now().millisecondsSinceEpoch,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
    ));

    if (mounted) Navigator.pop(context);
  }
}

// ── Edit Note Sheet ───────────────────────────────────────────────────────────

class _EditNoteSheet extends ConsumerStatefulWidget {
  final Item note;
  const _EditNoteSheet({required this.note});

  @override
  ConsumerState<_EditNoteSheet> createState() => _EditNoteSheetState();
}

class _EditNoteSheetState extends ConsumerState<_EditNoteSheet> {
  late TextEditingController _titleController;
  late TextEditingController _bodyController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note.title);
    _bodyController = TextEditingController(text: widget.note.notes ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      decoration: const BoxDecoration(
        color: AuraColors.bgElevated,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AuraRadius.xl)),
        border: Border(top: BorderSide(color: AuraColors.border, width: 1)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AuraSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Edit Note', style: AuraTypography.cardTitle.copyWith(color: AuraColors.textPrimary, fontWeight: FontWeight.w700)),
                IconButton(
                  icon: const Icon(LucideIcons.trash2, size: 18, color: AuraColors.accentRed),
                  onPressed: _delete,
                ),
              ],
            ),
            const SizedBox(height: AuraSpacing.sm),
            TextField(
              controller: _titleController,
              style: AuraTypography.cardTitle.copyWith(color: AuraColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'Title',
                hintStyle: AuraTypography.body.copyWith(color: AuraColors.textMuted),
                filled: true,
                fillColor: AuraColors.bgSubtle,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(AuraRadius.sm), borderSide: const BorderSide(color: AuraColors.border)),
              ),
            ),
            const SizedBox(height: AuraSpacing.sm),
            TextField(
              controller: _bodyController,
              style: AuraTypography.body.copyWith(color: AuraColors.textPrimary),
              maxLines: 5,
              decoration: InputDecoration(
                hintText: 'Body',
                hintStyle: AuraTypography.body.copyWith(color: AuraColors.textMuted),
                filled: true,
                fillColor: AuraColors.bgSubtle,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(AuraRadius.sm), borderSide: const BorderSide(color: AuraColors.border)),
              ),
            ),
            const SizedBox(height: AuraSpacing.md),
            AuraButton(
              label: 'UPDATE NOTE',
              fullWidth: true,
              isLoading: _isSaving,
              onPressed: _update,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _update() async {
    setState(() => _isSaving = true);
    final dao = ref.read(itemDaoProvider);
    await dao.updateItem(ItemsCompanion(
      id: drift.Value(widget.note.id),
      title: drift.Value(_titleController.text.trim()),
      notes: drift.Value(_bodyController.text.trim()),
      updatedAt: drift.Value(DateTime.now().millisecondsSinceEpoch),
    ));
    if (mounted) Navigator.pop(context);
  }

  Future<void> _delete() async {
    final dao = ref.read(itemDaoProvider);
    await dao.softDeleteItem(widget.note.id, DateTime.now().millisecondsSinceEpoch);
    if (mounted) Navigator.pop(context);
  }
}

// ── Empty Notes View ──────────────────────────────────────────────────────────

class _EmptyNotesView extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyNotesView({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(LucideIcons.fileText, size: 48, color: AuraColors.textMuted.withValues(alpha: 0.3)),
          const SizedBox(height: AuraSpacing.md),
          Text('No notes found', style: AuraTypography.body.copyWith(color: AuraColors.textMuted)),
          const SizedBox(height: AuraSpacing.md),
          AuraButton(label: 'CREATE NOTE', icon: LucideIcons.plus, onPressed: onAdd),
        ],
      ),
    );
  }
}
