import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import 'package:aura/core/constants/colors.dart';
import 'package:aura/core/constants/typography.dart';

class TaskDeadlineCard extends StatelessWidget {
  final DateTime? deadline;
  final ValueChanged<DateTime>? onDeadlineChanged;

  const TaskDeadlineCard({
    super.key,
    this.deadline,
    this.onDeadlineChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (deadline == null) {
      return GestureDetector(
        onTap: () => _pickDateTime(context),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AuraColors.bgCard,
            border: Border.all(color: AuraColors.borderMuted, width: 1.5),
          ),
          child: Row(
            children: [
              const Icon(LucideIcons.calendar, color: AuraColors.textSecondary, size: 18),
              const SizedBox(width: 10),
              Text(
                'No deadline set — tap to add',
                style: AuraTypography.bodySmall.copyWith(fontStyle: FontStyle.italic),
              ),
            ],
          ),
        ),
      );
    }

    final now = DateTime.now();
    final isOverdue = deadline!.isBefore(now);
    final diff = deadline!.difference(now);

    Color chipColor;
    String chipText;

    if (isOverdue) {
      chipColor = AuraColors.accentRed;
      chipText = '🔴 Overdue by ${_formatDiff(now.difference(deadline!))}';
    } else if (diff.inHours < 24) {
      chipColor = AuraColors.accentRed;
      chipText = 'Due in ${diff.inHours} hours';
    } else if (diff.inDays <= 3) {
      chipColor = AuraColors.accentOrange;
      chipText = 'Due in ${diff.inDays} days';
    } else {
      chipColor = AuraColors.accentGreen;
      chipText = 'Due in ${diff.inDays} days';
    }

    final formattedDate = DateFormat('EEE, MMM d · h:mm a').format(deadline!);

    return GestureDetector(
      onTap: () => _pickDateTime(context),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AuraColors.bgCard,
          border: Border.all(
            color: isOverdue ? AuraColors.accentRed : AuraColors.border,
            width: 2,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(LucideIcons.calendar, color: AuraColors.textPrimary, size: 18),
                const SizedBox(width: 8),
                Text(
                  formattedDate,
                  style: AuraTypography.cardTitle.copyWith(color: AuraColors.textPrimary),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: chipColor.withValues(alpha: 0.15),
                border: Border.all(color: chipColor, width: 1),
              ),
              child: Text(
                chipText,
                style: AuraTypography.badgeText.copyWith(color: chipColor),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDiff(Duration d) {
    if (d.inDays > 0) return '${d.inDays} days';
    if (d.inHours > 0) return '${d.inHours} hours';
    return '${d.inMinutes} mins';
  }

  Future<void> _pickDateTime(BuildContext context) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: deadline ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    if (pickedDate != null && context.mounted) {
      final pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(deadline ?? DateTime.now()),
      );
      if (pickedTime != null) {
        final newDeadline = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );
        onDeadlineChanged?.call(newDeadline);
      }
    }
  }
}
