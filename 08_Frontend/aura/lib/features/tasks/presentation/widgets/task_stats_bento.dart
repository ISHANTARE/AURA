import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:aura/core/constants/colors.dart';
import 'package:aura/core/constants/typography.dart';

class TaskStatsBento extends StatelessWidget {
  final String status;
  final String priority;
  final String source;
  final ValueChanged<String>? onStatusChanged;
  final ValueChanged<String>? onPriorityChanged;

  const TaskStatsBento({
    super.key,
    required this.status,
    required this.priority,
    required this.source,
    this.onStatusChanged,
    this.onPriorityChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: AuraColors.bgCard,
        border: Border.all(color: AuraColors.border, width: 2),
      ),
      child: Row(
        children: [
          // STATUS cell
          Expanded(
            child: InkWell(
              onTap: () {
                final next = status == 'todo'
                    ? 'in_progress'
                    : (status == 'in_progress' ? 'done' : 'todo');
                onStatusChanged?.call(next);
              },
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('STATUS', style: AuraTypography.bentoMetricLabel.copyWith(color: AuraColors.textSecondary)),
                    const SizedBox(height: 4),
                    Text(
                      status.toUpperCase(),
                      style: AuraTypography.badgeText.copyWith(
                        color: status == 'done'
                            ? AuraColors.accentGreen
                            : (status == 'in_progress' ? AuraColors.accentLime : AuraColors.textPrimary),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Container(width: 2, color: AuraColors.border),

          // PRIORITY cell
          Expanded(
            child: InkWell(
              onTap: () {
                final next = priority == 'high'
                    ? 'medium'
                    : (priority == 'medium' ? 'low' : 'high');
                onPriorityChanged?.call(next);
              },
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('PRIORITY', style: AuraTypography.bentoMetricLabel.copyWith(color: AuraColors.textSecondary)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          priority.toUpperCase(),
                          style: AuraTypography.badgeText.copyWith(
                            color: priority == 'high'
                                ? AuraColors.priorityHigh
                                : (priority == 'medium' ? AuraColors.priorityMedium : AuraColors.textPrimary),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          priority == 'high'
                              ? LucideIcons.alertTriangle
                              : (priority == 'medium' ? LucideIcons.minus : LucideIcons.arrowDown),
                          size: 12,
                          color: priority == 'high'
                              ? AuraColors.priorityHigh
                              : (priority == 'medium' ? AuraColors.priorityMedium : AuraColors.textSecondary),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          Container(width: 2, color: AuraColors.border),

          // SOURCE cell (Info only)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('SOURCE', style: AuraTypography.bentoMetricLabel.copyWith(color: AuraColors.textSecondary)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        source == 'voice'
                            ? LucideIcons.mic
                            : (source == 'share' ? LucideIcons.share2 : LucideIcons.keyboard),
                        size: 12,
                        color: AuraColors.accentLime,
                      ),
                      const SizedBox(width: 4),
                      Text(source.toUpperCase(), style: AuraTypography.badgeText.copyWith(color: AuraColors.textPrimary)),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
