import '../../../../database/daos/task_dao.dart';
import '../../../notifications/services/notification_service.dart';

class OverdueReminderUseCase {
  final TaskDao _taskDao;
  final NotificationService _notificationService;

  OverdueReminderUseCase({
    required TaskDao taskDao,
    NotificationService? notificationService,
  })  : _taskDao = taskDao,
        _notificationService = notificationService ?? NotificationService();

  /// Check overdue tasks and send non-spam notification if needed.
  Future<int> execute() async {
    final overdueTasks = await _taskDao.getOverdueTasks();
    if (overdueTasks.isEmpty) return 0;

    final count = overdueTasks.length;
    final firstTask = overdueTasks.first;

    final String title = count == 1
        ? 'Task Overdue 🔴'
        : '$count Tasks Overdue 🔴';

    final String body = count == 1
        ? '${firstTask.name} is past deadline. Mark done or update deadline.'
        : '${firstTask.name} and ${count - 1} other tasks need your attention.';

    await _notificationService.showNotification(
      id: 'overdue_summary'.hashCode.abs(),
      title: title,
      body: body,
      channelId: NotificationService.channelRemindersId,
      payload: 'route:/home',
    );

    return count;
  }
}
