import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../database/daos/reminder_dao.dart';
import 'notification_service.dart';

/// DND Monitoring & Replay Service (PRD F-08).
///
/// Listens to Android DND state via EventChannel.
/// When DND turns OFF, fetches all reminders that fired during DND
/// (missedDnd = true, replayedAt = null) and fires a single consolidated
/// summary notification so the user sees everything they missed.
class DndService {
  static const _methodChannel = MethodChannel('com.aura.aura/dnd');
  static const _eventChannel = EventChannel('com.aura.aura/dnd_events');

  final ReminderDao _reminderDao;
  final NotificationService _notificationService;

  StreamSubscription<dynamic>? _subscription;
  bool _wasDnd = false;

  DndService(this._reminderDao)
      : _notificationService = NotificationService();

  /// Start listening to DND state changes.
  void start() {
    _subscription = _eventChannel
        .receiveBroadcastStream()
        .listen(_onDndStateChanged, onError: _onError);

    // Seed initial DND state
    _checkInitialDndState();
  }

  /// Stop listening — call on app pause / dispose.
  void stop() {
    _subscription?.cancel();
    _subscription = null;
  }

  Future<void> _checkInitialDndState() async {
    try {
      final isDnd = await _methodChannel.invokeMethod<bool>('isDndActive') ?? false;
      _wasDnd = isDnd;
    } catch (_) {
      // Not critical — DND query failure should not crash the app
    }
  }

  void _onDndStateChanged(dynamic isDndActive) {
    final isDnd = isDndActive as bool? ?? false;

    // DND turned OFF → replay missed reminders
    if (_wasDnd && !isDnd) {
      _replayMissedReminders();
    }

    _wasDnd = isDnd;
  }

  void _onError(dynamic error) {
    // Swallow errors — DND monitoring is best-effort
  }

  Future<void> _replayMissedReminders() async {
    try {
      final missed = await _reminderDao.getDndMissedUnreplayed();
      if (missed.isEmpty) return;

      final now = DateTime.now().millisecondsSinceEpoch;

      // Mark all as replayed
      for (final rem in missed) {
        await _reminderDao.markReplayed(rem.id, now);
      }

      // Fire a single consolidated summary notification (ID: 9999 reserved for DND replay)
      final count = missed.length;
      await _notificationService.showInstantNotification(
        id: 9999,
        title: '🔕 While you were in DND',
        body: count == 1
            ? 'You missed 1 reminder. Tap to review.'
            : 'You missed $count reminders. Tap to review.',
        payload: 'dnd_replay',
      );
    } catch (_) {
      // Never crash the app on replay failure
    }
  }
}

// ── Riverpod Provider ─────────────────────────────────────────────────────────

final dndServiceProvider = Provider<DndService>((ref) {
  final reminderDao = ref.watch(reminderDaoProvider);
  final service = DndService(reminderDao);
  service.start();
  ref.onDispose(service.stop);
  return service;
});
