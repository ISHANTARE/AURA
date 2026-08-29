import 'package:flutter_test/flutter_test.dart';

import 'package:aura/features/reminders/domain/recurrence_resolver.dart';

void main() {
  final base = DateTime(2025, 3, 17, 9, 0); // Monday 2025-03-17 09:00

  group('RecurrenceResolver', () {
    group('daily', () {
      test('returns next day at same time', () {
        final next = RecurrenceResolver.nextOccurrence('daily', base);
        expect(next, DateTime(2025, 3, 18, 9, 0));
      });

      test('chains correctly across month boundary', () {
        final endOfMonth = DateTime(2025, 3, 31, 8, 30);
        final next = RecurrenceResolver.nextOccurrence('daily', endOfMonth);
        expect(next, DateTime(2025, 4, 1, 8, 30));
      });
    });

    group('weekly', () {
      test('returns same time next week', () {
        final next = RecurrenceResolver.nextOccurrence('weekly', base);
        expect(next, DateTime(2025, 3, 24, 9, 0));
      });
    });

    group('DAYS:', () {
      test('resolves to the next matching weekday', () {
        // base is Monday (weekday=1); rule includes Wednesday (3) and Friday (5).
        final next = RecurrenceResolver.nextOccurrence('DAYS:3,5', base);
        expect(next!.weekday, 3); // Wednesday
        expect(next.isAfter(base), true);
      });

      test('resolves correctly when current weekday is the last in the list', () {
        // Friday = weekday 5; rule only includes Mon (1) and Wed (3).
        final friday = DateTime(2025, 3, 21, 9, 0);
        final next = RecurrenceResolver.nextOccurrence('DAYS:1,3', friday);
        expect(next!.weekday, 1); // Monday
      });

      test('returns null for empty DAYS rule', () {
        final next = RecurrenceResolver.nextOccurrence('DAYS:', base);
        expect(next, isNull);
      });

      test('ignores invalid weekday numbers', () {
        // Only valid weekday is 3 (Wednesday); 0 and 8 are invalid.
        final next = RecurrenceResolver.nextOccurrence('DAYS:0,3,8', base);
        expect(next!.weekday, 3);
      });

      test('parseWeekdays extracts correct set', () {
        final days = RecurrenceResolver.parseWeekdays('DAYS:1,3,5');
        expect(days, {1, 3, 5});
      });

      test('parseWeekdays returns empty set for non-DAYS rule', () {
        final days = RecurrenceResolver.parseWeekdays('daily');
        expect(days, isEmpty);
      });
    });

    group('SPECIFIC_DATE:', () {
      test('returns the target date if in the future', () {
        const rule = 'SPECIFIC_DATE:2025-12-25';
        // base is before Dec 25, so it should return Dec 25 at base time.
        final next = RecurrenceResolver.nextOccurrence(rule, base);
        expect(next, isNotNull);
        expect(next!.year, 2025);
        expect(next.month, 12);
        expect(next.day, 25);
      });

      test('returns null for past SPECIFIC_DATE (one-shot expired)', () {
        // target 2020-01-01 is before base (2025-03-17)
        final next =
            RecurrenceResolver.nextOccurrence('SPECIFIC_DATE:2020-01-01', base);
        expect(next, isNull);
      });

      test('returns null for malformed date string', () {
        final next =
            RecurrenceResolver.nextOccurrence('SPECIFIC_DATE:notadate', base);
        expect(next, isNull);
      });

      test('returns null for wrong date parts count', () {
        final next =
            RecurrenceResolver.nextOccurrence('SPECIFIC_DATE:2025-13', base);
        expect(next, isNull);
      });
    });

    group('Unknown / null rules', () {
      test('returns null for unrecognised rule', () {
        final next = RecurrenceResolver.nextOccurrence('biweekly', base);
        expect(next, isNull);
      });

      test('returns null for empty string', () {
        final next = RecurrenceResolver.nextOccurrence('', base);
        expect(next, isNull);
      });
    });
  });
}
