/// Resolves next occurrence times for recurring items.
///
/// Recurrence rule grammar (stored in `Items.recurrenceRule`):
///   `DAYS:1,3,5`              – weekly on the given weekdays (1=Mon … 7=Sun,
///                               matching Dart's DateTime.weekday)
///   `SPECIFIC_DATE:yyyy-MM-dd` – one-shot on that date
///   `daily` / `weekly` / `custom` – simple cadences (manual sheet writes 'daily')
abstract final class RecurrenceResolver {
  static final RegExp _daysRule = RegExp(r'^\s*DAYS:(.*)$', caseSensitive: false);
  static final RegExp _dateRule = RegExp(r'^SPECIFIC_DATE:(\d{4}-\d{2}-\d{2})$');

  /// Parses a `DAYS:` rule into a weekday set. Returns null when [rule] is
  /// not a weekday rule at all; returns an EMPTY set when it is one but
  /// specifies no valid weekdays (a broken rule must not silently become
  /// "every day").
  static Set<int>? parseWeekdays(String? rule) {
    if (rule == null) return null;
    final m = _daysRule.firstMatch(rule.trim().toUpperCase());
    if (m == null) return null;
    final days = m
        .group(1)!
        .split(',')
        .map((s) => int.tryParse(s.trim()))
        .whereType<int>()
        .where((d) => d >= 1 && d <= 7)
        .toSet();
    return days;
  }

  /// Parses a `SPECIFIC_DATE:` rule. Returns null when not a date rule or
  /// malformed.
  static DateTime? parseSpecificDate(String? rule) {
    if (rule == null) return null;
    final m = _dateRule.firstMatch(rule.trim().toUpperCase());
    if (m == null) return null;
    return DateTime.tryParse(m.group(1)!);
  }

  /// True when the rule describes an endlessly repeating cadence (as opposed
  /// to a one-shot SPECIFIC_DATE).
  static bool isRecurringRule(String? rule, {bool isRecurring = false}) {
    if (rule == null) return isRecurring;
    if (_dateRule.hasMatch(rule.trim().toUpperCase())) return false;
    if (_daysRule.hasMatch(rule.trim().toUpperCase())) return true;
    // Legacy/manual values ('daily' | 'weekly' | 'custom').
    return isRecurring;
  }

  /// Next occurrence strictly after [after], preserving the time-of-day of
  /// [anchor], or null when the rule has no further occurrence.
  ///
  /// Weekday rules iterate forward up to 7 days; simple cadences step by
  /// whole days until strictly after [after] (max 366 iterations).
  static DateTime? nextOccurrence({
    required String? recurrenceRule,
    required bool isRecurring,
    required DateTime anchor,
    required DateTime after,
  }) {
    final weekdays = parseWeekdays(recurrenceRule);
    if (weekdays != null) {
      if (weekdays.isEmpty) return null;
      for (var offset = 0; offset <= 7; offset++) {
        final day = DateTime(after.year, after.month, after.day + offset);
        final candidate = DateTime(
          day.year,
          day.month,
          day.day,
          anchor.hour,
          anchor.minute,
          anchor.second,
        );
        if (!candidate.isAfter(after)) continue;
        if (weekdays.contains(candidate.weekday)) return candidate;
      }
      return null;
    }

    final specificDate = parseSpecificDate(recurrenceRule);
    if (specificDate != null) {
      final candidate = DateTime(
        specificDate.year,
        specificDate.month,
        specificDate.day,
        anchor.hour,
        anchor.minute,
      );
      return candidate.isAfter(after) ? candidate : null;
    }

    // Simple daily-style cadence (default for recurring items without an
    // explicit DAYS rule): same wall-clock time on the next day.
    final nextDay = DateTime(
      after.year,
      after.month,
      after.day + 1,
      anchor.hour,
      anchor.minute,
      anchor.second,
    );
    return nextDay.isAfter(after) ? nextDay : nextDay.add(const Duration(days: 1));
  }
}
