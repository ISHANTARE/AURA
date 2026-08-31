import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/providers.dart';
import '../../domain/usecases/task_detail_usecases.dart';

final itemDetailStreamProvider = StreamProvider.family<Item?, String>((ref, itemId) {
  final itemDao = ref.watch(itemDaoProvider);
  return itemDao.watchById(itemId);
});

final updateTaskDetailUseCaseProvider = Provider<UpdateTaskDetailUseCase>((ref) {
  return UpdateTaskDetailUseCase(ref.watch(itemDaoProvider));
});

class TaskDetailActionNotifier extends StateNotifier<AsyncValue<void>> {
  final Ref _ref;

  TaskDetailActionNotifier(this._ref) : super(const AsyncData(null));

  Future<void> updateItem({
    required String itemId,
    String? title,
    String? notes,
    String? priority,
    String? status,
    DateTime? deadline,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final useCase = _ref.read(updateTaskDetailUseCaseProvider);
      await useCase.execute(
        itemId: itemId,
        title: title,
        notes: notes,
        priority: priority,
        status: status,
        deadline: deadline,
      );
    });
  }
}

final taskDetailActionProvider =
    StateNotifierProvider<TaskDetailActionNotifier, AsyncValue<void>>((ref) {
  return TaskDetailActionNotifier(ref);
});
