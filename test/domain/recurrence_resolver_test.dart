import 'package:flutter_test/flutter_test.dart';
import 'package:aura/features/reminders/domain/services/recurrence_resolver.dart';

void main() {
  group('RecurrenceResolver.parseWeekdays', () {
    test('parses DAYS rules', () {
      expect(RecurrenceResolver.parseWeekdays('DAYS:1,3,5'), {1, 3, 5});
      expect(RecurrenceResolver.parseWeekdays('days:2'), {2});
      expect(RecurrenceResolver.parseWeekdays('DAYS: 1 , 7'), {1, 7});
    });

    test('returns null for non-weekday rules', () {
      expect(RecurrenceResolver.parseWeekdays('daily'), isNull);
      expect(RecurrenceResolver.parseWeekdays('SPECIFIC_DATE:2026-09-01'), isNull);
      expect(RecurrenceResolver.parseWeekdays(null), isNull);
    });

    test('drops out-of-range tokens', () {
      expect(RecurrenceResolver.parseWeekdays('DAYS:0,8,3'), {3});
      expect(RecurrenceResolver.parseWeekdays('DAYS:x,y'), isEmpty);
    });
  });

  group('RecurrenceResolver.nextOccurrence', () {
    // Mon 2026-08-24 10:00 local.
    final monday10 = DateTime(2026, 8, 24, 10, 0);
    final after = DateTime(2026, 8, 24, 11, 0);

    test('weekday rule: same-day slot already passed → next matching weekday',
        () {
      // Rule includes Monday (1): 10:00 already passed at 11:00 → next Mon.
      final next = RecurrenceResolver.nextOccurrence(
        recurrenceRule: 'DAYS:1',
        isRecurring: true,
        anchor: monday10,
        after: after,
      );
      expect(next, DateTime(2026, 8, 31, 10, 0));
    });

    test('weekday rule: multi-day set picks the nearest future weekday', () {
      // Mon after 11:00; next in {Tue(2), Thu(4)} is Tue 10:00.
      final next = RecurrenceResolver.nextOccurrence(
        recurrenceRule: 'DAYS:2,4',
        isRecurring: true,
        anchor: monday10,
        after: after,
      );
      expect(next, DateTime(2026, 8, 25, 10, 0));
    });

    test('weekday rule: future slot later today is used', () {
      final next = RecurrenceResolver.nextOccurrence(
        recurrenceRule: 'DAYS:1',
        isRecurring: true,
        anchor: DateTime(2026, 8, 24, 10, 0),
        after: DateTime(2026, 8, 24, 9, 0),
      );
      expect(next, DateTime(2026, 8, 24, 10, 0));
    });

    test('SPECIFIC_DATE: future date at anchor time', () {
      final next = RecurrenceResolver.nextOccurrence(
        recurrenceRule: 'SPECIFIC_DATE:2026-12-25',
        isRecurring: false,
        anchor: monday10,
        after: after,
      );
      expect(next, DateTime(2026, 12, 25, 10, 0));
    });

    test('SPECIFIC_DATE: past date → null (one-shot never repeats)', () {
      final next = RecurrenceResolver.nextOccurrence(
        recurrenceRule: 'SPECIFIC_DATE:2026-01-01',
        isRecurring: false,
        anchor: monday10,
        after: after,
      );
      expect(next, isNull);
    });

    test('daily-style cadence: next day at anchor time', () {
      final next = RecurrenceResolver.nextOccurrence(
        recurrenceRule: 'daily',
        isRecurring: true,
        anchor: monday10,
        after: after,
      );
      expect(next, DateTime(2026, 8, 25, 10, 0));
    });

    test('null rule with isRecurring falls back to daily-style', () {
      final next = RecurrenceResolver.nextOccurrence(
        recurrenceRule: null,
        isRecurring: true,
        anchor: monday10,
        after: after,
      );
      expect(next, DateTime(2026, 8, 25, 10, 0));
    });

    test('empty weekday set → null', () {
      final next = RecurrenceResolver.nextOccurrence(
        recurrenceRule: 'DAYS:',
        isRecurring: true,
        anchor: monday10,
        after: after,
      );
      expect(next, isNull);
    });

    test('isRecurringRule classifies correctly', () {
      expect(
          RecurrenceResolver.isRecurringRule('DAYS:1,2', isRecurring: false),
          isTrue);
      expect(
          RecurrenceResolver.isRecurringRule('SPECIFIC_DATE:2026-09-09',
              isRecurring: true),
          isFalse);
      expect(RecurrenceResolver.isRecurringRule('daily', isRecurring: true),
          isTrue);
      expect(RecurrenceResolver.isRecurringRule(null, isRecurring: false),
          isFalse);
    });
  });
}
