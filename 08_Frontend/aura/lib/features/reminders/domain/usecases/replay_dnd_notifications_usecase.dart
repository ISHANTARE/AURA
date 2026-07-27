import '../../../../database/daos/notification_dao.dart';
import '../../../../database/daos/reminder_dao.dart';
import '../../../../database/daos/task_dao.dart';
import '../../../notifications/services/notification_service.dart';

class ReplayDndNotificationsUseCase {
  final NotificationDao _notificationDao;
  final ReminderDao _reminderDao;
  final TaskDao _taskDao;
  final NotificationService _notificationService;

  ReplayDndNotificationsUseCase({
    required NotificationDao notificationDao,
    required ReminderDao reminderDao,
    required TaskDao taskDao,
    NotificationService? notificationService,
  })  : _notificationDao = notificationDao,
        _reminderDao = reminderDao,
        _taskDao = taskDao,
        _notificationService = notificationService ?? NotificationService();

  /// Check for missed DND notifications and dispatch a single batch summary replay.
  Future<int> execute() async {
    final dndMissedReminders = await _reminderDao.getDndMissedUnreplayed();
    final dndLogs = await _notificationDao.getUnreplayed();

    if (dndMissedReminders.isEmpty && dndLogs.isEmpty) {
      return 0;
    }

    final now = DateTime.now();
    final nowMs = now.millisecondsSinceEpoch;
    final List<String> bulletPoints = [];

    for (final reminder in dndMissedReminders) {
      if (reminder.taskId != null) {
        final task = await _taskDao.getById(reminder.taskId!);
        if (task != null && task.status != 'completed') {
          final elapsedHours = (nowMs - reminder.fireAt) ~/ (1000 * 60 * 60);
          if (elapsedHours >= 2) {
            bulletPoints.add('· ${task.name} (was due $elapsedHours hrs ago)');
          } else {
            bulletPoints.add('· ${task.name}');
          }
        }
      }
      await _reminderDao.markReplayed(reminder.id, nowMs);
    }

    for (final log in dndLogs) {
      await _notificationDao.markReplayed(log.id);
    }

    if (bulletPoints.isNotEmpty) {
      final String summaryBody = bulletPoints.take(3).join('\n') +
          (bulletPoints.length > 3 ? '\n+${bulletPoints.length - 3} more items' : '');

      await _notificationService.showNotification(
        id: 'dnd_replay'.hashCode.abs(),
        title: 'While you were away (DND):',
        body: summaryBody,
        channelId: NotificationService.channelRemindersId,
        payload: 'route:/home',
      );
    }

    return bulletPoints.length;
  }
}
