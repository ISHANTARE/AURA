import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../database/app_database.dart';
import '../../../../database/daos/event_dao.dart';
import '../../../../database/daos/task_dao.dart';
import '../../../../database/daos/workspace_dao.dart';
import '../../domain/entities/workspace_models.dart';
import '../../domain/usecases/workspace_usecases.dart';

/// Stream of active workspaces with stats and previews.
final activeWorkspacesWithStatsProvider =
    StreamProvider<List<WorkspaceWithStats>>((ref) {
  final useCases = ref.watch(workspaceUseCasesProvider);
  return useCases.watchActiveWorkspacesWithStats();
});

/// Stream of archived workspaces.
final archivedWorkspacesProvider = StreamProvider<List<Workspace>>((ref) {
  final dao = ref.watch(workspaceDaoProvider);
  return dao.watchArchived();
});

/// Stream of workspace detail stats.
final workspaceStatsProvider =
    StreamProvider.family<WorkspaceStats, String>((ref, workspaceId) {
  final useCases = ref.watch(workspaceUseCasesProvider);
  return useCases.watchWorkspaceStats(workspaceId);
});

/// Stream of sections for a workspace.
final workspaceSectionsProvider =
    StreamProvider.family<List<WorkspaceSection>, String>((ref, workspaceId) {
  final dao = ref.watch(workspaceDaoProvider);
  return dao.watchSections(workspaceId);
});

/// Stream of tasks for a workspace, optionally filtered by sectionId.
final workspaceTasksProvider =
    StreamProvider.family<List<Task>, ({String workspaceId, String? sectionId})>(
        (ref, arg) {
  final taskDao = ref.watch(taskDaoProvider);
  if (arg.sectionId != null) {
    return taskDao.watchBySection(arg.sectionId!);
  }
  return taskDao.watchAllByWorkspace(arg.workspaceId);
});

/// Stream of events for a workspace.
final workspaceEventsProvider =
    StreamProvider.family<List<Event>, String>((ref, workspaceId) {
  final eventDao = ref.watch(eventDaoProvider);
  return eventDao.watchByWorkspace(workspaceId);
});

/// Single workspace info by ID.
final workspaceByIdProvider =
    FutureProvider.family<Workspace?, String>((ref, workspaceId) {
  final dao = ref.watch(workspaceDaoProvider);
  return dao.getById(workspaceId);
});

/// StateNotifier for handling CRUD operations and workspace actions.
class WorkspaceActionNotifier extends StateNotifier<AsyncValue<void>> {
  final WorkspaceUseCases _useCases;

  WorkspaceActionNotifier(this._useCases) : super(const AsyncValue.data(null));

  Future<String?> createWorkspace({
    required String name,
    required String iconKey,
    required String colorHex,
  }) async {
    state = const AsyncValue.loading();
    try {
      final id = await _useCases.createWorkspace(
        name: name,
        iconKey: iconKey,
        colorHex: colorHex,
      );
      state = const AsyncValue.data(null);
      return id;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return null;
    }
  }

  Future<bool> updateWorkspace({
    required String id,
    required String name,
    required String iconKey,
    required String colorHex,
  }) async {
    state = const AsyncValue.loading();
    try {
      await _useCases.updateWorkspace(
        id: id,
        name: name,
        iconKey: iconKey,
        colorHex: colorHex,
      );
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<void> archiveWorkspace(String id) async {
    state = const AsyncValue.loading();
    try {
      await _useCases.archiveWorkspace(id);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> unarchiveWorkspace(String id) async {
    state = const AsyncValue.loading();
    try {
      await _useCases.unarchiveWorkspace(id);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<String?> createSection({
    required String workspaceId,
    required String name,
  }) async {
    state = const AsyncValue.loading();
    try {
      final secId = await _useCases.createSection(
        workspaceId: workspaceId,
        name: name,
      );
      state = const AsyncValue.data(null);
      return secId;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return null;
    }
  }

  Future<void> archiveSection(String id) async {
    state = const AsyncValue.loading();
    try {
      await _useCases.archiveSection(id);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final workspaceActionNotifierProvider =
    StateNotifierProvider<WorkspaceActionNotifier, AsyncValue<void>>((ref) {
  return WorkspaceActionNotifier(ref.watch(workspaceUseCasesProvider));
});
