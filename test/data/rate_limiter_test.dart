import 'package:flutter_test/flutter_test.dart';
import 'package:aura/features/capture/data/datasources/llm_api_datasource.dart';

void main() {
  group('RateLimiter (sliding window)', () {
    test('allows bursts under the limit without waiting', () async {
      var micros = 0;
      final limiter = RateLimiter(
        maxPerMinute: 3,
        window: const Duration(milliseconds: 100),
        clock: () => DateTime.fromMicrosecondsSinceEpoch(micros += 10000),
      );

      final sw = Stopwatch()..start();
      await limiter.throttle();
      await limiter.throttle();
      await limiter.throttle();
      // Fake clock advances 10ms per call; real elapsed stays tiny.
      expect(sw.elapsedMilliseconds, lessThan(500));
    });

    test('blocks at the limit until the oldest request leaves the window',
        () async {
      var micros = 0;
      final limiter = RateLimiter(
        maxPerMinute: 2,
        window: const Duration(milliseconds: 80),
        clock: () => DateTime.fromMicrosecondsSinceEpoch(micros += 10000),
      );

      await limiter.throttle(); // stamp ~10ms
      await limiter.throttle(); // stamp ~20ms

      final sw = Stopwatch()..start();
      await limiter.throttle(); // must wait for the first stamp to expire
      expect(sw.elapsedMilliseconds, greaterThanOrEqualTo(50),
          reason: 'throttle should actually wait when the window is full');
    });

    test('never exceeds maxPerMinute within one window', () async {
      var micros = 0;
      final limiter = RateLimiter(
        maxPerMinute: 3,
        window: const Duration(milliseconds: 60),
        clock: () => DateTime.fromMicrosecondsSinceEpoch(micros += 10000),
      );

      final stamps = <DateTime>[];
      for (var i = 0; i < 9; i++) {
        await limiter.throttle();
        stamps.add(DateTime.fromMicrosecondsSinceEpoch(micros));
      }

      for (var i = 0; i < stamps.length; i++) {
        final inWindow =
            stamps.where((s) => !s.isBefore(stamps[i])).length; // sanity
        expect(inWindow, lessThanOrEqualTo(9));
      }
      // Strict check: any sliding 60ms fake-time frame holds ≤3 requests.
      for (final anchor in stamps) {
        final count = stamps
            .where((s) => !s.isBefore(anchor) &&
                s.isBefore(anchor.add(const Duration(milliseconds: 60))))
            .length;
        expect(count, lessThanOrEqualTo(3),
            reason: 'window starting at $anchor admitted $count requests');
      }
    });
  });
}
