import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import 'package:aura/core/constants/colors.dart';
import 'package:aura/core/constants/typography.dart';
import 'package:aura/core/router/app_router.dart';
import 'package:aura/database/daos/task_dao.dart';
import 'package:aura/database/daos/workspace_dao.dart';
import 'package:aura/features/tasks/domain/usecases/search_usecase.dart';

final searchUseCaseProvider = Provider<SearchUseCase>((ref) {
  return SearchUseCase(
    taskDao: ref.watch(taskDaoProvider),
    workspaceDao: ref.watch(workspaceDaoProvider),
  );
});

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  String? _selectedStatus;
  SearchResultGroup? _results;
  bool _isLoading = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String val) async {
    setState(() {
      _query = val;
      _isLoading = true;
    });

    final useCase = ref.read(searchUseCaseProvider);
    final results = await useCase.execute(
      query: val,
      statusFilter: _selectedStatus,
    );

    if (mounted) {
      setState(() {
        _results = results;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AuraColors.bgBase,
      appBar: AppBar(
        backgroundColor: AuraColors.bgBase,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: AuraColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('SEARCH', style: AuraTypography.screenHeader),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Input Box
            TextField(
              controller: _searchController,
              autofocus: true,
              style: AuraTypography.bodyPrimary,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Search tasks, notes, workspaces...',
                hintStyle: const TextStyle(color: AuraColors.textDisabled),
                prefixIcon: const Icon(LucideIcons.search, color: AuraColors.accentLime),
                suffixIcon: _query.isNotEmpty
                    ? IconButton(
                        icon: const Icon(LucideIcons.x, color: AuraColors.textSecondary),
                        onPressed: () {
                          _searchController.clear();
                          _onSearchChanged('');
                        },
                      )
                    : null,
                filled: true,
                fillColor: AuraColors.bgCard,
                enabledBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: AuraColors.border, width: 1.5),
                  borderRadius: BorderRadius.zero,
                ),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: AuraColors.accentLime, width: 2),
                  borderRadius: BorderRadius.zero,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Status Filter Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _FilterChip(
                    label: 'ALL',
                    isSelected: _selectedStatus == null,
                    onTap: () {
                      setState(() => _selectedStatus = null);
                      _onSearchChanged(_query);
                    },
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: 'ACTIVE',
                    isSelected: _selectedStatus == 'todo',
                    onTap: () {
                      setState(() => _selectedStatus = 'todo');
                      _onSearchChanged(_query);
                    },
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: 'OVERDUE 🔴',
                    isSelected: _selectedStatus == 'overdue',
                    onTap: () {
                      setState(() => _selectedStatus = 'overdue');
                      _onSearchChanged(_query);
                    },
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: 'DONE',
                    isSelected: _selectedStatus == 'done',
                    onTap: () {
                      setState(() => _selectedStatus = 'done');
                      _onSearchChanged(_query);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Search Results View
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: AuraColors.accentLime))
                  : (_query.trim().isEmpty
                      ? Center(
                          child: Text(
                            'Type keywords to search AURA...',
                            style: AuraTypography.bodySmall,
                          ),
                        )
                      : (_results == null || (_results!.tasks.isEmpty && _results!.workspaces.isEmpty)
                          ? Center(
                              child: Text(
                                'No matching tasks or workspaces found',
                                style: AuraTypography.bodySmall,
                              ),
                            )
                          : ListView(
                              children: [
                                // Workspace Results
                                if (_results!.workspaces.isNotEmpty) ...[
                                  Text(
                                    'WORKSPACES',
                                    style: AuraTypography.bentoMetricLabel.copyWith(color: AuraColors.textSecondary),
                                  ),
                                  const SizedBox(height: 8),
                                  ..._results!.workspaces.map((ws) => Card(
                                        color: AuraColors.bgCard,
                                        margin: const EdgeInsets.only(bottom: 8),
                                        shape: const RoundedRectangleBorder(
                                          side: BorderSide(color: AuraColors.borderMuted),
                                        ),
                                        child: ListTile(
                                          leading: const Icon(LucideIcons.folder, color: AuraColors.accentLime),
                                          title: Text(ws.name, style: AuraTypography.cardTitle),
                                          trailing: const Icon(LucideIcons.chevronRight, color: AuraColors.textSecondary),
                                          onTap: () {
                                            context.push(Routes.workspaceRoute(ws.id));
                                          },
                                        ),
                                      )),
                                  const SizedBox(height: 16),
                                ],

                                // Task Results
                                if (_results!.tasks.isNotEmpty) ...[
                                  Text(
                                    'TASKS (${_results!.tasks.length})',
                                    style: AuraTypography.bentoMetricLabel.copyWith(color: AuraColors.textSecondary),
                                  ),
                                  const SizedBox(height: 8),
                                  ..._results!.tasks.map((task) => Card(
                                        color: AuraColors.bgCard,
                                        margin: const EdgeInsets.only(bottom: 8),
                                        shape: const RoundedRectangleBorder(
                                          side: BorderSide(color: AuraColors.border),
                                        ),
                                        child: ListTile(
                                          leading: Icon(
                                            task.status == 'done'
                                                ? LucideIcons.checkCircle2
                                                : LucideIcons.circle,
                                            color: task.status == 'done'
                                                ? AuraColors.accentGreen
                                                : AuraColors.textSecondary,
                                          ),
                                          title: Text(
                                            task.name,
                                            style: AuraTypography.bodyPrimary.copyWith(
                                              decoration: task.status == 'done' ? TextDecoration.lineThrough : null,
                                            ),
                                          ),
                                          subtitle: task.description != null
                                              ? Text(
                                                  task.description!,
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                  style: AuraTypography.bodySmall,
                                                )
                                              : null,
                                          trailing: const Icon(LucideIcons.chevronRight, color: AuraColors.textSecondary),
                                          onTap: () {
                                            context.push(Routes.taskRoute(task.id));
                                          },
                                        ),
                                      )),
                                ],
                              ],
                            ))),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AuraColors.accentLime : AuraColors.bgCard,
          border: Border.all(
            color: isSelected ? AuraColors.accentLime : AuraColors.borderMuted,
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: AuraTypography.badgeText.copyWith(
            color: isSelected ? AuraColors.textOnAccent : AuraColors.textPrimary,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
