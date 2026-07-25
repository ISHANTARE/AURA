import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/constants/icons.dart';
import '../../../../core/constants/typography.dart';
import '../providers/workspace_providers.dart';
import '../widgets/create_workspace_modal.dart';
import '../widgets/workspace_card.dart';
import '../widgets/workspace_options_sheet.dart';

/// Workspace List View matching wireframe 04_workspace_screen.md exactly.
class WorkspaceListScreen extends ConsumerStatefulWidget {
  const WorkspaceListScreen({super.key});

  @override
  ConsumerState<WorkspaceListScreen> createState() =>
      _WorkspaceListScreenState();
}

class _WorkspaceListScreenState extends ConsumerState<WorkspaceListScreen> {
  bool _showArchived = false;

  @override
  Widget build(BuildContext context) {
    final activeAsync = ref.watch(activeWorkspacesWithStatsProvider);
    final archivedAsync = ref.watch(archivedWorkspacesProvider);

    return Scaffold(
      backgroundColor: AuraColors.bgBase,
      body: SafeArea(
        child: Column(
          children: [
            // Header Bar (56dp)
            Container(
              height: 56.0,
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: AuraColors.borderMuted, width: 1.0),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'WORKSPACES',
                    style: AuraTypography.screenHeader.copyWith(
                      letterSpacing: 1.5,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => CreateWorkspaceModal.show(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12.0,
                        vertical: 6.0,
                      ),
                      decoration: BoxDecoration(
                        color: AuraColors.accentLime,
                        borderRadius: BorderRadius.zero,
                        border: Border.all(
                            color: AuraColors.border, width: 2.0),
                        boxShadow: const [
                          BoxShadow(
                            color: AuraColors.shadow,
                            offset: Offset(2, 2),
                            blurRadius: 0,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            AuraIcons.add,
                            size: AuraIcons.sizeInline,
                            color: AuraColors.textOnAccent,
                          ),
                          const SizedBox(width: 4.0),
                          Text(
                            'NEW',
                            style: AuraTypography.buttonText.copyWith(
                              fontSize: 12.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Content Area
            Expanded(
              child: activeAsync.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(
                      color: AuraColors.accentLime),
                ),
                error: (err, _) => Center(
                  child: Text(
                    'Failed to load workspaces: $err',
                    style: AuraTypography.bodySmall
                        .copyWith(color: AuraColors.accentRed),
                  ),
                ),
                data: (items) {
                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Active Workspaces Grid (2 Columns)
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 1.1,
                            crossAxisSpacing: 12.0,
                            mainAxisSpacing: 12.0,
                          ),
                          itemCount: items.length + 1,
                          itemBuilder: (context, index) {
                            if (index < items.length) {
                              final item = items[index];
                              return WorkspaceCard(
                                item: item,
                                onTap: () => context.push(
                                    '/workspace/${item.workspace.id}'),
                                onLongPress: () => WorkspaceOptionsSheet.show(
                                    context, item.workspace),
                              );
                            }
                            // [+ Add workspace] Card
                            return GestureDetector(
                              onTap: () => CreateWorkspaceModal.show(context),
                              child: Container(
                                padding: const EdgeInsets.all(16.0),
                                decoration: BoxDecoration(
                                  color: AuraColors.bgCard,
                                  borderRadius: BorderRadius.zero,
                                  border: Border.all(
                                    color: AuraColors.borderMuted,
                                    width: 2.0,
                                  ),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8.0),
                                      decoration: BoxDecoration(
                                        color: AuraColors.accentLime
                                            .withValues(alpha: 0.1),
                                        border: Border.all(
                                          color: AuraColors.accentLime,
                                          width: 1.5,
                                        ),
                                      ),
                                      child: const Icon(
                                        AuraIcons.add,
                                        size: AuraIcons.sizeStandard,
                                        color: AuraColors.accentLime,
                                      ),
                                    ),
                                    const SizedBox(height: 10.0),
                                    Text(
                                      'Add Workspace',
                                      style:
                                          AuraTypography.cardTitle.copyWith(
                                        fontSize: 14.0,
                                        color: AuraColors.accentLime,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 4.0),
                                    Text(
                                      'Tap to create',
                                      style:
                                          AuraTypography.bodySmall.copyWith(
                                        color: AuraColors.textDisabled,
                                        fontSize: 11.0,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 24.0),

                        // Archived Accordion Section
                        archivedAsync.when(
                          loading: () => const SizedBox.shrink(),
                          error: (_, __) => const SizedBox.shrink(),
                          data: (archived) {
                            if (archived.isEmpty) return const SizedBox.shrink();
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Divider(
                                    color: AuraColors.borderMuted, height: 1.0),
                                const SizedBox(height: 12.0),
                                InkWell(
                                  onTap: () => setState(
                                      () => _showArchived = !_showArchived),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 8.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'ARCHIVED (${archived.length})',
                                          style: AuraTypography.badgeText,
                                        ),
                                        Icon(
                                          _showArchived
                                              ? AuraIcons.priorityLow
                                              : AuraIcons.forward,
                                          size: AuraIcons.sizeInline,
                                          color: AuraColors.textSecondary,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                if (_showArchived)
                                  ListView.builder(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemCount: archived.length,
                                    itemBuilder: (context, index) {
                                      final ws = archived[index];
                                      return ListTile(
                                        contentPadding: EdgeInsets.zero,
                                        leading: Icon(
                                          AuraIcons.forWorkspace(ws.name),
                                          color: AuraColors.textSecondary,
                                        ),
                                        title: Text(
                                          ws.name,
                                          style: AuraTypography.bodyMedium
                                              .copyWith(
                                            color: AuraColors.textSecondary,
                                            decoration:
                                                TextDecoration.lineThrough,
                                          ),
                                        ),
                                        trailing: IconButton(
                                          icon: const Icon(AuraIcons.archive,
                                              color: AuraColors.accentLime),
                                          onPressed: () => ref
                                              .read(workspaceActionNotifierProvider
                                                  .notifier)
                                              .unarchiveWorkspace(ws.id),
                                        ),
                                      );
                                    },
                                  ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
