import '../../../../database/app_database.dart';
import '../../data/services/notification_service.dart';
import '../services/notification_ids.dart';

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
        final firedTimeMs = log.firedAt ?? log.scheduledAt;
        // Clamp negative elapsed times (clock drift / future schedules).
        final elapsedMinutes =
            ((nowMs - firedTimeMs) / 60000).floor().clamp(0, 24 * 60);
        final timeAgo = elapsedMinutes < 60
            ? '$elapsedMinutes mins ago'
            : '${(elapsedMinutes / 60).round()} hrs ago';

        await _notificationService.showInstantNotification(
          id: NotificationIds.forReminder(log.reminderId),
          title: 'Missed while silent',
          body: 'Scheduled $timeAgo · Tap to view details',
          payload: await _itemPayloadFor(log.reminderId),
        );
      } else {
        await _notificationService.showInstantNotification(
          id: NotificationIds.dndCatchup, // stable — replaces prior summary
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

    // Secondary fallback: pending items due within the last 12 hours.
    final twelveHoursAgo = nowMs - (12 * 3600 * 1000);
    final activeItems = await _db.itemDao.watchAllActive().first;
    final missedDndItems = activeItems.where((t) {
      if (t.status == 'completed') return false;
      final time = t.fireAt ?? t.deadline;
      return time != null && time >= twelveHoursAgo && time <= nowMs;
    }).toList();

    if (missedDndItems.isEmpty) return 0;

    await _notificationService.showInstantNotification(
      id: NotificationIds.dndCatchup,
      title: 'Missed Reminders Catchup',
      body:
          'You have ${missedDndItems.length} pending items from earlier today.',
      payload: 'route:/briefing',
    );

    return missedDndItems.length;
  }

  /// Maps a RemindersSchedule row back to its owning item for tap-through.
  Future<String> _itemPayloadFor(String reminderRowId) async {
    try {
      final rows = await (_db.select(_db.remindersSchedule)
            ..where((r) => r.id.equals(reminderRowId)))
          .getSingleOrNull();
      if (rows != null) return 'item:${rows.itemId}';
    } catch (_) {
      // Fall through to the briefing route below.
    }
    return 'route:/briefing';
  }
}
