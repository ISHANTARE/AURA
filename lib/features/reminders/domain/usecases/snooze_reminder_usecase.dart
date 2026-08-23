import '../../../../database/app_database.dart';
import '../entities/reminder_models.dart';
import '../services/reminder_scheduling_service.dart';

/// Snoozes a reminder through the single [ReminderSchedulingService] path:
/// the DB (`fireAt`) and the OS notification move together, so overdue stats
/// and Today's Focus reflect the snoozed time instead of the original one.
class SnoozeReminderUseCase {
  final AppDatabase _db;
  final ReminderSchedulingService _scheduling;

  SnoozeReminderUseCase({
    required AppDatabase db,
    ReminderSchedulingService? scheduling,
  })  : _db = db,
        _scheduling = scheduling ?? ReminderSchedulingService(db: db);

  /// Snooze a reminder using a preset or custom DateTime
  Future<void> execute({
    required String reminderId,
    required String taskTitle,
    required String taskId,
    required SnoozePreset preset,
    DateTime? customDateTime,
  }) async {
    final targetTime = preset.calculateTargetTime(customTime: customDateTime);

    final item = await ItemDao(_db).getById(taskId);
    if (item == null) return;

    await _scheduling.snooze(item: item, target: targetTime, title: taskTitle);
  }
}
