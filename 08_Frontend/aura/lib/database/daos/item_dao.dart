import 'package:drift/drift.dart';
import '../app_database.dart';

part 'item_dao.g.dart';

@DriftAccessor(tables: [Items, RemindersSchedule])
class ItemDao extends DatabaseAccessor<AppDatabase> with _$ItemDaoMixin {
  ItemDao(super.db);

  // ── Queries ─────────────────────────────────────────────────────────────────

  /// Get single item by ID
  Future<Item?> getById(String id) =>
      (select(items)..where((t) => t.id.equals(id))).getSingleOrNull();

  /// Watch single item by ID
  Stream<Item?> watchById(String id) =>
      (select(items)..where((t) => t.id.equals(id))).watchSingleOrNull();

  /// Watch all active (non-deleted) items
  Stream<List<Item>> watchAllActive() =>
      (select(items)
        ..where((t) => t.deletedAt.isNull())
        ..orderBy([(t) => OrderingTerm.desc(t.updatedAt)]))
      .watch();

  /// Watch items by Category ('alarm' | 'reminder')
  Stream<List<Item>> watchByCategory(String category) =>
      (select(items)
        ..where((t) => t.category.equals(category) & t.deletedAt.isNull())
        ..orderBy([(t) => OrderingTerm.asc(t.fireAt)]))
      .watch();

  /// Watch items by Kind ('generic' | 'task' | 'event')
  Stream<List<Item>> watchByKind(String kind) =>
      (select(items)
        ..where((t) => t.kind.equals(kind) & t.deletedAt.isNull())
        ..orderBy([(t) => OrderingTerm.desc(t.updatedAt)]))
      .watch();

  /// Watch items by Workspace ID
  Stream<List<Item>> watchByWorkspace(String workspaceId) =>
      (select(items)
        ..where((t) => t.workspaceId.equals(workspaceId) & t.deletedAt.isNull())
        ..orderBy([(t) => OrderingTerm.desc(t.updatedAt)]))
      .watch();

  /// Watch urgent items (High priority pending tasks/reminders)
  Stream<List<Item>> watchUrgent() =>
      (select(items)
        ..where((t) =>
            t.priority.equals('high') &
            t.status.equals('pending') &
            t.deletedAt.isNull())
        ..orderBy([(t) => OrderingTerm.asc(t.deadline)]))
      .watch();

  /// Watch today's focus items
  Stream<List<Item>> watchTodayFocus() {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day).millisecondsSinceEpoch;
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59).millisecondsSinceEpoch;

    return (select(items)
      ..where((t) =>
          t.deletedAt.isNull() &
          t.status.equals('pending') &
          ((t.deadline.isBiggerOrEqualValue(startOfDay) & t.deadline.isSmallerOrEqualValue(endOfDay)) |
           (t.fireAt.isBiggerOrEqualValue(startOfDay) & t.fireAt.isSmallerOrEqualValue(endOfDay)) |
           (t.startTime.isBiggerOrEqualValue(startOfDay) & t.startTime.isSmallerOrEqualValue(endOfDay))))
      ..orderBy([(t) => OrderingTerm.asc(t.fireAt)]))
    .watch();
  }

  /// Search items by title query
  Future<List<Item>> search(String query) =>
      (select(items)
        ..where((t) =>
            t.title.like('%$query%') & t.deletedAt.isNull())
        ..limit(20))
      .get();

  // ── Sub-Reminders Schedule Queries ─────────────────────────────────────────

  /// Get sub-reminders for an item
  Future<List<ReminderSchedule>> getRemindersForItem(String itemId) =>
      (select(remindersSchedule)..where((r) => r.itemId.equals(itemId))).get();

  /// Watch sub-reminders for an item
  Stream<List<ReminderSchedule>> watchRemindersForItem(String itemId) =>
      (select(remindersSchedule)..where((r) => r.itemId.equals(itemId))).watch();

  // ── Mutators ────────────────────────────────────────────────────────────────

  /// Insert single item
  Future<int> insertItem(ItemsCompanion companion) =>
      into(items).insert(companion);

  /// Insert item along with optional sub-reminders inside a transaction
  Future<void> insertItemWithReminders(
    ItemsCompanion item,
    List<RemindersScheduleCompanion> reminders,
  ) async {
    await transaction(() async {
      await into(items).insert(item);
      for (final r in reminders) {
        await into(remindersSchedule).insert(r);
      }
    });
  }

  /// Update item
  Future<bool> updateItem(ItemsCompanion companion) =>
      update(items).replace(companion);

  /// Soft delete item by ID
  Future<int> softDelete(String id) async {
    final nowEpoch = DateTime.now().millisecondsSinceEpoch;
    return (update(items)..where((t) => t.id.equals(id))).write(
      ItemsCompanion(
        deletedAt: Value(nowEpoch),
        updatedAt: Value(nowEpoch),
      ),
    );
  }

  /// Update item status by ID ('pending' | 'completed')
  Future<int> updateStatus(String id, String status) async {
    final nowEpoch = DateTime.now().millisecondsSinceEpoch;
    return (update(items)..where((t) => t.id.equals(id))).write(
      ItemsCompanion(
        status: Value(status),
        updatedAt: Value(nowEpoch),
      ),
    );
  }

  /// Watch subtasks for a given parent item ID
  Stream<List<Item>> watchSubtasks(String parentId) =>
      (select(items)
        ..where((t) => t.parentId.equals(parentId) & t.deletedAt.isNull())
        ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
      .watch();

  /// Update workspace ID for an item
  Future<int> updateWorkspace(String id, String workspaceId) async {
    final nowEpoch = DateTime.now().millisecondsSinceEpoch;
    return (update(items)..where((t) => t.id.equals(id))).write(
      ItemsCompanion(
        workspaceId: Value(workspaceId),
        updatedAt: Value(nowEpoch),
      ),
    );
  }

  /// Duplicate an existing item
  Future<String?> duplicateItem(String id) async {
    final original = await getById(id);
    if (original == null) return null;
    final nowEpoch = DateTime.now().millisecondsSinceEpoch;
    final newId = 'item_${nowEpoch}_${original.title.hashCode.abs()}';
    final companion = ItemsCompanion(
      id: Value(newId),
      title: Value('${original.title} (Copy)'),
      category: Value(original.category),
      kind: Value(original.kind),
      status: const Value('pending'),
      priority: Value(original.priority),
      notes: Value(original.notes),
      workspaceId: Value(original.workspaceId),
      parentId: Value(original.parentId),
      fireAt: Value(original.fireAt),
      deadline: Value(original.deadline),
      createdAt: Value(nowEpoch),
      updatedAt: Value(nowEpoch),
    );
    await insertItem(companion);
    return newId;
  }

  /// Hard delete item by ID
  Future<int> hardDelete(String id) =>
      (delete(items)..where((t) => t.id.equals(id))).go();
}
