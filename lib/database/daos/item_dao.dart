import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/items.dart';
import '../tables/reminders_schedule.dart';
import '../tables/workspaces.dart';

part 'item_dao.g.dart';

/// DAO managing Unified Items and Reminders Schedule operations.
/// Reference: overhaul-docs/03-database-schema.md Section 3
@DriftAccessor(tables: [Items, RemindersSchedule, Workspaces])
class ItemDao extends DatabaseAccessor<AppDatabase> with _$ItemDaoMixin {
  ItemDao(super.db);

  /// Streams all active, non-deleted items ordered by creation date descending.
  Stream<List<Item>> watchAllActive() {
    return (select(items)
          ..where((t) => t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .watch();
  }

  /// Streams today's items: active items scheduled or due on [dateFormatted] (or matching epoch bounds).
  Stream<List<Item>> watchTodayItems(int startOfDayMs, int endOfDayMs) {
    return (select(items)
          ..where((t) =>
              t.deletedAt.isNull() &
              ((t.fireAt.isBiggerOrEqualValue(startOfDayMs) &
                      t.fireAt.isSmallerOrEqualValue(endOfDayMs)) |
                  (t.deadline.isBiggerOrEqualValue(startOfDayMs) &
                      t.deadline.isSmallerOrEqualValue(endOfDayMs))))
          ..orderBy([(t) => OrderingTerm.asc(t.fireAt)]))
        .watch();
  }

  /// Streams active overdue items where deadline has passed.
  Stream<List<Item>> watchOverdue(int nowMs) {
    return (select(items)
          ..where((t) =>
              t.deletedAt.isNull() &
              t.deadline.isSmallerThanValue(nowMs) &
              t.status.isNotValue('completed'))
          ..orderBy([(t) => OrderingTerm.asc(t.deadline)]))
        .watch();
  }

  /// Streams active alarms.
  Stream<List<Item>> watchAlarms() {
    return (select(items)
          ..where(
              (t) => t.deletedAt.isNull() & t.category.equals('alarm'))
          ..orderBy([(t) => OrderingTerm.asc(t.fireAt)]))
        .watch();
  }

  /// Streams subtasks of a parent item.
  Stream<List<Item>> watchSubtasks(String parentId) {
    return (select(items)
          ..where(
              (t) => t.deletedAt.isNull() & t.parentId.equals(parentId))
          ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
        .watch();
  }

  /// Streams active items within a specific workspace.
  Stream<List<Item>> watchItemsByWorkspace(String workspaceId) {
    return (select(items)
          ..where((t) =>
              t.deletedAt.isNull() & t.workspaceId.equals(workspaceId))
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .watch();
  }

  /// Retrieves an item by its UUID.
  Future<Item?> getItemById(String id) {
    return (select(items)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  /// Inserts a new item.
  Future<int> insertItem(ItemsCompanion item) {
    return into(items).insert(item);
  }

  /// Updates an existing item.
  Future<bool> updateItem(ItemsCompanion item) {
    return update(items).replace(item);
  }

  /// Soft deletes an item and cascades soft-delete to its subtasks.
  Future<void> softDeleteItem(String id, int nowMs) async {
    await transaction(() async {
      await (update(items)..where((t) => t.id.equals(id))).write(
        ItemsCompanion(deletedAt: Value(nowMs), updatedAt: Value(nowMs)),
      );
      await (update(items)..where((t) => t.parentId.equals(id))).write(
        ItemsCompanion(deletedAt: Value(nowMs), updatedAt: Value(nowMs)),
      );
    });
  }

  /// Marks an item completed or pending.
  Future<void> completeItem(String id, bool isCompleted, int nowMs) async {
    await (update(items)..where((t) => t.id.equals(id))).write(
      ItemsCompanion(
        status: Value(isCompleted ? 'completed' : 'pending'),
        updatedAt: Value(nowMs),
      ),
    );
  }

  /// Searches items by title.
  Future<List<Item>> search(String query) {
    return (select(items)
          ..where((t) =>
              t.deletedAt.isNull() & t.title.contains(query))
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .get();
  }
}
