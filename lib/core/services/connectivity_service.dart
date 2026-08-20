import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Network Connectivity Monitor Service (Sprint 7)
/// Uses connectivity_plus to stream online/offline network status.
class ConnectivityService {
  final Connectivity _connectivity = Connectivity();
  final StreamController<bool> _isOnlineController =
      StreamController<bool>.broadcast();

  StreamSubscription<List<ConnectivityResult>>? _subscription;

  ConnectivityService() {
    _subscription = _connectivity.onConnectivityChanged.listen(_updateState);
    _checkInitialState();
  }

  /// Stream emitting `true` when online, `false` when offline.
  Stream<bool> get onConnectivityChanged => _isOnlineController.stream;

  /// Check current online status asynchronously.
  Future<bool> isOnline() async {
    final results = await _connectivity.checkConnectivity();
    return _isOnline(results);
  }

  void _checkInitialState() async {
    final results = await _connectivity.checkConnectivity();
    _isOnlineController.add(_isOnline(results));
  }

  void _updateState(List<ConnectivityResult> results) {
    _isOnlineController.add(_isOnline(results));
  }

  bool _isOnline(List<ConnectivityResult> results) {
    return results.any((r) => r != ConnectivityResult.none);
  }

  void dispose() {
    _subscription?.cancel();
    _isOnlineController.close();
  }
}

// ── Riverpod Providers ────────────────────────────────────────────────────────

final connectivityServiceProvider = Provider<ConnectivityService>((ref) {
  final service = ConnectivityService();
  ref.onDispose(service.dispose);
  return service;
});

final isOnlineProvider = StreamProvider<bool>((ref) {
  final service = ref.watch(connectivityServiceProvider);
  return service.onConnectivityChanged;
});
