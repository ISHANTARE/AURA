import 'package:drift/drift.dart';
import '../../../../database/app_database.dart';

class UpdateTaskDetailUseCase {
  final ItemDao _itemDao;

  UpdateTaskDetailUseCase(this._itemDao);

  Future<void> execute({
    required String itemId,
    String? title,
    String? notes,
    String? priority,
    String? status,
    DateTime? deadline,
  }) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    await _itemDao.updateItemPartial(
      ItemsCompanion(
        id: Value(itemId),
        title: title != null ? Value(title) : const Value.absent(),
        notes: notes != null ? Value(notes) : const Value.absent(),
        priority: priority != null ? Value(priority) : const Value.absent(),
        status: status != null ? Value(status) : const Value.absent(),
        deadline: deadline != null ? Value(deadline.millisecondsSinceEpoch) : const Value.absent(),
        updatedAt: Value(now),
      ),
    );
  }
}
