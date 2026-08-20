import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/spacing.dart';
import '../../../../core/constants/typography.dart';
import '../../../../core/providers/providers.dart';
import '../../domain/entities/capture_state.dart';
import '../../domain/entities/intent_result.dart';
import '../../domain/entities/workspace_match_result.dart';
import '../providers/capture_provider.dart';

import 'workspace_confirmation_card.dart';
import 'delete_confirmation_card.dart';
import 'note_confirmation_card.dart';
import 'alarm_confirmation_card.dart';
import 'voice_capture_overlay.dart';

class ConfirmationBox extends ConsumerStatefulWidget {
  final CaptureState state;

  const ConfirmationBox({super.key, required this.state});

  @override
  ConsumerState<ConfirmationBox> createState() => _ConfirmationBoxState();
}

class _ConfirmationBoxState extends ConsumerState<ConfirmationBox> {
  bool _isEditingAll = false;
  late TextEditingController _titleController;
  late TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    final intent = widget.state.intentResult;
    _titleController = TextEditingController(text: intent?.title ?? '');
    _notesController = TextEditingController(text: intent?.notes ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final intent = widget.state.intentResult;
    if (intent == null) return const SizedBox.shrink();

    // Dedicated Card Routing
    switch (intent.intentType) {
      case 'create_alarm':
        return AlarmConfirmationCard(intent: intent);
      case 'create_workspace':
        return WorkspaceConfirmationCard(intent: intent);
      case 'delete_task':
      case 'delete_workspace':
        return DeleteConfirmationCard(intent: intent);
      case 'add_note':
        return NoteConfirmationCard(intent: intent);
      // create_event and create_reminder fall through to the generic task card
      // which displays all fields including eventStart, eventEnd, eventLocation
    }

    final workspaceMatch = widget.state.workspaceMatch;

    return SingleChildScrollView(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(AuraSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              children: [
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(LucideIcons.sparkles, size: 12, color: Colors.white),
                  ),
                ),
                const SizedBox(width: AuraSpacing.xs),
                Text(
                  _actionLabel(intent.intentType),
                  style: AuraTypography.label.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () async {
                    HapticFeedback.selectionClick();
                    await ref.read(captureProvider.notifier).cancelCapture();
                    if (context.mounted) VoiceCaptureOverlay.closeOverlay(context);
                  },
                  child: const Icon(LucideIcons.x, size: 20, color: AuraColors.textSecondary),
                ),
              ],
            ),

            const SizedBox(height: AuraSpacing.sm),

            // Title Row
            _buildTitleRow(intent),

            const SizedBox(height: AuraSpacing.xs),
            const Divider(color: AuraColors.borderMuted, height: 16),

            // Field Rows
            _buildDeadlineRow(intent),
            const SizedBox(height: AuraSpacing.xs),
            _buildRemindersRow(intent),
            const SizedBox(height: AuraSpacing.xs),
            _buildWorkspaceRow(intent, workspaceMatch),
            const SizedBox(height: AuraSpacing.xs),
            _buildPriorityRow(intent),
            const SizedBox(height: AuraSpacing.xs),
            _buildRecurringRow(intent),

            // Notes Section — Always visible if notes present or when editing
            if ((intent.notes != null && intent.notes!.isNotEmpty) || _isEditingAll) ...[
              const SizedBox(height: AuraSpacing.sm),
              Row(
                children: [
                  const Icon(LucideIcons.fileText, size: 14, color: AuraColors.textSecondary),
                  const SizedBox(width: 6),
                  Text('Notes & Spoken Details', style: AuraTypography.overline),
                ],
              ),
              const SizedBox(height: AuraSpacing.xs),
              TextField(
                controller: _notesController,
                maxLines: 3,
                minLines: 2,
                style: AuraTypography.bodyPrimary,
                decoration: InputDecoration(
                  hintText: 'Add notes or context...',
                  hintStyle: AuraTypography.body,
                  filled: true,
                  fillColor: AuraColors.bgElevated,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4),
                    borderSide: const BorderSide(color: AuraColors.border),
                  ),
                ),
                onChanged: (val) {
                  ref.read(captureProvider.notifier).updateIntent(
                        intent.copyWith(notes: val),
                      );
                },
              ),
            ],

            const SizedBox(height: AuraSpacing.md),

            // Action buttons
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  String _actionLabel(String intentType) {
    switch (intentType) {
      case 'create_workspace':
        return 'CREATE WORKSPACE';
      case 'delete_task':
        return 'DELETE TASK';
      case 'delete_workspace':
        return 'DELETE WORKSPACE';
      case 'create_event':
        return 'CREATE EVENT';
      case 'add_note':
        return 'ADD NOTE';
      case 'create_reminder':
        return 'CREATE REMINDER';
      case 'create_task':
      default:
        return 'CREATE TASK';
    }
  }

  Widget _buildTitleRow(IntentResult intent) {
    final isLowConf = (intent.titleConf ?? intent.confidence) < 0.7;

    return Container(
      padding: const EdgeInsets.all(AuraSpacing.xs + 2),
      decoration: BoxDecoration(
        color: AuraColors.bgElevated,
        border: Border.all(
          color: isLowConf ? AuraColors.accentOrange : AuraColors.border,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          Icon(
            intent.intentType == 'create_event' ? LucideIcons.calendar : LucideIcons.checkSquare,
            size: 16,
            color: AuraColors.accentLime,
          ),
          const SizedBox(width: AuraSpacing.xs),
          if (isLowConf) ...[
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: AuraColors.accentOrange,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: AuraSpacing.xs),
          ],
          Expanded(
            child: TextField(
              controller: _titleController,
              style: AuraTypography.cardTitle,
              decoration: const InputDecoration(
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
              onChanged: (newTitle) {
                ref.read(captureProvider.notifier).updateIntent(
                      intent.copyWith(title: newTitle),
                    );
              },
            ),
          ),
          const Icon(LucideIcons.pencil, size: 14, color: AuraColors.textSecondary),
        ],
      ),
    );
  }

  Widget _buildDeadlineRow(IntentResult intent) {
    final deadline = intent.deadline;
    final isLowConf = (intent.deadlineConf ?? intent.confidence) < 0.7;

    return GestureDetector(
      onTap: () async {
        HapticFeedback.selectionClick();
        final now = DateTime.now();
        final pickedDate = await showDatePicker(
          context: context,
          initialDate: deadline ?? now,
          firstDate: now.subtract(const Duration(days: 1)),
          lastDate: now.add(const Duration(days: 365)),
        );
        if (pickedDate != null && mounted) {
          final pickedTime = await showTimePicker(
            context: context,
            initialTime: TimeOfDay.fromDateTime(deadline ?? now),
          );
          if (pickedTime != null) {
            final newDt = DateTime(
              pickedDate.year,
              pickedDate.month,
              pickedDate.day,
              pickedTime.hour,
              pickedTime.minute,
            );
            ref.read(captureProvider.notifier).updateIntent(
                  intent.copyWith(deadline: newDt),
                );
          }
        }
      },
      child: _buildFieldContainer(
        icon: LucideIcons.calendar,
        label: 'Deadline',
        content: Row(
          children: [
            if (isLowConf && deadline != null) ...[
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: AuraColors.accentOrange,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 4),
            ],
            Text(
              deadline != null
                  ? _formatDateTime(deadline)
                  : 'No deadline — tap to set',
              style: deadline != null
                  ? AuraTypography.bodyPrimary
                  : AuraTypography.body.copyWith(fontStyle: FontStyle.italic),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRemindersRow(IntentResult intent) {
    return GestureDetector(
      onTap: () => _showReminderPicker(context, intent),
      child: _buildFieldContainer(
        icon: LucideIcons.bell,
        label: 'Reminders',
        content: Row(
          children: [
            Expanded(
              child: intent.reminders.isEmpty
                  ? Text('No reminders — tap to set', style: AuraTypography.body.copyWith(fontStyle: FontStyle.italic))
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: intent.reminders.map((r) {
                        return Text(
                          '${r.offsetValue} ${r.offsetUnit} before (${r.type})',
                          style: AuraTypography.bodyPrimary.copyWith(fontSize: 13),
                        );
                      }).toList(),
                    ),
            ),
            const Icon(LucideIcons.pencil, size: 14, color: AuraColors.textSecondary),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkspaceRow(IntentResult intent, WorkspaceMatchResult? match) {
    String nameDisplay = 'Select workspace';
    String badgeText = '';
    Color badgeColor = AuraColors.accentLime;

    if (match != null) {
      if (match.matchedWorkspace != null) {
        nameDisplay = match.matchedWorkspace!.name;
        if (match.type == WorkspaceMatchType.keyword) {
          badgeText = 'auto';
          badgeColor = AuraColors.accentOrange;
        } else if (match.type == WorkspaceMatchType.exact) {
          badgeText = 'exact';
          badgeColor = AuraColors.accentLime;
        }
      } else if (match.suggestedWorkspaceName != null) {
        nameDisplay = match.suggestedWorkspaceName!;
        badgeText = 'new';
        badgeColor = AuraColors.accentLime;
      }
    } else if (intent.workspaceHint != null) {
      nameDisplay = intent.workspaceHint!;
      badgeText = 'auto';
    }

    return GestureDetector(
      onTap: () => _showWorkspacePicker(context, intent, match),
      child: _buildFieldContainer(
        icon: LucideIcons.folder,
        label: 'Workspace',
        content: Row(
          children: [
            Expanded(
              child: Row(
                children: [
                  Text(nameDisplay, style: AuraTypography.bodyPrimary),
                  if (badgeText.isNotEmpty) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: badgeColor.withValues(alpha: 0.15),
                        border: Border.all(color: badgeColor, width: 1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        badgeText,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: badgeColor,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const Icon(LucideIcons.pencil, size: 14, color: AuraColors.textSecondary),
          ],
        ),
      ),
    );
  }

  Future<void> _showWorkspacePicker(
    BuildContext context,
    IntentResult intent,
    WorkspaceMatchResult? match,
  ) async {
    HapticFeedback.selectionClick();
    final db = ref.read(databaseProvider);
    final workspaces = await db.workspaceDao.getAll();

    if (!context.mounted) return;

    final currentWsId = match?.matchedWorkspace?.id;

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AuraColors.bgElevated,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AuraSpacing.md),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Select Workspace', style: AuraTypography.cardTitle),
                    GestureDetector(
                      onTap: () => Navigator.of(ctx).pop(),
                      child: const Icon(LucideIcons.x, size: 20, color: AuraColors.textSecondary),
                    ),
                  ],
                ),
                const SizedBox(height: AuraSpacing.sm),
                const Divider(color: AuraColors.borderMuted, height: 1),
                const SizedBox(height: AuraSpacing.xs),
                Flexible(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        ...workspaces.map((ws) {
                          final isSelected = ws.id == currentWsId;
                          Color wsColor;
                          try {
                            final clean = ws.colorHex.replaceFirst('#', '');
                            wsColor = Color(int.parse('FF$clean', radix: 16));
                          } catch (_) {
                            wsColor = AuraColors.accentLime;
                          }

                          return ListTile(
                            dense: true,
                            leading: Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: wsColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                            title: Text(
                              ws.name,
                              style: AuraTypography.bodyPrimary.copyWith(
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                color: isSelected
                                    ? Theme.of(ctx).colorScheme.primary
                                    : AuraColors.textPrimary,
                              ),
                            ),
                            trailing: isSelected
                                ? Icon(LucideIcons.check, size: 18, color: Theme.of(ctx).colorScheme.primary)
                                : null,
                            onTap: () {
                              Navigator.of(ctx).pop();
                              final newMatch = WorkspaceMatchResult.exact(ws);
                              final newIntent = intent.copyWith(workspaceHint: ws.name);
                              ref.read(captureProvider.notifier).updateIntentAndWorkspace(newIntent, newMatch);
                            },
                          );
                        }),
                        const Divider(color: AuraColors.borderMuted, height: 1),
                        ListTile(
                          dense: true,
                          leading: const Icon(LucideIcons.plusCircle, size: 18, color: AuraColors.accentLime),
                          title: Text(
                            '+ Create custom workspace...',
                            style: AuraTypography.bodyPrimary.copyWith(color: AuraColors.accentLime),
                          ),
                          onTap: () {
                            Navigator.of(ctx).pop();
                            _promptCustomWorkspace(context, intent);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _promptCustomWorkspace(BuildContext context, IntentResult intent) async {
    final controller = TextEditingController();
    final newName = await showDialog<String>(
      context: context,
      builder: (dialogCtx) {
        return AlertDialog(
          backgroundColor: AuraColors.bgCard,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: const BorderSide(color: AuraColors.border, width: 2),
          ),
          title: Text('New Workspace Name', style: AuraTypography.cardTitle),
          content: TextField(
            controller: controller,
            autofocus: true,
            style: AuraTypography.bodyPrimary,
            decoration: const InputDecoration(
              hintText: 'e.g. Project X',
              hintStyle: TextStyle(color: AuraColors.textDisabled),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogCtx).pop(),
              child: const Text('CANCEL', style: TextStyle(color: AuraColors.textSecondary)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AuraColors.accentLime, foregroundColor: Colors.black),
              onPressed: () => Navigator.of(dialogCtx).pop(controller.text.trim()),
              child: const Text('SET'),
            ),
          ],
        );
      },
    );

    if (newName != null && newName.isNotEmpty && mounted) {
      final newMatch = WorkspaceMatchResult.newWorkspace(newName);
      final newIntent = intent.copyWith(workspaceHint: newName);
      ref.read(captureProvider.notifier).updateIntentAndWorkspace(newIntent, newMatch);
    }
  }

  Future<void> _showReminderPicker(
    BuildContext context,
    IntentResult intent,
  ) async {
    HapticFeedback.selectionClick();

    final options = [
      {'label': 'No reminder', 'value': 0, 'unit': 'none'},
      {'label': '10 minutes before', 'value': 10, 'unit': 'minutes'},
      {'label': '30 minutes before', 'value': 30, 'unit': 'minutes'},
      {'label': '1 hour before', 'value': 1, 'unit': 'hours'},
      {'label': '2 hours before', 'value': 2, 'unit': 'hours'},
      {'label': '1 day before', 'value': 1, 'unit': 'days'},
    ];

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AuraColors.bgCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        side: BorderSide(color: AuraColors.border, width: 2),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AuraSpacing.md),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Set Reminder', style: AuraTypography.cardTitle),
                    GestureDetector(
                      onTap: () => Navigator.of(ctx).pop(),
                      child: const Icon(LucideIcons.x, size: 20, color: AuraColors.textSecondary),
                    ),
                  ],
                ),
                const SizedBox(height: AuraSpacing.sm),
                const Divider(color: AuraColors.borderMuted, height: 1),
                const SizedBox(height: AuraSpacing.xs),
                ...options.map((opt) {
                  final label = opt['label'] as String;
                  final val = opt['value'] as int;
                  final unit = opt['unit'] as String;

                  final isCurrent = (unit == 'none' && intent.reminders.isEmpty) ||
                      (intent.reminders.isNotEmpty &&
                          intent.reminders.first.offsetValue == val &&
                          intent.reminders.first.offsetUnit == unit);

                  return ListTile(
                    dense: true,
                    leading: Icon(
                      unit == 'none' ? LucideIcons.bellOff : LucideIcons.bell,
                      size: 18,
                      color: isCurrent ? AuraColors.accentLime : AuraColors.textSecondary,
                    ),
                    title: Text(
                      label,
                      style: AuraTypography.bodyPrimary.copyWith(
                        fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                        color: isCurrent ? AuraColors.accentLime : AuraColors.textPrimary,
                      ),
                    ),
                    trailing: isCurrent
                        ? const Icon(LucideIcons.check, size: 18, color: AuraColors.accentLime)
                        : null,
                    onTap: () {
                      Navigator.of(ctx).pop();
                      List<ExtractedReminder> newReminders = [];
                      if (unit != 'none') {
                        newReminders = [
                          ExtractedReminder(
                            offsetValue: val,
                            offsetUnit: unit,
                            type: 'notification',
                          ),
                        ];
                      }
                      ref.read(captureProvider.notifier).updateIntent(
                            intent.copyWith(reminders: newReminders),
                          );
                    },
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPriorityRow(IntentResult intent) {
    final priority = (intent.priority ?? 'medium').toUpperCase();

    return _buildFieldContainer(
      icon: LucideIcons.zap,
      label: 'Priority',
      content: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          final next = priority == 'HIGH'
              ? 'medium'
              : (priority == 'MEDIUM' ? 'low' : 'high');
          ref.read(captureProvider.notifier).updateIntent(
                intent.copyWith(priority: next),
              );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: priority == 'HIGH'
                ? AuraColors.accentRed.withValues(alpha: 0.2)
                : (priority == 'MEDIUM'
                    ? AuraColors.accentOrange.withValues(alpha: 0.2)
                    : AuraColors.bgElevated),
            border: Border.all(
              color: priority == 'HIGH'
                  ? AuraColors.accentRed
                  : (priority == 'MEDIUM' ? AuraColors.accentOrange : AuraColors.border),
            ),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            priority,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: priority == 'HIGH'
                  ? AuraColors.accentRed
                  : (priority == 'MEDIUM' ? AuraColors.accentOrange : AuraColors.textSecondary),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRecurringRow(IntentResult intent) {
    return _buildFieldContainer(
      icon: LucideIcons.repeat,
      label: 'Recurring',
      content: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          ref.read(captureProvider.notifier).updateIntent(
                intent.copyWith(
                  isRecurring: !intent.isRecurring,
                  recurrenceType: intent.isRecurring ? null : 'daily',
                ),
              );
        },
        child: Text(
          intent.isRecurring
              ? (intent.recurrenceType ?? 'daily')
              : 'No',
          style: AuraTypography.bodyPrimary,
        ),
      ),
    );
  }

  Widget _buildFieldContainer({
    required IconData icon,
    required String label,
    required Widget content,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 15, color: AuraColors.textSecondary),
          const SizedBox(width: 8),
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: AuraTypography.label.copyWith(color: AuraColors.textSecondary),
            ),
          ),
          Expanded(child: content),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    final isSaving = widget.state.isSaving;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 46,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                    elevation: 2,
                    minimumSize: const Size(0, 46),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: isSaving
                      ? null
                      : () {
                          HapticFeedback.mediumImpact();
                          ref.read(captureProvider.notifier).confirmAndSave();
                        },
                  child: isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.black,
                          ),
                        )
                      : Text(
                          'CONFIRM & SAVE',
                          style: AuraTypography.label.copyWith(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                ),
              ),
            ),
            const SizedBox(width: AuraSpacing.sm),
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(0, 46),
                side: const BorderSide(color: AuraColors.border),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                HapticFeedback.selectionClick();
                setState(() => _isEditingAll = !_isEditingAll);
              },
              child: Text(
                _isEditingAll ? 'DONE' : 'EDIT ALL',
                style: AuraTypography.label.copyWith(color: AuraColors.textPrimary),
              ),
            ),
          ],
        ),
        const SizedBox(height: AuraSpacing.xs),
        GestureDetector(
          onTap: () {
            HapticFeedback.selectionClick();
            ref.read(captureProvider.notifier).startCapture();
          },
          child: Text(
            'Start over',
            style: AuraTypography.overline.copyWith(
              color: AuraColors.textSecondary,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }

  String _formatDateTime(DateTime dt) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    final dayName = days[dt.weekday - 1];
    final monthName = months[dt.month - 1];

    final hour = dt.hour == 0 ? 12 : (dt.hour > 12 ? dt.hour - 12 : dt.hour);
    final ampm = dt.hour >= 12 ? 'PM' : 'AM';
    final minuteStr = dt.minute.toString().padLeft(2, '0');

    return '$dayName, $monthName ${dt.day} · $hour:$minuteStr $ampm';
  }
}
