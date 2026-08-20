import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

/// Runtime config loaded from SharedPreferences.
/// Falls back to AppConfig compile-time constants if not set by user.
class _RuntimeConfig {
  final String apiKey;
  final String baseUrl;
  final String model;

  const _RuntimeConfig({
    required this.apiKey,
    required this.baseUrl,
    required this.model,
  });

  static Future<_RuntimeConfig> load() async {
    final prefs = await SharedPreferences.getInstance();
    final key = prefs.getString('LLM_API_KEY') ?? '';
    final url = prefs.getString('LLM_BASE_URL') ?? '';
    final model = prefs.getString('LLM_MODEL') ?? '';
    return _RuntimeConfig(
      apiKey: key.isNotEmpty ? key : AppConfig.llmApiKey,
      baseUrl: url.isNotEmpty ? url : AppConfig.llmBaseUrl,
      model: model.isNotEmpty ? model : AppConfig.llmModel,
    );
  }
}

/// Datasource calling NVIDIA NIM / OpenAI compatible chat completion endpoints.
class LlmApiDataSource {
  final http.Client _client;
  final RateLimiter _rateLimiter = RateLimiter();

  LlmApiDataSource({http.Client? client}) : _client = client ?? http.Client();

  static const String _systemPrompt = '''
You are AURA's intent extraction & command intelligence engine for an AI life management app.
Your job is to parse a voice transcript, identify the core action/intent, and extract structured metadata.

ACTIONS & INTENTS:
- "create_task": Task (something to do, title, deadline, priority, workspace, notes).
- "create_reminder": Timed reminder/deadline to alert before submission.
- "create_event": Event (meetings, interview, placement talk, with start time, end time, location).
- "create_alarm": General time-of-day alarm (e.g. "add an alarm for 1.45pm today", "set alarm for 7am").
- "create_workspace": Requests to create a workspace/folder (e.g. "Create a workspace for Placement Prep").
- "delete_task": Requests to remove or cancel a task.
- "delete_workspace": Requests to remove a workspace.
- "add_note": Pure freeform thoughts or ideas without a task/alarm.

CRITICAL RULES:
1. Return ONLY valid JSON — no markdown backticks, no text explanations.
2. NOTES CATCH-ALL RULE: Put any extra details, subtasks, instructions, or descriptions inside "notes".
3. ALARM RULE: If the user says "add an alarm", "set alarm", or mentions a specific wake-up/alert time without task context, set intent_type to "create_alarm".
4. Relative dates: Resolve relative to current_datetime in context.

EXAMPLES:
- "Add an alarm for 1.45pm today"
  → {"intent_type": "create_alarm", "title": "Alarm 1:45 PM", "deadline_iso": "2026-07-27T13:45:00"}

- "Create a new workspace named IIT Prep with blue color"
  → {"intent_type": "create_workspace", "title": "IIT Prep", "workspace_color_hex": "#3B82F6"}

- "Remind me tomorrow at 5pm to call doctor and ask about prescription"
  → {"intent_type": "create_reminder", "title": "Call doctor", "deadline_iso": "<tomorrow 17:00>", "notes": "ask about prescription"}

- "Just note down project submission portal opens on Friday"
  → {"intent_type": "add_note", "title": "Project submission portal opens on Friday", "notes": "project submission portal opens on Friday"}

OUTPUT SCHEMA:
{
  "intent_type": "create_task" | "create_reminder" | "create_event" | "create_alarm" | "create_workspace" | "delete_task" | "delete_workspace" | "add_note",
  "title": string | null,                  // Core task title or workspace name
  "target_name": string | null,            // Item name to delete/update if intent is delete_task or delete_workspace
  "deadline_iso": string | null,           // ISO 8601 e.g. "2026-08-01T23:59:00"
  "event_start_iso": string | null,
  "event_end_iso": string | null,
  "event_location": string | null,
  "workspace_hint": string | null,         // Target workspace name
  "workspace_color_hex": string | null,    // Hex color if creating workspace e.g. "#FF5733"
  "workspace_icon_key": string | null,     // Icon key if creating workspace e.g. "folder", "book", "code", "briefcase"
  "priority": "high" | "medium" | "low" | null,
  "is_recurring": boolean,
  "recurrence_type": "daily" | "weekly" | "custom" | null,
  "reminders": [
    {
      "offset_value": integer,
      "offset_unit": "minutes" | "hours" | "days",
      "type": "notification" | "alarm"
    }
  ],
  "notes": string | null,                  // ALL extra spoken details, context, or sub-points
  "confidence": float
}
''';

  /// Extracts structured intent from a voice/text transcript.
  /// Reads API key, base URL, and model from SharedPreferences at call time
  /// so that Settings changes take effect immediately without restarting the app.
  Future<IntentResult> extractIntent({
    required String transcript,
    List<String> userWorkspaces = const [],
  }) async {
    await _rateLimiter.throttle();

    // Load runtime config from SharedPreferences (respects user Settings changes)
    final config = await _RuntimeConfig.load();

    if (config.apiKey.isEmpty) {
      throw Exception(
          'No API key configured. Go to Settings → AI Engine and enter your API key.');
    }

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

    final uri = Uri.parse('${config.baseUrl}/chat/completions');

    final body = {
      'model': config.model,
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
              'Authorization': 'Bearer ${config.apiKey}',
            },
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 401 || response.statusCode == 403) {
        throw Exception(
            'Invalid API key (${response.statusCode}). Update your key in Settings → AI Engine.');
      }

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
      throw Exception(
          'Request timed out after 30s. Check your internet connection or try a different model in Settings.');
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
