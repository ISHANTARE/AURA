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

    final bg = AuraColors.bgOf(context);
    final cardBg = AuraColors.cardOf(context);
    final borderColor = AuraColors.borderOf(context);
    final textPrimary = AuraColors.textPrimaryOf(context);
    final textSecondary = AuraColors.textSecondaryOf(context);
    final isDark = AuraColors.isDarkMode(context);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: Text('WORKSPACES', style: AuraTypography.screenHeader.copyWith(color: textPrimary)),
        backgroundColor: bg,
        elevation: 0,
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
              final wsColor =
                  hexToColor(ws.colorHex, fallback: primaryColor);

              return InkWell(
                onTap: () => context.push('/workspace/${ws.id}'),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: borderColor, width: 1),
                    boxShadow: [
                      BoxShadow(
                        color: isDark ? AuraColors.shadow : AuraColors.lightShadow,
                        blurRadius: 12,
                        spreadRadius: 0,
                        offset: const Offset(0, 4),
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
                              style: AuraTypography.cardTitle.copyWith(color: textPrimary),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '$count ${count == 1 ? 'item' : 'items'}',
                              style: AuraTypography.caption.copyWith(color: textSecondary),
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
