import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/connectivity_service.dart';

export '../services/connectivity_service.dart' show connectivityServiceProvider;

/// Live online/offline state as a reactive stream.
///
/// Seeded with an immediate connectivity probe so consumers never see a stale
/// default while the first platform event arrives.
final isOnlineProvider = StreamProvider<bool>((ref) {
  final service = ref.watch(connectivityServiceProvider);
  return () async* {
    yield await service.isOnline();
    yield* service.onConnectivityChanged;
  }();
});
