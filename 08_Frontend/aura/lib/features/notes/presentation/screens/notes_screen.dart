import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:drift/drift.dart' hide Column;

import '../../../../core/constants/colors.dart';
import '../../../../core/constants/spacing.dart';
import '../../../../core/constants/typography.dart';
import '../../../../database/app_database.dart';

/// Notes Screen — Dedicated Notes navigation tab (Sprint 8)
class NotesScreen extends ConsumerWidget {
  const NotesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                ],
              ),
            ),

            // Notes List
            Expanded(
              child: StreamBuilder<List<Task>>(
                stream: (db.select(db.tasks)
                      ..where((t) => t.description.isNotNull())
                      ..where((t) => t.deletedAt.isNull())
                      ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
                    .watch(),
                builder: (context, snapshot) {
                  final notes = snapshot.data ?? [];

                  if (notes.isEmpty) {
                    return _buildEmptyNotes();
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(AuraSpacing.md),
                    itemCount: notes.length,
                    itemBuilder: (context, i) {
                      final item = notes[i];
                      return Container(
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
            'Tap the floating orb and say:\n"Note down project deadline is Friday"',
            style: AuraTypography.body.copyWith(color: AuraColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
