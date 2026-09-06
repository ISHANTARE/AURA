import 'dart:async';
import 'dart:convert';
import 'dart:collection';
import 'dart:io' show SocketException;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/security/secret_store.dart';
import '../../domain/entities/intent_result.dart';
import '../../domain/services/local_intent_parser.dart';

/// Sliding-window rate limiter: at most [maxPerMinute] requests per rolling
/// [window]. A caller at the limit WAITS until the oldest request ages out of
/// the window — it never proceeds anyway.
class RateLimiter {
  RateLimiter({
    this.maxPerMinute = 12,
    this.window = const Duration(seconds: 60),
    DateTime Function()? clock,
  }) : _now = clock ?? DateTime.now;

  final int maxPerMinute;
  final Duration window;
  final DateTime Function() _now;

  final Queue<DateTime> _stamps = Queue();

  Future<void> throttle() async {
    while (true) {
      final now = _now();
      while (_stamps.isNotEmpty && now.difference(_stamps.first) > window) {
        _stamps.removeFirst();
      }
      if (_stamps.length < maxPerMinute) {
        _stamps.addLast(now);
        return;
      }
      final resumeAt = _stamps.first.add(window);
      final waitMs = resumeAt.difference(now).inMilliseconds;
      if (waitMs > 0) await Future<void>.delayed(Duration(milliseconds: waitMs));
    }
  }
}

/// Why an LLM call failed. Config errors (auth/model) are actionable by the
/// user and are NEVER silently masked by the offline parser.
enum LlmFailureKind { auth, modelNotFound, rateLimited, network, badResponse, noApiKey }

/// Typed failure from the LLM API with user-actionable guidance.
class LlmApiException implements Exception {
  final LlmFailureKind kind;
  final String message;
  const LlmApiException(this.kind, this.message);

  /// True when the user must fix configuration before AI works again.
  bool get isConfigError =>
      kind == LlmFailureKind.auth || kind == LlmFailureKind.modelNotFound;

  @override
  String toString() => message;
}

/// Result of an intent extraction, including whether the offline rule-based
/// parser was used instead of the LLM (and why), so the UI can say so honestly.
class ExtractOutcome {
  final IntentResult result;

  /// Non-null when [result] came from [LocalIntentParser] rather than the LLM.
  final String? fallbackNotice;

  const ExtractOutcome({required this.result, this.fallbackNotice});

  bool get usedLocalFallback => fallbackNotice != null;
}

/// Runtime config resolution.
///
/// Precedence (identical for every field):
///   user settings (secure store / prefs) > --dart-define (AppConfig) > dotenv > default.
class _RuntimeConfig {
  final String apiKey;
  final String baseUrl;
  final String model;

  const _RuntimeConfig({
    required this.apiKey,
    required this.baseUrl,
    required this.model,
  });

  static String _pick(String user, String dartDefine, String? dotenvValue, String fallback) {
    if (user.isNotEmpty) return user;
    if (dartDefine.isNotEmpty) return dartDefine;
    if (dotenvValue != null && dotenvValue.isNotEmpty) return dotenvValue;
    return fallback;
  }

  static Future<_RuntimeConfig> load({SecretStore? secretStore}) async {
    final prefs = await SharedPreferences.getInstance();
    try {
      await prefs.reload();
    } catch (_) {}
    final store = secretStore ?? SecretStore();
    final key = await store.readApiKey();
    final url = prefs.getString('LLM_BASE_URL') ?? '';
    final model = prefs.getString('LLM_MODEL') ?? '';

    final env = dotenv.isInitialized ? dotenv.env : const <String, String>{};

    return _RuntimeConfig(
      apiKey: _pick(key, AppConfig.llmApiKey, env['GEMINI_API_KEY'] ?? env['LLM_API_KEY'], ''),
      baseUrl: _pick(
          url,
          AppConfig.llmBaseUrl,
          env['GEMINI_BASE_URL'] ?? env['LLM_BASE_URL'],
          AppConfig.llmBaseUrl),
      model: _pick(model, AppConfig.llmModel, env['GEMINI_MODEL'] ?? env['LLM_MODEL'],
          AppConfig.llmModel),
    );
  }
}

/// Datasource calling OpenAI-compatible chat completion endpoints
/// (Google Gemini / NVIDIA NIM / Groq / OpenRouter / Ollama).
class LlmApiDataSource {
  final http.Client _client;
  final RateLimiter _rateLimiter;
  final SecretStore _secretStore;

  LlmApiDataSource({http.Client? client, RateLimiter? rateLimiter, SecretStore? secretStore})
      : _client = client ?? http.Client(),
        _rateLimiter = rateLimiter ?? RateLimiter(),
        _secretStore = secretStore ?? SecretStore();

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
5. STRICT EMOJI PROHIBITION: NEVER output any emojis anywhere in the JSON output (in title, notes, or elsewhere). Use clean plain text only.

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

  /// Extracts structured intent, surfacing fallback reasons to the caller.
  ///
  /// Error contract:
  ///  • Auth / model-config problems → THROWS [LlmApiException] (never masked).
  ///  • Transient problems (network, timeout, 5xx, malformed response) →
  ///    falls back to the offline parser and reports why in [ExtractOutcome].
  Future<ExtractOutcome> extractIntentWithMeta({
    required String transcript,
    List<String> userWorkspaces = const [],
  }) async {
    final config = await _RuntimeConfig.load(secretStore: _secretStore);

    if (config.apiKey.isEmpty) {
      return ExtractOutcome(
        result: LocalIntentParser.parse(transcript, userWorkspaces: userWorkspaces),
        fallbackNotice: 'No API key set — using offline parser. '
            'Add a key in Settings → AI Engine for full AI parsing.',
      );
    }

    final userPrompt = _buildUserPrompt(transcript, userWorkspaces);
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
      await _rateLimiter.throttle();

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
        throw LlmApiException(
          LlmFailureKind.auth,
          'Invalid API key (${response.statusCode}). '
          'Update your key in Settings → AI Engine.',
        );
      }

      if (response.statusCode == 400 || response.statusCode == 404) {
        throw LlmApiException(
          LlmFailureKind.modelNotFound,
          'Model "${config.model}" was not found or is deprecated (${response.statusCode}). '
          'Pick an active model in Settings → AI Engine.',
        );
      }

      if (response.statusCode == 429) {
        return _localFallback(
            transcript, userWorkspaces, 'AI rate limit reached — parsed offline.');
      }

      if (response.statusCode != 200) {
        return _localFallback(transcript, userWorkspaces,
            'AI service error (${response.statusCode}) — parsed offline.');
      }

      final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
      final choices = jsonResponse['choices'] as List<dynamic>?;
      if (choices == null || choices.isEmpty) {
        return _localFallback(
            transcript, userWorkspaces, 'AI returned an empty response — parsed offline.');
      }

      final content = choices.first['message']['content'] as String?;
      if (content == null || content.isEmpty) {
        return _localFallback(
            transcript, userWorkspaces, 'AI returned an empty response — parsed offline.');
      }

      final cleanedJson = _cleanJsonString(content);
      final parsedMap = jsonDecode(cleanedJson) as Map<String, dynamic>;
      return ExtractOutcome(result: IntentResult.fromJson(parsedMap));
    } on LlmApiException {
      rethrow; // Config errors must surface to the user.
    } on TimeoutException {
      return _localFallback(
          transcript, userWorkspaces, 'AI request timed out — parsed offline.');
    } on SocketException {
      return _localFallback(
          transcript, userWorkspaces, 'Network error — parsed offline.');
    } on FormatException catch (e) {
      return _localFallback(
          transcript, userWorkspaces, 'AI returned unreadable output — parsed offline. ($e)');
    } catch (e) {
      // Unknown transport-layer failure: degrade gracefully but say so.
      return _localFallback(transcript, userWorkspaces, 'AI error — parsed offline. ($e)');
    }
  }

  /// Back-compat wrapper. Throws [LlmApiException] on config errors.
  Future<IntentResult> extractIntent({
    required String transcript,
    List<String> userWorkspaces = const [],
  }) async {
    final outcome = await extractIntentWithMeta(
      transcript: transcript,
      userWorkspaces: userWorkspaces,
    );
    return outcome.result;
  }

  ExtractOutcome _localFallback(String transcript, List<String> workspaces, String reason) {
    return ExtractOutcome(
      result: LocalIntentParser.parse(transcript, userWorkspaces: workspaces),
      fallbackNotice: reason,
    );
  }

  String _buildUserPrompt(String transcript, List<String> userWorkspaces) {
    final now = DateTime.now();
    final nowIso = now.toIso8601String();
    final weekdayName = DateFormat('EEEE').format(now);
    return '''
Context:
- Current datetime: $nowIso ($weekdayName)
- User timezone offset: ${now.timeZoneOffset}
- User's existing workspaces: ${userWorkspaces.join(", ")}

Voice transcript:
"$transcript"

Extract the intent and return JSON only. Ensure deadline_iso is correctly resolved relative to Current datetime.
''';
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
