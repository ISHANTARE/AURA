// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'item_dao.dart';

// ignore_for_file: type=lint
mixin _$ItemDaoMixin on DatabaseAccessor<AppDatabase> {
  $WorkspacesTable get workspaces => attachedDatabase.workspaces;
  $WorkspaceSectionsTable get workspaceSections =>
      attachedDatabase.workspaceSections;
  $ItemsTable get items => attachedDatabase.items;
  $RemindersScheduleTable get remindersSchedule =>
      attachedDatabase.remindersSchedule;
  ItemDaoManager get managers => ItemDaoManager(this);
}

class ItemDaoManager {
  final _$ItemDaoMixin _db;
  ItemDaoManager(this._db);
  $$WorkspacesTableTableManager get workspaces =>
      $$WorkspacesTableTableManager(_db.attachedDatabase, _db.workspaces);
  $$WorkspaceSectionsTableTableManager get workspaceSections =>
      $$WorkspaceSectionsTableTableManager(
          _db.attachedDatabase, _db.workspaceSections);
  $$ItemsTableTableManager get items =>
      $$ItemsTableTableManager(_db.attachedDatabase, _db.items);
  $$RemindersScheduleTableTableManager get remindersSchedule =>
      $$RemindersScheduleTableTableManager(
          _db.attachedDatabase, _db.remindersSchedule);
}
