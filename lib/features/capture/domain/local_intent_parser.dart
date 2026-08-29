import 'extracted_intent.dart';

/// Offline rule-based NLP intent parser using deterministic regular expressions
/// and date arithmetic. Guarantees 100% offline functionality.
class LocalIntentParser {
  /// Parses [transcript] offline, returning structured [ExtractedIntent].
  static ExtractedIntent parse(String transcript, {DateTime? now}) {
    final text = transcript.trim();
    final lower = text.toLowerCase();
    final baseNow = now ?? DateTime.now();

    // 1. Alarm Pattern
    final alarmMatch = _alarmRegex.firstMatch(lower);
    if (alarmMatch != null) {
      return _parseAlarm(alarmMatch, lower, baseNow);
    }

    // 2. Create Workspace Pattern
    final wsMatch = _createWorkspaceRegex.firstMatch(lower);
    if (wsMatch != null) {
      final name = wsMatch.group(1)?.trim();
      if (name != null && name.isNotEmpty) {
        return ExtractedIntent(
          intentType: 'create_workspace',
          title: _capitalize(name),
          workspaceColorHex: '#C8FF00',
          confidence: 0.90,
        );
      }
    }

    // 3. Delete Task Pattern
    final deleteTaskMatch = _deleteTaskRegex.firstMatch(lower);
    if (deleteTaskMatch != null) {
      final target = deleteTaskMatch.group(1)?.trim();
      return ExtractedIntent(
        intentType: 'delete_task',
        targetName: target,
        confidence: 0.85,
      );
    }

    // 4. Delete Workspace Pattern
    final deleteWsMatch = _deleteWorkspaceRegex.firstMatch(lower);
    if (deleteWsMatch != null) {
      final target = deleteWsMatch.group(1)?.trim();
      return ExtractedIntent(
        intentType: 'delete_workspace',
        targetName: target,
        confidence: 0.85,
      );
    }

    // 5. Quick Note Pattern
    final noteMatch = _noteRegex.firstMatch(lower);
    if (noteMatch != null) {
      final body = text.substring(noteMatch.start + noteMatch.group(0)!.length - noteMatch.group(1)!.length).trim();
      final title = body.length > 30 ? '${body.substring(0, 30)}...' : body;
      return ExtractedIntent(
        intentType: 'add_note',
        title: title,
        notes: body,
        confidence: 0.85,
      );
    }

    // 6. Task / Reminder Pattern
    return _parseTaskOrReminder(text, lower, baseNow);
  }

  // ── Regex Definitions ──────────────────────────────────────────────────────

  static final _alarmRegex = RegExp(
    r'(?:set\s+an?\s+alarm|add\s+an?\s+alarm|set\s+alarm|alarm)\s+(?:for|at)?\s*(\d{1,2})(?:[:\.](\d{2}))?\s*(am|pm)?',
    caseSensitive: false,
  );

  static final _createWorkspaceRegex = RegExp(
    r'(?:create|add|new)\s+(?:a\s+)?workspace\s+(?:named|called|for)?\s+(.+)',
    caseSensitive: false,
  );

  static final _deleteTaskRegex = RegExp(
    r'(?:delete|remove|cancel)\s+(?:task|reminder)\s+(.+)',
    caseSensitive: false,
  );

  static final _deleteWorkspaceRegex = RegExp(
    r'(?:delete|remove)\s+workspace\s+(.+)',
    caseSensitive: false,
  );

  static final _noteRegex = RegExp(
    r'^(?:just\s+)?(?:note\s+down|add\s+note|quick\s+note|take\s+a\s+note:?)\s+(.+)',
    caseSensitive: false,
  );

  static final _workspaceHintRegex = RegExp(
    r'(?:in|for)\s+(?:workspace\s+)?([a-zA-Z0-9_\-]+)\s*(?:workspace)?',
    caseSensitive: false,
  );

  // ── Helpers ────────────────────────────────────────────────────────────────

  static ExtractedIntent _parseAlarm(Match match, String lower, DateTime now) {
    var hour = int.parse(match.group(1)!);
    final minute = match.group(2) != null ? int.parse(match.group(2)!) : 0;
    final ampm = match.group(3)?.toLowerCase();

    if (ampm == 'pm' && hour < 12) {
      hour += 12;
    } else if (ampm == 'am' && hour == 12) {
      hour = 0;
    }

    var targetDate = DateTime(now.year, now.month, now.day, hour, minute);
    if (lower.contains('tomorrow')) {
      targetDate = targetDate.add(const Duration(days: 1));
    } else if (targetDate.isBefore(now)) {
      targetDate = targetDate.add(const Duration(days: 1));
    }

    final formattedTime = '${hour % 12 == 0 ? 12 : hour % 12}:${minute.toString().padLeft(2, '0')} ${hour >= 12 ? 'PM' : 'AM'}';

    return ExtractedIntent(
      intentType: 'create_alarm',
      title: 'Alarm $formattedTime',
      deadlineIso: targetDate.toIso8601String(),
      confidence: 0.85,
    );
  }

  static ExtractedIntent _parseTaskOrReminder(String rawText, String lower, DateTime now) {
    var cleanTitle = rawText;

    // Strip leading command prefixes
    cleanTitle = cleanTitle.replaceFirst(RegExp(r'^(?:please\s+)?(?:remind\s+me\s+(?:to\s+)?|add\s+(?:a\s+)?task\s+(?:to\s+)?|create\s+(?:a\s+)?task\s+(?:to\s+)?|todo:?\s*)', caseSensitive: false), '');

    // Extract workspace hint
    String? workspaceHint;
    final wsHintMatch = _workspaceHintRegex.firstMatch(cleanTitle);
    if (wsHintMatch != null) {
      workspaceHint = wsHintMatch.group(1)?.trim();
    }

    // Extract priority
    String priority = 'medium';
    if (lower.contains('urgent') || lower.contains('high priority') || lower.contains('asap')) {
      priority = 'high';
    } else if (lower.contains('low priority')) {
      priority = 'low';
    }

    // Extract deadline
    DateTime? deadline;
    final isTomorrow = lower.contains('tomorrow');
    final isTonight = lower.contains('tonight');
    final isToday = lower.contains('today');

    final timeMatch = RegExp(r'(?:at|by)\s+(\d{1,2})(?:[:\.](\d{2}))?\s*(am|pm)?', caseSensitive: false).firstMatch(lower);
    if (timeMatch != null) {
      var hour = int.parse(timeMatch.group(1)!);
      final minute = timeMatch.group(2) != null ? int.parse(timeMatch.group(2)!) : 0;
      final ampm = timeMatch.group(3)?.toLowerCase();

      if (ampm == 'pm' && hour < 12) hour += 12;
      if (ampm == 'am' && hour == 12) hour = 0;

      deadline = DateTime(now.year, now.month, now.day, hour, minute);
      if (isTomorrow) {
        deadline = deadline.add(const Duration(days: 1));
      } else if (deadline.isBefore(now)) {
        deadline = deadline.add(const Duration(days: 1));
      }
    } else if (isTomorrow) {
      deadline = DateTime(now.year, now.month, now.day, 9, 0).add(const Duration(days: 1));
    } else if (isTonight) {
      deadline = DateTime(now.year, now.month, now.day, 21, 0);
    } else if (isToday) {
      deadline = DateTime(now.year, now.month, now.day, 18, 0);
    }

    final isReminder = lower.contains('remind') || deadline != null;

    final reminders = deadline != null
        ? [const ExtractedReminder(offsetValue: 30, offsetUnit: 'minutes', type: 'notification')]
        : <ExtractedReminder>[];

    return ExtractedIntent(
      intentType: isReminder ? 'create_reminder' : 'create_task',
      title: cleanTitle.trim(),
      deadlineIso: deadline?.toIso8601String(),
      workspaceHint: workspaceHint,
      priority: priority,
      reminders: reminders,
      confidence: 0.75,
    );
  }

  static String _capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1);
  }
}
