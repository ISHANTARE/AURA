import 'dart:io';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

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

  /// Get all active (non-deleted) items
  Future<List<Item>> getAllActive() =>
      (select(items)
        ..where((t) => t.deletedAt.isNull())
        ..orderBy([(t) => OrderingTerm.desc(t.updatedAt)]))
      .get();

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

  /// Watch today's focus items: pending items due today (or created today).
  ///
  /// [now] is injectable for tests; callers should re-subscribe when the day
  /// rolls over (see dayRefreshProvider) because drift watches do not react
  /// to wall-clock changes.
  ///
  /// Bounded on BOTH ends: deadline/fireAt/startTime must fall within today,
  /// so months-old never-completed items no longer accumulate forever here —
  /// they surface through the overdue stat and urgent list instead.
  Stream<List<Item>> watchTodayFocus({DateTime? now}) {
    final effectiveNow = now ?? DateTime.now();
    final startOfDay = DateTime(effectiveNow.year, effectiveNow.month, effectiveNow.day).millisecondsSinceEpoch;
    final endOfDay = DateTime(effectiveNow.year, effectiveNow.month, effectiveNow.day, 23, 59, 59).millisecondsSinceEpoch;

    return (select(items)
      ..where((t) =>
          t.deletedAt.isNull() &
          t.status.equals('pending') &
          (
            (t.deadline.isNotNull() & t.deadline.isBiggerOrEqualValue(startOfDay) & t.deadline.isSmallerOrEqualValue(endOfDay)) |
            (t.fireAt.isNotNull() & t.fireAt.isBiggerOrEqualValue(startOfDay) & t.fireAt.isSmallerOrEqualValue(endOfDay)) |
            (t.startTime.isNotNull() & t.startTime.isBiggerOrEqualValue(startOfDay) & t.startTime.isSmallerOrEqualValue(endOfDay)) |
            (t.createdAt.isBiggerOrEqualValue(startOfDay) & t.createdAt.isSmallerOrEqualValue(endOfDay))
          )
      )
      ..orderBy([
        (t) => OrderingTerm.asc(coalesce([t.fireAt, t.startTime, t.deadline, t.createdAt]))
      ]))
    .watch();
  }

  /// Search items by title, notes body, or AI transcript
  Future<List<Item>> search(String query) =>
      (select(items)
        ..where((t) =>
            (t.title.like('%$query%') |
             t.notes.like('%$query%') |
             t.aiTranscript.like('%$query%')) &
            t.deletedAt.isNull())
        ..limit(30))
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

  /// Insert or update single item on primary key conflict
  Future<int> upsertItem(ItemsCompanion companion) =>
      into(items).insertOnConflictUpdate(companion);

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

  /// Replace entire item
  Future<bool> updateItem(ItemsCompanion companion) =>
      update(items).replace(companion);

  /// Partial update of specified fields on an item
  Future<int> updateItemPartial(ItemsCompanion companion) {
    return (update(items)..where((t) => t.id.equals(companion.id.value))).write(companion);
  }

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
    // UUID primary key — title-hash-derived IDs collided when the same item
    // was duplicated twice within one millisecond.
    final newId = const Uuid().v4();
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

  /// Hard delete item by ID, cleaning up any associated reminders, shared content, and physical media files
  Future<int> hardDelete(String id) async {
    final item = await getById(id);
    if (item != null) {
      // 1. Delete associated physical file if referenced in location
      if (item.location != null && item.location!.isNotEmpty) {
        try {
          final file = File(item.location!);
          if (await file.exists()) {
            await file.delete();
          }
        } catch (_) {}
      }

      // 2. Delete associated physical file if referenced in notes attachment tag
      if (item.notes != null && item.notes!.isNotEmpty) {
        final match = RegExp(r'\[Attachment:\s*([^\]]+)\]').firstMatch(item.notes!);
        if (match != null) {
          final path = match.group(1)?.trim();
          if (path != null && path.isNotEmpty) {
            try {
              final file = File(path);
              if (await file.exists()) {
                await file.delete();
              }
            } catch (_) {}
          }
        }
      }

      // 3. Delete shared contents entry and any linked raw file
      try {
        final sharedRecords = await (db.select(db.sharedContents)..where((s) => s.itemId.equals(id))).get();
        for (final record in sharedRecords) {
          if (record.rawPath != null && record.rawPath!.isNotEmpty) {
            try {
              final file = File(record.rawPath!);
              if (await file.exists()) {
                await file.delete();
              }
            } catch (_) {}
          }
        }
        await (db.delete(db.sharedContents)..where((s) => s.itemId.equals(id))).go();
      } catch (_) {}

      // 4. Delete sub-reminders
      await (delete(remindersSchedule)..where((r) => r.itemId.equals(id))).go();
    }

    return (delete(items)..where((t) => t.id.equals(id))).go();
  }
}
