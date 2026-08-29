/// Recurrence grammar resolver for AURA's recurrence rule strings.
///
/// Supported grammar:
///   - `DAYS:1,3,5`            — Weekly on specific weekdays (1=Mon, 7=Sun).
///   - `SPECIFIC_DATE:yyyy-MM-dd` — One-shot target date.
///   - `daily`                 — Next occurrence = same time next day.
///   - `weekly`                — Next occurrence = same time next week.
class RecurrenceResolver {
  /// Resolves the next occurrence of a recurrence rule after [after].
  ///
  /// Returns `null` if the rule is one-shot and the target date is in the past,
  /// or if the [rule] is unrecognised.
  static DateTime? nextOccurrence(String rule, DateTime after) {
    if (rule == 'daily') {
      return after.add(const Duration(days: 1));
    }

    if (rule == 'weekly') {
      return after.add(const Duration(days: 7));
    }

    if (rule.startsWith('DAYS:')) {
      return _resolveWeekdays(rule, after);
    }

    if (rule.startsWith('SPECIFIC_DATE:')) {
      return _resolveSpecificDate(rule, after);
    }

    return null; // unrecognised rule
  }

  /// Returns the set of weekday integers in a `DAYS:` rule (1=Mon, 7=Sun),
  /// or an empty set if the rule is not a `DAYS:` rule.
  static Set<int> parseWeekdays(String rule) {
    if (!rule.startsWith('DAYS:')) return {};
    final parts = rule.substring('DAYS:'.length).split(',');
    return parts
        .map((p) => int.tryParse(p.trim()))
        .whereType<int>()
        .where((d) => d >= 1 && d <= 7)
        .toSet();
  }

  // ── Private helpers ────────────────────────────────────────────────────────

  static DateTime? _resolveWeekdays(String rule, DateTime after) {
    final weekdays = parseWeekdays(rule);
    if (weekdays.isEmpty) return null;

    // Walk forward up to 7 days to find the next matching weekday.
    var candidate = after.add(const Duration(days: 1));
    for (var i = 0; i < 7; i++) {
      if (weekdays.contains(candidate.weekday)) {
        return candidate;
      }
      candidate = candidate.add(const Duration(days: 1));
    }
    return null;
  }

  static DateTime? _resolveSpecificDate(String rule, DateTime after) {
    final dateStr = rule.substring('SPECIFIC_DATE:'.length);
    final parts = dateStr.split('-');
    if (parts.length != 3) return null;

    final year = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    final day = int.tryParse(parts[2]);
    if (year == null || month == null || day == null) return null;

    final target = DateTime(year, month, day, after.hour, after.minute, after.second);
    // One-shot: only valid if the target is strictly in the future.
    return target.isAfter(after) ? target : null;
  }
}
