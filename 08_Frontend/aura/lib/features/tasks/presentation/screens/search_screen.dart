import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/constants/spacing.dart';
import '../../../../core/constants/typography.dart';
import '../../../../core/providers/providers.dart';
import '../../../../core/router/app_router.dart';

enum SearchFilter { all, tasks, events, notes }

/// Instant Reactive Search Screen for AURA v2 (<200ms query speed)
class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Item> _rawResults = [];
  SearchFilter _selectedFilter = SearchFilter.all;
  bool _isLoading = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _rawResults = [];
        _isLoading = false;
      });
      return;
    }

    setState(() => _isLoading = true);

    final itemDao = ref.read(itemDaoProvider);
    final results = await itemDao.search(query.trim());

    if (mounted) {
      setState(() {
        _rawResults = results;
        _isLoading = false;
      });
    }
  }

  List<Item> get _filteredResults {
    switch (_selectedFilter) {
      case SearchFilter.tasks:
        return _rawResults.where((i) => i.kind == 'task').toList();
      case SearchFilter.events:
        return _rawResults.where((i) => i.kind == 'event').toList();
      case SearchFilter.notes:
        return _rawResults
            .where((i) => i.kind == 'generic' || (i.notes != null && i.notes!.isNotEmpty))
            .toList();
      case SearchFilter.all:
        return _rawResults;
    }
  }

  @override
  Widget build(BuildContext context) {
    final results = _filteredResults;
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: AuraColors.bgBase,
      appBar: AppBar(
        backgroundColor: AuraColors.bgBase,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: AuraColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('SEARCH', style: AuraTypography.screenHeader),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AuraSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Input Field
            TextField(
              controller: _searchController,
              autofocus: true,
              style: AuraTypography.bodyPrimary,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Search items, tasks, notes...',
                prefixIcon: Icon(LucideIcons.search, color: primaryColor),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(LucideIcons.x, color: AuraColors.textSecondary),
                        onPressed: () {
                          _searchController.clear();
                          _onSearchChanged('');
                        },
                      )
                    : null,
              ),
            ),
            const SizedBox(height: AuraSpacing.sm),

            // Filter Chips Row
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _FilterChip(
                    label: 'ALL',
                    isSelected: _selectedFilter == SearchFilter.all,
                    onTap: () => setState(() => _selectedFilter = SearchFilter.all),
                  ),
                  const SizedBox(width: 6),
                  _FilterChip(
                    label: 'TASKS',
                    isSelected: _selectedFilter == SearchFilter.tasks,
                    onTap: () => setState(() => _selectedFilter = SearchFilter.tasks),
                  ),
                  const SizedBox(width: 6),
                  _FilterChip(
                    label: 'EVENTS',
                    isSelected: _selectedFilter == SearchFilter.events,
                    onTap: () => setState(() => _selectedFilter = SearchFilter.events),
                  ),
                  const SizedBox(width: 6),
                  _FilterChip(
                    label: 'NOTES',
                    isSelected: _selectedFilter == SearchFilter.notes,
                    onTap: () => setState(() => _selectedFilter = SearchFilter.notes),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AuraSpacing.md),

            // Result Header Badge
            if (_searchController.text.isNotEmpty && !_isLoading) ...[
              Text(
                'RESULTS (${results.length})',
                style: AuraTypography.label.copyWith(
                  color: primaryColor,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: AuraSpacing.xs),
            ],

            // Results List / Loading / Empty State
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : (results.isEmpty
                      ? Center(
                          child: Text(
                            _searchController.text.isEmpty
                                ? 'Type keywords to search AURA...'
                                : 'No matching items found.',
                            style: AuraTypography.body,
                          ),
                        )
                      : ListView.separated(
                          itemCount: results.length,
                          separatorBuilder: (_, __) => const SizedBox(height: AuraSpacing.sm),
                          itemBuilder: (context, index) {
                            final item = results[index];
                            return GestureDetector(
                              onTap: () => context.push(Routes.taskRoute(item.id)),
                              child: Container(
                                padding: const EdgeInsets.all(AuraSpacing.md),
                                decoration: BoxDecoration(
                                  color: AuraColors.bgCard,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: AuraColors.border, width: 1),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: AuraColors.shadow,
                                      blurRadius: 10,
                                      offset: Offset(0, 3),
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
                                          Text(
                                            '${item.category.toUpperCase()} · ${item.kind.toUpperCase()}',
                                            style: AuraTypography.label.copyWith(
                                              color: primaryColor,
                                              fontSize: 10,
                                            ),
                                          ),
                                          if (item.notes != null && item.notes!.isNotEmpty) ...[
                                            const SizedBox(height: 4),
                                            Text(
                                              item.notes!,
                                              style: AuraTypography.bodySmall,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                    const Icon(LucideIcons.chevronRight,
                                        color: AuraColors.textSecondary, size: 18),
                                  ],
                                ),
                              ),
                            );
                          },
                        )),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? primary : AuraColors.bgCard,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? primary : AuraColors.border,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: AuraTypography.label.copyWith(
            color: isSelected ? Colors.white : AuraColors.textSecondary,
            fontWeight: FontWeight.bold,
            fontSize: 10,
          ),
        ),
      ),
    );
  }
}
