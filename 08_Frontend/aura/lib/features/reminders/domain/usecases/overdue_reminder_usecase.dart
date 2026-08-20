import 'package:shared_preferences/shared_preferences.dart';

import '../../../../database/app_database.dart';
import '../../data/services/notification_service.dart';

/// Scans active items and fires summary notification for overdue tasks (PRD F-07).
class OverdueReminderUseCase {
  final AppDatabase _db;
  final NotificationService _notificationService;

  OverdueReminderUseCase({
    required AppDatabase db,
    NotificationService? notificationService,
  })  : _db = db,
        _notificationService = notificationService ?? NotificationService();

  Future<int> execute() async {
    final now = DateTime.now();
    final todayKey = 'overdue_notif_${now.year}_${now.month}_${now.day}';

    // 1/day max guard
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(todayKey) == true) {
      return 0;
    }

    final activeItems = await _db.itemDao.watchAllActive().first;
    final nowMs = now.millisecondsSinceEpoch;

    final overdueItems = activeItems.where((t) {
      if (t.status == 'completed') return false;
      final deadline = t.deadline ?? t.fireAt;
      return deadline != null && deadline < nowMs;
    }).toList();

    if (overdueItems.isEmpty) return 0;

    final count = overdueItems.length;
    final firstTitle = overdueItems.first.title;

    await _notificationService.showInstantNotification(
      id: 'overdue_summary_$todayKey'.hashCode.abs(),
      title: 'Overdue Task Alert',
      body: count == 1
          ? 'Overdue: "$firstTitle"'
          : '$count tasks overdue. First up: "$firstTitle"',
      payload: 'route:/briefing',
    );

    await prefs.setBool(todayKey, true);
    return count;
  }
}
