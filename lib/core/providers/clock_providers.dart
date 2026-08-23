import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

/// App-wide wall-clock day tracker.
///
/// Drift watches react to TABLE CHANGES, not to the calendar — a query built
/// on "today" would otherwise freeze at whatever day its provider was first
/// constructed. Consumers (Today's Focus, quick stats) watch [dayRefreshProvider]
/// so their windows roll over at midnight and correct after long suspends.
class DayRefreshNotifier extends StateNotifier<DateTime> {
  Timer? _timer;

  DayRefreshNotifier() : super(DateTime.now()) {
    _scheduleMidnightTick();
  }

  void _scheduleMidnightTick() {
    _timer?.cancel();
    final now = DateTime.now();
    final nextMidnight = DateTime(now.year, now.month, now.day + 1);
    _timer = Timer(nextMidnight.difference(now), () {
      if (!mounted) return;
      state = DateTime.now();
      _scheduleMidnightTick();
    });
  }

  /// Called from the app-lifecycle `resumed` hook: catches up when the device
  /// was suspended across midnight (timers do not fire while suspended).
  void notifyResumed() {
    final now = DateTime.now();
    if (now.year != state.year || now.month != state.month || now.day != state.day) {
      state = now;
      _scheduleMidnightTick();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

final dayRefreshProvider =
    StateNotifierProvider<DayRefreshNotifier, DateTime>((ref) {
  return DayRefreshNotifier();
});
