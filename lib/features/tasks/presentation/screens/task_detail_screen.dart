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
    _tabController = TabController(length: 3, vsync: this);
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
            body: Center(child: CircularProgressIndicator()),
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

        final isNote = item.kind == 'note' || item.category == 'note';
        if (isNote) {
          return _NoteDetailView(item: item);
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
              labelStyle: AuraTypography.label.copyWith(fontSize: 11),
              tabs: const [
                Tab(text: 'DETAILS'),
                Tab(text: 'SUBTASKS'),
                Tab(text: 'NOTES'),
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
                        content: const Text('Task marked done'),
                        duration: const Duration(seconds: 10),
                        action: SnackBarAction(
                          label: 'UNDO',
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
              TaskSubtasksTab(itemId: item.id),

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
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AuraColors.border, width: 1),
              boxShadow: const [
                BoxShadow(
                  color: AuraColors.shadow,
                  blurRadius: 16,
                  offset: Offset(0, 4),
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
                          Icon(LucideIcons.calendar,
                              size: 16, color: Theme.of(context).colorScheme.primary),
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
          Consumer(
            builder: (context, _, __) {
              final primary = Theme.of(context).colorScheme.primary;
              return Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isCompleted ? AuraColors.bgElevated : primary,
                        foregroundColor: isCompleted ? AuraColors.textPrimary : Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: onToggleStatus,
                      child: Text(
                        isCompleted ? 'MARK AS PENDING' : 'MARK AS DONE',
                        style: AuraTypography.label.copyWith(
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
                        side: const BorderSide(color: AuraColors.border, width: 1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      icon: Icon(LucideIcons.clock, size: 18, color: primary),
                      label: const Text('SNOOZE REMINDER'),
                      onPressed: () => SnoozePickerSheet.show(
                        context,
                        taskId: item.id,
                        taskTitle: item.title,
                      ),
                    ),
                  ),
                ],
              );
            },
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

class _NotesTab extends StatefulWidget {
  const _NotesTab({
    required this.notesController,
    required this.onSaveNotes,
  });

  final TextEditingController notesController;
  final ValueChanged<String> onSaveNotes;

  @override
  State<_NotesTab> createState() => _NotesTabState();
}

class _NotesTabState extends State<_NotesTab> {
  bool _isSaving = false;

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.all(AuraSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('NOTES & DETAILS', style: AuraTypography.label.copyWith(color: AuraColors.textSecondary)),
              if (_isSaving)
                Text('Saving...', style: AuraTypography.caption.copyWith(color: primaryColor)),
            ],
          ),
          const SizedBox(height: AuraSpacing.xs),
          Expanded(
            child: TextField(
              controller: widget.notesController,
              maxLines: null,
              expands: true,
              style: AuraTypography.bodyPrimary,
              decoration: const InputDecoration(
                hintText: 'Type notes, ideas, or key details here...',
                contentPadding: EdgeInsets.all(AuraSpacing.md),
              ),
              onChanged: widget.onSaveNotes,
            ),
          ),
          const SizedBox(height: AuraSpacing.md),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(LucideIcons.save, size: 18),
              label: const Text('SAVE NOTES', style: TextStyle(fontWeight: FontWeight.bold)),
              onPressed: () async {
                setState(() => _isSaving = true);
                HapticFeedback.mediumImpact();
                widget.onSaveNotes(widget.notesController.text);
                await Future.delayed(const Duration(milliseconds: 300));
                if (mounted) {
                  setState(() => _isSaving = false);
                  ScaffoldMessenger.of(context).clearSnackBars();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Notes saved successfully.'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}



class _Tag extends StatelessWidget {
  const _Tag({required this.label, this.color});

  final String label;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = color ?? Theme.of(context).colorScheme.primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: AuraTypography.label.copyWith(
          color: c,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _NoteDetailView extends ConsumerStatefulWidget {
  const _NoteDetailView({required this.item});
  final Item item;

  @override
  ConsumerState<_NoteDetailView> createState() => _NoteDetailViewState();
}

class _NoteDetailViewState extends ConsumerState<_NoteDetailView> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.item.title);
    _contentController = TextEditingController(
      text: (widget.item.notes != null && widget.item.notes!.isNotEmpty)
          ? widget.item.notes
          : widget.item.title,
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final itemDao = ref.watch(itemDaoProvider);
    final dtStr = DateFormat('EEE, MMM d, yyyy · h:mm a').format(
      DateTime.fromMillisecondsSinceEpoch(widget.item.createdAt),
    );

    return Scaffold(
      backgroundColor: AuraColors.bgBase,
      appBar: AppBar(
        backgroundColor: AuraColors.bgBase,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: AuraColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('NOTE', style: AuraTypography.screenHeader),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.moreVertical, color: AuraColors.textPrimary),
            onPressed: () => TaskOptionsSheet.show(
              context,
              taskId: widget.item.id,
              taskTitle: widget.item.title,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AuraSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Created timestamp badge
              Row(
                children: [
                  Icon(LucideIcons.fileText, size: 14, color: primaryColor),
                  const SizedBox(width: 6),
                  Text(dtStr, style: AuraTypography.overline),
                ],
              ),
              const SizedBox(height: AuraSpacing.md),

              // Title input
              TextField(
                controller: _titleController,
                style: AuraTypography.display.copyWith(fontSize: 22),
                decoration: const InputDecoration(
                  hintText: 'Note Title',
                  border: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const SizedBox(height: AuraSpacing.sm),
              const Divider(color: AuraColors.border, height: 1),
              const SizedBox(height: AuraSpacing.md),

              // Notes content editor / viewer
              Container(
                constraints: const BoxConstraints(minHeight: 250),
                padding: const EdgeInsets.all(AuraSpacing.md),
                decoration: BoxDecoration(
                  color: AuraColors.bgCard,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AuraColors.border, width: 1),
                ),
                child: TextField(
                  controller: _contentController,
                  maxLines: null,
                  keyboardType: TextInputType.multiline,
                  style: AuraTypography.bodyPrimary.copyWith(height: 1.5, fontSize: 15),
                  decoration: const InputDecoration(
                    hintText: 'Type or speak your note content...',
                    border: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    enabledBorder: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(height: AuraSpacing.lg),

              // Save button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  icon: const Icon(LucideIcons.save, size: 18),
                  label: Text(_isSaving ? 'SAVING...' : 'SAVE NOTE'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: _isSaving
                      ? null
                      : () async {
                          setState(() => _isSaving = true);
                          HapticFeedback.lightImpact();
                          final newTitle = _titleController.text.trim().isEmpty
                              ? 'Untitled Note'
                              : _titleController.text.trim();
                          final newNotes = _contentController.text.trim();

                          await UpdateTaskDetailUseCase(itemDao).execute(
                            itemId: widget.item.id,
                            title: newTitle,
                            notes: newNotes,
                          );

                          if (context.mounted) {
                            setState(() => _isSaving = false);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Note saved successfully.')),
                            );
                          }
                        },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
