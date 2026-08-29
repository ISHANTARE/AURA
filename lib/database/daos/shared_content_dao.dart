import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/shared_contents.dart';

part 'shared_content_dao.g.dart';

/// DAO managing staging buffer for shared contents (ACTION_SEND).
/// Reference: overhaul-docs/03-database-schema.md Section 3
@DriftAccessor(tables: [SharedContents])
class SharedContentDao extends DatabaseAccessor<AppDatabase>
    with _$SharedContentDaoMixin {
  SharedContentDao(super.db);

  /// Retrieves all pending shared content items.
  Future<List<SharedContent>> getPending() {
    return (select(sharedContents)
          ..where((t) => t.status.equals('pending'))
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .get();
  }

  /// Marks a shared content item as processed.
  Future<void> markProcessed(String id) {
    return (update(sharedContents)..where((t) => t.id.equals(id))).write(
      const SharedContentsCompanion(
        status: Value('processed'),
      ),
    );
  }

  /// Inserts a new shared content record.
  Future<int> insertContent(SharedContentsCompanion content) {
    return into(sharedContents).insert(content);
  }

  /// Deletes shared content files older than cutoff (e.g. 24 hours).
  Future<int> deleteOlderThan(int cutoffMs) {
    return (delete(sharedContents)
          ..where((t) => t.createdAt.isSmallerThanValue(cutoffMs)))
        .go();
  }
}
