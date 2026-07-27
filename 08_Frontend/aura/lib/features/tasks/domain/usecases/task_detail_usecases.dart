import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../../database/app_database.dart';
import '../../../../database/daos/task_dao.dart';

class UpdateTaskDetailUseCase {
  final TaskDao _taskDao;

  UpdateTaskDetailUseCase(this._taskDao);

  Future<void> execute({
    required String taskId,
    String? name,
    String? description,
    String? priority,
    String? status,
    DateTime? deadline,
    double? estimatedHours,
    String? workspaceId,
    String? sectionId,
  }) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    await ( _taskDao.update( _taskDao.tasks )..where((t) => t.id.equals(taskId)) ).write(
      TasksCompanion(
        name: name != null ? Value(name) : const Value.absent(),
        description: description != null ? Value(description) : const Value.absent(),
        priority: priority != null ? Value(priority) : const Value.absent(),
        status: status != null ? Value(status) : const Value.absent(),
        deadline: deadline != null ? Value(deadline.millisecondsSinceEpoch) : const Value.absent(),
        estimatedHours: estimatedHours != null ? Value(estimatedHours) : const Value.absent(),
        workspaceId: workspaceId != null ? Value(workspaceId) : const Value.absent(),
        sectionId: sectionId != null ? Value(sectionId) : const Value.absent(),
        updatedAt: Value(now),
      ),
    );
  }
}

class ToggleSubtaskUseCase {
  final TaskDao _taskDao;
  static const _uuid = Uuid();

  ToggleSubtaskUseCase(this._taskDao);

  Future<void> createSubtask({
    required String parentTaskId,
    required String workspaceId,
    required String title,
  }) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final subtaskId = _uuid.v4();

    await _taskDao.insertSubtask(
      TasksCompanion.insert(
        id: subtaskId,
        workspaceId: workspaceId,
        parentTaskId: Value(parentTaskId),
        name: title,
        status: const Value('todo'),
        createdAt: now,
        updatedAt: now,
      ),
    );
  }

  Future<void> toggleSubtaskDone(String subtaskId, bool isDone) async {
    if (isDone) {
      await _taskDao.markDone(subtaskId);
    } else {
      await _taskDao.markTodo(subtaskId);
    }
  }
}

class TaskActionUseCase {
  final TaskDao _taskDao;
  static const _uuid = Uuid();

  TaskActionUseCase(this._taskDao);

  Future<String> duplicateTask(String taskId) async {
    final original = await _taskDao.getById(taskId);
    if (original == null) return taskId;

    final now = DateTime.now().millisecondsSinceEpoch;
    final newId = _uuid.v4();

    await _taskDao.insertWithReminders(
      TasksCompanion.insert(
        id: newId,
        workspaceId: original.workspaceId,
        sectionId: Value(original.sectionId),
        name: '${original.name} (Copy)',
        description: Value(original.description),
        priority: Value(original.priority),
        status: const Value('todo'),
        deadline: Value(original.deadline),
        estimatedHours: Value(original.estimatedHours),
        isRecurring: Value(original.isRecurring),
        createdAt: now,
        updatedAt: now,
      ),
      [],
    );
    return newId;
  }

  Future<void> softDeleteTask(String taskId) async {
    await _taskDao.softDelete(taskId);
  }

  Future<void> restoreTask(String taskId) async {
    await _taskDao.restoreSoftDelete(taskId);
  }
}
