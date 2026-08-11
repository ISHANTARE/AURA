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
}

