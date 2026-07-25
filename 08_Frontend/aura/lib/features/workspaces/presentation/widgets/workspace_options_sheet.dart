import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/constants/icons.dart';
import '../../../../core/constants/typography.dart';
import '../../../../database/app_database.dart';
import '../providers/workspace_providers.dart';
import 'create_workspace_modal.dart';

/// Context menu options bottom sheet for Workspace actions (Edit, Archive, Delete).
class WorkspaceOptionsSheet extends ConsumerWidget {
  final Workspace workspace;

  const WorkspaceOptionsSheet({super.key, required this.workspace});

  static Future<void> show(BuildContext context, Workspace workspace) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => WorkspaceOptionsSheet(workspace: workspace),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(workspaceActionNotifierProvider.notifier);

    return Container(
      decoration: const BoxDecoration(
        color: AuraColors.bgElevated,
        border: Border(
          top: BorderSide(color: AuraColors.border, width: 2.0),
          left: BorderSide(color: AuraColors.border, width: 2.0),
          right: BorderSide(color: AuraColors.border, width: 2.0),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Row(
            children: [
              Icon(
                AuraIcons.forWorkspace(workspace.name),
                color: AuraColors.accentLime,
                size: AuraIcons.sizeStandard,
              ),
              const SizedBox(width: 10.0),
              Text(
                workspace.name.toUpperCase(),
                style: AuraTypography.cardTitle.copyWith(letterSpacing: 1.0),
              ),
            ],
          ),

          const SizedBox(height: 16.0),
          const Divider(color: AuraColors.borderMuted, height: 1.0),
          const SizedBox(height: 12.0),

          // Option: Edit
          ListTile(
            leading: const Icon(AuraIcons.edit, color: AuraColors.textPrimary),
            title: Text('Edit Workspace', style: AuraTypography.bodyMedium),
            onTap: () {
              Navigator.of(context).pop();
              CreateWorkspaceModal.show(context, workspace: workspace);
            },
          ),

          // Option: Archive / Unarchive
          if (workspace.isArchived)
            ListTile(
              leading: const Icon(AuraIcons.archive, color: AuraColors.accentLime),
              title: Text('Unarchive Workspace', style: AuraTypography.bodyMedium),
              onTap: () async {
                Navigator.of(context).pop();
                await notifier.unarchiveWorkspace(workspace.id);
              },
            )
          else
            ListTile(
              leading: const Icon(AuraIcons.archive, color: AuraColors.accentOrange),
              title: Text('Archive Workspace', style: AuraTypography.bodyMedium),
              onTap: () async {
                Navigator.of(context).pop();
                await notifier.archiveWorkspace(workspace.id);
              },
            ),

          // Option: Delete
          ListTile(
            leading: const Icon(AuraIcons.delete, color: AuraColors.accentRed),
            title: Text(
              'Delete Workspace',
              style: AuraTypography.bodyMedium.copyWith(color: AuraColors.accentRed),
            ),
            onTap: () async {
              Navigator.of(context).pop();
              await notifier.archiveWorkspace(workspace.id);
            },
          ),
        ],
      ),
    );
  }
}
