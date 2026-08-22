import 'package:intl/intl.dart';
import '../entities/intent_result.dart';

/// Lightweight offline rule-based NLP intent parser fallback.
/// Runs locally on device without network requests or API keys.
class LocalIntentParser {
  /// Extract structured intent from plain text/voice transcript using pattern matching.
  static IntentResult parse(String transcript, {List<String> userWorkspaces = const []}) {
    final text = transcript.trim();
    final lower = text.toLowerCase();
    final now = DateTime.now();

    // 1. Alarm Pattern: e.g. "set alarm for 7:30 am", "add alarm at 8pm"
    final alarmRegExp = RegExp(
      r'(?:set\s+an?\s+alarm|add\s+an?\s+alarm|set\s+alarm|alarm)\s+(?:for|at)?\s*(\d{1,2})(?::(\d{2}))?\s*(am|pm)?',
      caseSensitive: false,
    );
    final alarmMatch = alarmRegExp.firstMatch(lower);
    if (alarmMatch != null || lower.contains('alarm') || lower.contains('wake me up')) {
      final hourStr = alarmMatch?.group(1);
      final minStr = alarmMatch?.group(2);
      final ampmStr = alarmMatch?.group(3);

      DateTime targetTime = _parseTimeOfDay(now, hourStr, minStr, ampmStr) ??
          now.add(const Duration(hours: 1));

      final formattedTime = DateFormat('h:mm a').format(targetTime);

      return IntentResult(
        intentType: 'create_alarm',
        title: 'Alarm $formattedTime',
        deadline: targetTime,
        confidence: 0.85,
        notes: text,
      );
    }

    // 2. Workspace Pattern: e.g. "create a workspace named IIT Prep"
    final wsRegExp = RegExp(
      r'(?:create|add|new)\s+(?:a\s+)?workspace\s+(?:named|called|for)?\s+(.+)',
      caseSensitive: false,
    );
    final wsMatch = wsRegExp.firstMatch(text);
    if (wsMatch != null) {
      final wsTitle = wsMatch.group(1)?.trim() ?? 'New Workspace';
      return IntentResult(
        intentType: 'create_workspace',
        title: wsTitle,
        workspaceHint: wsTitle,
        workspaceColorHex: '#C8FF00',
        confidence: 0.90,
      );
    }

    // 3. Delete Task / Workspace: e.g. "delete task assignment", "delete workspace test"
    if (lower.startsWith('delete task') || lower.startsWith('remove task')) {
      final targetName = text.replaceFirst(RegExp(r'^(delete|remove)\s+task\s+', caseSensitive: false), '').trim();
      return IntentResult(
        intentType: 'delete_task',
        title: targetName,
        targetName: targetName,
        confidence: 0.85,
      );
    }
    if (lower.startsWith('delete workspace') || lower.startsWith('remove workspace')) {
      final targetName = text.replaceFirst(RegExp(r'^(delete|remove)\s+workspace\s+', caseSensitive: false), '').trim();
      return IntentResult(
        intentType: 'delete_workspace',
        title: targetName,
        targetName: targetName,
        confidence: 0.85,
      );
    }

    // 4. Quick Note Pattern: e.g. "note down project ideas", "just note meeting points"
    final noteRegExp = RegExp(
      r'^(?:just\s+)?(?:note\s+down|add\s+note|quick\s+note|take\s+a\s+note)\s+(.+)',
      caseSensitive: false,
    );
    final noteMatch = noteRegExp.firstMatch(text);
    if (noteMatch != null || lower.startsWith('note ')) {
      final content = noteMatch?.group(1)?.trim() ?? text;
      final titleStr = content.length > 30 ? '${content.substring(0, 30)}...' : content;
      return IntentResult(
        intentType: 'add_note',
        title: titleStr,
        notes: content,
        confidence: 0.85,
      );
    }

    // 5. Task / Reminder Pattern: "remind me to call doctor tomorrow at 5pm"
    final deadlineDate = _parseDateAndTime(text, now);
    String titleText = text;

    // Clean leading action prefixes from title
    final cleanTitleRegExp = RegExp(
      r'^(?:remind\s+me\s+(?:to\s+)?|add\s+(?:a\s+)?task\s+(?:to\s+)?|create\s+task\s+)',
      caseSensitive: false,
    );
    titleText = titleText.replaceFirst(cleanTitleRegExp, '').trim();

    // Strip date/time words from title
    final dateSuffixRegExp = RegExp(
      r'\s+(?:today|tomorrow|at\s+\d{1,2}(?::\d{2})?\s*(?:am|pm)?|next\s+\w+).*$',
      caseSensitive: false,
    );
    titleText = titleText.replaceFirst(dateSuffixRegExp, '').trim();

    if (titleText.isEmpty) titleText = text;

    // Workspace Routing Hint
    String? matchedWorkspace;
    for (final ws in userWorkspaces) {
      if (lower.contains(ws.toLowerCase())) {
        matchedWorkspace = ws;
        break;
      }
    }

    final isReminder = lower.contains('remind') || lower.contains('reminder');

    return IntentResult(
      intentType: isReminder ? 'create_reminder' : 'create_task',
      title: titleText[0].toUpperCase() + titleText.substring(1),
      deadline: deadlineDate,
      workspaceHint: matchedWorkspace,
      priority: lower.contains('urgent') || lower.contains('important') ? 'high' : 'medium',
      reminders: deadlineDate != null
          ? [
              const ExtractedReminder(
                offsetValue: 30,
                offsetUnit: 'minutes',
                type: 'notification',
              ),
            ]
          : [],
      notes: text,
      confidence: 0.75,
    );
  }

  static DateTime? _parseTimeOfDay(DateTime now, String? hourStr, String? minStr, String? ampmStr) {
    if (hourStr == null) return null;
    int hour = int.tryParse(hourStr) ?? 9;
    int min = minStr != null ? (int.tryParse(minStr) ?? 0) : 0;

    if (ampmStr != null) {
      final ampm = ampmStr.toLowerCase();
      if (ampm == 'pm' && hour < 12) hour += 12;
      if (ampm == 'am' && hour == 12) hour = 0;
    }

    var result = DateTime(now.year, now.month, now.day, hour, min);
    if (result.isBefore(now)) {
      result = result.add(const Duration(days: 1));
    }
    return result;
  }

  static DateTime? _parseDateAndTime(String text, DateTime now) {
    final lower = text.toLowerCase();
    DateTime targetDate = now;

    if (lower.contains('tomorrow')) {
      targetDate = now.add(const Duration(days: 1));
    }

    final timeMatch = RegExp(r'at\s+(\d{1,2})(?::(\d{2}))?\s*(am|pm)?', caseSensitive: false).firstMatch(lower);
    int hour = 9;
    int minute = 0;

    if (timeMatch != null) {
      final h = int.tryParse(timeMatch.group(1) ?? '');
      final m = int.tryParse(timeMatch.group(2) ?? '');
      final ampm = timeMatch.group(3)?.toLowerCase();

      if (h != null) {
        hour = h;
        if (ampm == 'pm' && hour < 12) hour += 12;
        if (ampm == 'am' && hour == 12) hour = 0;
      }
      if (m != null) minute = m;
    }

    var result = DateTime(targetDate.year, targetDate.month, targetDate.day, hour, minute);
    if (result.isBefore(now) && !lower.contains('tomorrow')) {
      result = result.add(const Duration(days: 1));
    }
    return result;
  }
}
