import 'package:flutter_test/flutter_test.dart';
import 'package:aura/features/reminders/domain/services/notification_ids.dart';

void main() {
  group('NotificationIds (deterministic codec)', () {
    test('is deterministic for the same key', () {
      expect(NotificationIds.forItem('abc-123'),
          NotificationIds.forItem('abc-123'));
      expect(NotificationIds.forReminder('rem-1'),
          NotificationIds.forReminder('rem-1'));
    });

    test('differs across namespaces and inputs', () {
      final ids = <int>{
        NotificationIds.forItem('x'),
        NotificationIds.forSnooze('x'),
        NotificationIds.forReminder('x'),
        NotificationIds.forItemWeekday('x', 1),
        NotificationIds.forItemWeekday('x', 2),
      };
      expect(ids.length, 5, reason: 'namespaced keys must not collide');
    });

    test('always returns positive int31 values', () {
      const keys = [
        '', 'item:', 'item:zzzz', 'snooze:😀', 'item:some-uuid-4f9c2b',
        'rem:0', 'item:0:wd7',
      ];
      for (final k in keys) {
        final id = notificationId(k);
        expect(id, greaterThanOrEqualTo(0));
        expect(id, lessThanOrEqualTo(0x7FFFFFFF));
      }
    });

    test('pinned golden vectors — changing these breaks upgrade cancels', () {
      // If any of these change, previously scheduled notifications become
      // uncancellable and the notif_scheme_migrated_v2 sweep must be
      // re-triggered for every install.
      expect(notificationId(''), 18652613);
      expect(notificationId('a'), 1678518572);
      expect(notificationId('b'), 1728851429);
      expect(notificationId('item:test-alarm'), 1598386380);
      expect(notificationId('snooze:x'), 1459903717);
      expect(notificationId('rem:abc'), 1988023241);
      expect(NotificationIds.forItem('test-alarm'),
          notificationId('item:test-alarm'));
    });

    test('reserved system slots are in the low stable range', () {
      const reserved = [
        NotificationIds.briefing,
        NotificationIds.overdueSummary,
        NotificationIds.nudge,
        NotificationIds.dndCatchup,
        NotificationIds.offlineReview,
      ];
      for (final id in reserved) {
        expect(id, lessThan(20000));
      }
    });
  });
}
