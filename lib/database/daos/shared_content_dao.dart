import 'package:drift/drift.dart';
import '../../core/providers/providers.dart';
import '../app_database.dart';

class SharedContentDao {
  final AppDatabase db;
  SharedContentDao(this.db);

  Future<void> insertSharedContent(SharedContentsCompanion content) =>
      db.into(db.sharedContents).insert(content);

  Future<List<SharedContent>> getAll() => db.select(db.sharedContents).get();

  Future<SharedContent?> getById(String id) =>
      (db.select(db.sharedContents)..where((s) => s.id.equals(id))).getSingleOrNull();

  Future<void> updateContent(SharedContentsCompanion content) =>
      db.update(db.sharedContents).replace(content);

  Future<int> linkToItem(String sharedContentId, String itemId, {String? permanentPath}) {
    final nowEpoch = DateTime.now().millisecondsSinceEpoch;
    return (db.update(db.sharedContents)..where((s) => s.id.equals(sharedContentId))).write(
      SharedContentsCompanion(
        itemId: Value(itemId),
        rawPath: permanentPath != null ? Value(permanentPath) : const Value.absent(),
        status: const Value('saved_as_item'),
        updatedAt: Value(nowEpoch),
      ),
    );
  }

  Future<SharedContent?> getByItemId(String itemId) =>
      (db.select(db.sharedContents)..where((s) => s.itemId.equals(itemId))).getSingleOrNull();

  Stream<SharedContent?> watchByItemId(String itemId) =>
      (db.select(db.sharedContents)..where((s) => s.itemId.equals(itemId))).watchSingleOrNull();

  Future<int> deleteByItemId(String itemId) =>
      (db.delete(db.sharedContents)..where((s) => s.itemId.equals(itemId))).go();
}

