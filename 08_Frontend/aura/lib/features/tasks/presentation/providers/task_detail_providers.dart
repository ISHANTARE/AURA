import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../database/app_database.dart';
import '../../../../database/daos/task_dao.dart';
import '../../../../database/daos/workspace_dao.dart';
import '../../domain/usecases/task_detail_usecases.dart';

final taskDetailStreamProvider = StreamProvider.family<Task?, String>((ref, taskId) {
  final taskDao = ref.watch(taskDaoProvider);
  return (taskDao.select(taskDao.tasks)..where((t) => t.id.equals(taskId))).watchSingleOrNull();
});

final taskSubtasksStreamProvider = StreamProvider.family<List<Task>, String>((ref, parentTaskId) {
  final taskDao = ref.watch(taskDaoProvider);
  return taskDao.watchSubtasks(parentTaskId);
});

final parentWorkspaceStreamProvider = StreamProvider.family<Workspace?, String>((ref, workspaceId) {
  final workspaceDao = ref.watch(workspaceDaoProvider);
  return (workspaceDao.select(workspaceDao.workspaces)..where((w) => w.id.equals(workspaceId))).watchSingleOrNull();
});

final updateTaskDetailUseCaseProvider = Provider<UpdateTaskDetailUseCase>((ref) {
  return UpdateTaskDetailUseCase(ref.watch(taskDaoProvider));
});

final toggleSubtaskUseCaseProvider = Provider<ToggleSubtaskUseCase>((ref) {
  return ToggleSubtaskUseCase(ref.watch(taskDaoProvider));
});

final taskActionUseCaseProvider = Provider<TaskActionUseCase>((ref) {
  return TaskActionUseCase(ref.watch(taskDaoProvider));
});

class TaskDetailActionNotifier extends StateNotifier<AsyncValue<void>> {
  final Ref _ref;

  TaskDetailActionNotifier(this._ref) : super(const AsyncData(null));

  Future<void> updateTask({
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
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final useCase = _ref.read(updateTaskDetailUseCaseProvider);
      await useCase.execute(
        taskId: taskId,
        name: name,
        description: description,
        priority: priority,
        status: status,
        deadline: deadline,
        estimatedHours: estimatedHours,
        workspaceId: workspaceId,
        sectionId: sectionId,
      );
    });
  }

  Future<void> addSubtask({
    required String parentTaskId,
    required String workspaceId,
    required String title,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final useCase = _ref.read(toggleSubtaskUseCaseProvider);
      await useCase.createSubtask(
        parentTaskId: parentTaskId,
        workspaceId: workspaceId,
        title: title,
      );
    });
  }

  Future<void> toggleSubtask(String subtaskId, bool isDone) async {
    state = await AsyncValue.guard(() async {
      final useCase = _ref.read(toggleSubtaskUseCaseProvider);
      await useCase.toggleSubtaskDone(subtaskId, isDone);
    });
  }

  Future<String?> duplicateTask(String taskId) async {
    state = const AsyncLoading();
    String? newId;
    state = await AsyncValue.guard(() async {
      final useCase = _ref.read(taskActionUseCaseProvider);
      newId = await useCase.duplicateTask(taskId);
    });
    return newId;
  }

  Future<void> softDeleteTask(String taskId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final useCase = _ref.read(taskActionUseCaseProvider);
      await useCase.softDeleteTask(taskId);
    });
  }

  Future<void> restoreTask(String taskId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final useCase = _ref.read(taskActionUseCaseProvider);
      await useCase.restoreTask(taskId);
    });
  }
}

final taskDetailActionProvider =
    StateNotifierProvider<TaskDetailActionNotifier, AsyncValue<void>>((ref) {
  return TaskDetailActionNotifier(ref);
});
