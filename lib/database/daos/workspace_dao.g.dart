// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workspace_dao.dart';

// ignore_for_file: type=lint
mixin _$WorkspaceDaoMixin on DatabaseAccessor<AppDatabase> {
  $WorkspacesTable get workspaces => attachedDatabase.workspaces;
  $WorkspaceSectionsTable get workspaceSections =>
      attachedDatabase.workspaceSections;
  $ItemsTable get items => attachedDatabase.items;
  WorkspaceDaoManager get managers => WorkspaceDaoManager(this);
}

class WorkspaceDaoManager {
  final _$WorkspaceDaoMixin _db;
  WorkspaceDaoManager(this._db);
  $$WorkspacesTableTableManager get workspaces =>
      $$WorkspacesTableTableManager(_db.attachedDatabase, _db.workspaces);
  $$WorkspaceSectionsTableTableManager get workspaceSections =>
      $$WorkspaceSectionsTableTableManager(
          _db.attachedDatabase, _db.workspaceSections);
  $$ItemsTableTableManager get items =>
      $$ItemsTableTableManager(_db.attachedDatabase, _db.items);
}
