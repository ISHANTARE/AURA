import '../../../../database/app_database.dart';

class SearchResultGroup {
  final List<Item> items;
  final List<Workspace> workspaces;

  SearchResultGroup({
    required this.items,
    required this.workspaces,
  });
}

class SearchUseCase {
  final ItemDao _itemDao;
  final WorkspaceDao _workspaceDao;

  SearchUseCase({
    required ItemDao itemDao,
    required WorkspaceDao workspaceDao,
  })  : _itemDao = itemDao,
        _workspaceDao = workspaceDao;

  Future<SearchResultGroup> execute({
    required String query,
    String? workspaceFilterId,
    String? statusFilter,
  }) async {
    final cleanQuery = query.trim().toLowerCase();
    if (cleanQuery.isEmpty) {
      return SearchResultGroup(items: [], workspaces: []);
    }

    final allItems = await _itemDao.search(cleanQuery);
    final allWorkspaces = await _workspaceDao.getAll();

    final filteredWorkspaces = allWorkspaces.where((w) {
      return w.name.toLowerCase().contains(cleanQuery);
    }).toList();

    return SearchResultGroup(
      items: allItems,
      workspaces: filteredWorkspaces,
    );
  }
}
