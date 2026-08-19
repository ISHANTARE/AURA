import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import 'package:aura/core/constants/colors.dart';
import 'package:aura/core/constants/typography.dart';
import 'package:aura/features/reminders/domain/entities/reminder_models.dart';
import 'package:aura/features/reminders/presentation/providers/reminder_providers.dart';

class SnoozeBottomSheet extends ConsumerStatefulWidget {
  final String reminderId;
  final String taskId;
  final String taskTitle;

  const SnoozeBottomSheet({
    super.key,
    required this.reminderId,
    required this.taskId,
    required this.taskTitle,
  });

  static Future<void> show(
    BuildContext context, {
    required String reminderId,
    required String taskId,
    required String taskTitle,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => SnoozeBottomSheet(
        reminderId: reminderId,
        taskId: taskId,
        taskTitle: taskTitle,
      ),
    );
  }

  @override
  ConsumerState<SnoozeBottomSheet> createState() => _SnoozeBottomSheetState();
}

class _SnoozeBottomSheetState extends ConsumerState<SnoozeBottomSheet> {
  SnoozePreset _selectedPreset = SnoozePreset.minutes30;
  DateTime? _customDateTime;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AuraColors.bgElevated,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        border: Border(
          top: BorderSide(color: AuraColors.border, width: 2),
          left: BorderSide(color: AuraColors.border, width: 2),
          right: BorderSide(color: AuraColors.border, width: 2),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AuraColors.textDisabled,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Header
          Row(
            children: [
              Icon(LucideIcons.bellRing, color: Theme.of(context).colorScheme.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                'SNOOZE REMINDER',
                style: AuraTypography.label.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          Text(
            widget.taskTitle,
            style: AuraTypography.cardTitle.copyWith(color: AuraColors.textPrimary),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 20),

          // Presets grid
          Wrap(
            spacing: 8,
            runSpacing: 10,
            children: SnoozePreset.values.map((preset) {
              final isSelected = _selectedPreset == preset;
              return GestureDetector(
                onTap: () async {
                  if (preset == SnoozePreset.custom) {
                    final pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (pickedDate != null && context.mounted) {
                      final pickedTime = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );
                      if (pickedTime != null) {
                        setState(() {
                          _customDateTime = DateTime(
                            pickedDate.year,
                            pickedDate.month,
                            pickedDate.day,
                            pickedTime.hour,
                            pickedTime.minute,
                          );
                          _selectedPreset = preset;
                        });
                      }
                    }
                  } else {
                    setState(() {
                      _selectedPreset = preset;
                    });
                  }
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : AuraColors.bgCard,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : AuraColors.borderMuted,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        preset == SnoozePreset.custom
                            ? LucideIcons.calendar
                            : LucideIcons.clock,
                        size: 14,
                        color: isSelected ? Colors.white : AuraColors.textSecondary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        preset == SnoozePreset.custom && _customDateTime != null
                            ? '${_customDateTime!.month}/${_customDateTime!.day} ${_customDateTime!.hour}:${_customDateTime!.minute.toString().padLeft(2, '0')}'
                            : preset.label,
                        style: AuraTypography.bodySmall.copyWith(
                          color: isSelected ? Colors.white : AuraColors.textPrimary,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),

          // Action CTA button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () async {
                final notifier = ref.read(reminderActionProvider.notifier);
                await notifier.snoozeReminder(
                  reminderId: widget.reminderId,
                  taskId: widget.taskId,
                  taskTitle: widget.taskTitle,
                  preset: _selectedPreset,
                  customDateTime: _customDateTime,
                );
                if (context.mounted) Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: Text(
                'CONFIRM SNOOZE',
                style: AuraTypography.buttonText.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
