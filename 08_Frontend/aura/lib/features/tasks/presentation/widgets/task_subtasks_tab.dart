import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/constants/spacing.dart';
import '../../../../core/constants/typography.dart';
import '../../../../core/providers/providers.dart';

/// Subtasks Tab Widget — Reactive subtask list & inline subtask creation
class TaskSubtasksTab extends ConsumerStatefulWidget {
  final String parentTaskId;
  final String workspaceId;

  const TaskSubtasksTab({
    super.key,
    required this.parentTaskId,
    required this.workspaceId,
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
    final subtaskId = 'subtask_${nowEpoch}_${title.hashCode.abs()}';

    await itemDao.insertItem(
      ItemsCompanion(
        id: Value(subtaskId),
        title: Value(title),
        parentId: Value(widget.parentTaskId),
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

    return Column(
      children: [
        // Subtask List
        Expanded(
          child: StreamBuilder<List<Item>>(
            stream: itemDao.watchSubtasks(widget.parentTaskId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(
                    valueColor:
                        AlwaysStoppedAnimation<Color>(AuraColors.accentLime),
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
                      color: AuraColors.bgCard,
                      border: Border.all(color: AuraColors.border, width: 1),
                    ),
                    child: Row(
                      children: [
                        Checkbox(
                          value: isDone,
                          activeColor: AuraColors.accentLime,
                          checkColor: Colors.black,
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
                                  : AuraColors.textPrimary,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(LucideIcons.trash2,
                              color: AuraColors.textSecondary, size: 16),
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
                style: AuraTypography.bodyPrimary,
                decoration: InputDecoration(
                  hintText: 'Add subtask...',
                  hintStyle: AuraTypography.bodySmall,
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: AuraSpacing.md, vertical: AuraSpacing.sm),
                ),
                onSubmitted: (_) => _addSubtask(),
              ),
            ),
            const SizedBox(width: AuraSpacing.xs),
            IconButton(
              style: IconButton.styleFrom(
                backgroundColor: AuraColors.accentLime,
                foregroundColor: Colors.black,
                shape: const RoundedRectangleBorder(
                  side: BorderSide(color: AuraColors.border, width: 2),
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
