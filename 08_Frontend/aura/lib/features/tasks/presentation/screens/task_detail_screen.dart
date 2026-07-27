import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import 'package:aura/core/constants/colors.dart';
import 'package:aura/core/constants/typography.dart';
import 'package:aura/features/reminders/presentation/providers/reminder_providers.dart';
import 'package:aura/features/reminders/presentation/widgets/snooze_bottom_sheet.dart';
import '../providers/task_detail_providers.dart';
import '../widgets/task_deadline_card.dart';
import '../widgets/task_options_sheet.dart';
import '../widgets/task_stats_bento.dart';
import '../widgets/task_subtasks_tab.dart';

class TaskDetailScreen extends ConsumerStatefulWidget {
  final String taskId;

  const TaskDetailScreen({
    super.key,
    required this.taskId,
  });

  @override
  ConsumerState<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends ConsumerState<TaskDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  bool _isEditingTitle = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final taskAsync = ref.watch(taskDetailStreamProvider(widget.taskId));

    return taskAsync.when(
      data: (task) {
        if (task == null) {
          return Scaffold(
            backgroundColor: AuraColors.bgBase,
            appBar: AppBar(backgroundColor: AuraColors.bgBase),
            body: Center(
              child: Text('Task not found or deleted', style: AuraTypography.body),
            ),
          );
        }

        if (!_isEditingTitle && _titleController.text != task.name) {
          _titleController.text = task.name;
        }

        final workspaceAsync = ref.watch(parentWorkspaceStreamProvider(task.workspaceId));
        final workspaceName = workspaceAsync.value?.name ?? 'General';
        final isDone = task.status == 'done';

        return Scaffold(
          backgroundColor: AuraColors.bgBase,

          // App Bar
          appBar: AppBar(
            backgroundColor: AuraColors.bgBase,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(LucideIcons.arrowLeft, color: AuraColors.textPrimary),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: const Icon(LucideIcons.edit2, color: AuraColors.accentLime, size: 20),
                onPressed: () => setState(() => _isEditingTitle = !_isEditingTitle),
              ),
              IconButton(
                icon: const Icon(LucideIcons.moreVertical, color: AuraColors.textPrimary),
                onPressed: () {
                  TaskOptionsSheet.show(context, taskId: task.id, taskTitle: task.name);
                },
              ),
            ],
          ),

          body: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Breadcrumb
                      Row(
                        children: [
                          Container(
                            width: 4,
                            height: 14,
                            color: AuraColors.accentLime,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'TASK — ${workspaceName.toUpperCase()}',
                            style: AuraTypography.labelLime,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Task Name (Inline Edit)
                      if (_isEditingTitle)
                        TextField(
                          controller: _titleController,
                          autofocus: true,
                          style: AuraTypography.display.copyWith(fontSize: 22),
                          decoration: const InputDecoration(
                            border: UnderlineInputBorder(
                              borderSide: BorderSide(color: AuraColors.accentLime, width: 2),
                            ),
                          ),
                          onSubmitted: (val) {
                            if (val.trim().isNotEmpty) {
                              ref
                                  .read(taskDetailActionProvider.notifier)
                                  .updateTask(taskId: task.id, name: val.trim());
                            }
                            setState(() => _isEditingTitle = false);
                          },
                        )
                      else
                        GestureDetector(
                          onTap: () => setState(() => _isEditingTitle = true),
                          child: Text(
                            task.name,
                            style: AuraTypography.display.copyWith(
                              fontSize: 24,
                              decoration: isDone ? TextDecoration.lineThrough : null,
                              color: isDone ? AuraColors.textDisabled : AuraColors.textPrimary,
                            ),
                          ),
                        ),
                      const SizedBox(height: 20),

                      // Quick Stats Bento
                      TaskStatsBento(
                        status: task.status,
                        priority: task.priority,
                        source: task.source,
                        onStatusChanged: (newStatus) {
                          ref
                              .read(taskDetailActionProvider.notifier)
                              .updateTask(taskId: task.id, status: newStatus);
                        },
                        onPriorityChanged: (newPriority) {
                          ref
                              .read(taskDetailActionProvider.notifier)
                              .updateTask(taskId: task.id, priority: newPriority);
                        },
                      ),
                      const SizedBox(height: 20),

                      // Deadline Section
                      Text('DEADLINE', style: AuraTypography.bentoMetricLabel.copyWith(color: AuraColors.textSecondary)),
                      const SizedBox(height: 8),
                      TaskDeadlineCard(
                        deadline: task.deadline != null
                            ? DateTime.fromMillisecondsSinceEpoch(task.deadline!)
                            : null,
                        onDeadlineChanged: (newDeadline) {
                          ref.read(taskDetailActionProvider.notifier).updateTask(
                                taskId: task.id,
                                deadline: newDeadline,
                              );
                        },
                      ),
                      const SizedBox(height: 20),

                      // Reminders Section
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('REMINDERS', style: AuraTypography.bentoMetricLabel.copyWith(color: AuraColors.textSecondary)),
                          TextButton.icon(
                            onPressed: () {
                              if (task.deadline != null) {
                                ref.read(reminderActionProvider.notifier).scheduleForTask(
                                      taskId: task.id,
                                      title: task.name,
                                      deadline: DateTime.fromMillisecondsSinceEpoch(task.deadline!),
                                    );
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Reminder scheduled!')),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Set a deadline first to add reminders.')),
                                );
                              }
                            },
                            icon: const Icon(LucideIcons.plus, size: 14, color: AuraColors.accentLime),
                            label: Text('+ Add', style: AuraTypography.labelLime),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      Consumer(
                        builder: (ctx, r, _) {
                          final remindersAsync = r.watch(taskRemindersStreamProvider(task.id));
                          return remindersAsync.when(
                            data: (reminders) {
                              if (reminders.isEmpty) {
                                return Text(
                                  'No active reminders',
                                  style: AuraTypography.bodySmall.copyWith(fontStyle: FontStyle.italic),
                                );
                              }
                              return Column(
                                children: reminders.map((rem) {
                                  final fireDate = DateTime.fromMillisecondsSinceEpoch(rem.fireAt);
                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 6),
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: AuraColors.bgCard,
                                      border: Border.all(color: AuraColors.borderMuted, width: 1),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(LucideIcons.bell, size: 14, color: AuraColors.accentLime),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            '${fireDate.month}/${fireDate.day} · ${fireDate.hour}:${fireDate.minute.toString().padLeft(2, '0')}',
                                            style: AuraTypography.bodySmall.copyWith(color: AuraColors.textPrimary),
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: rem.status == 'fired'
                                                ? AuraColors.accentGreen.withValues(alpha: 0.2)
                                                : AuraColors.bgElevated,
                                          ),
                                          child: Text(
                                            rem.status.toUpperCase(),
                                            style: AuraTypography.badgeText.copyWith(
                                              fontSize: 9,
                                              color: rem.status == 'fired' ? AuraColors.accentGreen : AuraColors.textSecondary,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              );
                            },
                            loading: () => const SizedBox.shrink(),
                            error: (e, s) => const SizedBox.shrink(),
                          );
                        },
                      ),

                      const SizedBox(height: 24),

                      // Content Tabs Header
                      TabBar(
                        controller: _tabController,
                        indicatorColor: AuraColors.accentLime,
                        labelColor: AuraColors.accentLime,
                        unselectedLabelColor: AuraColors.textSecondary,
                        labelStyle: AuraTypography.badgeText,
                        tabs: const [
                          Tab(text: 'Details'),
                          Tab(text: 'Subtasks'),
                          Tab(text: 'Notes'),
                          Tab(text: 'Attachments'),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Content Tabs View
                      SizedBox(
                        height: 260,
                        child: TabBarView(
                          controller: _tabController,
                          children: [
                            // Tab 1: Details
                            SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('DESCRIPTION', style: AuraTypography.bentoMetricLabel.copyWith(color: AuraColors.textSecondary)),
                                  const SizedBox(height: 6),
                                  TextField(
                                    controller: _descController..text = task.description ?? '',
                                    maxLines: 3,
                                    style: AuraTypography.bodyPrimary,
                                    decoration: const InputDecoration(
                                      hintText: 'Add description or context...',
                                      hintStyle: TextStyle(color: AuraColors.textDisabled),
                                      filled: true,
                                      fillColor: AuraColors.bgCard,
                                      border: OutlineInputBorder(
                                        borderSide: BorderSide(color: AuraColors.borderMuted),
                                      ),
                                    ),
                                    onChanged: (val) {
                                      ref.read(taskDetailActionProvider.notifier).updateTask(
                                            taskId: task.id,
                                            description: val,
                                          );
                                    },
                                  ),
                                  const SizedBox(height: 12),
                                  if (task.aiRawTranscript != null && task.aiRawTranscript!.isNotEmpty)
                                    ExpansionTile(
                                      title: Text('Raw Voice Transcript', style: AuraTypography.bodySmall),
                                      iconColor: AuraColors.accentLime,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(
                                            '"${task.aiRawTranscript}"',
                                            style: AuraTypography.bodySmall.copyWith(fontStyle: FontStyle.italic),
                                          ),
                                        ),
                                      ],
                                    ),
                                ],
                              ),
                            ),

                            // Tab 2: Subtasks
                            TaskSubtasksTab(
                              parentTaskId: task.id,
                              workspaceId: task.workspaceId,
                            ),

                            // Tab 3: Notes
                            SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('TASK NOTES', style: AuraTypography.bentoMetricLabel.copyWith(color: AuraColors.textSecondary)),
                                  const SizedBox(height: 6),
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: AuraColors.bgElevated,
                                      border: Border.all(color: AuraColors.border, width: 1.5),
                                    ),
                                    child: Text(
                                      task.description ?? 'No notes recorded for this task yet.',
                                      style: AuraTypography.bodyMedium,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Tab 4: Attachments
                            Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(LucideIcons.paperclip, color: AuraColors.textDisabled, size: 32),
                                  const SizedBox(height: 8),
                                  Text('No attachments yet', style: AuraTypography.bodySmall),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Fixed Action Bar (64dp)
              Container(
                height: 64,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                decoration: const BoxDecoration(
                  color: AuraColors.bgElevated,
                  border: Border(top: BorderSide(color: AuraColors.border, width: 2)),
                ),
                child: Row(
                  children: [
                    // MARK AS DONE CTA
                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            HapticFeedback.heavyImpact();
                            final newStatus = isDone ? 'todo' : 'done';
                            await ref.read(taskDetailActionProvider.notifier).updateTask(
                              taskId: task.id,
                              status: newStatus,
                            );

                            if (context.mounted && !isDone) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Task "${task.name}" completed!'),
                                  action: SnackBarAction(
                                    label: 'UNDO',
                                    onPressed: () {
                                      HapticFeedback.mediumImpact();
                                      ref.read(taskDetailActionProvider.notifier).updateTask(
                                        taskId: task.id,
                                        status: 'todo',
                                      );
                                    },
                                  ),
                                  duration: const Duration(seconds: 5),
                                ),
                              );
                            }
                          },
                          icon: Icon(
                            isDone ? LucideIcons.rotateCcw : LucideIcons.checkCircle,
                            size: 18,
                            color: AuraColors.textOnAccent,
                          ),
                          label: Text(
                            isDone ? 'MARK AS TODO' : 'MARK AS DONE',
                            style: AuraTypography.buttonText.copyWith(fontWeight: FontWeight.bold),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isDone ? AuraColors.textSecondary : AuraColors.accentLime,
                            foregroundColor: AuraColors.textOnAccent,
                            elevation: 0,
                            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    // SNOOZE REMINDER button
                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            HapticFeedback.mediumImpact();
                            SnoozeBottomSheet.show(
                              context,
                              reminderId: 'r-${task.id}',
                              taskId: task.id,
                              taskTitle: task.name,
                            );
                          },
                          icon: const Icon(LucideIcons.clock, size: 18, color: AuraColors.textPrimary),
                          label: Text('SNOOZE', style: AuraTypography.buttonSecondary),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AuraColors.border, width: 1.5),
                            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const Scaffold(
        backgroundColor: AuraColors.bgBase,
        body: Center(child: CircularProgressIndicator(color: AuraColors.accentLime)),
      ),
      error: (e, s) => Scaffold(
        backgroundColor: AuraColors.bgBase,
        body: Center(child: Text('Error loading task: $e', style: AuraTypography.body)),
      ),
    );
  }
}
