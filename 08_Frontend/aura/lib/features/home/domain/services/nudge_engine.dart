import 'package:shared_preferences/shared_preferences.dart';

import '../../../../database/daos/task_dao.dart';
import '../../../notifications/services/notification_service.dart';

class NudgeEngine {
  final TaskDao _taskDao;
  final NotificationService _notificationService;

  NudgeEngine({
    required TaskDao taskDao,
    NotificationService? notificationService,
  })  : _taskDao = taskDao,
        _notificationService = notificationService ?? NotificationService();

  /// Evaluate context and trigger proactive nudge if criteria met.
  Future<bool> evaluateAndNudge() async {
    final now = DateTime.now();

    // 1. Quiet hours check (11 PM - 7 AM)
    if (now.hour >= 23 || now.hour < 7) {
      return false;
    }

    // 2. Max 3 nudges per day constraint
    final prefs = await SharedPreferences.getInstance();
    final todayKey = 'nudge_count_${now.year}_${now.month}_${now.day}';
    final currentCount = prefs.getInt(todayKey) ?? 0;
    if (currentCount >= 3) {
      return false;
    }

    // 3. Find urgent or high priority tasks
    final activeTasks = await _taskDao.getAll();
    final highPriority = activeTasks.where((t) {
      return t.status != 'done' && t.priority == 'high';
    }).toList();

    if (highPriority.isEmpty) {
      return false;
    }

    final targetTask = highPriority.first;

    // Trigger Nudge Notification
    await _notificationService.showNotification(
      id: 'nudge_${targetTask.id}'.hashCode.abs(),
      title: 'Proactive Nudge 💡',
      body: 'Focus time: Ready to complete "${targetTask.name}"?',
      channelId: NotificationService.channelNudgesId,
      payload: 'route:/task/${targetTask.id}',
    );

    await prefs.setInt(todayKey, currentCount + 1);
    return true;
  }
}
