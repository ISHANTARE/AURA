import 'package:drift/drift.dart';
import '../../core/providers/providers.dart';
import '../app_database.dart';

part 'shared_content_dao.g.dart';

@DriftAccessor(tables: [SharedContents])
class SharedContentDao extends DatabaseAccessor<AppDatabase> with _$SharedContentDaoMixin {
  SharedContentDao(super.db);

  Future<void> insertSharedContent(SharedContentsCompanion content) =>
      into(sharedContents).insert(content);

  Future<List<SharedContent>> getAll() => select(sharedContents).get();

  Future<SharedContent?> getById(String id) =>
      (select(sharedContents)..where((s) => s.id.equals(id))).getSingleOrNull();

  Future<void> updateContent(SharedContentsCompanion content) =>
      update(sharedContents).replace(content);

  Future<int> linkToItem(String sharedContentId, String itemId, {String? permanentPath}) {
    final nowEpoch = DateTime.now().millisecondsSinceEpoch;
    return (update(sharedContents)..where((s) => s.id.equals(sharedContentId))).write(
      SharedContentsCompanion(
        itemId: Value(itemId),
        rawPath: permanentPath != null ? Value(permanentPath) : const Value.absent(),
        status: const Value('saved_as_item'),
        updatedAt: Value(nowEpoch),
      ),
    );
  }

  Future<SharedContent?> getByItemId(String itemId) =>
      (select(sharedContents)..where((s) => s.itemId.equals(itemId))).getSingleOrNull();

  Stream<SharedContent?> watchByItemId(String itemId) =>
      (select(sharedContents)..where((s) => s.itemId.equals(itemId))).watchSingleOrNull();

  Future<int> deleteByItemId(String itemId) =>
      (delete(sharedContents)..where((s) => s.itemId.equals(itemId))).go();
}

