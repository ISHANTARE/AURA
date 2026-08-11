import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';

import 'package:drift/drift.dart' hide Column;

import '../../../../core/constants/colors.dart';
import '../../../../core/constants/spacing.dart';
import '../../../../core/constants/typography.dart';
import '../../../../core/providers/providers.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/widgets/empty_state.dart';

/// Notes Screen — AURA v2 Reactive Notes & Voice Captures Screen
class NotesScreen extends ConsumerWidget {
  const NotesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notesAsync = ref.watch(notesListProvider);
    final itemDao = ref.watch(itemDaoProvider);

    return Scaffold(
      backgroundColor: AuraColors.bgBase,
      appBar: AppBar(
        title: Text('NOTES', style: AuraTypography.screenHeader),
        backgroundColor: AuraColors.bgBase,
        elevation: 0,
      ),
      body: notesAsync.when(
        data: (notes) {
          if (notes.isEmpty) {
            return const AuraEmptyState(
              icon: LucideIcons.fileText,
              title: 'No Quick Notes',
              subtitle:
                  'Tap the AURA orb or say "Note down meeting ideas" to save notes.',
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(AuraSpacing.md),
            itemCount: notes.length,
            separatorBuilder: (_, __) => const SizedBox(height: AuraSpacing.sm),
            itemBuilder: (context, index) {
              final note = notes[index];
              final dateStr = DateFormat('MMM d, h:mm a').format(
                DateTime.fromMillisecondsSinceEpoch(note.updatedAt),
              );

              return GestureDetector(
                onTap: () => context.push(Routes.taskRoute(note.id)),
                child: Container(
                  padding: const EdgeInsets.all(AuraSpacing.md),
                  decoration: BoxDecoration(
                    color: AuraColors.bgCard,
                    border: Border.all(
                      color: AuraColors.border,
                      width: AuraSpacing.borderWidth,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black,
                        offset: Offset(4, 4),
                        blurRadius: 0,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(LucideIcons.fileText,
                              color: AuraColors.accentLime, size: 18),
                          const SizedBox(width: AuraSpacing.xs),
                          Expanded(
                            child: Text(
                              note.title,
                              style: AuraTypography.cardTitle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(LucideIcons.trash2,
                                color: AuraColors.textSecondary, size: 18),
                            onPressed: () async {
                              HapticFeedback.mediumImpact();
                              await itemDao.softDelete(note.id);
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Note deleted'),
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                              }
                            },
                          ),
                        ],
                      ),
                      if (note.notes != null && note.notes!.isNotEmpty) ...[
                        const SizedBox(height: AuraSpacing.xs),
                        Text(
                          note.notes!,
                          style: AuraTypography.body,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      const SizedBox(height: AuraSpacing.xs),
                      Text(
                        dateStr,
                        style: AuraTypography.overline.copyWith(
                          color: AuraColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AuraColors.accentLime),
          ),
        ),
        error: (err, _) =>
            Center(child: Text('Error: $err', style: AuraTypography.body)),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AuraColors.accentLime,
        foregroundColor: Colors.black,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
          side: BorderSide(color: Colors.black, width: 2),
        ),
        elevation: 0,
        onPressed: () => _showCreateNoteModal(context, ref),
        child: const Icon(LucideIcons.plus, size: 24),
      ),
    );
  }

  void _showCreateNoteModal(BuildContext context, WidgetRef ref) {
    final titleCtrl = TextEditingController();
    final bodyCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      backgroundColor: AuraColors.bgCard,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      isScrollControlled: true,
      builder: (ctx) {
        return Padding(
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
              Text('NEW NOTE', style: AuraTypography.cardTitle),
              const SizedBox(height: AuraSpacing.md),
              TextField(
                controller: titleCtrl,
                style: AuraTypography.body,
                decoration: InputDecoration(
                  labelText: 'NOTE TITLE',
                  labelStyle: AuraTypography.labelLime,
                  filled: true,
                  fillColor: AuraColors.bgBase,
                  enabledBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: AuraColors.border, width: 2),
                    borderRadius: BorderRadius.zero,
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: AuraColors.accentLime, width: 2),
                    borderRadius: BorderRadius.zero,
                  ),
                ),
              ),
              const SizedBox(height: AuraSpacing.md),
              TextField(
                controller: bodyCtrl,
                style: AuraTypography.body,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: 'NOTE CONTENT',
                  labelStyle: AuraTypography.labelLime,
                  filled: true,
                  fillColor: AuraColors.bgBase,
                  enabledBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: AuraColors.border, width: 2),
                    borderRadius: BorderRadius.zero,
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: AuraColors.accentLime, width: 2),
                    borderRadius: BorderRadius.zero,
                  ),
                ),
              ),
              const SizedBox(height: AuraSpacing.lg),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AuraColors.accentLime,
                    foregroundColor: Colors.black,
                    side: const BorderSide(color: Colors.black, width: 2),
                    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                  ),
                  onPressed: () async {
                    final title = titleCtrl.text.trim().isEmpty ? 'Untitled Note' : titleCtrl.text.trim();
                    final body = bodyCtrl.text.trim();
                    final itemDao = ref.read(itemDaoProvider);
                    final nowEpoch = DateTime.now().millisecondsSinceEpoch;

                    await itemDao.insertItem(
                      ItemsCompanion.insert(
                        id: 'note_$nowEpoch',
                        title: title,
                        category: 'reminder',
                        kind: 'note',
                        notes: Value(body.isEmpty ? null : body),
                        createdAt: nowEpoch,
                        updatedAt: nowEpoch,
                      ),
                    );

                    if (ctx.mounted) Navigator.pop(ctx);
                  },
                  child: Text('SAVE NOTE', style: AuraTypography.label.copyWith(color: Colors.black, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
