import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/constants/spacing.dart';
import '../../../../core/constants/typography.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../home/presentation/providers/home_providers.dart';
import '../widgets/create_workspace_modal.dart';

/// Workspace List Screen — AURA v2 Workspaces 2-Column Grid Layout
class WorkspaceListScreen extends ConsumerWidget {
  const WorkspaceListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workspacesAsync = ref.watch(workspacesListProvider);
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: AuraColors.bgBase,
      appBar: AppBar(
        title: Text('WORKSPACES', style: AuraTypography.screenHeader),
        backgroundColor: AuraColors.bgBase,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(LucideIcons.plus, color: primaryColor),
            onPressed: () => CreateWorkspaceModal.show(context),
          ),
        ],
      ),
      body: workspacesAsync.when(
        data: (workspaces) {
          if (workspaces.isEmpty) {
            return const AuraEmptyState(
              icon: LucideIcons.layoutGrid,
              title: 'No Workspaces',
              subtitle: 'Workspaces organize your life into distinct contexts (e.g. Prep, VIT, Personal).',
            );
          }
          return GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.05,
            padding: const EdgeInsets.all(AuraSpacing.md),
            children: workspaces.map((ws) {
              final countAsync = ref.watch(workspaceItemCountProvider(ws.id));
              final count = countAsync.value ?? 0;
              Color wsColor;
              try {
                final clean = ws.colorHex.replaceFirst('#', '');
                wsColor = Color(int.parse('FF$clean', radix: 16));
              } catch (_) {
                wsColor = primaryColor;
              }

              return InkWell(
                onTap: () => context.push('/workspace/${ws.id}'),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  decoration: BoxDecoration(
                    color: AuraColors.bgCard,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AuraColors.border, width: 1),
                    boxShadow: const [
                      BoxShadow(
                        color: AuraColors.shadow,
                        blurRadius: 12,
                        spreadRadius: 0,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Top color stripe accent
                      Container(
                        height: 6,
                        decoration: BoxDecoration(
                          color: wsColor,
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(AuraSpacing.md),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: wsColor.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(LucideIcons.folder, color: wsColor, size: 20),
                            ),
                            const SizedBox(height: AuraSpacing.sm),
                            Text(
                              ws.name,
                              style: AuraTypography.cardTitle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '$count ${count == 1 ? 'item' : 'items'}',
                              style: AuraTypography.caption,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err', style: AuraTypography.body)),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        onPressed: () => CreateWorkspaceModal.show(context),
        child: const Icon(LucideIcons.plus, size: 24),
      ),
    );
  }
}

