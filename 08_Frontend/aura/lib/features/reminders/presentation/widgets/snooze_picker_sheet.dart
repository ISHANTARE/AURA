import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/constants/spacing.dart';
import '../../../../core/constants/typography.dart';
import '../../../../core/providers/providers.dart';
import '../../domain/entities/reminder_models.dart';

/// Neubrutalist Snooze Picker Sheet — Preset & Custom Snooze Picker (PRD F-07)
class SnoozePickerSheet extends ConsumerWidget {
  const SnoozePickerSheet({
    super.key,
    required this.taskId,
    required this.taskTitle,
    this.reminderId,
  });

  final String taskId;
  final String taskTitle;
  final String? reminderId;

  static Future<void> show(
    BuildContext context, {
    required String taskId,
    required String taskTitle,
    String? reminderId,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => SnoozePickerSheet(
        taskId: taskId,
        taskTitle: taskTitle,
        reminderId: reminderId,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final snoozeUseCase = ref.watch(snoozeReminderUseCaseProvider);

    return Container(
      decoration: const BoxDecoration(
        color: AuraColors.bgElevated,
        border: Border(
          top: BorderSide(
              color: AuraColors.border, width: AuraSpacing.borderWidth),
        ),
      ),
      padding: const EdgeInsets.all(AuraSpacing.md),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('SNOOZE REMINDER', style: AuraTypography.screenHeader),
              IconButton(
                icon: const Icon(LucideIcons.x, color: AuraColors.textPrimary),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          Text('Task: "$taskTitle"',
              style: AuraTypography.bodySmall,
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
          const SizedBox(height: AuraSpacing.md),
          const Divider(color: AuraColors.borderMuted, height: 1),
          const SizedBox(height: AuraSpacing.sm),

          // Presets list
          ...SnoozePreset.values.map(
            (preset) => _SnoozeTile(
              label: preset.label,
              icon: _presetIcon(preset),
              onTap: () async {
                HapticFeedback.mediumImpact();
                if (preset == SnoozePreset.custom) {
                  final customDt = await _pickCustomDateTime(context);
                  if (customDt == null) return;
                  await snoozeUseCase.execute(
                    reminderId: reminderId ?? taskId,
                    taskTitle: taskTitle,
                    taskId: taskId,
                    preset: SnoozePreset.custom,
                    customDateTime: customDt,
                  );
                } else {
                  await snoozeUseCase.execute(
                    reminderId: reminderId ?? taskId,
                    taskTitle: taskTitle,
                    taskId: taskId,
                    preset: preset,
                  );
                }

                if (context.mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Snoozed: ${preset.label}'),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                }
              },
            ),
          ),
          const SizedBox(height: AuraSpacing.md),
        ],
      ),
    );
  }

  IconData _presetIcon(SnoozePreset preset) {
    switch (preset) {
      case SnoozePreset.minutes30:
        return LucideIcons.clock;
      case SnoozePreset.hour1:
        return LucideIcons.timer;
      case SnoozePreset.tonight9pm:
        return LucideIcons.moon;
      case SnoozePreset.tomorrow8am:
        return LucideIcons.sun;
      case SnoozePreset.custom:
        return LucideIcons.calendar;
    }
  }

  Future<DateTime?> _pickCustomDateTime(BuildContext context) async {
    final now = DateTime.now();
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(hours: 1)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (pickedDate == null) return null;

    if (!context.mounted) return null;
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(now.add(const Duration(hours: 1))),
    );
    if (pickedTime == null) return null;

    return DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );
  }
}

class _SnoozeTile extends StatelessWidget {
  const _SnoozeTile({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        onTap: onTap,
        shape: const RoundedRectangleBorder(
          side: BorderSide(color: AuraColors.border, width: 1),
          borderRadius: BorderRadius.zero,
        ),
        tileColor: AuraColors.bgCard,
        leading: Icon(icon, color: AuraColors.accentLime, size: 20),
        title: Text(label, style: AuraTypography.cardTitle),
        trailing: const Icon(LucideIcons.chevronRight,
            color: AuraColors.textSecondary, size: 16),
      ),
    );
  }
}
