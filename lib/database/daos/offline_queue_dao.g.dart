// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'offline_queue_dao.dart';

// ignore_for_file: type=lint
mixin _$OfflineQueueDaoMixin on DatabaseAccessor<AppDatabase> {
  $OfflineQueuesTable get offlineQueues => attachedDatabase.offlineQueues;
  OfflineQueueDaoManager get managers => OfflineQueueDaoManager(this);
}

class OfflineQueueDaoManager {
  final _$OfflineQueueDaoMixin _db;
  OfflineQueueDaoManager(this._db);
  $$OfflineQueuesTableTableManager get offlineQueues =>
      $$OfflineQueuesTableTableManager(_db.attachedDatabase, _db.offlineQueues);
}
