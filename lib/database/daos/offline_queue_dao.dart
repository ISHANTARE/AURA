import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/offline_queues.dart';

part 'offline_queue_dao.g.dart';

/// DAO managing offline voice captures and queued actions.
/// Reference: overhaul-docs/03-database-schema.md Section 3
@DriftAccessor(tables: [OfflineQueues])
class OfflineQueueDao extends DatabaseAccessor<AppDatabase>
    with _$OfflineQueueDaoMixin {
  OfflineQueueDao(super.db);

  /// Retrieves all pending offline items ordered by creation time ascending (FIFO).
  Future<List<OfflineQueue>> getPendingItems() {
    return (select(offlineQueues)
          ..where((t) => t.status.equals('pending'))
          ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
        .get();
  }

  /// Marks an offline queue item as successfully processed.
  Future<void> markProcessed(String id, int processedAt) {
    return (update(offlineQueues)..where((t) => t.id.equals(id))).write(
      OfflineQueuesCompanion(
        status: const Value('processed'),
        processedAt: Value(processedAt),
      ),
    );
  }

  /// Marks an offline queue item as failed.
  Future<void> markFailed(String id) {
    return (update(offlineQueues)..where((t) => t.id.equals(id))).write(
      const OfflineQueuesCompanion(
        status: Value('failed'),
      ),
    );
  }

  /// Increments retry count; marks as failed if attempts >= 5.
  Future<void> incrementAttempt(String id, int currentAttempts) {
    final nextAttempts = currentAttempts + 1;
    final isFailed = nextAttempts >= 5;

    return (update(offlineQueues)..where((t) => t.id.equals(id))).write(
      OfflineQueuesCompanion(
        attempts: Value(nextAttempts),
        status: isFailed ? const Value('failed') : const Value('pending'),
      ),
    );
  }

  /// Enqueues a new item to the offline buffer.
  Future<int> enqueue(OfflineQueuesCompanion entry) {
    return into(offlineQueues).insert(entry);
  }
}
