import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/constants/spacing.dart';
import '../../../../core/constants/typography.dart';
import '../../../../core/providers/providers.dart';
import '../../domain/usecases/task_detail_usecases.dart';
import '../../presentation/widgets/task_options_sheet.dart';
import '../../presentation/widgets/task_subtasks_tab.dart';
import '../../../reminders/presentation/widgets/snooze_picker_sheet.dart';

/// Task / Item Detail Screen for AURA v2
class TaskDetailScreen extends ConsumerStatefulWidget {
  const TaskDetailScreen({super.key, required this.taskId});

  final String taskId;

  @override
  ConsumerState<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends ConsumerState<TaskDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  bool _isEditingTitle = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _notesController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final itemDao = ref.watch(itemDaoProvider);

    return StreamBuilder<Item?>(
      stream: itemDao.watchById(widget.taskId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: AuraColors.bgBase,
            body: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AuraColors.accentLime),
              ),
            ),
          );
        }

        final item = snapshot.data;
        if (item == null) {
          return Scaffold(
            backgroundColor: AuraColors.bgBase,
            appBar: AppBar(
              backgroundColor: AuraColors.bgBase,
              leading: IconButton(
                icon: const Icon(LucideIcons.arrowLeft,
                    color: AuraColors.textPrimary),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            body: Center(
              child: Text('Item not found or deleted.',
                  style: AuraTypography.body),
            ),
          );
        }

        if (_notesController.text.isEmpty && item.notes != null) {
          _notesController.text = item.notes!;
        }
        if (!_isEditingTitle && _titleController.text != item.title) {
          _titleController.text = item.title;
        }

        final isCompleted = item.status == 'completed';

        return Scaffold(
          backgroundColor: AuraColors.bgBase,
          appBar: AppBar(
            backgroundColor: AuraColors.bgBase,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(LucideIcons.arrowLeft,
                  color: AuraColors.textPrimary),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: Text(item.kind.toUpperCase(),
                style: AuraTypography.screenHeader),
            actions: [
              IconButton(
                icon: const Icon(LucideIcons.moreVertical,
                    color: AuraColors.textPrimary),
                onPressed: () => TaskOptionsSheet.show(
                  context,
                  taskId: item.id,
                  taskTitle: item.title,
                ),
              ),
            ],
            bottom: TabBar(
              controller: _tabController,
              indicatorColor: AuraColors.accentLime,
              labelColor: AuraColors.accentLime,
              unselectedLabelColor: AuraColors.textSecondary,
              labelStyle: AuraTypography.label.copyWith(fontSize: 11),
              tabs: const [
                Tab(text: 'DETAILS'),
                Tab(text: 'SUBTASKS'),
                Tab(text: 'NOTES'),
                Tab(text: 'ATTACHMENTS'),
              ],
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              // Tab 1: Details
              _DetailsTab(
                item: item,
                isCompleted: isCompleted,
                isEditingTitle: _isEditingTitle,
                titleController: _titleController,
                onTitleEditToggle: (editing) {
                  setState(() => _isEditingTitle = editing);
                },
                onSaveTitle: (newTitle) async {
                  if (newTitle.trim().isNotEmpty) {
                    await UpdateTaskDetailUseCase(itemDao).execute(
                      itemId: item.id,
                      title: newTitle.trim(),
                    );
                  }
                  setState(() => _isEditingTitle = false);
                },
                onToggleStatus: () async {
                  HapticFeedback.mediumImpact();
                  final newStatus = isCompleted ? 'pending' : 'completed';
                  await itemDao.updateStatus(item.id, newStatus);

                  if (context.mounted && newStatus == 'completed') {
                    ScaffoldMessenger.of(context).clearSnackBars();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Task marked done ✓'),
                        duration: const Duration(seconds: 10),
                        action: SnackBarAction(
                          label: 'UNDO',
                          textColor: AuraColors.accentLime,
                          onPressed: () async {
                            await itemDao.updateStatus(item.id, 'pending');
                          },
                        ),
                      ),
                    );
                  }
                },
              ),

              // Tab 2: Subtasks
              Padding(
                padding: const EdgeInsets.all(AuraSpacing.md),
                child: TaskSubtasksTab(
                  parentTaskId: item.id,
                  workspaceId: item.workspaceId ?? '',
                ),
              ),

              // Tab 3: Notes
              _NotesTab(
                notesController: _notesController,
                onSaveNotes: (newNotes) async {
                  await UpdateTaskDetailUseCase(itemDao).execute(
                    itemId: item.id,
                    notes: newNotes,
                  );
                },
              ),

              // Tab 4: Attachments
              _AttachmentsTab(item: item),
            ],
          ),
        );
      },
    );
  }
}

// ── Sub-Tabs Components ──────────────────────────────────────────────────────

class _DetailsTab extends StatelessWidget {
  const _DetailsTab({
    required this.item,
    required this.isCompleted,
    required this.isEditingTitle,
    required this.titleController,
    required this.onTitleEditToggle,
    required this.onSaveTitle,
    required this.onToggleStatus,
  });

  final Item item;
  final bool isCompleted;
  final bool isEditingTitle;
  final TextEditingController titleController;
  final ValueChanged<bool> onTitleEditToggle;
  final ValueChanged<String> onSaveTitle;
  final VoidCallback onToggleStatus;

  @override
  Widget build(BuildContext context) {
    final deadline = item.deadline ?? item.fireAt;
    final deadlineStr = deadline != null
        ? DateFormat('EEEE, MMM d · h:mm a')
            .format(DateTime.fromMillisecondsSinceEpoch(deadline))
        : 'No deadline set (Tap to add)';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AuraSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Main Card ───────────────────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AuraSpacing.md),
            decoration: BoxDecoration(
              color: AuraColors.bgCard,
              border: Border.all(
                  color: AuraColors.border, width: AuraSpacing.borderWidth),
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
                // Title (Inline Editable)
                isEditingTitle
                    ? Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: titleController,
                              autofocus: true,
                              style: AuraTypography.cardTitle,
                              onSubmitted: onSaveTitle,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(LucideIcons.check,
                                color: AuraColors.accentLime),
                            onPressed: () => onSaveTitle(titleController.text),
                          ),
                        ],
                      )
                    : GestureDetector(
                        onTap: () => onTitleEditToggle(true),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                item.title,
                                style: AuraTypography.display.copyWith(
                                  fontSize: 22,
                                  decoration: isCompleted
                                      ? TextDecoration.lineThrough
                                      : null,
                                  color: isCompleted
                                      ? AuraColors.textDisabled
                                      : AuraColors.textPrimary,
                                ),
                              ),
                            ),
                            const Icon(LucideIcons.edit2,
                                size: 16, color: AuraColors.textSecondary),
                          ],
                        ),
                      ),
                const SizedBox(height: AuraSpacing.sm),

                // Tags Row
                Wrap(
                  spacing: AuraSpacing.sm,
                  runSpacing: AuraSpacing.xs,
                  children: [
                    _Tag(
                      label: item.category.toUpperCase(),
                      color: AuraColors.accentLime,
                    ),
                    _Tag(
                      label: item.kind.toUpperCase(),
                      color: AuraColors.accentBlue,
                    ),
                    _Tag(
                      label: item.priority.toUpperCase(),
                      color: _priorityColor(item.priority),
                    ),
                    _Tag(
                      label: isCompleted ? 'COMPLETED' : 'PENDING',
                      color: isCompleted
                          ? AuraColors.accentGreen
                          : AuraColors.accentOrange,
                    ),
                  ],
                ),

                const SizedBox(height: AuraSpacing.md),
                const Divider(color: AuraColors.borderMuted, height: 1),
                const SizedBox(height: AuraSpacing.md),

                // Deadline tile (Tap to pick date/time)
                Consumer(
                  builder: (context, ref, _) => InkWell(
                    onTap: () => _pickDeadline(context, ref, item),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          const Icon(LucideIcons.calendar,
                              size: 16, color: AuraColors.accentLime),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(deadlineStr, style: AuraTypography.body),
                          ),
                          const Icon(LucideIcons.chevronRight,
                              size: 16, color: AuraColors.textSecondary),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AuraSpacing.xl),

          // ── Actions ─────────────────────────────────────────────
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: isCompleted
                    ? AuraColors.bgElevated
                    : AuraColors.accentLime,
                foregroundColor: Colors.black,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.zero,
                  side: BorderSide(color: AuraColors.border, width: 2),
                ),
                elevation: 0,
              ),
              onPressed: onToggleStatus,
              child: Text(
                isCompleted ? 'MARK AS PENDING ↺' : 'MARK AS DONE ✓',
                style: AuraTypography.label.copyWith(
                  color: isCompleted ? AuraColors.textPrimary : Colors.black,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ),
          ),

          const SizedBox(height: AuraSpacing.sm),

          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: AuraColors.textPrimary,
                side: const BorderSide(color: AuraColors.border, width: 2),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.zero,
                ),
              ),
              icon: const Icon(LucideIcons.clock,
                  size: 18, color: AuraColors.accentLime),
              label: Text(
                'SNOOZE REMINDER ⏰',
                style: AuraTypography.label.copyWith(
                  color: AuraColors.textPrimary,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
              onPressed: () => SnoozePickerSheet.show(
                context,
                taskId: item.id,
                taskTitle: item.title,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickDeadline(
      BuildContext context, WidgetRef ref, Item item) async {
    final now = DateTime.now();
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: item.deadline != null
          ? DateTime.fromMillisecondsSinceEpoch(item.deadline!)
          : now.add(const Duration(days: 1)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (pickedDate == null) return;

    if (!context.mounted) return;
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 9, minute: 0),
    );
    if (pickedTime == null) return;

    final newDeadline = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );

    final itemDao = ref.read(itemDaoProvider);
    await UpdateTaskDetailUseCase(itemDao).execute(
      itemId: item.id,
      deadline: newDeadline,
    );
    HapticFeedback.lightImpact();
  }

  Color _priorityColor(String? priority) {
    switch (priority) {
      case 'high':
        return AuraColors.accentRed;
      case 'medium':
        return AuraColors.accentOrange;
      default:
        return AuraColors.textSecondary;
    }
  }
}

class _NotesTab extends StatelessWidget {
  const _NotesTab({
    required this.notesController,
    required this.onSaveNotes,
  });

  final TextEditingController notesController;
  final ValueChanged<String> onSaveNotes;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AuraSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('ITEM NOTES 📝', style: AuraTypography.labelLime),
          const SizedBox(height: AuraSpacing.xs),
          Expanded(
            child: TextField(
              controller: notesController,
              maxLines: null,
              expands: true,
              style: AuraTypography.bodyPrimary,
              decoration: const InputDecoration(
                hintText: 'Type notes, ideas, or key details here...',
                contentPadding: EdgeInsets.all(AuraSpacing.md),
              ),
              onChanged: onSaveNotes,
            ),
          ),
        ],
      ),
    );
  }
}

class _AttachmentsTab extends StatelessWidget {
  const _AttachmentsTab({required this.item});
  final Item item;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AuraSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('ATTACHMENTS & OCR DATA 📎', style: AuraTypography.labelLime),
          const SizedBox(height: AuraSpacing.md),
          Container(
            padding: const EdgeInsets.all(AuraSpacing.md),
            decoration: BoxDecoration(
              color: AuraColors.bgCard,
              border: Border.all(color: AuraColors.border, width: 1),
            ),
            child: Row(
              children: [
                const Icon(LucideIcons.fileText,
                    color: AuraColors.accentLime, size: 24),
                const SizedBox(width: AuraSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.title, style: AuraTypography.cardTitle),
                      const SizedBox(height: 2),
                      Text('Category: ${item.category} | Kind: ${item.kind}',
                          style: AuraTypography.bodySmall),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        border: Border.all(color: color, width: 1),
      ),
      child: Text(
        label,
        style: AuraTypography.label.copyWith(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
