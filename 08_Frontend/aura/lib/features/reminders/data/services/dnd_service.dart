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

  DndService(this._db, {ReplayDndNotificationsUseCase? replayDndUseCase})
      : _replayDndUseCase =
            replayDndUseCase ?? ReplayDndNotificationsUseCase(db: _db);

  /// Start listening to DND state changes.
  void start() {
    _subscription = _eventChannel
        .receiveBroadcastStream()
        .listen(_onDndStateChanged, onError: _onError);

    _checkInitialDndState();
  }

  void stop() {
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

  void _onError(dynamic error) {}

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
