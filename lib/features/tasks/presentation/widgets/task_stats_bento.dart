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
        color: AuraColors.cardOf(context),
        border: Border.all(color: AuraColors.borderOf(context), width: 2),
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
                    Text('STATUS', style: AuraTypography.bentoMetricLabel.copyWith(color: AuraColors.textSecondaryOf(context))),
                    const SizedBox(height: 4),
                    Text(
                      status.toUpperCase(),
                      style: AuraTypography.badgeText.copyWith(
                        color: status == 'done'
                            ? AuraColors.accentGreen
                            : (status == 'in_progress' ? AuraColors.accentLime : AuraColors.textPrimaryOf(context)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Container(width: 2, color: AuraColors.borderOf(context)),

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
                    Text('PRIORITY', style: AuraTypography.bentoMetricLabel.copyWith(color: AuraColors.textSecondaryOf(context))),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          priority.toUpperCase(),
                          style: AuraTypography.badgeText.copyWith(
                            color: priority == 'high'
                                ? AuraColors.priorityHigh
                                : (priority == 'medium' ? AuraColors.priorityMedium : AuraColors.textPrimaryOf(context)),
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
                              : (priority == 'medium' ? AuraColors.priorityMedium : AuraColors.textSecondaryOf(context)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          Container(width: 2, color: AuraColors.borderOf(context)),

          // SOURCE cell (Info only)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('SOURCE', style: AuraTypography.bentoMetricLabel.copyWith(color: AuraColors.textSecondaryOf(context))),
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
                      Text(source.toUpperCase(), style: AuraTypography.badgeText.copyWith(color: AuraColors.textPrimaryOf(context))),
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
