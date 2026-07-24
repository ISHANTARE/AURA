import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../../../../core/config/app_config.dart';
import '../../domain/entities/intent_result.dart';

/// Rate limiter ensuring max 12 AI requests/minute to respect API limits.
class RateLimiter {
  int _requestsThisMinute = 0;
  static const int _maxPerMinute = 12;

  Future<void> throttle() async {
    if (_requestsThisMinute >= _maxPerMinute) {
      await Future.delayed(const Duration(seconds: 5));
    }
    _requestsThisMinute++;
    Future.delayed(const Duration(seconds: 60), () {
      if (_requestsThisMinute > 0) _requestsThisMinute--;
    });
  }
}

/// Datasource calling NVIDIA NIM / OpenAI compatible chat completion endpoints.
class LlmApiDataSource {
  final http.Client _client;
  final RateLimiter _rateLimiter = RateLimiter();

  LlmApiDataSource({http.Client? client}) : _client = client ?? http.Client();

  static const String _systemPrompt = '''
You are AURA's intent extraction engine for an AI life management app.
Your job is to parse a voice transcript and extract structured task or event data.

RULES:
1. Return ONLY valid JSON — no markdown backticks, no explanation, no surrounding text.
2. Never invent data the user did not mention. Set unknown fields to null.
3. Include a confidence score (0.0 to 1.0) for the overall parse.
4. Understand Indian English: "toh", "na", "yaar", colloquial date references.
5. Date references: resolve relative to current_datetime in context.
   "today" = current date, "tomorrow" = +1 day, "next Friday" = next occurrence of Friday.
6. Time references without AM/PM: assume context (morning = AM, afternoon/evening = PM).
7. "remind me before" = set a reminder N time before deadline.

OUTPUT SCHEMA:
{
  "intent_type": "create_task" | "create_event" | "set_reminder" | "add_note" | "query" | "ambiguous",
  "title": string | null,
  "deadline_iso": string | null,           // ISO 8601 e.g. "2026-08-01T23:59:00"
  "event_start_iso": string | null,
  "event_end_iso": string | null,
  "event_location": string | null,
  "workspace_hint": string | null,         // Detected workspace keyword
  "section_hint": string | null,
  "priority": "high" | "medium" | "low" | null,
  "is_recurring": boolean,
  "recurrence_type": "daily" | "weekly" | "custom" | null,
  "recurrence_days": [string] | null,
  "reminders": [
    {
      "offset_value": integer,
      "offset_unit": "minutes" | "hours" | "days",
      "type": "notification" | "alarm"
    }
  ],
  "notes": string | null,
  "contact": string | null,
  "confidence": float,
  "title_conf": float | null,
  "deadline_conf": float | null,
  "workspace_conf": float | null
}
''';

  /// Extracts structured intent from a voice/text transcript.
  Future<IntentResult> extractIntent({
    required String transcript,
    List<String> userWorkspaces = const [],
  }) async {
    await _rateLimiter.throttle();

    final now = DateTime.now();
    final nowIso = now.toIso8601String();
    final weekdayName = DateFormat('EEEE').format(now);
    final userPrompt = '''
Context:
- Current datetime: $nowIso ($weekdayName)
- User timezone offset: ${now.timeZoneOffset}
- User's existing workspaces: ${userWorkspaces.join(", ")}

Voice transcript:
"$transcript"

Extract the intent and return JSON only. Ensure deadline_iso is correctly resolved relative to Current datetime.
''';

    final uri = Uri.parse('${AppConfig.llmBaseUrl}/chat/completions');

    final body = {
      'model': AppConfig.llmModel,
      'messages': [
        {'role': 'system', 'content': _systemPrompt},
        {'role': 'user', 'content': userPrompt},
      ],
      'temperature': 0.1,
      'max_tokens': 1000,
    };

    try {
      final response = await _client
          .post(
            uri,
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer ${AppConfig.llmApiKey}',
            },
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 12));

      if (response.statusCode != 200) {
        throw Exception(
            'LLM API failed with status ${response.statusCode}: ${response.body}');
      }

      final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
      final choices = jsonResponse['choices'] as List<dynamic>?;
      if (choices == null || choices.isEmpty) {
        throw Exception('LLM returned no choices');
      }

      final content = choices.first['message']['content'] as String;
      final cleanedJson = _cleanJsonString(content);
      final parsedMap = jsonDecode(cleanedJson) as Map<String, dynamic>;

      return IntentResult.fromJson(parsedMap);
    } on TimeoutException {
      throw Exception('Request timed out. Please try again.');
    } catch (e) {
      rethrow;
    }
  }

  /// Robustly extract a JSON object from LLM output.
  /// Handles: pure JSON, ```json...``` fences, and conversational wrapping with notes.
  String _cleanJsonString(String raw) {
    // Strategy 1: Find first '{' and last '}' — handles all wrapping patterns.
    final firstBrace = raw.indexOf('{');
    final lastBrace = raw.lastIndexOf('}');
    if (firstBrace != -1 && lastBrace != -1 && lastBrace > firstBrace) {
      return raw.substring(firstBrace, lastBrace + 1).trim();
    }
    // Strategy 2: Fallback — strip code fences if present.
    var trimmed = raw.trim();
    if (trimmed.startsWith('```')) {
      final lines = trimmed.split('\n');
      if (lines.first.startsWith('```')) lines.removeAt(0);
      if (lines.isNotEmpty && lines.last.startsWith('```')) lines.removeLast();
      trimmed = lines.join('\n').trim();
    }
    return trimmed;
  }
}
