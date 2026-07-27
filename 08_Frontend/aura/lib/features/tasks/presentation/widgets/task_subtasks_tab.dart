import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import 'package:aura/core/constants/colors.dart';
import 'package:aura/core/constants/typography.dart';
import '../providers/task_detail_providers.dart';

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
  bool _isAdding = false;

  @override
  void dispose() {
    _subtaskController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final subtasksAsync = ref.watch(taskSubtasksStreamProvider(widget.parentTaskId));

    return subtasksAsync.when(
      data: (subtasks) {
        final total = subtasks.length;
        final completed = subtasks.where((s) => s.status == 'done').length;
        final progress = total > 0 ? completed / total : 0.0;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Progress Bar
            if (total > 0) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '$completed / $total subtasks done',
                    style: AuraTypography.bodySmall.copyWith(color: AuraColors.textSecondary),
                  ),
                  Text(
                    '${(progress * 100).round()}%',
                    style: AuraTypography.badgeText.copyWith(color: AuraColors.accentLime),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                height: 8,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AuraColors.bgElevated,
                  border: Border.all(color: AuraColors.border, width: 1.5),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: progress,
                  child: Container(color: AuraColors.accentLime),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Subtask items
            ...subtasks.map((subtask) {
              final isDone = subtask.status == 'done';
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: AuraColors.bgCard,
                  border: Border.all(color: AuraColors.borderMuted, width: 1),
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        ref
                            .read(taskDetailActionProvider.notifier)
                            .toggleSubtask(subtask.id, !isDone);
                      },
                      child: Icon(
                        isDone ? LucideIcons.checkSquare : LucideIcons.square,
                        size: 20,
                        color: isDone ? AuraColors.accentGreen : AuraColors.textSecondary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        subtask.name,
                        style: AuraTypography.bodyPrimary.copyWith(
                          decoration: isDone ? TextDecoration.lineThrough : null,
                          color: isDone ? AuraColors.textDisabled : AuraColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),

            const SizedBox(height: 12),

            // Inline Add Subtask
            if (_isAdding)
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _subtaskController,
                      autofocus: true,
                      style: AuraTypography.bodyPrimary,
                      decoration: const InputDecoration(
                        hintText: 'Enter subtask name...',
                        hintStyle: TextStyle(color: AuraColors.textDisabled),
                        filled: true,
                        fillColor: AuraColors.bgElevated,
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: AuraColors.border, width: 1.5),
                          borderRadius: BorderRadius.zero,
                        ),
                      ),
                      onSubmitted: (_) => _submitSubtask(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(LucideIcons.check, color: AuraColors.accentLime),
                    onPressed: _submitSubtask,
                  ),
                  IconButton(
                    icon: const Icon(LucideIcons.x, color: AuraColors.textSecondary),
                    onPressed: () => setState(() => _isAdding = false),
                  ),
                ],
              )
            else
              OutlinedButton.icon(
                onPressed: () => setState(() => _isAdding = true),
                icon: const Icon(LucideIcons.plus, size: 16, color: AuraColors.accentLime),
                label: Text(
                  'ADD SUBTASK',
                  style: AuraTypography.buttonSecondary.copyWith(
                    color: AuraColors.accentLime,
                    fontSize: 13,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AuraColors.border, width: 1.5),
                  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                ),
              ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator(color: AuraColors.accentLime)),
      error: (e, s) => Text('Error loading subtasks: $e', style: AuraTypography.bodySmall),
    );
  }

  void _submitSubtask() {
    final text = _subtaskController.text.trim();
    if (text.isNotEmpty) {
      ref.read(taskDetailActionProvider.notifier).addSubtask(
            parentTaskId: widget.parentTaskId,
            workspaceId: widget.workspaceId,
            title: text,
          );
      _subtaskController.clear();
      setState(() => _isAdding = false);
    }
  }
}
