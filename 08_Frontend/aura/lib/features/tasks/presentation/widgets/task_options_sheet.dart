import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/constants/spacing.dart';
import '../../../../core/constants/typography.dart';
import '../../../../core/providers/providers.dart';

/// Task Options Bottom Sheet (Share / Duplicate / Move / Delete)
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
    final itemDao = ref.watch(itemDaoProvider);
    final workspacesAsync = ref.watch(workspacesListProvider);

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
              Expanded(
                child: Text(
                  taskTitle,
                  style: AuraTypography.screenHeader,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                icon: const Icon(LucideIcons.x, color: AuraColors.textPrimary),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const SizedBox(height: AuraSpacing.xs),
          const Divider(color: AuraColors.borderMuted, height: 1),
          const SizedBox(height: AuraSpacing.sm),

          // 1. Share Item
          _OptionTile(
            icon: LucideIcons.share2,
            title: 'Share Item',
            subtitle: 'Share item title via device apps',
            onTap: () async {
              HapticFeedback.lightImpact();
              Navigator.of(context).pop();
              await Clipboard.setData(ClipboardData(text: 'AURA Task: $taskTitle'));
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Task copied to clipboard!'),
                    duration: Duration(seconds: 2),
                  ),
                );
              }
            },
          ),

          // 2. Duplicate Item
          _OptionTile(
            icon: LucideIcons.copy,
            title: 'Duplicate Item',
            subtitle: 'Create a copy of this task',
            onTap: () async {
              HapticFeedback.mediumImpact();
              Navigator.of(context).pop();
              final newId = await itemDao.duplicateItem(taskId);
              if (context.mounted && newId != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Item duplicated!'),
                    duration: Duration(seconds: 2),
                  ),
                );
              }
            },
          ),

          // 3. Move Workspace
          _OptionTile(
            icon: LucideIcons.folderInput,
            title: 'Move Workspace',
            subtitle: 'Re-assign task to a different workspace',
            onTap: () {
              Navigator.of(context).pop();
              workspacesAsync.whenData((workspaces) {
                _showMoveWorkspaceDialog(context, itemDao, workspaces);
              });
            },
          ),

          // 4. Delete Item
          _OptionTile(
            icon: LucideIcons.trash2,
            title: 'Delete Item',
            subtitle: 'Soft delete item from workspace',
            iconColor: AuraColors.accentRed,
            titleColor: AuraColors.accentRed,
            onTap: () {
              Navigator.of(context).pop();
              _showDeleteConfirmationDialog(context, itemDao);
            },
          ),

          const SizedBox(height: AuraSpacing.sm),
        ],
      ),
    );
  }

  void _showMoveWorkspaceDialog(
    BuildContext context,
    ItemDao itemDao,
    List<Workspace> workspaces,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AuraColors.bgCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text('MOVE TO WORKSPACE', style: AuraTypography.screenHeader),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: workspaces
              .map(
                (ws) => ListTile(
                  title: Text(ws.name, style: AuraTypography.cardTitle),
                  subtitle: Text(ws.colorHex, style: AuraTypography.bodySmall),
                  onTap: () async {
                    HapticFeedback.lightImpact();
                    await itemDao.updateWorkspace(taskId, ws.id);
                    if (ctx.mounted) {
                      Navigator.of(ctx).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Moved to "${ws.name}"'),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    }
                  },
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, ItemDao itemDao) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AuraColors.bgCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text('DELETE TASK?', style: AuraTypography.screenHeader),
        content: Text(
          'Are you sure you want to delete "$taskTitle"? It will be moved to trash.',
          style: AuraTypography.body,
        ),
        actions: [
          TextButton(
            child: Text('CANCEL', style: AuraTypography.buttonSecondary),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AuraColors.accentRed,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text('DELETE',
                style: AuraTypography.buttonPrimary
                    .copyWith(color: Colors.white)),
            onPressed: () async {
              HapticFeedback.mediumImpact();
              await itemDao.softDelete(taskId);
              if (ctx.mounted) {
                Navigator.of(ctx).pop();
                if (context.mounted) {
                  Navigator.of(context).pop(); // pop detail screen
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Task deleted'),
                      duration: Duration(seconds: 2),
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
  const _OptionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.iconColor = AuraColors.textPrimary,
    this.titleColor = AuraColors.textPrimary,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Color iconColor;
  final Color titleColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        onTap: onTap,
        tileColor: AuraColors.bgCard,
        shape: const RoundedRectangleBorder(
          side: BorderSide(color: AuraColors.border, width: 1),
        ),
        leading: Icon(icon, color: iconColor, size: 20),
        title: Text(title,
            style: AuraTypography.cardTitle.copyWith(color: titleColor)),
        subtitle: Text(subtitle, style: AuraTypography.bodySmall),
        trailing: const Icon(LucideIcons.chevronRight,
            color: AuraColors.textSecondary, size: 16),
      ),
    );
  }
}
