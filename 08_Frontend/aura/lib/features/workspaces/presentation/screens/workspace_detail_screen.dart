import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/constants/spacing.dart';
import '../../../../core/constants/typography.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/widgets/empty_state.dart';
import '../providers/workspace_providers.dart';

/// Workspace Detail Screen — AURA v2 Workspace Detail View
class WorkspaceDetailScreen extends ConsumerWidget {
  const WorkspaceDetailScreen({super.key, required this.workspaceId});

  final String workspaceId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workspaceAsync = ref.watch(workspaceByIdProvider(workspaceId));
    final itemsAsync = ref.watch(workspaceItemsProvider(workspaceId));

    return workspaceAsync.when(
      loading: () => const Scaffold(
        backgroundColor: AuraColors.bgBase,
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (err, _) => Scaffold(
        backgroundColor: AuraColors.bgBase,
        body: Center(child: Text('Error: $err', style: AuraTypography.body)),
      ),
      data: (workspace) {
        if (workspace == null) {
          return Scaffold(
            backgroundColor: AuraColors.bgBase,
            body: Center(child: Text('Workspace not found', style: AuraTypography.body)),
          );
        }

        return Scaffold(
          backgroundColor: AuraColors.bgBase,
          appBar: AppBar(
            backgroundColor: AuraColors.bgBase,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(LucideIcons.arrowLeft, color: AuraColors.textPrimary),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: Text(workspace.name.toUpperCase(), style: AuraTypography.screenHeader),
          ),
          body: itemsAsync.when(
            data: (items) {
              if (items.isEmpty) {
                return AuraEmptyState(
                  icon: LucideIcons.folder,
                  title: 'No items in ${workspace.name}',
                  subtitle: 'Tap the AURA orb to capture tasks, reminders, or alarms for this workspace.',
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.all(AuraSpacing.md),
                itemCount: items.length,
                separatorBuilder: (_, __) => const SizedBox(height: AuraSpacing.sm),
                itemBuilder: (context, index) {
                  final item = items[index];
                  return InkWell(
                    onTap: () => context.push(Routes.taskRoute(item.id)),
                    child: Container(
                      padding: const EdgeInsets.all(AuraSpacing.md),
                      decoration: BoxDecoration(
                        color: AuraColors.bgCard,
                        border: Border.all(color: AuraColors.border, width: AuraSpacing.borderWidth),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black,
                            offset: Offset(4, 4),
                            blurRadius: 0,
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(item.title, style: AuraTypography.cardTitle),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: AuraColors.accentLime.withValues(alpha: 0.15),
                                        border: Border.all(color: AuraColors.accentLime, width: 1),
                                      ),
                                      child: Text(
                                        item.kind.toUpperCase(),
                                        style: AuraTypography.labelLime.copyWith(fontSize: 10),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      item.priority.toUpperCase(),
                                      style: AuraTypography.overline,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const Icon(LucideIcons.chevronRight, color: AuraColors.textSecondary, size: 20),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, _) => Center(child: Text('Error: $err', style: AuraTypography.body)),
          ),
        );
      },
    );
  }
}
