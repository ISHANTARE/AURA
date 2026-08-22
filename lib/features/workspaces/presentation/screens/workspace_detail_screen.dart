import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:drift/drift.dart' hide Column;

import '../../../../core/constants/colors.dart';
import '../../../../core/constants/spacing.dart';
import '../../../../core/constants/typography.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../tasks/presentation/widgets/manual_task_sheet.dart';
import '../../../../core/providers/providers.dart';
import '../providers/workspace_providers.dart';

/// Workspace Detail Screen — AURA v2 Redesigned 3-Tab Workspace View
class WorkspaceDetailScreen extends ConsumerWidget {
  const WorkspaceDetailScreen({super.key, required this.workspaceId});

  final String workspaceId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workspaceAsync = ref.watch(workspaceByIdProvider(workspaceId));
    final itemsAsync = ref.watch(workspaceItemsProvider(workspaceId));
    final sharedItemsAsync = ref.watch(workspaceSharedItemsProvider(workspaceId));
    final primaryColor = Theme.of(context).colorScheme.primary;

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

        return itemsAsync.when(
          data: (items) {
            final sharedItems = sharedItemsAsync.value ?? [];
            final nonSharedItems = items.where((i) => i.kind != 'shared' && i.category != 'shared').toList();
            final pendingItems = nonSharedItems.where((i) => i.status != 'completed').toList();
            final completedItems = nonSharedItems.where((i) => i.status == 'completed').toList();

            return DefaultTabController(
              length: 3,
              child: Scaffold(
                backgroundColor: AuraColors.bgBase,
                appBar: AppBar(
                  backgroundColor: AuraColors.bgBase,
                  elevation: 0,
                  leading: IconButton(
                    icon: const Icon(LucideIcons.arrowLeft, color: AuraColors.textPrimary),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  title: Text(workspace.name, style: AuraTypography.screenHeader),
                  bottom: TabBar(
                    indicatorColor: primaryColor,
                    labelColor: primaryColor,
                    unselectedLabelColor: AuraColors.textMuted,
                    labelStyle: AuraTypography.label.copyWith(fontSize: 11, fontWeight: FontWeight.bold),
                    tabs: [
                      Tab(text: 'PENDING (${pendingItems.length})'),
                      Tab(text: 'COMPLETED (${completedItems.length})'),
                      Tab(text: 'SHARED (${sharedItems.length})'),
                    ],
                  ),
                ),
                body: TabBarView(
                  children: [
                    _WorkspaceItemList(
                      items: pendingItems,
                      emptyTitle: 'No pending items',
                      emptySubtitle: 'All caught up! Tap + to create new tasks or reminders for ${workspace.name}.',
                      workspaceName: workspace.name,
                      primaryColor: primaryColor,
                      isCompletedList: false,
                    ),
                    _WorkspaceItemList(
                      items: completedItems,
                      emptyTitle: 'No completed items',
                      emptySubtitle: 'Completed tasks and reminders for ${workspace.name} will appear here.',
                      workspaceName: workspace.name,
                      primaryColor: primaryColor,
                      isCompletedList: true,
                    ),
                    _WorkspaceSharedList(
                      workspaceId: workspaceId,
                      workspaceName: workspace.name,
                      primaryColor: primaryColor,
                    ),
                  ],
                ),
                floatingActionButton: FloatingActionButton(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  onPressed: () => ManualTaskSheet.show(context, workspaceId: workspaceId),
                  child: const Icon(LucideIcons.plus, size: 24),
                ),
              ),
            );
          },
          loading: () => const Scaffold(
            backgroundColor: AuraColors.bgBase,
            body: Center(child: CircularProgressIndicator()),
          ),
          error: (err, _) => Scaffold(
            backgroundColor: AuraColors.bgBase,
            body: Center(child: Text('Error: $err', style: AuraTypography.body)),
          ),
        );
      },
    );
  }
}

class _WorkspaceItemList extends StatelessWidget {
  const _WorkspaceItemList({
    required this.items,
    required this.emptyTitle,
    required this.emptySubtitle,
    required this.workspaceName,
    required this.primaryColor,
    required this.isCompletedList,
  });

  final List<Item> items;
  final String emptyTitle;
  final String emptySubtitle;
  final String workspaceName;
  final Color primaryColor;
  final bool isCompletedList;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return AuraEmptyState(
        icon: isCompletedList ? LucideIcons.checkCircle2 : LucideIcons.folder,
        title: emptyTitle,
        subtitle: emptySubtitle,
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
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(AuraSpacing.md),
            decoration: BoxDecoration(
              color: AuraColors.bgCard,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AuraColors.border, width: 1),
              boxShadow: const [
                BoxShadow(
                  color: AuraColors.shadow,
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                if (isCompletedList)
                  const Padding(
                    padding: EdgeInsets.only(right: 10),
                    child: Icon(LucideIcons.checkCircle2, color: AuraColors.accentGreen, size: 20),
                  ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: AuraTypography.cardTitle.copyWith(
                          color: isCompletedList ? AuraColors.textMuted : AuraColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: primaryColor.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              item.kind.toUpperCase(),
                              style: AuraTypography.label.copyWith(
                                color: primaryColor,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            item.priority.toUpperCase(),
                            style: AuraTypography.overline.copyWith(
                              color: item.priority == 'high'
                                  ? AuraColors.accentRed
                                  : AuraColors.textMuted,
                            ),
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
  }
}

class _WorkspaceSharedList extends ConsumerWidget {
  const _WorkspaceSharedList({
    required this.workspaceId,
    required this.workspaceName,
    required this.primaryColor,
  });

  final String workspaceId;
  final String workspaceName;
  final Color primaryColor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sharedAsync = ref.watch(workspaceSharedItemsProvider(workspaceId));

    return sharedAsync.when(
      data: (items) {
        if (items.isEmpty) {
          return AuraEmptyState(
            icon: LucideIcons.share2,
            title: 'No shared content',
            subtitle:
                'Web links, OCR screenshots, and documents shared to $workspaceName will appear here.',
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(AuraSpacing.md),
          itemCount: items.length,
          separatorBuilder: (_, __) => const SizedBox(height: AuraSpacing.sm),
          itemBuilder: (context, index) {
            final item = items[index];
            final isUrl = item.location != null && (item.location!.startsWith('http://') || item.location!.startsWith('https://'));
            final hasNotes = item.notes != null && item.notes!.isNotEmpty;

            return Container(
              padding: const EdgeInsets.all(AuraSpacing.md),
              decoration: BoxDecoration(
                color: AuraColors.bgCard,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AuraColors.border, width: 1),
                boxShadow: const [
                  BoxShadow(
                    color: AuraColors.shadow,
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: primaryColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          isUrl ? LucideIcons.link : LucideIcons.fileText,
                          color: primaryColor,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          item.title,
                          style: AuraTypography.cardTitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  if (hasNotes) ...[
                    const SizedBox(height: 8),
                    Text(
                      item.notes!,
                      style: AuraTypography.bodySmall.copyWith(color: AuraColors.textSecondary),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton.icon(
                        icon: const Icon(LucideIcons.plus, size: 14),
                        label: const Text('CONVERT TO TASK'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: () async {
                          final itemDao = ref.read(itemDaoProvider);
                          await itemDao.updateItemPartial(
                            ItemsCompanion(
                              id: Value(item.id),
                              kind: const Value('task'),
                              category: const Value('reminder'),
                              updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
                            ),
                          );
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Converted to task in Pending tab!')),
                            );
                          }
                        },
                      ),
                      IconButton(
                        icon: const Icon(LucideIcons.trash2, size: 18, color: AuraColors.textMuted),
                        onPressed: () async {
                          final itemDao = ref.read(itemDaoProvider);
                          await itemDao.softDelete(item.id);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text('Error: $err', style: AuraTypography.body)),
    );
  }
}

