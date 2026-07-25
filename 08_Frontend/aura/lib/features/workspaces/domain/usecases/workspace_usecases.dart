import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../../database/app_database.dart';
import '../../../../database/daos/workspace_dao.dart';
import '../entities/workspace_models.dart';

class WorkspaceUseCases {
  final WorkspaceDao _workspaceDao;

  WorkspaceUseCases(this._workspaceDao);

  /// Streams active workspaces enriched with real-time stats.
  Stream<List<WorkspaceWithStats>> watchActiveWorkspacesWithStats() {
    return _workspaceDao.watchAll().asyncMap((workspaces) async {
      final list = <WorkspaceWithStats>[];
      for (final w in workspaces) {
        final tasks = await _workspaceDao.watchTaskCount(w.id).first;
        final events = await _workspaceDao.watchEventCount(w.id).first;
        final overdue = await _workspaceDao.watchOverdueTaskCount(w.id).first;

        String? preview;
        if (overdue > 0) {
          preview = '$overdue overdue';
        } else if (tasks > 0) {
          preview = '$tasks active tasks';
        } else if (events > 0) {
          preview = '$events scheduled events';
        } else {
          preview = 'Tap to add tasks';
        }

        list.add(WorkspaceWithStats(
          workspace: w,
          activeTaskCount: tasks,
          eventCount: events,
          overdueCount: overdue,
          previewText: preview,
        ));
      }
      return list;
    });
  }

  /// Streams single workspace detail stats.
  Stream<WorkspaceStats> watchWorkspaceStats(String workspaceId) {
    return _workspaceDao.watchTaskCount(workspaceId).asyncMap((active) async {
      final overdue = await _workspaceDao.watchOverdueTaskCount(workspaceId).first;
      final events = await _workspaceDao.watchEventCount(workspaceId).first;
      final sections = await _workspaceDao.watchSectionCount(workspaceId).first;
      return WorkspaceStats(
        activeTasks: active,
        overdueTasks: overdue,
        totalEvents: events,
        totalSections: sections,
      );
    });
  }

  /// Create a workspace with custom options.
  Future<String> createWorkspace({
    required String name,
    required String iconKey,
    required String colorHex,
    String createdBy = 'USER_EXPLICIT',
  }) async {
    final id = 'ws_${const Uuid().v4().substring(0, 8)}';
    final now = DateTime.now().millisecondsSinceEpoch;

    await _workspaceDao.insertWorkspace(
      WorkspacesCompanion(
        id: Value(id),
        name: Value(name),
        iconKey: Value(iconKey),
        colorHex: Value(colorHex),
        sortOrder: const Value(0),
        createdBy: Value(createdBy),
        createdAt: Value(now),
        updatedAt: Value(now),
      ),
    );
    return id;
  }

  /// Update an existing workspace.
  Future<void> updateWorkspace({
    required String id,
    required String name,
    required String iconKey,
    required String colorHex,
  }) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final existing = await _workspaceDao.getById(id);
    if (existing == null) return;

    await _workspaceDao.updateWorkspace(
      existing.toCompanion(true).copyWith(
        name: Value(name),
        iconKey: Value(iconKey),
        colorHex: Value(colorHex),
        updatedAt: Value(now),
      ),
    );
  }

  /// Archive a workspace.
  Future<void> archiveWorkspace(String id) async {
    await _workspaceDao.archive(id);
  }

  /// Unarchive a workspace.
  Future<void> unarchiveWorkspace(String id) async {
    await _workspaceDao.unarchive(id);
  }

  /// Create a section in a workspace.
  Future<String> createSection({
    required String workspaceId,
    required String name,
  }) async {
    final id = 'sec_${const Uuid().v4().substring(0, 8)}';
    final now = DateTime.now().millisecondsSinceEpoch;

    await _workspaceDao.insertSection(
      WorkspaceSectionsCompanion(
        id: Value(id),
        workspaceId: Value(workspaceId),
        name: Value(name),
        createdAt: Value(now),
        updatedAt: Value(now),
      ),
    );
    return id;
  }

  /// Archive a section.
  Future<void> archiveSection(String id) async {
    await _workspaceDao.archiveSection(id);
  }
}

final workspaceUseCasesProvider = Provider<WorkspaceUseCases>((ref) {
  return WorkspaceUseCases(ref.watch(workspaceDaoProvider));
});
