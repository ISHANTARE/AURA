import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app_database.dart';
import '../tables/tasks_table.dart';
import '../tables/reminders_table.dart';

part 'task_dao.g.dart';

@DriftAccessor(tables: [Tasks, Reminders])
class TaskDao extends DatabaseAccessor<AppDatabase> with _$TaskDaoMixin {
  TaskDao(super.db);

  // ── Streams (reactive) ──────────────────────────────────────────────────

  /// Watch all active (non-deleted, non-done) tasks in a workspace, ordered by deadline.
  Stream<List<Task>> watchActiveByWorkspace(String workspaceId) =>
      (select(tasks)
            ..where((t) => t.workspaceId.equals(workspaceId))
            ..where((t) => t.status.isNotIn(const ['done', 'cancelled']))
            ..where((t) => t.deletedAt.isNull())
            ..orderBy([
              (t) => OrderingTerm(
                    expression: t.deadline,
                    mode: OrderingMode.asc,
                    nulls: NullsOrder.last,
                  )
            ]))
          .watch();

  /// Watch all tasks in a workspace (including done), for full list views.
  Stream<List<Task>> watchAllByWorkspace(String workspaceId) =>
      (select(tasks)
            ..where((t) => t.workspaceId.equals(workspaceId))
            ..where((t) => t.deletedAt.isNull())
            ..orderBy([
              (t) => OrderingTerm(expression: t.deadline, mode: OrderingMode.asc, nulls: NullsOrder.last)
            ]))
          .watch();

  /// Watch tasks in a specific section.
  Stream<List<Task>> watchBySection(String sectionId) =>
      (select(tasks)
            ..where((t) => t.sectionId.equals(sectionId))
            ..where((t) => t.deletedAt.isNull())
            ..orderBy([
              (t) => OrderingTerm(expression: t.deadline, mode: OrderingMode.asc, nulls: NullsOrder.last)
            ]))
          .watch();

  /// Watch tasks overdue right now (deadline passed, status = todo).
  Stream<List<Task>> watchOverdue() {
    final now = DateTime.now().millisecondsSinceEpoch;
    return (select(tasks)
          ..where((t) => t.deadline.isSmallerOrEqualValue(now))
          ..where((t) => t.status.equals('todo'))
          ..where((t) => t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm(expression: t.deadline)]))
        .watch();
  }

  /// Watch tasks due today (between now and midnight tonight).
  Stream<List<Task>> watchDueToday() {
    final now = DateTime.now();
    final midnight = DateTime(now.year, now.month, now.day + 1).millisecondsSinceEpoch;
    final nowMs = now.millisecondsSinceEpoch;
    return (select(tasks)
          ..where((t) => t.deadline.isBiggerOrEqualValue(nowMs))
          ..where((t) => t.deadline.isSmallerThanValue(midnight))
          ..where((t) => t.status.isNotIn(const ['done', 'cancelled']))
          ..where((t) => t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm(expression: t.deadline)]))
        .watch();
  }

  /// Watch all active recurring tasks.
  Stream<List<Task>> watchRecurring() =>
      (select(tasks)
            ..where((t) => t.isRecurring.equals(true))
            ..where((t) => t.deletedAt.isNull()))
          .watch();

  /// Watch subtasks of a parent task.
  Stream<List<Task>> watchSubtasks(String parentId) =>
      (select(tasks)
            ..where((t) => t.parentTaskId.equals(parentId))
            ..where((t) => t.deletedAt.isNull()))
          .watch();

  // ── Reads ───────────────────────────────────────────────────────────────

  /// Get a single task by ID.
  Future<Task?> getById(String id) =>
      (select(tasks)..where((t) => t.id.equals(id))).getSingleOrNull();

  /// Get all tasks due within the next N days (for briefing).
  Future<List<Task>> getDueWithinDays(int days) {
    final now = DateTime.now().millisecondsSinceEpoch;
    final limit = DateTime.now().add(Duration(days: days)).millisecondsSinceEpoch;
    return (select(tasks)
          ..where((t) => t.deadline.isBiggerOrEqualValue(now))
          ..where((t) => t.deadline.isSmallerOrEqualValue(limit))
          ..where((t) => t.status.equals('todo'))
          ..where((t) => t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm(expression: t.deadline)]))
        .get();
  }

  // ── Writes ──────────────────────────────────────────────────────────────

  /// Insert a task + its reminders atomically.
  Future<void> insertWithReminders(
    TasksCompanion task,
    List<RemindersCompanion> taskReminders,
  ) =>
      transaction(() async {
        await into(tasks).insert(task);
        for (final r in taskReminders) {
          await into(reminders).insert(r);
        }
      });

  /// Update a task.
  Future<bool> updateTask(TasksCompanion task) => update(tasks).replace(task);

  /// Mark a task as done.
  Future<void> markDone(String id) {
    final now = DateTime.now().millisecondsSinceEpoch;
    return (update(tasks)..where((t) => t.id.equals(id))).write(
      TasksCompanion(
        status: const Value('done'),
        completedAt: Value(now),
        updatedAt: Value(now),
      ),
    );
  }

  /// Mark a task back to todo (undo done).
  Future<void> markTodo(String id) {
    final now = DateTime.now().millisecondsSinceEpoch;
    return (update(tasks)..where((t) => t.id.equals(id))).write(
      TasksCompanion(
        status: const Value('todo'),
        completedAt: const Value.absent(),
        updatedAt: Value(now),
      ),
    );
  }

  /// Soft delete — sets deleted_at, never hard deletes.
  Future<void> softDelete(String id) {
    final now = DateTime.now().millisecondsSinceEpoch;
    return (update(tasks)..where((t) => t.id.equals(id))).write(
      TasksCompanion(
        deletedAt: Value(now),
        updatedAt: Value(now),
      ),
    );
  }
}

// ── Riverpod Provider ─────────────────────────────────────────────────────────
final taskDaoProvider = Provider<TaskDao>(
  (ref) => TaskDao(ref.watch(databaseProvider)),
);
