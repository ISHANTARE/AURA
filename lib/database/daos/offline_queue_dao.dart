import 'package:drift/drift.dart';

import '../app_database.dart';

part 'offline_queue_dao.g.dart';

@DriftAccessor(tables: [OfflineQueues])
class OfflineQueueDao extends DatabaseAccessor<AppDatabase>
    with _$OfflineQueueDaoMixin {
  OfflineQueueDao(super.db);

  /// Enqueue an offline capture transcript.
  Future<String> enqueueCapture({
    required String id,
    required String content,
    String? contextJson,
    String type = 'transcript',
  }) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    await into(offlineQueues).insert(
      OfflineQueuesCompanion.insert(
        id: id,
        type: Value(type),
        content: content,
        contextJson: Value(contextJson),
        status: const Value('pending'),
        attempts: const Value(0),
        createdAt: now,
      ),
    );
    return id;
  }

  /// Get all pending queued items ordered by creation time.
  Future<List<OfflineQueue>> getPendingItems() {
    return (select(offlineQueues)
          ..where((q) => q.status.equals('pending'))
          ..orderBy([(q) => OrderingTerm(expression: q.createdAt)]))
        .get();
  }

  /// Watch count of pending items for UI badge.
  Stream<int> watchPendingCount() {
    final countExpr = offlineQueues.id.count();
    final query = selectOnly(offlineQueues)
      ..addColumns([countExpr])
      ..where(offlineQueues.status.equals('pending'));
    return query.map((row) => row.read(countExpr) ?? 0).watchSingle();
  }

  /// Mark item as processed.
  Future<void> markProcessed(String id) {
    final now = DateTime.now().millisecondsSinceEpoch;
    return (update(offlineQueues)..where((q) => q.id.equals(id))).write(
      OfflineQueuesCompanion(
        status: const Value('processed'),
        processedAt: Value(now),
      ),
    );
  }

  /// Increment retry attempt count.
  Future<void> incrementAttempt(String id, int currentAttempts) {
    final newStatus = currentAttempts >= 2 ? 'failed' : 'pending';
    return (update(offlineQueues)..where((q) => q.id.equals(id))).write(
      OfflineQueuesCompanion(
        attempts: Value(currentAttempts + 1),
        status: Value(newStatus),
      ),
    );
  }
}

