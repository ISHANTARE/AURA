import 'package:flutter/services.dart';

import '../../../core/services/notification_ids.dart';
import '../../../core/services/notification_service.dart';
import '../../../database/daos/notification_dao.dart';

/// Monitors Android DND (Do Not Disturb) broadcast events and replays any
/// notifications that were missed while DND was active.
///
/// Listens on the `com.aura.aura/dnd_events` EventChannel. When DND
/// transitions from active to inactive, [ReplayDndNotificationsUseCase]
/// is invoked to catch up missed reminders.
class DndService {
  static const _channel = EventChannel('com.aura.aura/dnd_events');

  final NotificationDao _notificationDao;
  final NotificationService _notificationService;

  DndService({
    required NotificationDao notificationDao,
    required NotificationService notificationService,
  })  : _notificationDao = notificationDao,
        _notificationService = notificationService;

  bool _isDnd = false;

  /// Starts listening to DND state transitions from the Kotlin native layer.
  void startListening() {
    _channel.receiveBroadcastStream().listen(
      (event) async {
        final isDndNow = event as bool;
        if (_isDnd && !isDndNow) {
          // DND has just ended — replay missed notifications.
          await ReplayDndNotificationsUseCase(
            notificationDao: _notificationDao,
            notificationService: _notificationService,
          ).execute();
        }
        _isDnd = isDndNow;
      },
      onError: (_) {}, // Platform not wired; silently ignore.
    );
  }
}

/// Replays notifications that were missed during DND.
///
/// - 1 missed item → fires an individual "Missed while silent" reminder.
/// - >1 missed items → fires a summary catchup notification (ID: 10004).
class ReplayDndNotificationsUseCase {
  final NotificationDao _notificationDao;
  final NotificationService _notificationService;

  ReplayDndNotificationsUseCase({
    required NotificationDao notificationDao,
    required NotificationService notificationService,
  })  : _notificationDao = notificationDao,
        _notificationService = notificationService;

  Future<void> execute() async {
    final nowMs = DateTime.now().millisecondsSinceEpoch;
    final unreplayed = await _notificationDao.getUnreplayed();
    if (unreplayed.isEmpty) return;

    if (unreplayed.length == 1) {
      final log = unreplayed.first;
      final minutesAgo = (nowMs - log.scheduledAt) ~/ 60000;
      await _notificationService.showImmediate(
        id: NotificationIds.dndCatchup,
        title: 'Missed while silent',
        body: 'Scheduled ${minutesAgo}m ago',
        payload: 'rem:${log.reminderId}',
      );
    } else {
      await _notificationService.showImmediate(
        id: NotificationIds.dndCatchup,
        title: 'DND Catchup',
        body: 'You missed ${unreplayed.length} reminders while DND was active',
        payload: 'route:/briefing',
      );
    }

    // Mark all as replayed.
    for (final log in unreplayed) {
      await _notificationDao.markReplayed(log.id, nowMs);
    }
  }
}
