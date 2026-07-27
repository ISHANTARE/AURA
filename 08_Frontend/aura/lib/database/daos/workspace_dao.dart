import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app_database.dart';
import '../tables/workspaces_table.dart';
import '../tables/workspace_sections_table.dart';

part 'workspace_dao.g.dart';

@DriftAccessor(tables: [Workspaces, WorkspaceSections])
class WorkspaceDao extends DatabaseAccessor<AppDatabase> with _$WorkspaceDaoMixin {
  WorkspaceDao(super.db);

  /// Watch all active (non-archived, non-deleted) workspaces.
  Stream<List<Workspace>> watchAll() =>
      (select(workspaces)
            ..where((w) => w.isArchived.equals(false))
            ..where((w) => w.deletedAt.isNull())
            ..orderBy([(w) => OrderingTerm(expression: w.sortOrder)]))
          .watch();

  /// Watch all archived (non-deleted) workspaces.
  Stream<List<Workspace>> watchArchived() =>
      (select(workspaces)
            ..where((w) => w.isArchived.equals(true))
            ..where((w) => w.deletedAt.isNull())
            ..orderBy([(w) => OrderingTerm(expression: w.sortOrder)]))
          .watch();

  /// Get count of active tasks for a workspace
  Stream<int> watchTaskCount(String workspaceId) {
    return (select(db.tasks)
          ..where((t) => t.workspaceId.equals(workspaceId))
          ..where((t) => t.status.isNotIn(const ['done', 'cancelled']))
          ..where((t) => t.deletedAt.isNull()))
        .watch()
        .map((list) => list.length);
  }

  /// Get count of overdue tasks for a workspace
  Stream<int> watchOverdueTaskCount(String workspaceId) {
    final now = DateTime.now().millisecondsSinceEpoch;
    return (select(db.tasks)
          ..where((t) => t.workspaceId.equals(workspaceId))
          ..where((t) => t.status.isNotIn(const ['done', 'cancelled']))
          ..where((t) => t.deadline.isSmallerThanValue(now))
          ..where((t) => t.deletedAt.isNull()))
        .watch()
        .map((list) => list.length);
  }

  /// Get count of events for a workspace
  Stream<int> watchEventCount(String workspaceId) {
    return (select(db.events)
          ..where((e) => e.workspaceId.equals(workspaceId))
          ..where((e) => e.deletedAt.isNull()))
        .watch()
        .map((list) => list.length);
  }

  /// Get count of sections for a workspace
  Stream<int> watchSectionCount(String workspaceId) {
    return (select(db.workspaceSections)
          ..where((s) => s.workspaceId.equals(workspaceId))
          ..where((s) => s.isArchived.equals(false))
          ..where((s) => s.deletedAt.isNull()))
        .watch()
        .map((list) => list.length);
  }

  /// Watch sections for a workspace.
  Stream<List<WorkspaceSection>> watchSections(String workspaceId) =>
      (select(workspaceSections)
            ..where((s) => s.workspaceId.equals(workspaceId))
            ..where((s) => s.isArchived.equals(false))
            ..where((s) => s.deletedAt.isNull())
            ..orderBy([(s) => OrderingTerm(expression: s.sortOrder)]))
          .watch();

  /// Get all workspaces (non-reactive, for AI workspace routing).
  Future<List<Workspace>> getAll() =>
      (select(workspaces)
            ..where((w) => w.isArchived.equals(false))
            ..where((w) => w.deletedAt.isNull()))
          .get();

  /// Get a single workspace by ID.
  Future<Workspace?> getById(String id) =>
      (select(workspaces)..where((w) => w.id.equals(id))).getSingleOrNull();

  /// Insert a new workspace.
  Future<void> insertWorkspace(WorkspacesCompanion workspace) =>
      into(workspaces).insert(workspace);

  /// Update a workspace.
  Future<bool> updateWorkspace(WorkspacesCompanion workspace) =>
      update(workspaces).replace(workspace);

  /// Archive a workspace (soft-disable, does not delete tasks).
  Future<void> archive(String id) {
    final now = DateTime.now().millisecondsSinceEpoch;
    return (update(workspaces)..where((w) => w.id.equals(id))).write(
      WorkspacesCompanion(
        isArchived: const Value(true),
        updatedAt: Value(now),
      ),
    );
  }

  /// Unarchive a workspace.
  Future<void> unarchive(String id) {
    final now = DateTime.now().millisecondsSinceEpoch;
    return (update(workspaces)..where((w) => w.id.equals(id))).write(
      WorkspacesCompanion(
        isArchived: const Value(false),
        updatedAt: Value(now),
      ),
    );
  }

  /// Soft delete a workspace.
  Future<void> softDelete(String id) {
    final now = DateTime.now().millisecondsSinceEpoch;
    return (update(workspaces)..where((w) => w.id.equals(id))).write(
      WorkspacesCompanion(
        deletedAt: Value(now),
        updatedAt: Value(now),
      ),
    );
  }

  /// Insert a section.
  Future<void> insertSection(WorkspaceSectionsCompanion section) =>
      into(workspaceSections).insert(section);

  /// Update a section.
  Future<bool> updateSection(WorkspaceSectionsCompanion section) =>
      update(workspaceSections).replace(section);

  /// Archive a section (tasks move to sectionId = null at app level).
  Future<void> archiveSection(String id) {
    final now = DateTime.now().millisecondsSinceEpoch;
    return (update(workspaceSections)..where((s) => s.id.equals(id))).write(
      WorkspaceSectionsCompanion(
        isArchived: const Value(true),
        updatedAt: Value(now),
      ),
    );
  }
}

final workspaceDaoProvider = Provider<WorkspaceDao>(
  (ref) => WorkspaceDao(ref.watch(databaseProvider)),
);
