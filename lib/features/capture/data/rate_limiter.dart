import 'dart:async';

/// Clock function type for deterministic unit testing.
typedef Clock = DateTime Function();

/// Sliding-window rate limiter.
///
/// Ensures no more than [maxRequests] are permitted within any rolling [windowDuration].
/// If the limit is reached, [acquire] asynchronously waits until the oldest request
/// in the window ages out.
class RateLimiter {
  final int maxRequests;
  final Duration windowDuration;
  final Clock _clock;

  final List<DateTime> _timestamps = [];

  RateLimiter({
    this.maxRequests = 12,
    this.windowDuration = const Duration(seconds: 60),
    Clock? clock,
  }) : _clock = clock ?? DateTime.now;

  /// Number of active requests currently tracked in the sliding window.
  int get activeCount {
    _pruneOldTimestamps();
    return _timestamps.length;
  }

  /// Removes timestamps that are older than [windowDuration] relative to now.
  void _pruneOldTimestamps() {
    final now = _clock();
    final cutoff = now.subtract(windowDuration);
    _timestamps.removeWhere((ts) => ts.isBefore(cutoff));
  }

  /// Returns how long a caller must wait before a request slot becomes available.
  /// Returns [Duration.zero] if a slot is available immediately.
  Duration waitDuration() {
    _pruneOldTimestamps();
    if (_timestamps.length < maxRequests) {
      return Duration.zero;
    }
    final now = _clock();
    final oldest = _timestamps.first;
    final expiresAt = oldest.add(windowDuration);
    final diff = expiresAt.difference(now);
    return diff.isNegative ? Duration.zero : diff;
  }

  /// Acquires a slot in the rate limiter, awaiting if the quota is currently exhausted.
  Future<void> acquire() async {
    while (true) {
      _pruneOldTimestamps();
      if (_timestamps.length < maxRequests) {
        _timestamps.add(_clock());
        return;
      }

      final wait = waitDuration();
      if (wait > Duration.zero) {
        await Future<void>.delayed(wait);
      }
    }
  }

  /// Resets all tracked timestamps.
  void reset() {
    _timestamps.clear();
  }
}
