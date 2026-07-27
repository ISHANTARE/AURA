import '../../../../database/app_database.dart';
import '../../../../database/daos/task_dao.dart';
import '../../../../database/daos/workspace_dao.dart';

class SearchResultGroup {
  final List<Task> tasks;
  final List<Workspace> workspaces;

  SearchResultGroup({
    required this.tasks,
    required this.workspaces,
  });
}

class SearchUseCase {
  final TaskDao _taskDao;
  final WorkspaceDao _workspaceDao;

  SearchUseCase({
    required TaskDao taskDao,
    required WorkspaceDao workspaceDao,
  })  : _taskDao = taskDao,
        _workspaceDao = workspaceDao;

  Future<SearchResultGroup> execute({
    required String query,
    String? workspaceFilterId,
    String? statusFilter,
  }) async {
    final cleanQuery = query.trim().toLowerCase();
    if (cleanQuery.isEmpty) {
      return SearchResultGroup(tasks: [], workspaces: []);
    }

    final allTasks = await _taskDao.getAll();
    final allWorkspaces = await _workspaceDao.getAll();

    final filteredWorkspaces = allWorkspaces.where((w) {
      return w.name.toLowerCase().contains(cleanQuery);
    }).toList();

    final filteredTasks = allTasks.where((t) {
      final matchesQuery = t.name.toLowerCase().contains(cleanQuery) ||
          (t.description != null && t.description!.toLowerCase().contains(cleanQuery)) ||
          (t.aiRawTranscript != null && t.aiRawTranscript!.toLowerCase().contains(cleanQuery));

      if (!matchesQuery) return false;

      if (workspaceFilterId != null && workspaceFilterId.isNotEmpty) {
        if (t.workspaceId != workspaceFilterId) return false;
      }

      if (statusFilter != null && statusFilter.isNotEmpty) {
        if (statusFilter == 'overdue') {
          final now = DateTime.now().millisecondsSinceEpoch;
          if (t.deadline == null || t.deadline! > now || t.status == 'done') return false;
        } else if (t.status != statusFilter) {
          return false;
        }
      }

      return true;
    }).toList();

    return SearchResultGroup(
      tasks: filteredTasks,
      workspaces: filteredWorkspaces,
    );
  }
}
