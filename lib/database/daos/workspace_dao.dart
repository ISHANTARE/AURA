import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/items.dart';
import '../tables/workspaces.dart';

part 'workspace_dao.g.dart';

/// DAO managing Workspaces and Workspace Sections.
/// Reference: overhaul-docs/03-database-schema.md Section 3
@DriftAccessor(tables: [Workspaces, WorkspaceSections, Items])
class WorkspaceDao extends DatabaseAccessor<AppDatabase>
    with _$WorkspaceDaoMixin {
  WorkspaceDao(super.db);

  /// Streams active, non-archived, non-deleted workspaces.
  Stream<List<Workspace>> watchAll() {
    return (select(workspaces)
          ..where((t) => t.deletedAt.isNull() & t.isArchived.equals(false))
          ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]))
        .watch();
  }

  /// Streams archived, non-deleted workspaces.
  Stream<List<Workspace>> watchArchived() {
    return (select(workspaces)
          ..where((t) => t.deletedAt.isNull() & t.isArchived.equals(true))
          ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]))
        .watch();
  }

  /// Streams sections within a workspace.
  Stream<List<WorkspaceSection>> watchSections(String workspaceId) {
    return (select(workspaceSections)
          ..where((t) =>
              t.deletedAt.isNull() & t.workspaceId.equals(workspaceId))
          ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]))
        .watch();
  }

  /// Retrieves a workspace by UUID.
  Future<Workspace?> getWorkspaceById(String id) {
    return (select(workspaces)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
  }

  /// Inserts a new workspace.
  Future<int> insertWorkspace(WorkspacesCompanion ws) {
    return into(workspaces).insert(ws);
  }

  /// Updates an existing workspace.
  Future<bool> updateWorkspace(WorkspacesCompanion ws) {
    return update(workspaces).replace(ws);
  }

  /// Soft deletes a workspace and cascades soft-delete to its sections and items.
  Future<void> softDeleteWorkspace(String id, int nowMs) async {
    await transaction(() async {
      await (update(workspaces)..where((t) => t.id.equals(id))).write(
        WorkspacesCompanion(
          deletedAt: Value(nowMs),
          updatedAt: Value(nowMs),
        ),
      );
      await (update(workspaceSections)
            ..where((t) => t.workspaceId.equals(id)))
          .write(
        WorkspaceSectionsCompanion(
          deletedAt: Value(nowMs),
          updatedAt: Value(nowMs),
        ),
      );
      await (update(items)..where((t) => t.workspaceId.equals(id))).write(
        ItemsCompanion(
          deletedAt: Value(nowMs),
          updatedAt: Value(nowMs),
        ),
      );
    });
  }

  /// Archives or unarchives a workspace.
  Future<void> archiveWorkspace(String id, bool isArchived, int nowMs) async {
    await (update(workspaces)..where((t) => t.id.equals(id))).write(
      WorkspacesCompanion(
        isArchived: Value(isArchived),
        updatedAt: Value(nowMs),
      ),
    );
  }

  /// Inserts a workspace section.
  Future<int> insertSection(WorkspaceSectionsCompanion section) {
    return into(workspaceSections).insert(section);
  }

  /// Updates a workspace section.
  Future<bool> updateSection(WorkspaceSectionsCompanion section) {
    return update(workspaceSections).replace(section);
  }

  /// Soft deletes a section and sets section_id null or cascades to items.
  Future<void> softDeleteSection(String sectionId, int nowMs) async {
    await transaction(() async {
      await (update(workspaceSections)
            ..where((t) => t.id.equals(sectionId)))
          .write(
        WorkspaceSectionsCompanion(
          deletedAt: Value(nowMs),
          updatedAt: Value(nowMs),
        ),
      );
      await (update(items)..where((t) => t.sectionId.equals(sectionId)))
          .write(
        ItemsCompanion(
          deletedAt: Value(nowMs),
          updatedAt: Value(nowMs),
        ),
      );
    });
  }
}
