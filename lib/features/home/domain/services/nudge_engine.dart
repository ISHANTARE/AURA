import 'package:shared_preferences/shared_preferences.dart';

import '../../../../database/daos/item_dao.dart';
import '../../../reminders/data/services/notification_service.dart';
import '../../../reminders/domain/services/notification_ids.dart';

/// Proactive nudges: gentle single-item prompts when the user opens AURA.
class NudgeEngine {
  final ItemDao _itemDao;
  final NotificationService _notificationService;

  /// Minimum spacing between two nudges — a date-keyed counter alone allowed
  /// three nudges within one minute of rapid app switching.
  static const Duration _minSpacing = Duration(hours: 3);

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

    final prefs = await SharedPreferences.getInstance();

    // Spacing guard: at most one nudge every [_minSpacing].
    final lastMs = prefs.getInt('last_nudge_ms') ?? 0;
    if (now.millisecondsSinceEpoch - lastMs < _minSpacing.inMilliseconds) {
      return false;
    }

    // Daily cap (belt to the suspenders above).
    final todayKey = 'nudge_count_${now.year}_${now.month}_${now.day}';
    final currentCount = prefs.getInt(todayKey) ?? 0;
    if (currentCount >= 3) return false;

    // Find urgent items.
    final activeItems = await _itemDao.getAllActive();
    final highPriority = activeItems
        .where((t) => t.status != 'completed' && t.priority == 'high')
        .toList();

    if (highPriority.isEmpty) return false;

    // Rotate through targets instead of nagging the same item forever.
    final index = prefs.getInt('nudge_rotate_idx') ?? 0;
    final targetItem = highPriority[index % highPriority.length];
    await prefs.setInt('nudge_rotate_idx', (index + 1) % highPriority.length);

    await _notificationService.showInstantNotification(
      id: NotificationIds.nudge,
      title: 'Proactive Nudge',
      body: 'Focus time: Ready to complete "${targetItem.title}"?',
      payload: 'item:${targetItem.id}',
    );

    await prefs.setInt(todayKey, currentCount + 1);
    await prefs.setInt('last_nudge_ms', now.millisecondsSinceEpoch);
    return true;
  }
}
