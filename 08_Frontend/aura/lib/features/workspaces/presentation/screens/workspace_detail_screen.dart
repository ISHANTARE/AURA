import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' hide Column;

import '../../../../core/constants/colors.dart';
import '../../../../core/constants/icons.dart';
import '../../../../core/constants/typography.dart';
import '../../../../database/app_database.dart';
import '../../../../database/daos/task_dao.dart';
import '../providers/workspace_providers.dart';
import '../widgets/workspace_options_sheet.dart';

/// Workspace Detail Screen — wireframe 04_workspace_screen.md
/// Shows: stats bento, section tabs, grouped task list, empty state.
class WorkspaceDetailScreen extends ConsumerStatefulWidget {
  final String workspaceId;

  const WorkspaceDetailScreen({super.key, required this.workspaceId});

  @override
  ConsumerState<WorkspaceDetailScreen> createState() =>
      _WorkspaceDetailScreenState();
}

class _WorkspaceDetailScreenState
    extends ConsumerState<WorkspaceDetailScreen> {
  String? _selectedSectionId; // null = "All" tab
  bool _addingSectionInline = false;
  final _sectionNameController = TextEditingController();

  @override
  void dispose() {
    _sectionNameController.dispose();
    super.dispose();
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  Color _parseColor(String hex) {
    try {
      final clean = hex.replaceFirst('#', '');
      return Color(int.parse('FF$clean', radix: 16));
    } catch (_) {
      return AuraColors.accentLime;
    }
  }

  String _deadlineLabel(int? deadlineMs) {
    if (deadlineMs == null) return 'No deadline';
    final dt = DateTime.fromMillisecondsSinceEpoch(deadlineMs);
    final now = DateTime.now();
    final diff = dt.difference(now);
    if (diff.isNegative) {
      final days = diff.inDays.abs();
      return days == 0 ? 'Today (overdue)' : '$days days overdue';
    }
    if (diff.inDays == 0) return 'Today';
    if (diff.inDays == 1) return 'Tomorrow';
    if (diff.inDays < 7) return '${diff.inDays} days left';
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  Color _deadlineColor(int? deadlineMs) {
    if (deadlineMs == null) return AuraColors.textDisabled;
    final dt = DateTime.fromMillisecondsSinceEpoch(deadlineMs);
    final now = DateTime.now();
    final diff = dt.difference(now);
    if (diff.isNegative) return AuraColors.accentRed;
    if (diff.inDays < 2) return AuraColors.accentOrange;
    if (diff.inDays < 7) return AuraColors.deadlineWarning;
    return AuraColors.deadlineSafe;
  }

  Color _priorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':   return AuraColors.priorityHigh;
      case 'medium': return AuraColors.priorityMedium;
      default:       return AuraColors.priorityLow;
    }
  }

  // Group tasks by temporal bucket
  Map<String, List<Task>> _groupTasks(List<Task> tasks) {
    final overdue   = <Task>[];
    final thisWeek  = <Task>[];
    final upcoming  = <Task>[];
    final someday   = <Task>[];
    final completed = <Task>[];

    final now     = DateTime.now();
    final weekEnd = now.add(const Duration(days: 7));

    for (final t in tasks) {
      if (t.status == 'done') {
        completed.add(t);
      } else if (t.deadline == null) {
        someday.add(t);
      } else {
        final dt = DateTime.fromMillisecondsSinceEpoch(t.deadline!);
        if (dt.isBefore(now)) {
          overdue.add(t);
        } else if (dt.isBefore(weekEnd)) {
          thisWeek.add(t);
        } else if (dt.isBefore(now.add(const Duration(days: 30)))) {
          upcoming.add(t);
        } else {
          someday.add(t);
        }
      }
    }

    return {
      if (overdue.isNotEmpty)   'OVERDUE':   overdue,
      if (thisWeek.isNotEmpty)  'THIS WEEK': thisWeek,
      if (upcoming.isNotEmpty)  'UPCOMING':  upcoming,
      if (someday.isNotEmpty)   'SOMEDAY':   someday,
      if (completed.isNotEmpty) 'COMPLETED': completed,
    };
  }

  // ── Stats Bento Row ───────────────────────────────────────────────────────

  Widget _statBentoCell({
    required String label,
    required String value,
    Color? valueColor,
    bool hasBorderRight = true,
  }) {
    return Expanded(
      child: Container(
        height: 80.0,
        decoration: BoxDecoration(
          border: Border(
            right: hasBorderRight
                ? const BorderSide(color: AuraColors.borderMuted, width: 1.0)
                : BorderSide.none,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              value,
              style: AuraTypography.display.copyWith(
                fontSize: 26.0,
                color: valueColor ?? AuraColors.textPrimary,
              ),
            ),
            const SizedBox(height: 2.0),
            Text(label, style: AuraTypography.bentoMetricLabel),
          ],
        ),
      ),
    );
  }

  // ── Section Tab ──────────────────────────────────────────────────────────

  Widget _sectionTab({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.only(right: 6.0),
        padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 6.0),
        decoration: BoxDecoration(
          color: isSelected ? AuraColors.accentLime : Colors.transparent,
          border: Border.all(
            color: isSelected ? AuraColors.border : AuraColors.borderMuted,
            width: 2.0,
          ),
        ),
        child: Text(
          label,
          style: AuraTypography.badgeText.copyWith(
            color: isSelected
                ? AuraColors.textOnAccent
                : AuraColors.textSecondary,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  // ── Task Item ────────────────────────────────────────────────────────────

  Widget _taskItem(Task task) {
    final color   = _priorityColor(task.priority);
    final dlLabel = _deadlineLabel(task.deadline);
    final dlColor = _deadlineColor(task.deadline);
    final isDone  = task.status == 'done';

    return GestureDetector(
      onTap: () => _showTaskDetailModal(context, task),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8.0),
        decoration: BoxDecoration(
          color: isDone ? AuraColors.bgElevated.withValues(alpha: 0.5) : AuraColors.bgCard,
          border: Border.all(
            color: isDone ? AuraColors.borderMuted : AuraColors.borderMuted,
            width: 1.0,
          ),
        ),
        child: Row(
          children: [
            // Priority stripe (4dp wide)
            Container(width: 4.0, height: 64.0, color: isDone ? AuraColors.textDisabled : color),
            const SizedBox(width: 12.0),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.name,
                      style: AuraTypography.cardTitle.copyWith(
                        fontSize: 15.0,
                        decoration: isDone ? TextDecoration.lineThrough : null,
                        color: isDone ? AuraColors.textDisabled : AuraColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4.0),
                    Row(
                      children: [
                        Icon(
                          task.deadline != null &&
                                  DateTime.fromMillisecondsSinceEpoch(
                                          task.deadline!)
                                      .isBefore(DateTime.now())
                              ? AuraIcons.overdue
                              : AuraIcons.reminder,
                          size: 12.0,
                          color: isDone ? AuraColors.textDisabled : dlColor,
                        ),
                        const SizedBox(width: 4.0),
                        Text(
                          dlLabel,
                          style: AuraTypography.bodySmall.copyWith(
                            color: isDone ? AuraColors.textDisabled : dlColor,
                            fontSize: 11.0,
                          ),
                        ),
                        if (task.description != null && task.description!.isNotEmpty) ...[
                          const SizedBox(width: 8.0),
                          const Icon(Icons.notes,
                              size: 11.0,
                              color: AuraColors.accentLime),
                        ],
                        if (task.isRecurring) ...[
                          const SizedBox(width: 8.0),
                          const Icon(AuraIcons.recurring,
                              size: 11.0,
                              color: AuraColors.accentPurple),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
            // Checkbox area (Interactive!)
            GestureDetector(
              onTap: () async {
                HapticFeedback.mediumImpact();
                final taskDao = ref.read(taskDaoProvider);
                if (isDone) {
                  await taskDao.markTodo(task.id);
                } else {
                  await taskDao.markDone(task.id);
                }
              },
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: 24.0,
                  height: 24.0,
                  decoration: BoxDecoration(
                    color: isDone ? AuraColors.accentLime : Colors.transparent,
                    border: Border.all(
                      color: isDone ? AuraColors.accentLime : AuraColors.border,
                      width: 2.0,
                    ),
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                  child: isDone
                      ? const Icon(
                          Icons.check,
                          size: 16.0,
                          color: Colors.black,
                        )
                      : null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showTaskDetailModal(BuildContext context, Task task) {
    HapticFeedback.selectionClick();
    final notesController = TextEditingController(text: task.description ?? '');
    final titleController = TextEditingController(text: task.name);
    bool isEditingNotes = false;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AuraColors.bgCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        side: BorderSide(color: AuraColors.border, width: 2),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setStateModal) {
            final isDone = task.status == 'done';

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom,
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Top Row: Priority Badge + Title + Close
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: _priorityColor(task.priority).withValues(alpha: 0.2),
                                border: Border.all(color: _priorityColor(task.priority)),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                task.priority.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: _priorityColor(task.priority),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextField(
                                controller: titleController,
                                style: AuraTypography.cardTitle.copyWith(
                                  fontSize: 18.0,
                                  decoration: isDone ? TextDecoration.lineThrough : null,
                                ),
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  isDense: true,
                                  contentPadding: EdgeInsets.zero,
                                ),
                                onSubmitted: (newTitle) async {
                                  if (newTitle.trim().isNotEmpty) {
                                    final taskDao = ref.read(taskDaoProvider);
                                    await taskDao.updateTask(
                                      task.toCompanion(true).copyWith(
                                        name: Value(newTitle.trim()),
                                        updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
                                      ),
                                    );
                                  }
                                },
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close, color: AuraColors.textSecondary),
                              onPressed: () => Navigator.of(ctx).pop(),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),
                        const Divider(color: AuraColors.borderMuted, height: 1),
                        const SizedBox(height: 12),

                        // Deadline Row
                        Row(
                          children: [
                            const Icon(AuraIcons.reminder, size: 16, color: AuraColors.textSecondary),
                            const SizedBox(width: 8),
                            Text('Deadline: ', style: AuraTypography.bodySmall),
                            Text(
                              _deadlineLabel(task.deadline),
                              style: AuraTypography.bodyPrimary.copyWith(
                                color: _deadlineColor(task.deadline),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        // Notes / Description Section
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.notes, size: 16, color: AuraColors.accentLime),
                                const SizedBox(width: 8),
                                Text('Notes & Details', style: AuraTypography.label.copyWith(color: AuraColors.accentLime)),
                              ],
                            ),
                            IconButton(
                              icon: Icon(
                                isEditingNotes ? Icons.check : Icons.edit,
                                size: 18,
                                color: AuraColors.accentLime,
                              ),
                              onPressed: () async {
                                if (isEditingNotes) {
                                  final newDesc = notesController.text.trim();
                                  final taskDao = ref.read(taskDaoProvider);
                                  await taskDao.updateTask(
                                    task.toCompanion(true).copyWith(
                                      description: Value(newDesc.isEmpty ? null : newDesc),
                                      updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
                                    ),
                                  );
                                }
                                setStateModal(() {
                                  isEditingNotes = !isEditingNotes;
                                });
                              },
                            ),
                          ],
                        ),

                        const SizedBox(height: 4),

                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AuraColors.bgElevated,
                            border: Border.all(color: AuraColors.borderMuted),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: isEditingNotes
                              ? TextField(
                                  controller: notesController,
                                  maxLines: 5,
                                  style: AuraTypography.bodyPrimary,
                                  decoration: const InputDecoration(
                                    hintText: 'Add extra details or notes here...',
                                    hintStyle: TextStyle(color: AuraColors.textDisabled),
                                    border: InputBorder.none,
                                  ),
                                )
                              : Text(
                                  (task.description != null && task.description!.isNotEmpty)
                                      ? task.description!
                                      : 'No extra details added yet. Tap edit icon above to add notes.',
                                  style: (task.description != null && task.description!.isNotEmpty)
                                      ? AuraTypography.bodyPrimary
                                      : AuraTypography.bodySmall.copyWith(fontStyle: FontStyle.italic),
                                ),
                        ),

                        if (task.aiRawTranscript != null && task.aiRawTranscript!.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Text('Original Voice Input:', style: AuraTypography.bodySmall),
                          const SizedBox(height: 4),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AuraColors.bgBase,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              '"${task.aiRawTranscript}"',
                              style: AuraTypography.bodySmall.copyWith(color: AuraColors.textSecondary, fontStyle: FontStyle.italic),
                            ),
                          ),
                        ],

                        const SizedBox(height: 20),

                        // Action Buttons: Complete/Todo & Delete
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isDone ? AuraColors.bgElevated : AuraColors.accentLime,
                                  foregroundColor: isDone ? AuraColors.textPrimary : Colors.black,
                                  side: const BorderSide(color: AuraColors.border, width: 2),
                                  minimumSize: const Size(0, 44),
                                ),
                                icon: Icon(isDone ? Icons.undo : Icons.check, size: 18),
                                label: Text(
                                  isDone ? 'MARK TODO' : 'MARK COMPLETE',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                onPressed: () async {
                                  HapticFeedback.mediumImpact();
                                  final taskDao = ref.read(taskDaoProvider);
                                  if (isDone) {
                                    await taskDao.markTodo(task.id);
                                  } else {
                                    await taskDao.markDone(task.id);
                                  }
                                  if (ctx.mounted) Navigator.of(ctx).pop();
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            IconButton(
                              style: IconButton.styleFrom(
                                side: const BorderSide(color: AuraColors.accentRed),
                              ),
                              icon: const Icon(Icons.delete_outline, color: AuraColors.accentRed),
                              onPressed: () async {
                                HapticFeedback.mediumImpact();
                                final taskDao = ref.read(taskDaoProvider);
                                await taskDao.softDelete(task.id);
                                if (ctx.mounted) Navigator.of(ctx).pop();
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ── Event Item ───────────────────────────────────────────────────────────

  Widget _eventItem(Event event) {
    final dt = DateTime.fromMillisecondsSinceEpoch(event.startAt);
    final label =
        '${dt.day}/${dt.month}  ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

    return Container(
      margin: const EdgeInsets.only(bottom: 8.0),
      decoration: BoxDecoration(
        color: AuraColors.bgCard,
        border: Border.all(color: AuraColors.borderMuted, width: 1.0),
      ),
      child: Row(
        children: [
          // Blue event stripe
          Container(
              width: 4.0, height: 64.0, color: AuraColors.accentBlue),
          const SizedBox(width: 12.0),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    style: AuraTypography.cardTitle.copyWith(fontSize: 15.0),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4.0),
                  Text(
                    label,
                    style: AuraTypography.bodySmall
                        .copyWith(color: AuraColors.accentBlue, fontSize: 11.0),
                  ),
                ],
              ),
            ),
          ),
          // Calendar icon (events aren't "completed")
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.0),
            child: Icon(AuraIcons.calendar,
                size: AuraIcons.sizeInline,
                color: AuraColors.accentBlue),
          ),
        ],
      ),
    );
  }

  // ── Empty State ───────────────────────────────────────────────────────────

  Widget _emptyState(String workspaceName) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(AuraIcons.workspaces,
                size: AuraIcons.sizeLarge,
                color: AuraColors.textDisabled),
            const SizedBox(height: 20.0),
            Text(
              'Nothing in $workspaceName yet.',
              style: AuraTypography.cardTitle,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12.0),
            Text(
              'Tap the orb and say something like:',
              style: AuraTypography.bodySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8.0),
            Text(
              '"Add something to $workspaceName workspace"',
              style: AuraTypography.bodySmall
                  .copyWith(color: AuraColors.accentLime),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28.0),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
              decoration: BoxDecoration(
                color: AuraColors.accentLime,
                border: Border.all(color: AuraColors.border, width: 2.0),
                boxShadow: const [
                  BoxShadow(
                    color: AuraColors.shadow,
                    offset: Offset(3, 3),
                    blurRadius: 0,
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(AuraIcons.mic,
                      size: AuraIcons.sizeStandard,
                      color: AuraColors.textOnAccent),
                  const SizedBox(width: 8.0),
                  Text('Tap to capture',
                      style: AuraTypography.buttonText),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final workspaceAsync =
        ref.watch(workspaceByIdProvider(widget.workspaceId));
    final statsAsync =
        ref.watch(workspaceStatsProvider(widget.workspaceId));
    final sectionsAsync =
        ref.watch(workspaceSectionsProvider(widget.workspaceId));
    final tasksAsync = ref.watch(workspaceTasksProvider((
      workspaceId: widget.workspaceId,
      sectionId: _selectedSectionId,
    )));
    final eventsAsync =
        ref.watch(workspaceEventsProvider(widget.workspaceId));

    return workspaceAsync.when(
      loading: () => const Scaffold(
        backgroundColor: AuraColors.bgBase,
        body: Center(
            child:
                CircularProgressIndicator(color: AuraColors.accentLime)),
      ),
      error: (err, _) => Scaffold(
        backgroundColor: AuraColors.bgBase,
        body: Center(child: Text('Error: $err')),
      ),
      data: (workspace) {
        if (workspace == null) {
          return const Scaffold(
            backgroundColor: AuraColors.bgBase,
            body: Center(child: Text('Workspace not found')),
          );
        }

        final wsColor = _parseColor(workspace.colorHex);

        return Scaffold(
          backgroundColor: AuraColors.bgBase,
          body: SafeArea(
            child: Column(
              children: [
                // ── App Bar ───────────────────────────────────────────
                Container(
                  height: 56.0,
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                          color: AuraColors.borderMuted, width: 1.0),
                    ),
                  ),
                  child: Row(
                    children: [
                      // Back button
                      IconButton(
                        icon: const Icon(AuraIcons.back,
                            color: AuraColors.textPrimary),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      // Workspace icon + title
                      Icon(
                        AuraIcons.forWorkspace(workspace.name),
                        color: wsColor,
                        size: AuraIcons.sizeStandard,
                      ),
                      const SizedBox(width: 8.0),
                      Expanded(
                        child: Text(
                          workspace.name,
                          style: AuraTypography.cardTitle.copyWith(
                            fontSize: 19.0,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      // Manual Add Item button (+)
                      IconButton(
                        icon: const Icon(Icons.add, color: AuraColors.accentLime),
                        tooltip: 'Add Task / Reminder / Event',
                        onPressed: () => _showManualAddItemSheet(context, workspace),
                      ),
                      // Options menu
                      IconButton(
                        icon: const Icon(AuraIcons.more,
                            color: AuraColors.textPrimary),
                        onPressed: () =>
                            WorkspaceOptionsSheet.show(context, workspace),
                      ),
                    ],
                  ),
                ),

                // ── Stats Bento Row (80dp) ───────────────────────────
                statsAsync.when(
                  loading: () => Container(
                    height: 80.0,
                    decoration: const BoxDecoration(
                      color: AuraColors.bgCard,
                    ),
                    child: const Center(
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            color: AuraColors.accentLime,
                            strokeWidth: 2),
                      ),
                    ),
                  ),
                  error: (_, __) => const SizedBox(height: 80.0),
                  data: (stats) => Container(
                    height: 80.0,
                    decoration: const BoxDecoration(
                      color: AuraColors.bgCard,
                      border: Border(
                        bottom: BorderSide(
                            color: AuraColors.borderMuted, width: 1.0),
                      ),
                    ),
                    child: Row(
                      children: [
                        _statBentoCell(
                          label: 'ACTIVE',
                          value: '${stats.activeTasks}',
                        ),
                        _statBentoCell(
                          label: 'OVERDUE',
                          value: '${stats.overdueTasks}',
                          valueColor: stats.overdueTasks > 0
                              ? AuraColors.accentRed
                              : null,
                        ),
                        _statBentoCell(
                          label: 'EVENTS',
                          value: '${stats.totalEvents}',
                          valueColor: stats.totalEvents > 0
                              ? AuraColors.accentBlue
                              : null,
                        ),
                        _statBentoCell(
                          label: 'SECTIONS',
                          value: '${stats.totalSections}',
                          hasBorderRight: false,
                        ),
                      ],
                    ),
                  ),
                ),

                // ── Section Tabs Row (48dp) ──────────────────────────
                sectionsAsync.when(
                  loading: () => const SizedBox(height: 48.0),
                  error: (_, __) => const SizedBox(height: 48.0),
                  data: (sections) => Container(
                    height: 52.0,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12.0, vertical: 6.0),
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                            color: AuraColors.borderMuted, width: 1.0),
                      ),
                    ),
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        // All tab
                        _sectionTab(
                          label: 'All',
                          isSelected: _selectedSectionId == null,
                          onTap: () => setState(
                              () => _selectedSectionId = null),
                        ),

                        // Dynamic section tabs
                        ...sections.map((sec) => _sectionTab(
                              label: sec.name,
                              isSelected: _selectedSectionId == sec.id,
                              onTap: () => setState(
                                  () => _selectedSectionId = sec.id),
                            )),

                        // [+] Add section
                        if (_addingSectionInline)
                          SizedBox(
                            width: 160.0,
                            child: TextField(
                              controller: _sectionNameController,
                              autofocus: true,
                              style: AuraTypography.bodySmall,
                              decoration: const InputDecoration(
                                hintText: 'Section name…',
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 8.0),
                                isDense: true,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.zero,
                                  borderSide: BorderSide(
                                      color: AuraColors.accentLime,
                                      width: 2.0),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.zero,
                                  borderSide: BorderSide(
                                      color: AuraColors.accentLime,
                                      width: 2.0),
                                ),
                              ),
                              onSubmitted: (val) async {
                                if (val.trim().isNotEmpty) {
                                  await ref
                                      .read(workspaceActionNotifierProvider
                                          .notifier)
                                      .createSection(
                                        workspaceId: widget.workspaceId,
                                        name: val.trim(),
                                      );
                                }
                                _sectionNameController.clear();
                                setState(() => _addingSectionInline = false);
                              },
                            ),
                          )
                        else
                          GestureDetector(
                            onTap: () => setState(
                                () => _addingSectionInline = true),
                            child: Container(
                              margin: const EdgeInsets.only(left: 4.0),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10.0, vertical: 6.0),
                              decoration: BoxDecoration(
                                border: Border.all(
                                    color: AuraColors.borderMuted,
                                    width: 2.0),
                              ),
                              child: const Icon(AuraIcons.add,
                                  size: 14.0,
                                  color: AuraColors.accentLime),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

                // ── Task List + Events ───────────────────────────────
                Expanded(
                  child: tasksAsync.when(
                    loading: () => const Center(
                      child: CircularProgressIndicator(
                          color: AuraColors.accentLime),
                    ),
                    error: (err, _) => Center(
                      child: Text('Error: $err',
                          style: AuraTypography.bodySmall
                              .copyWith(color: AuraColors.accentRed)),
                    ),
                    data: (tasks) {
                      final activeTasks = tasks
                          .where((t) =>
                              t.status != 'cancelled' &&
                              t.deletedAt == null)
                          .toList();

                      // Also pull events only on "All" tab
                      final showEvents = _selectedSectionId == null;

                      return eventsAsync.when(
                        loading: () => const Center(
                          child: CircularProgressIndicator(
                              color: AuraColors.accentLime),
                        ),
                        error: (_, __) =>
                            _buildTaskContent(activeTasks, workspace, []),
                        data: (events) => _buildTaskContent(
                            activeTasks,
                            workspace,
                            showEvents ? events : []),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTaskContent(
    List<Task> tasks,
    Workspace workspace,
    List<Event> events,
  ) {
    if (tasks.isEmpty && events.isEmpty) {
      return _emptyState(workspace.name);
    }

    final grouped = _groupTasks(tasks);

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        // Events always shown at top of "All" tab
        if (events.isNotEmpty) ...[
          Text('EVENTS', style: AuraTypography.badgeText),
          const SizedBox(height: 8.0),
          ...events.map(_eventItem),
          const SizedBox(height: 16.0),
        ],

        // Grouped task sections
        for (final entry in grouped.entries) ...[
          _groupHeader(entry.key),
          const SizedBox(height: 8.0),
          ...entry.value.map(_taskItem),
          const SizedBox(height: 16.0),
        ],
      ],
    );
  }

  Widget _groupHeader(String label) {
    final isOverdue = label == 'OVERDUE';
    return Text(
      label,
      style: AuraTypography.badgeText.copyWith(
        color: isOverdue ? AuraColors.accentRed : AuraColors.textSecondary,
      ),
    );
  }

  void _showManualAddItemSheet(BuildContext context, Workspace workspace) {
    final nameController = TextEditingController();
    final notesController = TextEditingController();
    String selectedType = 'TASK'; // TASK | REMINDER | EVENT
    String selectedPriority = 'medium';
    DateTime? selectedDate;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AuraColors.bgCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        side: BorderSide(color: AuraColors.border, width: 2),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setStateModal) => Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Add to ${workspace.name}', style: AuraTypography.sectionHeader),
                const SizedBox(height: 12),

                // Type Segmented Switcher
                Row(
                  children: ['TASK', 'REMINDER', 'EVENT'].map((type) {
                    final isSel = selectedType == type;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => setStateModal(() => selectedType = type),
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: isSel ? AuraColors.accentLime : AuraColors.bgElevated,
                            border: Border.all(
                              color: isSel ? AuraColors.accentLime : AuraColors.border,
                            ),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            type,
                            textAlign: TextAlign.center,
                            style: AuraTypography.label.copyWith(
                              color: isSel ? Colors.black : AuraColors.textSecondary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 16),

                // Title Input
                TextField(
                  controller: nameController,
                  style: AuraTypography.cardTitle,
                  decoration: InputDecoration(
                    hintText: '$selectedType Name / Title...',
                    filled: true,
                    fillColor: AuraColors.bgElevated,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),

                const SizedBox(height: 12),

                // Date Picker Row
                Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 16, color: AuraColors.textSecondary),
                    const SizedBox(width: 8),
                    Text(
                      selectedDate == null
                          ? 'No Date Set'
                          : '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}',
                      style: AuraTypography.bodySmall,
                    ),
                    const Spacer(),
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AuraColors.border),
                      ),
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: ctx,
                          initialDate: DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                        );
                        if (picked != null) {
                          setStateModal(() => selectedDate = picked);
                        }
                      },
                      child: const Text('PICK DATE'),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Priority Row (for Tasks & Reminders)
                if (selectedType != 'EVENT') ...[
                  Row(
                    children: [
                      Text('Priority:', style: AuraTypography.bodySmall),
                      const SizedBox(width: 12),
                      ...['low', 'medium', 'high'].map((p) {
                        final isP = selectedPriority == p;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(p.toUpperCase()),
                            selected: isP,
                            selectedColor: AuraColors.accentLime,
                            backgroundColor: AuraColors.bgElevated,
                            labelStyle: TextStyle(
                              color: isP ? Colors.black : AuraColors.textSecondary,
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                            ),
                            onSelected: (_) => setStateModal(() => selectedPriority = p),
                          ),
                        );
                      }),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],

                // Notes / Description Input
                TextField(
                  controller: notesController,
                  maxLines: 3,
                  minLines: 2,
                  style: AuraTypography.bodyPrimary,
                  decoration: InputDecoration(
                    hintText: 'Notes / Details...',
                    filled: true,
                    fillColor: AuraColors.bgElevated,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),

                const SizedBox(height: 16),

                // Submit CTA Button
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
                      final title = nameController.text.trim();
                      if (title.isEmpty) return;

                      final now = DateTime.now().millisecondsSinceEpoch;
                      final id = now.toString();
                      final notes = notesController.text.trim();

                      if (selectedType == 'EVENT') {
                        final startAt = selectedDate?.millisecondsSinceEpoch ?? now;
                        final endAt = startAt + 3600000; // 1 hour default
                        await ref.read(databaseProvider).into(ref.read(databaseProvider).events).insert(
                              EventsCompanion.insert(
                                id: id,
                                workspaceId: workspace.id,
                                title: title,
                                description: Value(notes.isNotEmpty ? notes : null),
                                startAt: startAt,
                                endAt: endAt,
                                createdAt: now,
                                updatedAt: now,
                              ),
                            );
                      } else {
                        // TASK or REMINDER
                        final deadlineMs = selectedDate?.millisecondsSinceEpoch;
                        await ref.read(databaseProvider).into(ref.read(databaseProvider).tasks).insert(
                              TasksCompanion.insert(
                                id: id,
                                workspaceId: workspace.id,
                                name: title,
                                description: Value(notes.isNotEmpty ? notes : null),
                                deadline: Value(deadlineMs),
                                priority: Value(selectedPriority),
                                createdAt: now,
                                updatedAt: now,
                              ),
                            );

                        if (selectedType == 'REMINDER' && deadlineMs != null) {
                          await ref.read(databaseProvider).into(ref.read(databaseProvider).reminders).insert(
                                RemindersCompanion.insert(
                                  id: 'rem_$id',
                                  taskId: Value(id),
                                  fireAt: deadlineMs,
                                  type: const Value('notification'),
                                  createdAt: now,
                                  updatedAt: now,
                                ),
                              );
                        }
                      }

                      if (ctx.mounted) Navigator.of(ctx).pop();
                    },
                    child: Text(
                      'CREATE $selectedType',
                      style: AuraTypography.label.copyWith(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
