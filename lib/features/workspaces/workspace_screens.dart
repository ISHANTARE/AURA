import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:uuid/uuid.dart';

import '../../../core/constants/colors.dart';
import '../../../core/constants/spacing.dart';
import '../../../core/constants/typography.dart';
import '../../../core/providers/database_provider.dart';
import '../../../core/widgets/aura_widgets.dart';
import '../../../database/app_database.dart';
import '../home/home_screen.dart' show dayAgendaProvider;

// ── Providers ─────────────────────────────────────────────────────────────────

final workspaceListProvider = StreamProvider<List<Workspace>>((ref) {
  return ref.watch(workspaceDaoProvider).watchAll();
});

final workspaceItemCountProvider = FutureProvider.family<int, String>((ref, wsId) async {
  final dao = ref.watch(itemDaoProvider);
  final all = await dao.watchAllActive().first;
  return all.where((i) => i.workspaceId == wsId && i.status == 'pending' && i.parentId == null).length;
});

// ── Workspace List Screen ─────────────────────────────────────────────────────

class WorkspaceListScreen extends ConsumerStatefulWidget {
  const WorkspaceListScreen({super.key});

  @override
  ConsumerState<WorkspaceListScreen> createState() => _WorkspaceListScreenState();
}

class _WorkspaceListScreenState extends ConsumerState<WorkspaceListScreen> {
  String _searchQuery = '';
  final bool _showArchived = false;

  @override
  Widget build(BuildContext context) {
    final workspacesAsync = ref.watch(workspaceListProvider);

    return Scaffold(
      backgroundColor: AuraColors.bgBase,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(AuraSpacing.md, AuraSpacing.md, AuraSpacing.md, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Text('Workspaces', style: AuraTypography.sectionHeader.copyWith(color: AuraColors.textPrimary)),
                  ),
                  AuraButton(
                    label: 'NEW',
                    icon: LucideIcons.plus,
                    variant: AuraButtonVariant.outline,
                    onPressed: () => _showCreateWorkspaceDialog(context),
                  ),
                ],
              ),
            ),

            // Search bar
            Padding(
              padding: const EdgeInsets.all(AuraSpacing.md),
              child: BentoCard(
                padding: const EdgeInsets.symmetric(horizontal: AuraSpacing.sm, vertical: AuraSpacing.xs),
                child: Row(
                  children: [
                    const Icon(LucideIcons.search, size: 16, color: AuraColors.textMuted),
                    const SizedBox(width: AuraSpacing.sm),
                    Expanded(
                      child: TextField(
                        onChanged: (v) => setState(() => _searchQuery = v),
                        style: AuraTypography.body.copyWith(color: AuraColors.textPrimary),
                        decoration: InputDecoration(
                          hintText: 'Search workspaces...',
                          hintStyle: AuraTypography.body.copyWith(color: AuraColors.textMuted),
                          border: InputBorder.none,
                          isDense: true,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Workspace grid
            Expanded(
              child: workspacesAsync.when(
                data: (workspaces) {
                  final filtered = workspaces
                      .where((w) =>
                          w.isArchived == _showArchived &&
                          (w.deletedAt == null) &&
                          (_searchQuery.isEmpty || w.name.toLowerCase().contains(_searchQuery.toLowerCase())))
                      .toList();

                  if (filtered.isEmpty) {
                    return _EmptyWorkspacesState(onAdd: () => _showCreateWorkspaceDialog(context));
                  }

                  return GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: AuraSpacing.md),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: AuraSpacing.sm,
                      mainAxisSpacing: AuraSpacing.sm,
                      childAspectRatio: 0.9,
                    ),
                    itemCount: filtered.length,
                    itemBuilder: (_, i) => _WorkspaceCard(workspace: filtered[i]),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Error: $e', style: const TextStyle(color: AuraColors.accentRed))),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCreateWorkspaceDialog(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _CreateWorkspaceSheet(),
    );
  }
}

// ── Workspace Card ────────────────────────────────────────────────────────────

class _WorkspaceCard extends ConsumerWidget {
  final Workspace workspace;
  const _WorkspaceCard({required this.workspace});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final countAsync = ref.watch(workspaceItemCountProvider(workspace.id));
    final hexStr = workspace.colorHex ?? '#C8FF00';
    final color = Color(int.parse(hexStr.replaceFirst('#', '0xFF')));

    return BentoCard(
      borderColor: color.withOpacity(0.3),
      onTap: () => context.push('/workspace/${workspace.id}'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(AuraRadius.sm),
                ),
                child: Icon(_iconFor(workspace.iconKey ?? 'folder'), size: 16, color: color),
              ),
              const Spacer(),
              PopupMenuButton<String>(
                icon: const Icon(LucideIcons.moreVertical, size: 16, color: AuraColors.textMuted),
                color: AuraColors.bgElevated,
                itemBuilder: (_) => [
                  const PopupMenuItem(value: 'archive', child: Text('Archive')),
                  const PopupMenuItem(value: 'delete', child: Text('Delete', style: TextStyle(color: AuraColors.accentRed))),
                ],
                onSelected: (v) async {
                  final dao = ref.read(workspaceDaoProvider);
                  if (v == 'archive') {
                    await dao.archiveWorkspace(workspace.id, true, DateTime.now().millisecondsSinceEpoch);
                  } else if (v == 'delete') {
                    await dao.softDeleteWorkspace(workspace.id, DateTime.now().millisecondsSinceEpoch);
                  }
                },
              ),
            ],
          ),
          const Spacer(),
          Container(height: 2, width: 32, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(AuraRadius.full))),
          const SizedBox(height: AuraSpacing.xs),
          Text(
            workspace.name,
            style: AuraTypography.cardTitle.copyWith(color: AuraColors.textPrimary),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          countAsync.when(
            data: (c) => Text('$c tasks', style: AuraTypography.caption.copyWith(color: AuraColors.textMuted)),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  IconData _iconFor(String key) => switch (key) {
        'book' => LucideIcons.book,
        'code' => LucideIcons.code2,
        'briefcase' => LucideIcons.briefcase,
        'user' => LucideIcons.user,
        'graduationCap' => LucideIcons.graduationCap,
        _ => LucideIcons.folder,
      };
}

// ── Create Workspace Sheet ────────────────────────────────────────────────────

class _CreateWorkspaceSheet extends ConsumerStatefulWidget {
  const _CreateWorkspaceSheet();

  @override
  ConsumerState<_CreateWorkspaceSheet> createState() => _CreateWorkspaceSheetState();
}

class _CreateWorkspaceSheetState extends ConsumerState<_CreateWorkspaceSheet> {
  final _nameController = TextEditingController();
  String _selectedColor = '#C8FF00';
  final _colors = ['#C8FF00', '#00D4FF', '#FF6B6B', '#A78BFA', '#34D399', '#FBBF24'];
  bool _isSaving = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      decoration: const BoxDecoration(
        color: AuraColors.bgElevated,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AuraRadius.xl)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AuraSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('New Workspace', style: AuraTypography.cardTitle.copyWith(color: AuraColors.textPrimary, fontWeight: FontWeight.w700)),
            const SizedBox(height: AuraSpacing.md),
            TextField(
              controller: _nameController,
              autofocus: true,
              style: AuraTypography.body.copyWith(color: AuraColors.textPrimary),
              decoration: InputDecoration(
                labelText: 'Workspace Name',
                labelStyle: AuraTypography.caption.copyWith(color: AuraColors.textMuted),
                filled: true,
                fillColor: AuraColors.bgSubtle,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(AuraRadius.sm), borderSide: const BorderSide(color: AuraColors.border)),
              ),
            ),
            const SizedBox(height: AuraSpacing.md),
            Text('Accent Color', style: AuraTypography.caption.copyWith(color: AuraColors.textMuted)),
            const SizedBox(height: AuraSpacing.xs),
            Wrap(
              spacing: 8,
              children: _colors.map((c) {
                final color = Color(int.parse(c.replaceFirst('#', '0xFF')));
                return GestureDetector(
                  onTap: () => setState(() => _selectedColor = c),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    width: 32, height: 32,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _selectedColor == c ? Colors.white : Colors.transparent,
                        width: 2.5,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: AuraSpacing.lg),
            AuraButton(
              label: 'CREATE WORKSPACE',
              fullWidth: true,
              isLoading: _isSaving,
              onPressed: _create,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _create() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;
    setState(() => _isSaving = true);
    final dao = ref.read(workspaceDaoProvider);
    await dao.insertWorkspace(WorkspacesCompanion.insert(
      id: const Uuid().v4(),
      name: name,
      colorHex: drift.Value(_selectedColor),
      sortOrder: const drift.Value(0),
      createdAt: DateTime.now().millisecondsSinceEpoch,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
    ));
    if (mounted) Navigator.pop(context);
  }
}

// ── Workspace Detail Screen ───────────────────────────────────────────────────

class WorkspaceDetailScreen extends ConsumerWidget {
  final String workspaceId;
  const WorkspaceDetailScreen({super.key, required this.workspaceId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workspacesAsync = ref.watch(workspaceListProvider);
    final itemsAsync = ref.watch(dayAgendaProvider(DateTime.now()));

    return workspacesAsync.when(
      data: (workspaces) {
        final ws = workspaces.where((w) => w.id == workspaceId).firstOrNull;
        if (ws == null) {
          return const Scaffold(
            backgroundColor: AuraColors.bgBase,
            body: Center(child: Text('Workspace not found', style: TextStyle(color: AuraColors.textMuted))),
          );
        }

        final hexStr = ws.colorHex ?? '#C8FF00';
        final color = Color(int.parse(hexStr.replaceFirst('#', '0xFF')));

        return Scaffold(
          backgroundColor: AuraColors.bgBase,
          body: SafeArea(
            child: Column(
              children: [
                // Hero header
                Container(
                  padding: const EdgeInsets.all(AuraSpacing.md),
                  decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(color: color.withOpacity(0.3), width: 1)),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(LucideIcons.arrowLeft, size: 20, color: AuraColors.textSecondary),
                        onPressed: () => context.pop(),
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(AuraRadius.sm),
                        ),
                        child: Icon(LucideIcons.folder, size: 18, color: color),
                      ),
                      const SizedBox(width: AuraSpacing.sm),
                      Expanded(
                        child: Text(ws.name, style: AuraTypography.sectionHeader.copyWith(color: AuraColors.textPrimary)),
                      ),
                      IconButton(
                        icon: const Icon(LucideIcons.settings2, size: 18, color: AuraColors.textSecondary),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ),

                // Items
                Expanded(
                  child: itemsAsync.when(
                    data: (items) {
                      final wsItems = items.where((i) => i.workspaceId == workspaceId).toList();
                      if (wsItems.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(LucideIcons.inbox, size: 40, color: AuraColors.textMuted.withOpacity(0.3)),
                              const SizedBox(height: AuraSpacing.md),
                              Text('No tasks in this workspace', style: AuraTypography.body.copyWith(color: AuraColors.textMuted)),
                              const SizedBox(height: AuraSpacing.md),
                              AuraButton(
                                label: 'ADD TASK',
                                variant: AuraButtonVariant.outline,
                                icon: LucideIcons.plus,
                                onPressed: () => context.push('/capture-overlay'),
                              ),
                            ],
                          ),
                        );
                      }
                      return ListView.builder(
                        padding: const EdgeInsets.all(AuraSpacing.md),
                        itemCount: wsItems.length,
                        itemBuilder: (_, i) {
                          final item = wsItems[i];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: AuraSpacing.xs),
                            child: BentoCard(
                              padding: const EdgeInsets.all(AuraSpacing.sm),
                              onTap: () => context.push('/task/${item.id}'),
                              child: Row(
                                children: [
                                  Container(
                                    width: 20, height: 20,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(color: color, width: 1.5),
                                    ),
                                  ),
                                  const SizedBox(width: AuraSpacing.sm),
                                  Expanded(child: Text(item.title, style: AuraTypography.bodySmall.copyWith(color: AuraColors.textPrimary))),
                                  PriorityBadge(priority: item.priority),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (e, _) => Center(child: Text('$e')),
                  ),
                ),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton(
            backgroundColor: color,
            onPressed: () => context.push('/capture-overlay'),
            child: const Icon(LucideIcons.mic, color: Colors.black),
          ),
        );
      },
      loading: () => const Scaffold(backgroundColor: AuraColors.bgBase, body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(backgroundColor: AuraColors.bgBase, body: Center(child: Text('$e'))),
    );
  }
}

class _EmptyWorkspacesState extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyWorkspacesState({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(LucideIcons.folderPlus, size: 48, color: AuraColors.textMuted.withOpacity(0.3)),
          const SizedBox(height: AuraSpacing.md),
          Text('No workspaces yet', style: AuraTypography.body.copyWith(color: AuraColors.textMuted)),
          const SizedBox(height: AuraSpacing.md),
          AuraButton(label: 'CREATE WORKSPACE', icon: LucideIcons.plus, onPressed: onAdd),
        ],
      ),
    );
  }
}
