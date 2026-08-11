import 'package:shared_preferences/shared_preferences.dart';

import '../../../../database/daos/item_dao.dart';
import '../../../notifications/services/notification_service.dart';

class NudgeEngine {
  final ItemDao _itemDao;
  final NotificationService _notificationService;

  NudgeEngine({
    required ItemDao itemDao,
    NotificationService? notificationService,
  })  : _itemDao = itemDao,
        _notificationService = notificationService ?? NotificationService();

  /// Evaluate context and trigger proactive nudge if criteria met.
  Future<bool> evaluateAndNudge() async {
    final now = DateTime.now();

    // Quiet hours check (11 PM - 7 AM)
    if (now.hour >= 23 || now.hour < 7) return false;

    // Max 3 nudges per day constraint
    final prefs = await SharedPreferences.getInstance();
    final todayKey = 'nudge_count_${now.year}_${now.month}_${now.day}';
    final currentCount = prefs.getInt(todayKey) ?? 0;
    if (currentCount >= 3) return false;

    // Find urgent items
    final activeItems = await _itemDao.watchAllActive().first;
    final highPriority = activeItems.where((t) {
      return t.status != 'completed' && t.priority == 'high';
    }).toList();

    if (highPriority.isEmpty) return false;

    final targetItem = highPriority.first;

    await _notificationService.showNotification(
      id: 'nudge_${targetItem.id}'.hashCode.abs(),
      title: 'Proactive Nudge 💡',
      body: 'Focus time: Ready to complete "${targetItem.title}"?',
      channelId: NotificationService.channelNudgesId,
      payload: 'route:/item/${targetItem.id}',
    );

    await prefs.setInt(todayKey, currentCount + 1);
    return true;
  }
}
