import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../database/app_database.dart';
import '../../../../database/daos/task_dao.dart';
import '../../../../database/daos/workspace_dao.dart';

/// Watch urgent/overdue tasks.
final urgentTasksProvider = StreamProvider.autoDispose<List<Task>>((ref) {
  final taskDao = ref.watch(taskDaoProvider);
  return taskDao.watchOverdue();
});

/// Watch today's focus tasks (all active tasks).
final focusTasksProvider = StreamProvider.autoDispose<List<Task>>((ref) {
  final taskDao = ref.watch(taskDaoProvider);
  return taskDao.watchAllActive();
});

/// Watch habits (recurring tasks).
final habitsProvider = StreamProvider.autoDispose<List<Task>>((ref) {
  final taskDao = ref.watch(taskDaoProvider);
  return taskDao.watchRecurring();
});

/// Watch workspaces.
final homeWorkspacesProvider = StreamProvider.autoDispose<List<Workspace>>((ref) {
  final wsDao = ref.watch(workspaceDaoProvider);
  return wsDao.watchAll();
});

/// Watch task count for a workspace.
final workspaceTaskCountProvider = StreamProvider.autoDispose.family<int, String>((ref, workspaceId) {
  final wsDao = ref.watch(workspaceDaoProvider);
  return wsDao.watchTaskCount(workspaceId);
});
