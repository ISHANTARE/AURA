import 'package:drift/drift.dart';

import '../app_database.dart';

part 'offline_queue_dao.g.dart';

@DriftAccessor(tables: [OfflineQueues])
class OfflineQueueDao extends DatabaseAccessor<AppDatabase>
    with _$OfflineQueueDaoMixin {
  OfflineQueueDao(super.db);

  /// Shared retry cap: an item fails permanently after this many attempts.
  /// Referenced by both this DAO and [OfflineQueueProcessor].
  static const int maxAttempts = 5;

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

  /// Mark item as permanently failed (retry cap exhausted).
  Future<void> markFailed(String id) {
    return (update(offlineQueues)..where((q) => q.id.equals(id))).write(
      const OfflineQueuesCompanion(status: Value('failed')),
    );
  }

  /// Increment retry attempt count. Flips to 'failed' only when the shared
  /// retry cap is reached — stays 'pending' (and visible to the processor)
  /// until then.
  Future<void> incrementAttempt(String id, int currentAttempts) {
    final newAttempts = currentAttempts + 1;
    return (update(offlineQueues)..where((q) => q.id.equals(id))).write(
      OfflineQueuesCompanion(
        attempts: Value(newAttempts),
        status: Value(newAttempts >= maxAttempts ? 'failed' : 'pending'),
      ),
    );
  }

  /// Watch count of failed items for the UI badge.
  Stream<int> watchFailedCount() {
    final countExpr = offlineQueues.id.count();
    final query = selectOnly(offlineQueues)
      ..addColumns([countExpr])
      ..where(offlineQueues.status.equals('failed'));
    return query.map((row) => row.read(countExpr) ?? 0).watchSingle();
  }

  /// Re-queue every failed item for processing (badge "TAP RETRY" action).
  Future<int> resetFailedToPending() {
    return (update(offlineQueues)..where((q) => q.status.equals('failed')))
        .write(const OfflineQueuesCompanion(status: Value('pending')));
  }
}

