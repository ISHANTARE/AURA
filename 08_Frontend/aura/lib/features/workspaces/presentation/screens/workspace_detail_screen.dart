import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/constants/spacing.dart';
import '../../../../core/constants/typography.dart';
import '../../../../core/providers/providers.dart';
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

        return Scaffold(
          backgroundColor: AuraColors.bgBase,
          appBar: AppBar(
            backgroundColor: AuraColors.bgBase,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(LucideIcons.arrowLeft, color: AuraColors.textPrimary),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: Text(workspace.name, style: AuraTypography.screenHeader),
          ),
          body: itemsAsync.when(
            data: (items) {
              if (items.isEmpty) {
                return AuraEmptyState(
                  icon: LucideIcons.folder,
                  title: 'No items in ${workspace.name}',
                  subtitle: 'Tap the + button below or tap the AURA orb to capture items for this workspace.',
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
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(item.title, style: AuraTypography.cardTitle),
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
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, _) => Center(child: Text('Error: $err', style: AuraTypography.body)),
          ),
          floatingActionButton: FloatingActionButton(
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            onPressed: () => _showCreateTaskModal(context, ref, workspaceId),
            child: const Icon(LucideIcons.plus, size: 24),
          ),
        );
      },
    );
  }

  void _showCreateTaskModal(BuildContext context, WidgetRef ref, String wsId) {
    final titleCtrl = TextEditingController();
    String selectedPriority = 'medium';

    showModalBottomSheet(
      context: context,
      backgroundColor: AuraColors.bgElevated,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      isScrollControlled: true,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: AuraSpacing.md,
                right: AuraSpacing.md,
                top: AuraSpacing.md,
                bottom: MediaQuery.of(context).viewInsets.bottom + AuraSpacing.md,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('NEW TASK', style: AuraTypography.cardTitle),
                  const SizedBox(height: AuraSpacing.md),
                  TextField(
                    controller: titleCtrl,
                    autofocus: true,
                    style: AuraTypography.bodyPrimary,
                    decoration: InputDecoration(
                      hintText: 'Task title...',
                      filled: true,
                      fillColor: AuraColors.bgCard,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AuraColors.border),
                      ),
                    ),
                  ),
                  const SizedBox(height: AuraSpacing.md),
                  Row(
                    children: [
                      Text('PRIORITY: ', style: AuraTypography.label),
                      const SizedBox(width: 8),
                      ...['low', 'medium', 'high'].map((p) {
                        final isSel = selectedPriority == p;
                        return Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: ChoiceChip(
                            label: Text(p.toUpperCase()),
                            selected: isSel,
                            onSelected: (_) => setModalState(() => selectedPriority = p),
                          ),
                        );
                      }),
                    ],
                  ),
                  const SizedBox(height: AuraSpacing.lg),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () async {
                        final title = titleCtrl.text.trim();
                        if (title.isEmpty) return;

                        final itemDao = ref.read(itemDaoProvider);
                        final nowEpoch = DateTime.now().millisecondsSinceEpoch;

                        await itemDao.insertItem(
                          ItemsCompanion.insert(
                            id: 'task_$nowEpoch',
                            workspaceId: Value(wsId),
                            title: title,
                            category: 'reminder',
                            kind: 'task',
                            priority: Value(selectedPriority),
                            createdAt: nowEpoch,
                            updatedAt: nowEpoch,
                          ),
                        );

                        if (context.mounted) Navigator.pop(context);
                      },
                      child: const Text('CREATE TASK'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

