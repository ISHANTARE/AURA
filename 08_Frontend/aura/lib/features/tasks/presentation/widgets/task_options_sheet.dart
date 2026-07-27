import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import 'package:aura/core/constants/colors.dart';
import 'package:aura/core/constants/typography.dart';
import '../providers/task_detail_providers.dart';

class TaskOptionsSheet extends ConsumerWidget {
  final String taskId;
  final String taskTitle;

  const TaskOptionsSheet({
    super.key,
    required this.taskId,
    required this.taskTitle,
  });

  static Future<void> show(
    BuildContext context, {
    required String taskId,
    required String taskTitle,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => TaskOptionsSheet(taskId: taskId, taskTitle: taskTitle),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
      padding: const EdgeInsets.symmetric(vertical: 20),
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

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              taskTitle,
              style: AuraTypography.sectionHeader,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 16),

          _OptionTile(
            icon: LucideIcons.share2,
            title: 'Share task',
            onTap: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Share functionality ready')),
              );
            },
          ),
          _OptionTile(
            icon: LucideIcons.copy,
            title: 'Duplicate task',
            onTap: () async {
              Navigator.pop(context);
              final newId = await ref
                  .read(taskDetailActionProvider.notifier)
                  .duplicateTask(taskId);
              if (context.mounted && newId != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Task duplicated!')),
                );
              }
            },
          ),
          const Divider(color: AuraColors.borderMuted, height: 1),
          _OptionTile(
            icon: LucideIcons.trash2,
            title: 'Delete task',
            textColor: AuraColors.accentRed,
            iconColor: AuraColors.accentRed,
            onTap: () async {
              Navigator.pop(context);
              final confirm = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  backgroundColor: AuraColors.bgElevated,
                  title: const Text('Delete Task?', style: TextStyle(color: AuraColors.textPrimary)),
                  content: const Text(
                    'Are you sure you want to delete this task? You can undo within 5 seconds.',
                    style: TextStyle(color: AuraColors.textSecondary),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text('CANCEL'),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      style: ElevatedButton.styleFrom(backgroundColor: AuraColors.accentRed),
                      child: const Text('DELETE', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              );

              if (confirm == true && context.mounted) {
                await ref
                    .read(taskDetailActionProvider.notifier)
                    .softDeleteTask(taskId);

                if (context.mounted) {
                  Navigator.pop(context); // Exit detail screen
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Task deleted'),
                      action: SnackBarAction(
                        label: 'UNDO',
                        textColor: AuraColors.accentLime,
                        onPressed: () {
                          ref
                              .read(taskDetailActionProvider.notifier)
                              .restoreTask(taskId);
                        },
                      ),
                      duration: const Duration(seconds: 5),
                    ),
                  );
                }
              }
            },
          ),
        ],
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Color? textColor;
  final Color? iconColor;

  const _OptionTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.textColor,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: iconColor ?? AuraColors.textPrimary, size: 20),
      title: Text(
        title,
        style: AuraTypography.bodyMedium.copyWith(
          color: textColor ?? AuraColors.textPrimary,
        ),
      ),
      onTap: onTap,
    );
  }
}
