import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final connectivityProvider = StreamProvider<bool>((ref) {
  return Connectivity().onConnectivityChanged.map((results) {
    return results.any((result) => result != ConnectivityResult.none);
  });
});

final isOnlineProvider = Provider<bool>((ref) {
  return ref.watch(connectivityProvider).value ?? true;
});
