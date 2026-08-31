import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Minimal contract for online/offline monitoring — lets services and
/// use cases stay testable without touching platform channels.
abstract class ConnectivityMonitor {
  Stream<bool> get onConnectivityChanged;
  Future<bool> isOnline();
}

/// Network Connectivity Monitor Service (Sprint 7)
/// Uses connectivity_plus to stream online/offline network status.
class ConnectivityService implements ConnectivityMonitor {
  final Connectivity _connectivity = Connectivity();
  final StreamController<bool> _isOnlineController =
      StreamController<bool>.broadcast();

  StreamSubscription<List<ConnectivityResult>>? _subscription;

  ConnectivityService() {
    _subscription = _connectivity.onConnectivityChanged.listen(_updateState);
    _checkInitialState();
  }

  @override
  Stream<bool> get onConnectivityChanged => _isOnlineController.stream;

  @override
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
// The canonical reactive online/offline providers live in
// core/providers/connectivity_provider.dart (built on this service).

final connectivityServiceProvider = Provider<ConnectivityService>((ref) {
  final service = ConnectivityService();
  ref.onDispose(service.dispose);
  return service;
});
