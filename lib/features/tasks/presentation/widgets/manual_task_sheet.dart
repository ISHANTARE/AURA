import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/constants/spacing.dart';
import '../../../../core/constants/typography.dart';
import '../../../../core/providers/providers.dart';
import '../../../capture/domain/entities/intent_result.dart';
import '../../../reminders/domain/services/reminder_scheduling_service.dart';

/// Comprehensive manual task creation bottom sheet.
/// Includes Title, Workspace, Priority, Deadline, Notes, Reminder, and Recurring settings.
class ManualTaskSheet extends ConsumerStatefulWidget {
  const ManualTaskSheet({super.key, this.initialWorkspaceId});

  final String? initialWorkspaceId;

  static Future<void> show(BuildContext context, {String? workspaceId}) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AuraColors.elevatedOf(context),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => ManualTaskSheet(initialWorkspaceId: workspaceId),
    );
  }

  @override
  ConsumerState<ManualTaskSheet> createState() => _ManualTaskSheetState();
}

class _ManualTaskSheetState extends ConsumerState<ManualTaskSheet> {
  final _titleController = TextEditingController();
  final _notesController = TextEditingController();

  String _priority = 'medium';
  String? _selectedWorkspaceId;
  DateTime? _deadline;
  int _reminderOffsetMinutes = 30; // 30 mins default
  bool _isRecurring = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _selectedWorkspaceId = widget.initialWorkspaceId;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final workspacesAsync = ref.watch(workspacesListProvider);

    return Padding(
      padding: EdgeInsets.only(
        left: AuraSpacing.md,
        right: AuraSpacing.md,
        top: AuraSpacing.md,
        bottom: MediaQuery.of(context).viewInsets.bottom + AuraSpacing.md,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: AuraSpacing.md),
                decoration: BoxDecoration(
                  color: AuraColors.borderMuted,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('CREATE TASK', style: AuraTypography.cardTitle),
                IconButton(
                  icon: const Icon(LucideIcons.x, size: 20, color: AuraColors.textSecondary),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: AuraSpacing.sm),

            // Title field
            TextField(
              controller: _titleController,
              autofocus: true,
              style: AuraTypography.cardTitle,
              decoration: InputDecoration(
                hintText: 'What needs to be done?',
                hintStyle: AuraTypography.body,
                filled: true,
                fillColor: AuraColors.cardOf(context),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AuraColors.borderOf(context)),
                ),
              ),
            ),
            const SizedBox(height: AuraSpacing.md),

            // Workspace & Priority Row
            Row(
              children: [
                // Workspace picker
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: AuraColors.cardOf(context),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AuraColors.borderOf(context)),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedWorkspaceId,
                        hint: Text('Workspace', style: AuraTypography.bodySmall),
                        dropdownColor: AuraColors.cardOf(context),
                        style: AuraTypography.bodyPrimary,
                        isExpanded: true,
                        items: workspacesAsync.when(
                          data: (wsList) => wsList.map((w) {
                            return DropdownMenuItem<String>(
                              value: w.id,
                              child: Text(w.name, overflow: TextOverflow.ellipsis),
                            );
                          }).toList(),
                          loading: () => [],
                          error: (_, __) => [],
                        ),
                        onChanged: (val) {
                          setState(() => _selectedWorkspaceId = val);
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AuraSpacing.sm),
                // Priority chips
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AuraColors.cardOf(context),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AuraColors.borderOf(context)),
                  ),
                  child: Row(
                    children: ['low', 'medium', 'high'].map((p) {
                      final isSel = _priority == p;
                      Color pColor;
                      if (p == 'high') {
                        pColor = AuraColors.accentRed;
                      } else if (p == 'medium') {
                        pColor = AuraColors.accentOrange;
                      } else {
                        pColor = AuraColors.accentGreen;
                      }

                      return GestureDetector(
                        onTap: () => setState(() => _priority = p),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: isSel ? pColor.withValues(alpha: 0.2) : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                            border: isSel ? Border.all(color: pColor, width: 1) : null,
                          ),
                          child: Text(
                            p[0].toUpperCase(),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: isSel ? pColor : AuraColors.textMuted,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AuraSpacing.md),

            // Deadline Tile
            InkWell(
              onTap: _pickDeadline,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(AuraSpacing.md),
                decoration: BoxDecoration(
                  color: AuraColors.cardOf(context),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AuraColors.borderOf(context)),
                ),
                child: Row(
                  children: [
                    Icon(LucideIcons.calendar, size: 18, color: primaryColor),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Deadline', style: AuraTypography.caption),
                          Text(
                            _deadline != null
                                ? DateFormat('EEE, MMM d · h:mm a').format(_deadline!)
                                : 'No deadline set (Tap to choose)',
                            style: _deadline != null
                                ? AuraTypography.bodyPrimary
                                : AuraTypography.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    if (_deadline != null)
                      IconButton(
                        icon: const Icon(LucideIcons.x, size: 16, color: AuraColors.textMuted),
                        onPressed: () => setState(() => _deadline = null),
                      )
                    else
                      const Icon(LucideIcons.chevronRight, size: 18, color: AuraColors.textMuted),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AuraSpacing.md),

            // Notes / Details field
            TextField(
              controller: _notesController,
              maxLines: 3,
              minLines: 2,
              style: AuraTypography.bodyPrimary,
              decoration: InputDecoration(
                hintText: 'Add notes, subtasks, or description...',
                hintStyle: AuraTypography.bodySmall,
                filled: true,
                fillColor: AuraColors.cardOf(context),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AuraColors.borderOf(context)),
                ),
              ),
            ),
            const SizedBox(height: AuraSpacing.md),

            // Options Row: Reminder + Recurring
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Reminder Selector
                Row(
                  children: [
                    const Icon(LucideIcons.bell, size: 16, color: AuraColors.textSecondary),
                    const SizedBox(width: 6),
                    Text('Remind:', style: AuraTypography.label),
                    const SizedBox(width: 8),
                    DropdownButton<int>(
                      value: _reminderOffsetMinutes,
                      dropdownColor: AuraColors.bgElevated,
                      style: AuraTypography.bodyPrimary.copyWith(fontSize: 13),
                      underline: const SizedBox.shrink(),
                      items: const [
                        DropdownMenuItem(value: 0, child: Text('At deadline')),
                        DropdownMenuItem(value: 15, child: Text('15m before')),
                        DropdownMenuItem(value: 30, child: Text('30m before')),
                        DropdownMenuItem(value: 60, child: Text('1h before')),
                        DropdownMenuItem(value: 1440, child: Text('1d before')),
                      ],
                      onChanged: (val) {
                        if (val != null) setState(() => _reminderOffsetMinutes = val);
                      },
                    ),
                  ],
                ),

                // Recurring switch
                Row(
                  children: [
                    Text('Recurring:', style: AuraTypography.label),
                    Switch(
                      value: _isRecurring,
                      activeColor: primaryColor,
                      onChanged: (val) => setState(() => _isRecurring = val),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: AuraSpacing.lg),

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: _isSaving ? null : _saveTask,
                child: _isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : Text(
                        'SAVE TASK',
                        style: AuraTypography.buttonText.copyWith(fontWeight: FontWeight.bold),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDeadline() async {
    final now = DateTime.now();
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _deadline ?? now.add(const Duration(hours: 1)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );

    if (pickedDate != null && mounted) {
      final pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_deadline ?? now.add(const Duration(hours: 1))),
      );
      if (pickedTime != null) {
        setState(() {
          _deadline = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  Future<void> _saveTask() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a task title')),
      );
      return;
    }

    setState(() => _isSaving = true);
    HapticFeedback.mediumImpact();

    try {
      final itemDao = ref.read(itemDaoProvider);
      final nowEpoch = DateTime.now().millisecondsSinceEpoch;
      final taskId = 'task_$nowEpoch';
      final notesText = _notesController.text.trim();

      // Find target workspace if not selected
      String wsId = _selectedWorkspaceId ?? '';
      if (wsId.isEmpty) {
        final allWs = await ref.read(databaseProvider).workspaceDao.getAll();
        if (allWs.isNotEmpty) {
          wsId = allWs.first.id;
        }
      }

      await itemDao.insertItem(
        ItemsCompanion.insert(
          id: taskId,
          title: title,
          notes: notesText.isNotEmpty ? Value(notesText) : const Value.absent(),
          workspaceId: wsId.isNotEmpty ? Value(wsId) : const Value.absent(),
          category: 'reminder',
          kind: 'task',
          priority: Value(_priority),
          deadline: _deadline != null ? Value(_deadline!.millisecondsSinceEpoch) : const Value.absent(),
          isRecurring: Value(_isRecurring),
          recurrenceRule: _isRecurring ? const Value('daily') : const Value.absent(),
          createdAt: nowEpoch,
          updatedAt: nowEpoch,
        ),
      );

      // Schedule the deadline reminder through the single scheduling path —
      // same engine voice capture uses, so behavior can never drift.
      if (_deadline != null) {
        final savedItem = await itemDao.getById(taskId);
        if (savedItem != null) {
          final service = ref.read(reminderSchedulingServiceProvider);
          final outcome = await service.syncForItem(
            savedItem,
            extractedReminders: [
              ExtractedReminder(
                offsetValue: _reminderOffsetMinutes,
                offsetUnit: 'minutes',
                type: 'notification',
              ),
            ],
          );
          if (mounted && outcome.usedInexactFallback) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text(
                      'Exact alarms unavailable — reminders may be delayed by a few minutes.')),
            );
          }
        }
      }

      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving task: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }
}
