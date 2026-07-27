import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:drift/drift.dart' hide Column;

import '../../../../core/constants/colors.dart';
import '../../../../core/constants/spacing.dart';
import '../../../../core/constants/typography.dart';
import '../../../../database/app_database.dart';

/// Notes Screen — Dedicated Notes navigation tab (Sprint 8)
class NotesScreen extends ConsumerStatefulWidget {
  const NotesScreen({super.key});

  @override
  ConsumerState<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends ConsumerState<NotesScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final db = ref.watch(databaseProvider);

    return Scaffold(
      backgroundColor: AuraColors.bgBase,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(AuraSpacing.md),
              child: Row(
                children: [
                  const Icon(LucideIcons.fileText, color: AuraColors.accentLime, size: 24),
                  const SizedBox(width: AuraSpacing.xs),
                  Text('Notes & Thoughts', style: AuraTypography.sectionHeader),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(LucideIcons.plus, color: AuraColors.accentLime),
                    onPressed: () => _showAddNoteModal(context, db),
                    tooltip: 'Add Note',
                  ),
                ],
              ),
            ),

            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AuraSpacing.md),
              child: TextField(
                onChanged: (val) => setState(() => _searchQuery = val.trim().toLowerCase()),
                style: AuraTypography.bodyPrimary,
                decoration: InputDecoration(
                  hintText: 'Search notes...',
                  hintStyle: AuraTypography.bodySmall,
                  prefixIcon: const Icon(LucideIcons.search, size: 18, color: AuraColors.textSecondary),
                  filled: true,
                  fillColor: AuraColors.bgElevated,
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AuraColors.border, width: 1),
                  ),
                ),
              ),
            ),

            const SizedBox(height: AuraSpacing.xs),

            // Notes List
            Expanded(
              child: StreamBuilder<List<Task>>(
                stream: (db.select(db.tasks)
                      ..where((t) => t.description.isNotNull())
                      ..where((t) => t.deletedAt.isNull())
                      ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
                    .watch(),
                builder: (context, snapshot) {
                  final allNotes = snapshot.data ?? [];
                  final notes = _searchQuery.isEmpty
                      ? allNotes
                      : allNotes.where((n) {
                          final title = n.name.toLowerCase();
                          final desc = (n.description ?? '').toLowerCase();
                          return title.contains(_searchQuery) || desc.contains(_searchQuery);
                        }).toList();

                  if (notes.isEmpty) {
                    return _buildEmptyNotes();
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(AuraSpacing.md),
                    itemCount: notes.length,
                    itemBuilder: (context, i) {
                      final item = notes[i];
                      return GestureDetector(
                        onTap: () => _showEditNoteModal(context, db, item),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: AuraSpacing.sm),
                          padding: const EdgeInsets.all(AuraSpacing.md),
                          decoration: BoxDecoration(
                            color: AuraColors.bgElevated,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: AuraColors.border,
                              width: 1,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(LucideIcons.stickyNote, size: 16, color: AuraColors.accentLime),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      item.name,
                                      style: AuraTypography.cardTitle,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const Icon(LucideIcons.pencil, size: 14, color: AuraColors.textSecondary),
                                ],
                              ),
                              if (item.description != null && item.description!.isNotEmpty) ...[
                                const SizedBox(height: AuraSpacing.xs),
                                Text(
                                  item.description!,
                                  style: AuraTypography.body.copyWith(color: AuraColors.textSecondary),
                                  maxLines: 4,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyNotes() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AuraColors.accentLime.withValues(alpha: 0.1),
              shape: BoxShape.circle,
              border: Border.all(color: AuraColors.accentLime.withValues(alpha: 0.4), width: 1.5),
            ),
            child: const Icon(LucideIcons.fileText, color: AuraColors.accentLime, size: 28),
          ),
          const SizedBox(height: AuraSpacing.md),
          Text('No notes captured yet', style: AuraTypography.sectionHeader),
          const SizedBox(height: AuraSpacing.xs),
          Text(
            'Tap the + button or floating orb to add a note',
            style: AuraTypography.body.copyWith(color: AuraColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showAddNoteModal(BuildContext context, AppDatabase db) {
    final titleController = TextEditingController();
    final contentController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AuraColors.bgCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: AuraSpacing.md,
          right: AuraSpacing.md,
          top: AuraSpacing.md,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + AuraSpacing.md,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Add Note', style: AuraTypography.sectionHeader),
            const SizedBox(height: AuraSpacing.md),
            TextField(
              controller: titleController,
              style: AuraTypography.cardTitle,
              decoration: InputDecoration(
                hintText: 'Note Title...',
                filled: true,
                fillColor: AuraColors.bgElevated,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            const SizedBox(height: AuraSpacing.sm),
            TextField(
              controller: contentController,
              maxLines: 4,
              minLines: 2,
              style: AuraTypography.bodyPrimary,
              decoration: InputDecoration(
                hintText: 'Note Content / Details...',
                filled: true,
                fillColor: AuraColors.bgElevated,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            const SizedBox(height: AuraSpacing.md),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AuraColors.accentLime,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () async {
                  final title = titleController.text.trim();
                  final content = contentController.text.trim();
                  if (title.isEmpty && content.isEmpty) return;

                  final now = DateTime.now().millisecondsSinceEpoch;
                  final noteId = now.toString();

                  // Fetch default workspace
                  final workspaces = await db.workspaceDao.getAll();
                  final wsId = workspaces.isNotEmpty ? workspaces.first.id : 'General';

                  await db.into(db.tasks).insert(
                        TasksCompanion.insert(
                          id: noteId,
                          workspaceId: wsId,
                          name: title.isNotEmpty ? title : 'Note',
                          description: Value(content),
                          createdAt: now,
                          updatedAt: now,
                        ),
                      );

                  if (ctx.mounted) Navigator.of(ctx).pop();
                },
                child: Text('SAVE NOTE', style: AuraTypography.label.copyWith(color: Colors.black, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditNoteModal(BuildContext context, AppDatabase db, Task noteItem) {
    final titleController = TextEditingController(text: noteItem.name);
    final contentController = TextEditingController(text: noteItem.description ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AuraColors.bgCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: AuraSpacing.md,
          right: AuraSpacing.md,
          top: AuraSpacing.md,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + AuraSpacing.md,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('Edit Note', style: AuraTypography.sectionHeader),
                const Spacer(),
                IconButton(
                  icon: const Icon(LucideIcons.trash2, color: AuraColors.accentRed, size: 20),
                  onPressed: () async {
                    final now = DateTime.now().millisecondsSinceEpoch;
                    await (db.update(db.tasks)..where((t) => t.id.equals(noteItem.id)))
                        .write(TasksCompanion(deletedAt: Value(now)));
                    if (ctx.mounted) Navigator.of(ctx).pop();
                  },
                ),
              ],
            ),
            const SizedBox(height: AuraSpacing.md),
            TextField(
              controller: titleController,
              style: AuraTypography.cardTitle,
              decoration: InputDecoration(
                hintText: 'Note Title...',
                filled: true,
                fillColor: AuraColors.bgElevated,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            const SizedBox(height: AuraSpacing.sm),
            TextField(
              controller: contentController,
              maxLines: 6,
              minLines: 3,
              style: AuraTypography.bodyPrimary,
              decoration: InputDecoration(
                hintText: 'Note Content / Details...',
                filled: true,
                fillColor: AuraColors.bgElevated,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            const SizedBox(height: AuraSpacing.md),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AuraColors.accentLime,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () async {
                  final title = titleController.text.trim();
                  final content = contentController.text.trim();
                  if (title.isEmpty && content.isEmpty) return;

                  final now = DateTime.now().millisecondsSinceEpoch;

                  await (db.update(db.tasks)..where((t) => t.id.equals(noteItem.id)))
                      .write(
                        TasksCompanion(
                          name: Value(title.isNotEmpty ? title : 'Note'),
                          description: Value(content),
                          updatedAt: Value(now),
                        ),
                      );

                  if (ctx.mounted) Navigator.of(ctx).pop();
                },
                child: Text('UPDATE NOTE', style: AuraTypography.label.copyWith(color: Colors.black, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
