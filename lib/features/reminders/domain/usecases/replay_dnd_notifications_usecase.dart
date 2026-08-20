import '../../../../database/app_database.dart';
import '../../data/services/notification_service.dart';

/// Replays missed notifications after DND window ends (PRD F-08).
class ReplayDndNotificationsUseCase {
  final AppDatabase _db;
  final NotificationService _notificationService;

  ReplayDndNotificationsUseCase({
    required AppDatabase db,
    NotificationService? notificationService,
  })  : _db = db,
        _notificationService = notificationService ?? NotificationService();

  Future<int> execute() async {
    final unreplayedLogs = await _db.notificationDao.getUnreplayed();
    final nowMs = DateTime.now().millisecondsSinceEpoch;

    if (unreplayedLogs.isNotEmpty) {
      if (unreplayedLogs.length == 1) {
        final log = unreplayedLogs.first;
        final firedTime = log.firedAt ?? log.scheduledAt;
        final elapsedMinutes = ((nowMs - firedTime) / 60000).round();
        final timeAgo = elapsedMinutes < 60
            ? '$elapsedMinutes mins ago'
            : '${(elapsedMinutes / 60).round()} hrs ago';

        await _notificationService.showInstantNotification(
          id: 'dnd_${log.id}'.hashCode.abs(),
          title: 'DND Replay: Missed Reminder',
          body: 'Scheduled $timeAgo · Tap to view task details',
          payload: 'item:${log.reminderId}',
        );
      } else {
        await _notificationService.showInstantNotification(
          id: 'dnd_summary_$nowMs'.hashCode.abs(),
          title: 'DND Catchup',
          body:
              'You missed ${unreplayedLogs.length} reminders while Do Not Disturb was active.',
          payload: 'route:/briefing',
        );
      }

      for (final log in unreplayedLogs) {
        await _db.notificationDao.markReplayed(log.id);
      }

      return unreplayedLogs.length;
    }

    // Secondary fallback: query items with deadline/fireAt in the last 12 hours that are pending
    final twelveHoursAgo = nowMs - (12 * 3600 * 1000);
    final activeItems = await _db.itemDao.watchAllActive().first;
    final missedDndItems = activeItems.where((t) {
      if (t.status == 'completed') return false;
      final time = t.fireAt ?? t.deadline;
      return time != null && time >= twelveHoursAgo && time <= nowMs;
    }).toList();

    if (missedDndItems.isEmpty) return 0;

    await _notificationService.showInstantNotification(
      id: 'dnd_catchup_items'.hashCode.abs(),
      title: 'Missed Reminders Catchup',
      body:
          'You have ${missedDndItems.length} pending items from earlier today.',
      payload: 'route:/briefing',
    );

    return missedDndItems.length;
  }
}
