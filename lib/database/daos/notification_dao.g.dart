// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_dao.dart';

// ignore_for_file: type=lint
mixin _$NotificationDaoMixin on DatabaseAccessor<AppDatabase> {
  $WorkspacesTable get workspaces => attachedDatabase.workspaces;
  $WorkspaceSectionsTable get workspaceSections =>
      attachedDatabase.workspaceSections;
  $ItemsTable get items => attachedDatabase.items;
  $RemindersScheduleTable get remindersSchedule =>
      attachedDatabase.remindersSchedule;
  $NotificationLogsTable get notificationLogs =>
      attachedDatabase.notificationLogs;
  NotificationDaoManager get managers => NotificationDaoManager(this);
}

class NotificationDaoManager {
  final _$NotificationDaoMixin _db;
  NotificationDaoManager(this._db);
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
  $$NotificationLogsTableTableManager get notificationLogs =>
      $$NotificationLogsTableTableManager(
          _db.attachedDatabase, _db.notificationLogs);
}
