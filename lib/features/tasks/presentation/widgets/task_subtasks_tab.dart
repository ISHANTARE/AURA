import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/constants/spacing.dart';
import '../../../../core/constants/typography.dart';
import '../../../../core/providers/providers.dart';

/// Subtasks Tab Widget — Reactive subtask list & inline subtask creation
class TaskSubtasksTab extends ConsumerStatefulWidget {
  final String itemId;
  final String? workspaceId;

  const TaskSubtasksTab({
    super.key,
    required this.itemId,
    this.workspaceId,
  });

  @override
  ConsumerState<TaskSubtasksTab> createState() => _TaskSubtasksTabState();
}

class _TaskSubtasksTabState extends ConsumerState<TaskSubtasksTab> {
  final TextEditingController _subtaskController = TextEditingController();

  @override
  void dispose() {
    _subtaskController.dispose();
    super.dispose();
  }

  Future<void> _addSubtask() async {
    final title = _subtaskController.text.trim();
    if (title.isEmpty) return;

    final itemDao = ref.read(itemDaoProvider);
    final nowEpoch = DateTime.now().millisecondsSinceEpoch;
    // UUID id — same-title subtasks added in the same millisecond collided.
    const uuid = Uuid();
    final subtaskId = 'subtask_${nowEpoch}_${uuid.v4()}';

    await itemDao.insertItem(
      ItemsCompanion(
        id: Value(subtaskId),
        title: Value(title),
        parentId: Value(widget.itemId),
        workspaceId: Value(widget.workspaceId),
        category: const Value('reminder'),
        kind: const Value('task'),
        status: const Value('pending'),
        priority: const Value('medium'),
        createdAt: Value(nowEpoch),
        updatedAt: Value(nowEpoch),
      ),
    );

    _subtaskController.clear();
    HapticFeedback.lightImpact();
  }

  @override
  Widget build(BuildContext context) {
    final itemDao = ref.watch(itemDaoProvider);
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Column(
      children: [
        // Subtask List
        Expanded(
          child: StreamBuilder<List<Item>>(
            stream: itemDao.watchSubtasks(widget.itemId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                  ),
                );
              }

              final subtasks = snapshot.data ?? [];
              if (subtasks.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(LucideIcons.checkSquare,
                          color: AuraColors.textDisabled, size: 32),
                      const SizedBox(height: 8),
                      Text('No subtasks yet. Add one below!',
                          style: AuraTypography.bodySmall),
                    ],
                  ),
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.symmetric(vertical: AuraSpacing.sm),
                itemCount: subtasks.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(height: AuraSpacing.xs),
                itemBuilder: (context, index) {
                  final subtask = subtasks[index];
                  final isDone = subtask.status == 'completed';

                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AuraSpacing.sm,
                      vertical: AuraSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: AuraColors.cardOf(context),
                      border: Border.all(color: AuraColors.borderOf(context), width: 1),
                    ),
                    child: Row(
                      children: [
                        Checkbox(
                          value: isDone,
                          activeColor: primaryColor,
                          checkColor: Colors.white,
                          onChanged: (val) async {
                            HapticFeedback.lightImpact();
                            await itemDao.updateStatus(
                              subtask.id,
                              val == true ? 'completed' : 'pending',
                            );
                          },
                        ),
                        Expanded(
                          child: Text(
                            subtask.title,
                            style: AuraTypography.bodyPrimary.copyWith(
                              decoration:
                                  isDone ? TextDecoration.lineThrough : null,
                              color: isDone
                                  ? AuraColors.textDisabled
                                  : AuraColors.textPrimaryOf(context),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(LucideIcons.trash2,
                              color: AuraColors.textSecondaryOf(context), size: 16),
                          onPressed: () async {
                            HapticFeedback.lightImpact();
                            await itemDao.softDelete(subtask.id);
                          },
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),

        const SizedBox(height: AuraSpacing.sm),

        // Inline Add Subtask Bar
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _subtaskController,
                style: AuraTypography.bodyPrimary.copyWith(color: AuraColors.textPrimaryOf(context)),
                decoration: InputDecoration(
                  hintText: 'Add subtask...',
                  hintStyle: AuraTypography.bodySmall.copyWith(color: AuraColors.textSecondaryOf(context)),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: AuraSpacing.md, vertical: AuraSpacing.sm),
                ),
                onSubmitted: (_) => _addSubtask(),
              ),
            ),
            const SizedBox(width: AuraSpacing.xs),
            IconButton(
              style: IconButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  side: BorderSide(color: AuraColors.borderOf(context), width: 2),
                ),
              ),
              icon: const Icon(LucideIcons.plus, size: 20),
              onPressed: _addSubtask,
            ),
          ],
        ),
      ],
    );
  }
}
