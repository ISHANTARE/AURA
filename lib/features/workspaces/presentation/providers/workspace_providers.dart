import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/providers.dart';
import '../../domain/usecases/workspace_usecases.dart';

export '../../domain/usecases/workspace_usecases.dart';

/// Stream of archived workspaces.
final archivedWorkspacesProvider = StreamProvider<List<Workspace>>((ref) {
  final dao = ref.watch(workspaceDaoProvider);
  return dao.watchArchived();
});

/// Stream of sections for a workspace.
final workspaceSectionsProvider =
    StreamProvider.family<List<WorkspaceSection>, String>((ref, workspaceId) {
  final dao = ref.watch(workspaceDaoProvider);
  return dao.watchSections(workspaceId);
});

/// Stream of items for a workspace.
final workspaceItemsProvider =
    StreamProvider.family<List<Item>, String>((ref, workspaceId) {
  final itemDao = ref.watch(itemDaoProvider);
  return itemDao.watchByWorkspace(workspaceId);
});

/// Stream of shared content items for a workspace.
final workspaceSharedItemsProvider =
    StreamProvider.family<List<Item>, String>((ref, workspaceId) {
  final itemDao = ref.watch(itemDaoProvider);
  return itemDao.watchByWorkspace(workspaceId).map((items) =>
      items.where((i) => i.kind == 'shared' || i.category == 'shared').toList());
});

/// Single workspace info by ID.
final workspaceByIdProvider =
    FutureProvider.family<Workspace?, String>((ref, workspaceId) {
  final dao = ref.watch(workspaceDaoProvider);
  return dao.getById(workspaceId);
});

/// Action notifier for Workspace CRUD.
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
}

final workspaceActionNotifierProvider =
    StateNotifierProvider<WorkspaceActionNotifier, AsyncValue<void>>((ref) {
  return WorkspaceActionNotifier(ref.watch(workspaceUseCasesProvider));
});
