import 'package:flutter_test/flutter_test.dart';

import 'package:aura/features/capture/data/rate_limiter.dart';

void main() {
  group('RateLimiter Unit Tests', () {
    late DateTime fakeNow;
    DateTime clock() => fakeNow;

    setUp(() {
      fakeNow = DateTime(2026, 8, 29, 12, 0, 0);
    });

    test('allows up to maxRequests immediately without waiting', () async {
      final limiter = RateLimiter(
        maxRequests: 5,
        windowDuration: const Duration(seconds: 10),
        clock: clock,
      );

      for (var i = 0; i < 5; i++) {
        expect(limiter.waitDuration(), Duration.zero);
        await limiter.acquire();
      }

      expect(limiter.activeCount, 5);
      expect(limiter.waitDuration(), const Duration(seconds: 10));
    });

    test('reports waitDuration correctly when window is full', () async {
      final limiter = RateLimiter(
        maxRequests: 2,
        windowDuration: const Duration(seconds: 60),
        clock: clock,
      );

      await limiter.acquire();
      fakeNow = fakeNow.add(const Duration(seconds: 10));
      await limiter.acquire();

      expect(limiter.activeCount, 2);
      // Oldest was at T+0, expires at T+60. Current time is T+10. Wait should be 50s.
      expect(limiter.waitDuration(), const Duration(seconds: 50));
    });

    test('prunes expired timestamps when clock advances past window', () async {
      final limiter = RateLimiter(
        maxRequests: 2,
        windowDuration: const Duration(seconds: 30),
        clock: clock,
      );

      await limiter.acquire();
      await limiter.acquire();
      expect(limiter.activeCount, 2);

      // Advance clock by 31s
      fakeNow = fakeNow.add(const Duration(seconds: 31));
      expect(limiter.activeCount, 0);
      expect(limiter.waitDuration(), Duration.zero);
    });

    test('reset clears all tracked timestamps', () async {
      final limiter = RateLimiter(
        maxRequests: 3,
        windowDuration: const Duration(seconds: 30),
        clock: clock,
      );

      await limiter.acquire();
      await limiter.acquire();
      expect(limiter.activeCount, 2);

      limiter.reset();
      expect(limiter.activeCount, 0);
      expect(limiter.waitDuration(), Duration.zero);
    });
  });
}
