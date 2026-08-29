import 'package:flutter_test/flutter_test.dart';

import 'package:aura/core/services/notification_ids.dart';

void main() {
  group('NotificationIds — FNV-1a Codec Tests', () {
    test('forItem returns a positive 31-bit integer', () {
      final id = NotificationIds.forItem('abc-123');
      expect(id, isA<int>());
      expect(id >= 0, true);
      expect(id <= 0x7FFFFFFF, true);
    });

    test('forReminder returns a positive 31-bit integer', () {
      final id = NotificationIds.forReminder('rem-456');
      expect(id, isA<int>());
      expect(id >= 0, true);
      expect(id <= 0x7FFFFFFF, true);
    });

    test('forItemWeekday returns a positive 31-bit integer', () {
      final id = NotificationIds.forItemWeekday('uuid-xyz', 3);
      expect(id, isA<int>());
      expect(id >= 0, true);
    });

    test('forSnooze returns a positive 31-bit integer', () {
      final id = NotificationIds.forSnooze('uuid-snooze');
      expect(id, isA<int>());
      expect(id >= 0, true);
    });

    test('Different namespaces produce different IDs for the same UUID', () {
      const uuid = '8f3a9c21-b1c2-4d5e-87f6-aabbbccc1234';
      final itemId = NotificationIds.forItem(uuid);
      final remId = NotificationIds.forReminder(uuid);
      final snoozeId = NotificationIds.forSnooze(uuid);
      final wdId = NotificationIds.forItemWeekday(uuid, 1);

      expect(itemId, isNot(equals(remId)));
      expect(itemId, isNot(equals(snoozeId)));
      expect(itemId, isNot(equals(wdId)));
      expect(remId, isNot(equals(snoozeId)));
    });

    test('Distinct UUIDs produce distinct forItem IDs (no collision)', () {
      final uuids = List.generate(
        200,
        (i) => 'item-uuid-$i-${i * 37}-${i * 7919}',
      );
      final ids = uuids.map(NotificationIds.forItem).toSet();
      // All IDs must be unique.
      expect(ids.length, uuids.length);
    });

    test('Distinct UUIDs produce distinct forReminder IDs (no collision)', () {
      final uuids = List.generate(
        200,
        (i) => 'rem-uuid-$i-${i * 53}-${i * 8191}',
      );
      final ids = uuids.map(NotificationIds.forReminder).toSet();
      expect(ids.length, uuids.length);
    });

    test('forItemWeekday is unique across all 7 weekdays for same UUID', () {
      const uuid = 'weekly-alarm-uuid-001';
      final ids = [1, 2, 3, 4, 5, 6, 7]
          .map((wd) => NotificationIds.forItemWeekday(uuid, wd))
          .toList();
      expect(ids.toSet().length, 7); // All 7 must be unique.
    });

    test('Reserved system IDs match specification', () {
      expect(NotificationIds.briefing, 10001);
      expect(NotificationIds.overdueSummary, 10002);
      expect(NotificationIds.nudge, 10003);
      expect(NotificationIds.dndCatchup, 10004);
      expect(NotificationIds.offlineReview, 10005);
    });

    test('forItem is deterministic across calls', () {
      const uuid = 'deterministic-test-uuid';
      expect(
        NotificationIds.forItem(uuid),
        NotificationIds.forItem(uuid),
      );
    });

    test('System singleton IDs do not collide with typical hashed IDs', () {
      final singletons = {
        NotificationIds.briefing,
        NotificationIds.overdueSummary,
        NotificationIds.nudge,
        NotificationIds.dndCatchup,
        NotificationIds.offlineReview,
      };
      // Hashed IDs are >= 0x811C9DC5 & 0x7FFFFFFF; reserved are <= 10005.
      // Verify no typical UUIDs hash to system IDs.
      final testUuids = List.generate(1000, (i) => 'test-uuid-$i');
      for (final uuid in testUuids) {
        expect(singletons.contains(NotificationIds.forItem(uuid)), false);
      }
    });
  });
}
