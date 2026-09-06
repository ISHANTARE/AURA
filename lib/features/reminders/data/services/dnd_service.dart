import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/providers.dart';
import '../../domain/usecases/replay_dnd_notifications_usecase.dart';

/// DND Monitoring & Replay Service (PRD F-08).
class DndService {
  static const _methodChannel = MethodChannel('com.aura.aura/dnd');
  static const _eventChannel = EventChannel('com.aura.aura/dnd_events');

  // ignore: unused_field
  final AppDatabase _db;
  final ReplayDndNotificationsUseCase _replayDndUseCase;

  StreamSubscription<dynamic>? _subscription;
  bool _wasDnd = false;
  bool _stopped = false;
  Timer? _retryTimer;

  DndService(this._db, {ReplayDndNotificationsUseCase? replayDndUseCase})
      : _replayDndUseCase =
            replayDndUseCase ?? ReplayDndNotificationsUseCase(db: _db);

  /// Start listening to DND state changes.
  /// Retries if the native channel isn't ready yet (cold-start race condition).
  void start() {
    _stopped = false;
    _trySubscribe();
    _checkInitialDndState();
  }

  void _trySubscribe() {
    if (_stopped) return;
    _subscription?.cancel();
    _subscription = _eventChannel
        .receiveBroadcastStream()
        .listen(_onDndStateChanged, onError: (dynamic error) {
      // MissingPluginException: channel not registered yet — retry in 2s.
      if (error is PlatformException || error is MissingPluginException) {
        _scheduleRetry();
      }
    });
  }

  void _scheduleRetry() {
    _retryTimer?.cancel();
    if (_stopped) return;
    _retryTimer = Timer(const Duration(seconds: 2), _trySubscribe);
  }

  void stop() {
    _stopped = true;
    _retryTimer?.cancel();
    _retryTimer = null;
    _subscription?.cancel();
    _subscription = null;
  }

  Future<void> _checkInitialDndState() async {
    try {
      final isDnd =
          await _methodChannel.invokeMethod<bool>('isDndActive') ?? false;
      _wasDnd = isDnd;
    } catch (_) {}
  }

  void _onDndStateChanged(dynamic isDndActive) {
    final isDnd = isDndActive as bool? ?? false;
    if (_wasDnd && !isDnd) {
      _replayMissedReminders();
    }
    _wasDnd = isDnd;
  }

  Future<void> _replayMissedReminders() async {
    await _replayDndUseCase.execute();
  }
}

final dndServiceProvider = Provider<DndService>((ref) {
  final db = ref.watch(databaseProvider);
  final service = DndService(db);
  service.start();
  ref.onDispose(service.stop);
  return service;
});
