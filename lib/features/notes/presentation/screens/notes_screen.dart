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

import '../providers/note_sort_provider.dart';

/// Notes Screen — AURA v2 Redesigned Notes Screen
class NotesScreen extends ConsumerWidget {
  const NotesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notesAsync = ref.watch(sortedNotesProvider);
    final currentSort = ref.watch(noteSortOrderProvider);
    final itemDao = ref.watch(itemDaoProvider);
    final primaryColor = Theme.of(context).colorScheme.primary;

    final bg = AuraColors.bgOf(context);
    final cardBg = AuraColors.cardOf(context);
    final borderColor = AuraColors.borderOf(context);
    final textPrimary = AuraColors.textPrimaryOf(context);
    final textSecondary = AuraColors.textSecondaryOf(context);
    final textMuted = AuraColors.textMutedOf(context);
    final isDark = AuraColors.isDarkMode(context);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: Text('NOTES', style: AuraTypography.screenHeader.copyWith(color: textPrimary)),
        backgroundColor: bg,
        elevation: 0,
        actions: [
          PopupMenuButton<NoteSortOrder>(
            initialValue: currentSort,
            icon: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: borderColor, width: 1),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(LucideIcons.arrowUpDown, size: 14, color: primaryColor),
                  const SizedBox(width: 6),
                  Text(
                    currentSort.label,
                    style: AuraTypography.caption.copyWith(
                      color: textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            color: cardBg,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: BorderSide(color: borderColor, width: 1),
            ),
            onSelected: (order) {
              ref.read(noteSortOrderProvider.notifier).setSortOrder(order);
            },
            itemBuilder: (context) => NoteSortOrder.values.map((order) {
              final isSelected = order == currentSort;
              return PopupMenuItem<NoteSortOrder>(
                value: order,
                child: Row(
                  children: [
                    Icon(
                      order == NoteSortOrder.lastEdited
                          ? LucideIcons.clock
                          : (order == NoteSortOrder.dateCreated
                              ? LucideIcons.calendar
                              : LucideIcons.arrowDownAZ),
                      size: 16,
                      color: isSelected ? primaryColor : textSecondary,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      order.label,
                      style: AuraTypography.body.copyWith(
                        color: isSelected ? primaryColor : textPrimary,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
          const SizedBox(width: AuraSpacing.sm),
        ],
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
              final dateStr = DateFormat('MMM d · h:mm a').format(
                DateTime.fromMillisecondsSinceEpoch(note.updatedAt),
              );
              final hasBody = note.notes != null && note.notes!.isNotEmpty;

              return GestureDetector(
                onTap: () => context.push(Routes.taskRoute(note.id)),
                child: Container(
                  padding: const EdgeInsets.all(AuraSpacing.md),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: borderColor, width: 1),
                    boxShadow: [
                      BoxShadow(
                        color: isDark ? AuraColors.shadow : AuraColors.lightShadow,
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header row
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: primaryColor.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(LucideIcons.fileText,
                                color: primaryColor, size: 16),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              note.title,
                              style: AuraTypography.cardTitle.copyWith(color: textPrimary),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          IconButton(
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            icon: Icon(LucideIcons.trash2,
                                color: textMuted, size: 18),
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
                      // Note body preview
                      if (hasBody) ...[
                        const SizedBox(height: 8),
                        Text(
                          note.notes!,
                          style: AuraTypography.body.copyWith(
                            color: textSecondary,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      const SizedBox(height: 8),
                      Text(
                        dateStr,
                        style: AuraTypography.overline.copyWith(
                          color: textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) =>
            Center(child: Text('Error: $err', style: AuraTypography.body)),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        onPressed: () => _showCreateNoteModal(context, ref),
        child: const Icon(LucideIcons.plus, size: 24),
      ),
    );
  }

  void _showCreateNoteModal(BuildContext context, WidgetRef ref) {
    final titleCtrl = TextEditingController();
    final bodyCtrl = TextEditingController();
    final primaryColor = Theme.of(context).colorScheme.primary;
    final elevatedBg = AuraColors.elevatedOf(context);
    final cardBg = AuraColors.cardOf(context);
    final borderColor = AuraColors.borderOf(context);
    final textPrimary = AuraColors.textPrimaryOf(context);
    final textSecondary = AuraColors.textSecondaryOf(context);

    showModalBottomSheet(
      context: context,
      backgroundColor: elevatedBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      isScrollControlled: true,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: AuraSpacing.md,
            right: AuraSpacing.md,
            top: AuraSpacing.lg,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + AuraSpacing.md,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: AuraSpacing.md),
                  decoration: BoxDecoration(
                    color: borderColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Text('NEW NOTE', style: AuraTypography.cardTitle.copyWith(color: textPrimary)),
              const SizedBox(height: AuraSpacing.md),
              TextField(
                controller: titleCtrl,
                autofocus: true,
                style: AuraTypography.bodyPrimary.copyWith(color: textPrimary),
                decoration: InputDecoration(
                  hintText: 'Note title...',
                  hintStyle: TextStyle(color: textSecondary),
                  filled: true,
                  fillColor: cardBg,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: borderColor),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: borderColor),
                  ),
                ),
              ),
              const SizedBox(height: AuraSpacing.sm),
              TextField(
                controller: bodyCtrl,
                style: AuraTypography.body.copyWith(color: textPrimary),
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Write something...',
                  hintStyle: TextStyle(color: textSecondary),
                  filled: true,
                  fillColor: cardBg,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: borderColor),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: borderColor),
                  ),
                ),
              ),
              const SizedBox(height: AuraSpacing.lg),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () async {
                    final title = titleCtrl.text.trim().isEmpty
                        ? 'Untitled Note'
                        : titleCtrl.text.trim();
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
                  child: const Text('SAVE NOTE'),
                ),
              ),
              const SizedBox(height: AuraSpacing.sm),
            ],
          ),
        );
      },
    );
  }
}
