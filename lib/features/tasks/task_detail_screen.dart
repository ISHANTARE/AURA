import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:uuid/uuid.dart';

import '../../../core/constants/colors.dart';
import '../../../core/constants/spacing.dart';
import '../../../core/constants/typography.dart';
import '../../../core/providers/database_provider.dart';
import '../../../core/widgets/aura_widgets.dart';
import '../../../database/app_database.dart';
import '../workspaces/workspace_screens.dart' show workspaceListProvider;

// ── Providers ─────────────────────────────────────────────────────────────────

final taskDetailProvider = StreamProvider.family<Item?, String>((ref, id) {
  return ref.watch(itemDaoProvider).watchAllActive().map(
        (items) => items.where((i) => i.id == id).firstOrNull,
      );
});

final subtasksProvider = StreamProvider.family<List<Item>, String>((ref, parentId) {
  return ref.watch(itemDaoProvider).watchSubtasks(parentId);
});

// ── Task Detail Screen ────────────────────────────────────────────────────────

class TaskDetailScreen extends ConsumerStatefulWidget {
  final String taskId;
  const TaskDetailScreen({super.key, required this.taskId});

  @override
  ConsumerState<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends ConsumerState<TaskDetailScreen> {
  final _titleController = TextEditingController();
  final _notesController = TextEditingController();
  final _newSubtaskController = TextEditingController();

  String _priority = 'medium';
  String? _selectedWorkspaceId;
  DateTime? _deadline;
  bool _isSaving = false;
  bool _isInitialized = false;

  void _initialize(Item item) {
    if (_isInitialized) return;
    _titleController.text = item.title;
    _notesController.text = item.notes ?? '';
    _priority = item.priority;
    _selectedWorkspaceId = item.workspaceId;
    if (item.fireAt != null) {
      _deadline = DateTime.fromMillisecondsSinceEpoch(item.fireAt!);
    } else if (item.deadline != null) {
      _deadline = DateTime.fromMillisecondsSinceEpoch(item.deadline!);
    }
    _isInitialized = true;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    _newSubtaskController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final itemAsync = ref.watch(taskDetailProvider(widget.taskId));
    final subtasksAsync = ref.watch(subtasksProvider(widget.taskId));
    final workspacesAsync = ref.watch(workspaceListProvider);
    final accent = Theme.of(context).colorScheme.primary;

    return itemAsync.when(
      data: (item) {
        if (item == null) {
          return const Scaffold(
            backgroundColor: AuraColors.bgBase,
            body: Center(child: Text('Task not found', style: TextStyle(color: AuraColors.textMuted))),
          );
        }

        _initialize(item);

        return Scaffold(
          backgroundColor: AuraColors.bgBase,
          appBar: AppBar(
            backgroundColor: AuraColors.bgBase,
            title: Text('Task Details', style: AuraTypography.sectionHeader.copyWith(color: AuraColors.textPrimary)),
            leading: IconButton(
              icon: const Icon(LucideIcons.arrowLeft, color: AuraColors.textSecondary),
              onPressed: () => context.pop(),
            ),
            actions: [
              IconButton(
                icon: const Icon(LucideIcons.trash2, color: AuraColors.accentRed),
                onPressed: () => _deleteTask(item.id),
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(AuraSpacing.md),
            children: [
              // Title Input
              BentoCard(
                child: TextField(
                  controller: _titleController,
                  style: AuraTypography.cardTitle.copyWith(color: AuraColors.textPrimary, fontWeight: FontWeight.w700),
                  decoration: const InputDecoration(
                    labelText: 'Task Title',
                    labelStyle: TextStyle(color: AuraColors.textMuted),
                    border: InputBorder.none,
                    isDense: true,
                  ),
                  maxLines: 2,
                ),
              ),
              const SizedBox(height: AuraSpacing.md),

              // Priority Selector
              BentoCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('PRIORITY', style: AuraTypography.caption.copyWith(color: AuraColors.textMuted, fontWeight: FontWeight.w700, letterSpacing: 1.0)),
                    const SizedBox(height: AuraSpacing.sm),
                    Row(
                      children: ['low', 'medium', 'high'].map((p) {
                        final isSelected = _priority == p;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: AuraChip(
                            label: p.toUpperCase(),
                            color: PriorityBadge.colorFor(p),
                            selected: isSelected,
                            onTap: () => setState(() => _priority = p),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AuraSpacing.md),

              // Workspace selector
              BentoCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('WORKSPACE', style: AuraTypography.caption.copyWith(color: AuraColors.textMuted, fontWeight: FontWeight.w700, letterSpacing: 1.0)),
                    const SizedBox(height: AuraSpacing.xs),
                    workspacesAsync.when(
                      data: (workspaces) {
                        return DropdownButton<String?>(
                          value: _selectedWorkspaceId,
                          isExpanded: true,
                          dropdownColor: AuraColors.bgElevated,
                          style: AuraTypography.bodySmall.copyWith(color: AuraColors.textPrimary),
                          underline: const SizedBox.shrink(),
                          hint: Text('No Workspace', style: AuraTypography.bodySmall.copyWith(color: AuraColors.textMuted)),
                          items: [
                            const DropdownMenuItem(value: null, child: Text('None (General)')),
                            ...workspaces.map((ws) => DropdownMenuItem(
                                  value: ws.id,
                                  child: Text(ws.name),
                                )),
                          ],
                          onChanged: (v) => setState(() => _selectedWorkspaceId = v),
                        );
                      },
                      loading: () => const LinearProgressIndicator(),
                      error: (_, __) => const SizedBox.shrink(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AuraSpacing.md),

              // Date & Time Picker
              BentoCard(
                onTap: _pickDateTime,
                child: Row(
                  children: [
                    const Icon(LucideIcons.calendar, size: 18, color: AuraColors.textMuted),
                    const SizedBox(width: AuraSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('DEADLINE & ALARM', style: AuraTypography.caption.copyWith(color: AuraColors.textMuted, fontWeight: FontWeight.w700, letterSpacing: 1.0)),
                          Text(
                            _deadline != null ? DateFormat('EEEE, MMMM d · hh:mm a').format(_deadline!) : 'No deadline set',
                            style: AuraTypography.bodySmall.copyWith(color: _deadline != null ? accent : AuraColors.textMuted),
                          ),
                        ],
                      ),
                    ),
                    if (_deadline != null)
                      IconButton(
                        icon: const Icon(LucideIcons.x, size: 16, color: AuraColors.textMuted),
                        onPressed: () => setState(() => _deadline = null),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: AuraSpacing.md),

              // Subtasks Section
              BentoCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('SUBTASKS', style: AuraTypography.caption.copyWith(color: AuraColors.textMuted, fontWeight: FontWeight.w700, letterSpacing: 1.0)),
                    const SizedBox(height: AuraSpacing.sm),
                    subtasksAsync.when(
                      data: (subtasks) {
                        return Column(
                          children: [
                            ...subtasks.map((st) {
                              final isDone = st.status == 'completed';
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 6),
                                child: Row(
                                  children: [
                                    GestureDetector(
                                      onTap: () => _toggleSubtask(st),
                                      child: Container(
                                        width: 18, height: 18,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: isDone ? accent : Colors.transparent,
                                          border: Border.all(color: isDone ? accent : AuraColors.border, width: 1.5),
                                        ),
                                        child: isDone ? const Icon(LucideIcons.check, size: 10, color: Colors.black) : null,
                                      ),
                                    ),
                                    const SizedBox(width: AuraSpacing.sm),
                                    Expanded(
                                      child: Text(
                                        st.title,
                                        style: AuraTypography.bodySmall.copyWith(
                                          color: isDone ? AuraColors.textMuted : AuraColors.textPrimary,
                                          decoration: isDone ? TextDecoration.lineThrough : null,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),
                            const SizedBox(height: AuraSpacing.xs),
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _newSubtaskController,
                                    style: AuraTypography.bodySmall.copyWith(color: AuraColors.textPrimary),
                                    decoration: InputDecoration(
                                      hintText: 'Add subtask...',
                                      hintStyle: AuraTypography.bodySmall.copyWith(color: AuraColors.textMuted),
                                      isDense: true,
                                      border: InputBorder.none,
                                    ),
                                    onSubmitted: (_) => _addSubtask(),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(LucideIcons.plusCircle, size: 18, color: AuraColors.textMuted),
                                  onPressed: _addSubtask,
                                ),
                              ],
                            ),
                          ],
                        );
                      },
                      loading: () => const LinearProgressIndicator(),
                      error: (_, __) => const SizedBox.shrink(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AuraSpacing.md),

              // Notes
              BentoCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('NOTES & CONTEXT', style: AuraTypography.caption.copyWith(color: AuraColors.textMuted, fontWeight: FontWeight.w700, letterSpacing: 1.0)),
                    const SizedBox(height: AuraSpacing.xs),
                    TextField(
                      controller: _notesController,
                      style: AuraTypography.bodySmall.copyWith(color: AuraColors.textPrimary),
                      maxLines: 4,
                      decoration: const InputDecoration(
                        hintText: 'Add additional details or context...',
                        hintStyle: TextStyle(color: AuraColors.textMuted),
                        border: InputBorder.none,
                      ),
                    ),
                  ],
                ),
              ),

              if (item.aiTranscript != null && item.aiTranscript!.isNotEmpty) ...[
                const SizedBox(height: AuraSpacing.md),
                BentoCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(LucideIcons.mic, size: 12, color: accent),
                          const SizedBox(width: 4),
                          Text('ORIGINAL TRANSCRIPT', style: AuraTypography.caption.copyWith(color: accent, fontWeight: FontWeight.w700, letterSpacing: 1.0)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(item.aiTranscript!, style: AuraTypography.bodySmall.copyWith(color: AuraColors.textSecondary, fontStyle: FontStyle.italic)),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: AuraSpacing.lg),

              // Save Button
              AuraButton(
                label: 'SAVE CHANGES',
                fullWidth: true,
                isLoading: _isSaving,
                onPressed: () => _saveChanges(item),
              ),
              const SizedBox(height: 40),
            ],
          ),
        );
      },
      loading: () => const Scaffold(backgroundColor: AuraColors.bgBase, body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(backgroundColor: AuraColors.bgBase, body: Center(child: Text('$e'))),
    );
  }

  Future<void> _pickDateTime() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: _deadline ?? now,
      firstDate: now.subtract(const Duration(days: 365)),
      lastDate: now.add(const Duration(days: 365 * 5)),
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: _deadline != null ? TimeOfDay.fromDateTime(_deadline!) : const TimeOfDay(hour: 17, minute: 0),
    );
    if (time == null) return;

    setState(() {
      _deadline = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  Future<void> _addSubtask() async {
    final title = _newSubtaskController.text.trim();
    if (title.isEmpty) return;
    _newSubtaskController.clear();

    final dao = ref.read(itemDaoProvider);
    await dao.insertItem(ItemsCompanion.insert(
      id: const Uuid().v4(),
      parentId: drift.Value(widget.taskId),
      title: title,
      category: const drift.Value('task'),
      status: const drift.Value('pending'),
      createdAt: DateTime.now().millisecondsSinceEpoch,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
    ));
  }

  Future<void> _toggleSubtask(Item st) async {
    final dao = ref.read(itemDaoProvider);
    final isDone = st.status == 'completed';
    await dao.completeItem(st.id, !isDone, DateTime.now().millisecondsSinceEpoch);
  }

  Future<void> _saveChanges(Item item) async {
    setState(() => _isSaving = true);
    final dao = ref.read(itemDaoProvider);

    await dao.updateItem(ItemsCompanion(
      id: drift.Value(item.id),
      title: drift.Value(_titleController.text.trim()),
      notes: drift.Value(_notesController.text.trim()),
      priority: drift.Value(_priority),
      workspaceId: drift.Value(_selectedWorkspaceId),
      deadline: drift.Value(_deadline?.millisecondsSinceEpoch),
      fireAt: drift.Value(_deadline?.millisecondsSinceEpoch),
      updatedAt: drift.Value(DateTime.now().millisecondsSinceEpoch),
    ));

    setState(() => _isSaving = false);
    if (mounted) context.pop();
  }

  Future<void> _deleteTask(String id) async {
    final dao = ref.read(itemDaoProvider);
    await dao.softDeleteItem(id, DateTime.now().millisecondsSinceEpoch);
    if (mounted) context.pop();
  }
}
